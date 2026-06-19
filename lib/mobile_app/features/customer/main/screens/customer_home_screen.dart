import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/data/repositories/customer_repository.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/domain/models/user/customer_model.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/customer_header.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/home_no_appointment_card.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/home_appointment_card.dart';
import 'package:royal_tint/mobile_app/features/customer/main/dialogs/home_appointment_details_dialog.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:intl/intl.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _customerRepo = CustomerRepository();
  final _appointmentService = AppointmentService();

  static const _bg = Colors.white;
  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  String _selectedStatus = 'all';
  String _selectedTime = 'all';
  DateTime? _customDate;
  DateTimeRange? _dateRange;

  Future<void> _selectCustomDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            onPrimary: Colors.black,
            surface: Color(0xFF1A1A1A),
            onSurface: Color(0xFFFFD700),
          ),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      setState(() {
        _customDate = date;
        _selectedTime = 'custom';
      });
    } else {
      setState(() {
        _selectedTime = 'all';
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            onPrimary: Colors.black,
            surface: Color(0xFF1A1A1A),
            onSurface: Color(0xFFFFD700),
          ),
        ),
        child: child!,
      ),
    );

    if (range != null) {
      setState(() {
        _dateRange = range;
        _selectedTime = 'range';
      });
    } else {
      setState(() {
        _selectedTime = 'all';
      });
    }
  }

  int _getStatusWeight(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'completed':
        return 1;
      case 'confirmed':
        return 2;
      case 'cancelled':
      case 'rejected':
        return 3;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: StreamBuilder<CustomerModel>(
        stream: _customerRepo.streamCurrentCustomer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: _gold));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final customer = snapshot.data!;
          return CustomScrollView(
            slivers: [
              // ── Header Section ──
              const SliverToBoxAdapter(
                child: CustomerHeader(title: 'Home', showCustomerInfo: true),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Appointments Section ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(BootstrapIcons.calendar_check_fill, color: _surface, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'My Appointments',
                            style: TextStyle(
                              color: _surface,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MenuDropdown<String>(
                              label: '',
                              icon: BootstrapIcons.bookmark,
                              hint: 'All Status',
                              value: _selectedStatus,
                              items: const [
                                MenuItem(value: 'all', label: 'All Status'),
                                MenuItem(value: 'pending', label: 'Pending'),
                                MenuItem(value: 'confirmed', label: 'Confirmed'),
                                MenuItem(value: 'completed', label: 'Completed'),
                                MenuItem(value: 'cancelled', label: 'Cancelled'),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MenuDropdown<String>(
                              label: '',
                              icon: BootstrapIcons.calendar3,
                              hint: 'All Time',
                              value: _selectedTime,
                              items: [
                                const MenuItem(value: 'all', label: 'All Time'),
                                const MenuItem(value: 'today', label: 'Today'),
                                const MenuItem(value: 'tomorrow', label: 'Tomorrow'),
                                const MenuItem(value: 'week', label: 'This Week'),
                                const MenuItem(value: 'month', label: 'This Month'),
                                const MenuItem(value: 'custom', label: 'Select Date...'),
                                MenuItem(
                                  value: 'range',
                                  label: _dateRange != null
                                      ? '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}'
                                      : 'Date Range...',
                                ),
                              ],
                              onChanged: (val) async {
                                if (val == null) return;
                                setState(() => _selectedTime = val);
                                if (val == 'custom') {
                                  await _selectCustomDate(context);
                                } else if (val == 'range') {
                                  await _selectDateRange(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<AppointmentModel>>(
                        stream: _appointmentService.getCustomerAppointmentsStream(customer.uid),
                        builder: (context, aptSnapshot) {
                          if (aptSnapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _gold.withValues(alpha: 0.5)),
                              ),
                              child: const CircularProgressIndicator(color: _gold),
                            );
                          }

                          final allApts = aptSnapshot.data ?? [];
                          var apts = allApts.where((a) => !a.isBranchSwap).toList();

                          // Apply Filters
                          if (_selectedStatus != 'all') {
                            apts = apts.where((a) => a.status.toLowerCase() == _selectedStatus.toLowerCase()).toList();
                          }

                          if (_selectedTime != 'all') {
                            final now = DateTime.now();
                            apts = apts.where((a) {
                              final aptDate = DateTime.tryParse(a.appointmentDate);
                              if (aptDate == null) return false;
                              
                              if (_selectedTime == 'today') {
                                return aptDate.year == now.year && aptDate.month == now.month && aptDate.day == now.day;
                              } else if (_selectedTime == 'tomorrow') {
                                final tomorrow = now.add(const Duration(days: 1));
                                return aptDate.year == tomorrow.year && aptDate.month == tomorrow.month && aptDate.day == tomorrow.day;
                              } else if (_selectedTime == 'week') {
                                final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                                final endOfWeek = startOfWeek.add(const Duration(days: 6));
                                return aptDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && aptDate.isBefore(endOfWeek.add(const Duration(days: 1)));
                              } else if (_selectedTime == 'month') {
                                return aptDate.year == now.year && aptDate.month == now.month;
                              } else if (_selectedTime == 'custom' && _customDate != null) {
                                return aptDate.year == _customDate!.year && aptDate.month == _customDate!.month && aptDate.day == _customDate!.day;
                              } else if (_selectedTime == 'range' && _dateRange != null) {
                                final start = _dateRange!.start;
                                final end = _dateRange!.end;
                                return (aptDate.isAfter(start.subtract(const Duration(days: 1))) && aptDate.isBefore(end.add(const Duration(days: 1))));
                              }
                              return true;
                            }).toList();
                          }

                          // Sort: pending -> completed -> confirmed -> cancelled
                          apts.sort((a, b) {
                            final weightA = _getStatusWeight(a.status);
                            final weightB = _getStatusWeight(b.status);
                            if (weightA != weightB) {
                              return weightA.compareTo(weightB);
                            }
                            return b.appointmentDate.compareTo(a.appointmentDate); // newest first
                          });

                          if (apts.isEmpty) {
                            return const HomeNoAppointmentCard();
                          }

                          return Column(
                            children: apts.map((apt) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => HomeAppointmentDetailsDialog(appointment: apt),
                                    );
                                  },
                                  child: HomeAppointmentCard(appointment: apt),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}
