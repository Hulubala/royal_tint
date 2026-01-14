// ✅ CORRECT VERSION - TIME SLOT CALENDAR 9AM-7PM
// This is what you originally had! Grid view + Time availability slots

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/features/manager/providers/manager_provider.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/data/models/appointment_model.dart';
import 'package:royal_tint/data/models/tint_package_model.dart';
import 'package:royal_tint/services/appointment_service.dart';
import 'package:royal_tint/services/package_service.dart';
import 'package:intl/intl.dart';

// Vehicle Database
class VehicleDatabase {
  static const Map<String, List<String>> brandModels = {
    'Perodua': ['Myvi', 'Axia', 'Bezza', 'Aruz', 'Alza'],
    'Proton': ['Saga', 'Persona', 'Iriz', 'X50', 'X70', 'Exora'],
    'Honda': ['Civic', 'City', 'Accord', 'CR-V', 'HR-V', 'BR-V'],
    'Toyota': ['Vios', 'Camry', 'Corolla', 'Fortuner', 'Rush', 'Innova', 'Alphard'],
    'Nissan': ['Almera', 'Teana', 'X-Trail', 'Serena'],
    'Mazda': ['2', '3', '6', 'CX-3', 'CX-5'],
    'Mercedes': ['C-Class', 'E-Class', 'GLC'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5'],
  };

  static const Map<String, Map<String, String>> modelDetails = {
    'Myvi': {'type': 'Sedan', 'minutes': '90'},
    'Axia': {'type': 'Sedan', 'minutes': '90'},
    'Bezza': {'type': 'Sedan', 'minutes': '90'},
    'Aruz': {'type': 'SUV', 'minutes': '120'},
    'Alza': {'type': 'MPV', 'minutes': '120'},
    'Saga': {'type': 'Sedan', 'minutes': '90'},
    'Persona': {'type': 'Sedan', 'minutes': '90'},
    'Iriz': {'type': 'Sedan', 'minutes': '90'},
    'X50': {'type': 'SUV', 'minutes': '120'},
    'X70': {'type': 'SUV', 'minutes': '120'},
    'Exora': {'type': 'MPV', 'minutes': '120'},
    'Civic': {'type': 'Sedan', 'minutes': '90'},
    'City': {'type': 'Sedan', 'minutes': '90'},
    'Accord': {'type': 'Sedan', 'minutes': '90'},
    'CR-V': {'type': 'SUV', 'minutes': '120'},
    'HR-V': {'type': 'SUV', 'minutes': '120'},
    'BR-V': {'type': 'MPV', 'minutes': '120'},
    'Vios': {'type': 'Sedan', 'minutes': '90'},
    'Camry': {'type': 'Sedan', 'minutes': '90'},
    'Corolla': {'type': 'Sedan', 'minutes': '90'},
    'Fortuner': {'type': 'SUV', 'minutes': '120'},
    'Rush': {'type': 'SUV', 'minutes': '120'},
    'Innova': {'type': 'MPV', 'minutes': '120'},
    'Alphard': {'type': 'MPV', 'minutes': '120'},
    'Almera': {'type': 'Sedan', 'minutes': '90'},
    'Teana': {'type': 'Sedan', 'minutes': '90'},
    'X-Trail': {'type': 'SUV', 'minutes': '120'},
    'Serena': {'type': 'MPV', 'minutes': '120'},
    '2': {'type': 'Sedan', 'minutes': '90'},
    '3': {'type': 'Sedan', 'minutes': '90'},
    '6': {'type': 'Sedan', 'minutes': '90'},
    'CX-3': {'type': 'SUV', 'minutes': '120'},
    'CX-5': {'type': 'SUV', 'minutes': '120'},
    'C-Class': {'type': 'Sedan', 'minutes': '90'},
    'E-Class': {'type': 'Sedan', 'minutes': '90'},
    'GLC': {'type': 'SUV', 'minutes': '120'},
    '3 Series': {'type': 'Sedan', 'minutes': '90'},
    '5 Series': {'type': 'Sedan', 'minutes': '90'},
    'X3': {'type': 'SUV', 'minutes': '120'},
    'X5': {'type': 'SUV', 'minutes': '120'},
  };

  static List<String> getAllBrands() => brandModels.keys.toList()..sort();
  static List<String> getModelsByBrand(String brand) => brandModels[brand] ?? [];
  static String getType(String model) => modelDetails[model]?['type'] ?? 'Sedan';
  static int getMinutes(String model) => int.parse(modelDetails[model]?['minutes'] ?? '90');
}

// ⭐ NEW: 30-Minute Time Picker Widget
class ThirtyMinuteTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final bool isWalkIn;
  final String? appointmentDate;
  final String? branchID;
  final int estimatedDuration;
  
  const ThirtyMinuteTimePicker({
    super.key, 
    required this.initialTime,
    required this.minTime,
    required this.maxTime,
    this.isWalkIn = false,
    this.appointmentDate,
    this.branchID,
    this.estimatedDuration = 90,
  });

  @override
  State<ThirtyMinuteTimePicker> createState() => _ThirtyMinuteTimePickerState();
}

class _ThirtyMinuteTimePickerState extends State<ThirtyMinuteTimePicker> {
  late TimeOfDay _selectedTime;
  List<String> _fullyBookedSlots = [];
  bool _isLoadingSlots = true;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _loadBookedSlots();
  }

  /// Load fully booked slots
  Future<void> _loadBookedSlots() async {
    if (widget.appointmentDate == null || widget.branchID == null) {
      setState(() => _isLoadingSlots = false);
      return;
    }

    try {
      final appointments = await AppointmentService().getAppointmentsByDate(
        branchID: widget.branchID!,
        date: widget.appointmentDate!,
      );

      final bookedSlots = <String>[];
      
      // Check each time slot
      for (int i = 0; i < 19; i++) {
        final totalMinutes = 540 + (i * 30);
        final hour = totalMinutes ~/ 60;
        final minute = totalMinutes % 60;
        final timeSlot = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        
        // Check if this slot is fully booked
        if (!_canAcceptAppointment(appointments, timeSlot, widget.estimatedDuration)) {
          bookedSlots.add(timeSlot);
        }
      }

      if (mounted) {
        setState(() {
          _fullyBookedSlots = bookedSlots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      print('Error loading booked slots: $e');
      
      // ⭐ FIX: Show error message to user if it's an index error
      if (e.toString().contains('index')) {
        print('⚠️ FIRESTORE INDEX REQUIRED - Please create the index in Firebase Console');
        print('Error details: $e');
      }
      
      if (mounted) {
        setState(() {
          _fullyBookedSlots = []; // Allow all slots if we can't check availability
          _isLoadingSlots = false;
        });
      }
    }
  }

  /// Check if slot can accept appointment
  bool _canAcceptAppointment(
    List<AppointmentModel> dayAppointments,
    String timeSlot,
    int durationMinutes,
  ) {
    final slotTime = _parseTimeSlotInt(timeSlot);
    final endTime = slotTime + durationMinutes;

    final overlappingCount = dayAppointments.where((apt) {
      final aptStartTime = _parseTimeSlotInt(apt.appointmentTime);
      final aptDuration = apt.estimatedDuration ?? 90;
      final aptEndTime = aptStartTime + aptDuration;

      return (aptStartTime < endTime && aptEndTime > slotTime);
    }).length;

    return overlappingCount < 2;
  }

  int _parseTimeSlotInt(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  List<TimeOfDay> _getAvailableTimeSlots() {
    const int interval = 30;
    final List<TimeOfDay> slots = [];

    final minMinutes = widget.minTime.hour * 60 + widget.minTime.minute;
    final maxMinutes = widget.maxTime.hour * 60 + widget.maxTime.minute;

    // Check if selected date is today
    final now = DateTime.now();
    final selectedDate = widget.appointmentDate != null 
        ? DateTime.parse(widget.appointmentDate!)
        : now;
    final isToday = selectedDate.year == now.year && 
                    selectedDate.month == now.month && 
                    selectedDate.day == now.day;

    // Current time in minutes (only relevant for today)
    final currentMinutes = now.hour * 60 + now.minute;

    // ⭐ FIXED: Start from opening time (9:00 AM = 540 minutes)
    for (int minutes = minMinutes; minutes < maxMinutes; minutes += interval) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;

      // ⭐ CRITICAL FIX: For scheduled appointments on FUTURE dates, show ALL slots
      // Only restrict current time for TODAY's appointments
      if (isToday) {
        // For walk-in on today: must be from NOW onwards
        if (widget.isWalkIn && minutes < currentMinutes) {
          continue;
        }
        // For scheduled on today: must be at least 30min from now (give prep time)
        if (!widget.isWalkIn && minutes < currentMinutes + 30) {
          continue;
        }
      }

      // ⛔ Skip slots that would overflow past closing time
      if (minutes + widget.estimatedDuration > maxMinutes) {
        continue;
      }

      slots.add(TimeOfDay(hour: hour, minute: minute));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _getAvailableTimeSlots();
    
    if (timeSlots.isEmpty && widget.isWalkIn) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(BootstrapIcons.exclamation_triangle, color: Color(0xFFFFC107), size: 48),
              const SizedBox(height: 16),
              const Text(
                'No Available Time Slots',
                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Shop is closed for today. Please try tomorrow.',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.clock, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.isWalkIn ? 'SELECT TIME (FROM NOW)' : 'SELECT TIME',
                    style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFFFFD700)),
                  ),
                ],
              ),
            ),
            
            if (_isLoadingSlots)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Checking availability...',
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    final time = timeSlots[index];
                    final isSelected = time.hour == _selectedTime.hour && time.minute == _selectedTime.minute;
                    
                    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    final isFullyBooked = _fullyBookedSlots.contains(timeString);
                    
                    return InkWell(
                      onTap: isFullyBooked ? null : () => setState(() => _selectedTime = time),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]) 
                              : null,
                          color: isSelected 
                              ? null 
                              : isFullyBooked 
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.black,
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFFFD700) 
                                : isFullyBooked 
                                    ? Colors.red.withOpacity(0.5)
                                    : const Color(0xFFFFD700).withOpacity(0.3), 
                            width: 2
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isFullyBooked ? BootstrapIcons.x_circle : BootstrapIcons.clock,
                              color: isSelected 
                                  ? Colors.black 
                                  : isFullyBooked 
                                      ? Colors.red 
                                      : const Color(0xFFFFD700),
                              size: 20
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatTime(time),
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.black 
                                      : isFullyBooked 
                                          ? Colors.red 
                                          : const Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: isFullyBooked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (isFullyBooked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'FULL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(13), bottomRight: Radius.circular(13)),
                border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, _selectedTime),
                    icon: const Icon(BootstrapIcons.check_circle),
                    label: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() => _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState extends State<AppointmentManagementScreen> {
  bool _isInitialized = false;
  String _selectedType = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';
  String _dateFilter = 'all';
  DateTime? _customDate;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // 📅 CALENDAR VIEW STATE
  bool _showCalendarView = false;
  DateTime _selectedCalendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;
    await Future.delayed(Duration.zero);
    final authProvider = context.read<AuthProvider>();
    final managerProvider = context.read<ManagerProvider>();
    if (authProvider.branchID != null) {
      await managerProvider.fetchAppointments(authProvider.branchID!);
    }
    setState(() => _isInitialized = true);
  }

  List<AppointmentModel> _getFilteredAppointments(List<AppointmentModel> appointments) {
    return appointments.where((apt) {
      if (_selectedType != 'all') {
        final aptType = (apt.appointmentType ?? 'scheduled').toLowerCase();
          if (aptType != _selectedType) return false;
      }
      if (_selectedStatus != 'all' && apt.status.toLowerCase() != _selectedStatus) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!apt.customerName.toLowerCase().contains(query) &&
            !apt.vehiclePlate.toLowerCase().contains(query) &&
            !apt.vehicleModel.toLowerCase().contains(query) &&
            !(apt.customerPhone?.toLowerCase().contains(query) ?? false)) return false;
      }
      if (_dateFilter != 'all') {
        final aptDate = DateTime.parse(apt.appointmentDate);
        final now = DateTime.now();
        switch (_dateFilter) {
          case 'today': if (!_isSameDay(aptDate, now)) return false; break;
          case 'tomorrow': if (!_isSameDay(aptDate, now.add(const Duration(days: 1)))) return false; break;
          case 'week': if (aptDate.isBefore(now) || aptDate.isAfter(now.add(const Duration(days: 7)))) return false; break;
          case 'month': if (aptDate.month != now.month || aptDate.year != now.year) return false; break;
          case 'custom': if (_customDate != null && !_isSameDay(aptDate, _customDate!)) return false; break;
          case 'range': 
            if (_startDate != null && _endDate != null) {
              if (aptDate.isBefore(_startDate!) || aptDate.isAfter(_endDate!)) return false;
            }
            break;
        }
      }
      return true;
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Map<String, int> _getStatistics(List<AppointmentModel> appointments) {
    return {
      'total': appointments.length,
      'pending': appointments.where((a) => a.status.toLowerCase() == 'pending').length,
      'confirmed': appointments.where((a) => a.status.toLowerCase() == 'confirmed').length,
      'in-progress': appointments.where((a) => a.status.toLowerCase() == 'in-progress').length,
      'completed': appointments.where((a) => a.status.toLowerCase() == 'completed').length,
      'cancelled': appointments.where((a) => a.status.toLowerCase() == 'cancelled').length,
    };
  }

  void _resetFilters() => setState(() {
    _selectedType = 'all';
    _selectedStatus = 'all';
    _searchQuery = '';
    _dateFilter = 'all';
    _customDate = null;
    _startDate = null;
    _endDate = null;
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFFFC107);
      case 'confirmed': return const Color(0xFF4CAF50);
      case 'in-progress': return const Color(0xFF2196F3);
      case 'completed': return const Color(0xFF9E9E9E);
      case 'cancelled': return const Color(0xFFF44336);
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return BootstrapIcons.clock;
      case 'confirmed': return BootstrapIcons.check_circle;
      case 'completed': return BootstrapIcons.check_all;
      case 'cancelled': return BootstrapIcons.x_circle;
      default: return BootstrapIcons.circle;
    }
  }

  Color _getCardBorderColor(int index) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFC107),
      const Color(0xFF00BCD4),
      const Color(0xFF9C27B0),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Consumer<ManagerProvider>(
        builder: (context, managerProvider, child) {
          if (!_isInitialized || managerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))));
          }

          if (managerProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(BootstrapIcons.exclamation_triangle, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${managerProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _initializeData, child: const Text('Retry')),
                ],
              ),
            );
          }

          final filteredAppointments = _getFilteredAppointments(managerProvider.appointments);
          final stats = _getStatistics(managerProvider.appointments);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 24),
                _buildViewToggle(),
                const SizedBox(height: 24),
                if (!_showCalendarView) ...[
                  _buildAppointmentStatsRow(stats),
                  const SizedBox(height: 24),
                  _buildAppointmentTypeFilter(managerProvider.appointments),
                  const SizedBox(height: 24),
                  _buildFilterSection(),
                  const SizedBox(height: 24),
                  _buildAppointmentsGrid(filteredAppointments),
                ] else ...[
                  _buildCalendarView(managerProvider.appointments),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // 📅 VIEW TOGGLE
  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showCalendarView = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: !_showCalendarView ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]) : null,
                  color: !_showCalendarView ? null : Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.grid_3x3_gap_fill, color: !_showCalendarView ? Colors.black : const Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 8),
                    Text('Grid View', style: TextStyle(color: !_showCalendarView ? Colors.black : const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showCalendarView = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: _showCalendarView ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]) : null,
                  color: _showCalendarView ? null : Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.calendar3, color: _showCalendarView ? Colors.black : const Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 8),
                    Text('Calendar View', style: TextStyle(color: _showCalendarView ? Colors.black : const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📅 CALENDAR VIEW WITH 30-MIN TIME SLOTS (9AM-6PM)
  Widget _buildCalendarView(List<AppointmentModel> appointments) {
    final dayAppointments = appointments.where((apt) => _isSameDay(DateTime.parse(apt.appointmentDate), _selectedCalendarDate)).toList();
    
    return Column(
      children: [
        // Calendar Date Selector
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedCalendarDate = _selectedCalendarDate.subtract(const Duration(days: 1))),
                icon: const Icon(BootstrapIcons.chevron_left, color: Color(0xFFFFD700)),
              ),
              InkWell(
                onTap: _selectCalendarDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(BootstrapIcons.calendar3, color: Colors.black),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedCalendarDate),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedCalendarDate = _selectedCalendarDate.add(const Duration(days: 1))),
                icon: const Icon(BootstrapIcons.chevron_right, color: Color(0xFFFFD700)),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Time Slots (9AM-6PM)
        _buildTimeSlots(dayAppointments),
      ],
    );
  }

  Future<void> _selectCalendarDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedCalendarDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFFFD700), onPrimary: Colors.black, surface: Color(0xFF1A1A1A), onSurface: Color(0xFFFFD700)),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedCalendarDate = date);
  }

  // ⭐ NEW: Parse time slot to minutes since midnight
  int _parseTimeSlotLocal(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  // ⭐ NEW: Get slot availability status
  Map<String, dynamic> _getSlotAvailability(
    List<AppointmentModel> dayAppointments,
    String timeSlot,
  ) {
    final slotTime = _parseTimeSlotLocal(timeSlot);
    final slotEndTime = slotTime + 30; // Each slot is 30 minutes
    
    // ⭐ FIXED: Find appointments that OVERLAP with this 30-minute slot
    final activeAppointments = dayAppointments.where((apt) {
      final aptStartTime = _parseTimeSlotLocal(apt.appointmentTime);
      final aptDuration = apt.estimatedDuration ?? 90;
      final aptEndTime = aptStartTime + aptDuration;
      
      // ⭐ CRITICAL FIX: Check if appointment overlaps with THIS slot
      // Overlap occurs if:
      // 1. Appointment starts before slot ends AND
      // 2. Appointment ends after slot starts
      return (aptStartTime < slotEndTime && aptEndTime > slotTime);
    }).toList();
    
    final availableSlots = 2 - activeAppointments.length;
    
    return {
      'available': availableSlots > 0,
      'activeAppointments': activeAppointments,
      'availableSlots': availableSlots,
    };
  }

  // ⏰ TIME SLOTS 9AM-6PM
  Widget _buildTimeSlots(List<AppointmentModel> appointments) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 2)),
            ),
            child: const Row(
              children: [
                Icon(BootstrapIcons.clock, color: Color(0xFFFFD700)),
                SizedBox(width: 12),
                Text('AVAILABLE TIME SLOTS (Max 2 cars per time)', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 21, // ⭐ FIXED: 9:00 AM to 7:00 PM = 10 hours = 20 thirty-minute slots
            separatorBuilder: (_, __) => Divider(color: const Color(0xFFFFD700).withOpacity(0.2), height: 1),
            itemBuilder: (context, index) {
              final totalMinutes = 540 + (index * 30); // Start at 9:00 AM (540 min)
              final hour = totalMinutes ~/ 60;
              final minute = totalMinutes % 60;
              
              // Stop at 6:30 PM (18:30 = 1110 minutes)
              if (totalMinutes >= 1110) return const SizedBox.shrink();
              
              final timeSlot = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
              
              final displayHour = hour > 12 ? hour - 12 : hour;
              final period = hour >= 12 ? 'PM' : 'AM';
              final displayTime = '$displayHour:${minute.toString().padLeft(2, '0')} $period';
              
              // ⭐ Get slot availability info
              final slotInfo = _getSlotAvailability(appointments, timeSlot);
              final isAvailable = slotInfo['available'] as bool;
              final activeAppointments = slotInfo['activeAppointments'] as List<AppointmentModel>;
              final availableSlots = slotInfo['availableSlots'] as int;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activeAppointments.isEmpty 
                      ? null 
                      : availableSlots == 0 
                          ? Colors.red.withOpacity(0.1) 
                          : Colors.orange.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    // Time Display
                    Container(
                      width: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: availableSlots == 0 
                              ? Colors.red 
                              : availableSlots == 1 
                                  ? Colors.orange 
                                  : const Color(0xFFFFD700), 
                          width: 2
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayTime,
                        style: TextStyle(
                          color: availableSlots == 0 
                              ? Colors.red 
                              : availableSlots == 1 
                                  ? Colors.orange 
                                  : const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Slot Status
                    Expanded(
                      child: activeAppointments.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(BootstrapIcons.check_circle, color: Color(0xFF4CAF50), size: 20),
                                  SizedBox(width: 12),
                                  Text('Available (2 slots free)', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                // Show active appointments
                                ...activeAppointments.asMap().entries.map((entry) {
                                  final apt = entry.value;
                                  final aptStartTime = _parseTimeSlotLocal(apt.appointmentTime);
                                  final aptDuration = apt.estimatedDuration ?? 90;
                                  final aptEndMinutes = aptStartTime + aptDuration;
                                  final endHour = aptEndMinutes ~/ 60;
                                  final endMinute = aptEndMinutes % 60;
                                  final endTimeStr = '${endHour > 12 ? endHour - 12 : endHour}:${endMinute.toString().padLeft(2, '0')} ${endHour >= 12 ? 'PM' : 'AM'}';
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: entry.key < activeAppointments.length - 1 ? 8 : 0),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [_getStatusColor(apt.status).withOpacity(0.2), Colors.black]),
                                        border: Border.all(color: _getStatusColor(apt.status), width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(_getStatusIcon(apt.status), color: _getStatusColor(apt.status), size: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(apt.customerName, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                                                    const SizedBox(height: 4),
                                                    Text('${apt.vehiclePlate} • ${apt.packageName}', style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.7), fontSize: 12), overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(color: _getStatusColor(apt.status), borderRadius: BorderRadius.circular(12)),
                                                child: Text(apt.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(BootstrapIcons.hourglass_split, color: Color(0xFFFFD700), size: 12),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Until $endTimeStr (${aptDuration}min)',
                                                style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.7), fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                
                                // Show availability status
                                if (availableSlots > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(BootstrapIcons.plus_circle, color: Colors.orange.withOpacity(0.7), size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          '1 more slot available',
                                          style: TextStyle(color: Colors.orange.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(BootstrapIcons.x_circle, color: Colors.red.withOpacity(0.7), size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'FULLY BOOKED',
                                          style: TextStyle(color: Colors.red.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(BootstrapIcons.calendar_check, color: Color(0xFFFFD700), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointment Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                SizedBox(height: 4),
                Text('Monitor walk-in and scheduled customer bookings', style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showNewAppointmentDialog,
            icon: const Icon(BootstrapIcons.plus_circle, size: 20),
            label: const Text('New Appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _appointmentStatuses = [
    {
      'key': 'total',
      'label': 'Total',
      'icon': BootstrapIcons.calendar_event_fill,
      'colors': [Color(0xFF2196F3), Color(0xFF1976D2)],
    },
    {
      'key': 'pending',
      'label': 'Pending',
      'icon': BootstrapIcons.clock_history,
      'colors': [Color(0xFFFFC107), Color(0xFFFF9800)],
    },
    {
      'key': 'confirmed',
      'label': 'Confirmed',
      'icon': BootstrapIcons.check_circle_fill,
      'colors': [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    },
    {
      'key': 'in-progress',
      'label': 'In-Progress',
      'icon': BootstrapIcons.arrow_repeat,
      'colors': [Color(0xFF00BCD4), Color(0xFF0097A7)],
    },
    {
      'key': 'completed',
      'label': 'Completed',
      'icon': BootstrapIcons.check_all,
      'colors': [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    },
    {
      'key': 'cancelled',
      'label': 'Cancelled',
      'icon': BootstrapIcons.x_circle_fill,
      'colors': [Color(0xFFE53935), Color(0xFFB71C1C)],
    },
  ];

  Widget _buildAppointmentStatsRow(Map<String, int> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {

        // 🖥 Desktop / Web → 6 cards in one row
        if (constraints.maxWidth >= 1100) {
          return Row(
            children: _appointmentStatuses.map((status) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildAppointmentStatCard(
                    label: status['label'],
                    count: stats[status['key']] ?? 0,
                    icon: status['icon'],
                    gradientColors: status['colors'],
                  ),
                ),
              );
            }).toList(),
          );
        }

        // 📱 Tablet → 2 rows (3 + 3)
        if (constraints.maxWidth >= 700) {
          return Column(
            children: [
              Row(
                children: _appointmentStatuses.take(3).map((status) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildAppointmentStatCard(
                        label: status['label'],
                        count: stats[status['key']] ?? 0,
                        icon: status['icon'],
                        gradientColors: status['colors'],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: _appointmentStatuses.skip(3).map((status) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildAppointmentStatCard(
                        label: status['label'],
                        count: stats[status['key']] ?? 0,
                        icon: status['icon'],
                        gradientColors: status['colors'],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }

        // 📲 Mobile → stacked
        return Column(
          children: _appointmentStatuses.map((status) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAppointmentStatCard(
                label: status['label'],
                count: stats[status['key']] ?? 0,
                icon: status['icon'],
                gradientColors: status['colors'],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAppointmentStatCard({
    required String label,
    required int count,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return _HoverableCard(
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ RESTORED: Walk-In/Scheduled Filter
  Widget _buildAppointmentTypeFilter(List<AppointmentModel> appointments) {
    final filteredByStatus = _selectedStatus == 'all' 
        ? appointments 
        : appointments.where((apt) => apt.status.toLowerCase() == _selectedStatus).toList();
    
    final allCount = filteredByStatus.length;
    final walkInCount = filteredByStatus.where((apt) => 
      (apt.appointmentType ?? 'scheduled').toLowerCase() == 'walk-in'
    ).length;
    final scheduledCount = filteredByStatus.where((apt) => 
      (apt.appointmentType ?? 'scheduled').toLowerCase() == 'scheduled'
    ).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTypeChip('All', 'all', Icons.grid_view, allCount)),
          const SizedBox(width: 12),
          Expanded(child: _buildTypeChip('Walk-In', 'walk-in', Icons.person_outline, walkInCount)),
          const SizedBox(width: 12),
          Expanded(child: _buildTypeChip('Scheduled', 'scheduled', Icons.calendar_month_outlined, scheduledCount)),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon, int count) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () => setState(() => _selectedType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)])
              : null,
          color: isSelected ? null : Colors.black,
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFFFD700).withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : const Color(0xFFFFD700),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(BootstrapIcons.funnel, color: Color(0xFFFFD700), size: 18),
                    SizedBox(width: 8),
                    Text('FILTER APPOINTMENTS', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(BootstrapIcons.arrow_clockwise, size: 14),
                  label: const Text('Reset All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildSearchField()),
                const SizedBox(width: 16),
                Expanded(child: _buildDateFilter()),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusDropdown()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Search', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4,),
        TextField(style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14,),
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Name, phone, or car plate...',
            hintStyle: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.4)),
            prefixIcon: const Icon(BootstrapIcons.search, color: Color(0xFFFFD700)),
            filled: true,
            fillColor: Colors.black,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3), width: 2)),
          ),
        )
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Date', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _dateFilter,
          onChanged: (value) {
            setState(() => _dateFilter = value!);
            if (value == 'custom') {
              _selectCustomDate();
            } else if (value == 'range') {
              _selectDateRange();
            }
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(BootstrapIcons.calendar3, color: Color(0xFFFFD700), size: 20),
            filled: true,
            fillColor: Colors.black,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
          ),
          dropdownColor: const Color(0xFF0A0A0A),
          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600),
          items:  [
            const DropdownMenuItem(value: 'all', child: Text('All Dates')),
            const DropdownMenuItem(value: 'today', child: Text('Today')),
            const DropdownMenuItem(value: 'tomorrow', child: Text('Tomorrow')),
            const DropdownMenuItem(value: 'week', child: Text('This Week')),
            const DropdownMenuItem(value: 'month', child: Text('This Month')),
            const DropdownMenuItem(value: 'custom', child: Text('Select Date...')),
            DropdownMenuItem(value: 'range', child: Text(_startDate != null && _endDate != null 
              ? '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}'
              : 'Date Range...')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Status', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          onChanged: (value) {
            if (value != null){
              setState(() => _selectedStatus = value!);
            }
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(BootstrapIcons.bookmark, color: Color(0xFFFFD700), size: 20),
            filled: true,
            fillColor: Colors.black,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
          ),
          dropdownColor: const Color(0xFF0A0A0A),
          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Status')),
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
            DropdownMenuItem(value: 'in-progress', child: Text('In-Progress')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
          ],
        ),
      ],
    );
  }

  Future<void> _selectCustomDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFFFD700), onPrimary: Colors.black, surface: Color(0xFF1A1A1A), onSurface: Color(0xFFFFD700)),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _customDate = date);
    else setState(() => _dateFilter = 'all');
  }

  Future<void> _selectDateRange() async {
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
        _startDate = range.start;
        _endDate = range.end;
        _dateFilter = 'range';
      });
    } else {
      setState(() => _dateFilter = 'all');
    }
  }

  Widget _buildAppointmentsGrid(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(BootstrapIcons.calendar_x, color: const Color(0xFFFFD700).withOpacity(0.5), size: 64),
              const SizedBox(height: 16),
              const Text('No appointments found', style: TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Try adjusting your filters', style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.7), fontSize: 14)),
            ],
          ),
        ),
      );
    }

    // 🔧 RESPONSIVE GRID: Narrower and shorter cards with suitable height
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxCardWidth;
        
        // Calculate optimal columns based on available width
        if (constraints.maxWidth < 600) {
          maxCardWidth = constraints.maxWidth; // 1 column
        } else if (constraints.maxWidth < 900) {
          maxCardWidth = 500; // 2 columns
        } else if (constraints.maxWidth < 1400) {
          maxCardWidth = 420; // 3 columns
        } else {
          maxCardWidth = 380; // 4 columns
        }
        
        return GridView.builder(
          shrinkWrap: true, // ⭐ REQUIRED
          physics: const NeverScrollableScrollPhysics(), // ⭐ REQUIRED
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCardWidth,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.97, // ⭐ more height → no overflow
          ),
          itemCount: appointments.length,
          itemBuilder: (context, index) =>
              _buildAppointmentCard(appointments[index], index),
        );
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, int index) {
    final borderColor = _getCardBorderColor(index);
    final statusColor = _getStatusColor(appointment.status);
    
    // Safely get appointment type
    String appointmentType = 'scheduled';
    try {
      appointmentType = appointment.appointmentType?.toLowerCase() ?? 'scheduled';
    } catch (e) {
      appointmentType = 'scheduled';
    }
    
    // Safely get customer phone - FORMAT IT!
    String customerPhone = 'N/A';
    try {
      customerPhone = _formatPhoneNumber(appointment.customerPhone ?? 'N/A');
    } catch (e) {
      customerPhone = 'N/A';
    }
    
    // Safely get vehicle display
    String vehicleDisplay = '${appointment.vehicleBrand} ${appointment.vehicleModel}';
    
    // Check if status is in-progress
    final isInProgress = appointment.status.toLowerCase() == 'in-progress';
    final isCompleted = appointment.status.toLowerCase() == 'completed';
    final isCancelled = appointment.status.toLowerCase() == 'cancelled';
    
    // Determine badge text colors based on background brightness
    final typeColor = appointmentType == 'walk-in' ? const Color(0xFF9C27B0) : const Color(0xFF00BCD4);
    final typeTextColor = _isLightColor(typeColor) ? Colors.black : Colors.white;
    final statusTextColor = _isLightColor(statusColor) ? Colors.black : Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with MORE HEIGHT - name bold, phone NOT bold
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // ⭐ More vertical space
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.2), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.customerName,
                        style: const TextStyle(
                          color: Color(0xFFFFD700), 
                          fontWeight: FontWeight.bold, // ✅ Name is BOLD
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointmentType == 'walk-in' ? 'WALK-IN' : 'SCHEDULED',
                        style: TextStyle(color: typeTextColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // ⭐ Better spacing between name and phone
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(BootstrapIcons.telephone_fill, color: Color(0xFFFFD700), size: 12),
                        const SizedBox(width: 6),
                        Text(
                          customerPhone, 
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF), 
                            fontSize: 12,
                            fontWeight: FontWeight.normal, // ✅ Phone is NOT bold
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isInProgress ? 'IN-PROGRESS' : appointment.status.toUpperCase(),
                        style: TextStyle(color: statusTextColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content with SUITABLE GAPS - not too packed!
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 21), // ⭐ Better spacing
            child: Column(
              children: [
                _buildCompactDetailRow(BootstrapIcons.calendar3, 'DATE', _formatDate(appointment.appointmentDate)),
                const SizedBox(height: 12), // ⭐ Suitable gap
                _buildCompactDetailRow(BootstrapIcons.clock, 'TIME', _formatTime(appointment.appointmentTime)),
                const SizedBox(height: 12), // ⭐ Suitable gap
                _buildCompactDetailRow(BootstrapIcons.car_front_fill, 'VEHICLE', '${appointment.vehiclePlate} • $vehicleDisplay'),
                const SizedBox(height: 12), // ⭐ Suitable gap
                _buildCompactDetailRow(BootstrapIcons.geo_alt_fill, 'BRANCH', _formatBranch(appointment.branchID)),
                const SizedBox(height: 12), // ⭐ Suitable gap
                _buildCompactDetailRow(BootstrapIcons.box_seam, 'PACKAGE', appointment.packageName),
                const SizedBox(height: 12), // ⭐ Suitable gap
                _buildCompactDetailRow(BootstrapIcons.cash_stack, 'PRICE', 'RM ${appointment.totalPrice?.toStringAsFixed(2) ?? '0.00'}'),
              ],
            ),
          ),
          
          // Action buttons with SUITABLE LENGTH & HEIGHT - CLOSE TO CARD BOTTOM
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // ⭐ Proper bottom padding
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewAppointment(appointment),
                    icon: const Icon(BootstrapIcons.eye, size: 12),
                    label: const Text('VIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9), // ⭐ Suitable padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                if (!isInProgress && !isCompleted && !isCancelled) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _editAppointment(appointment),
                      icon: const Icon(BootstrapIcons.pencil, size: 12),
                      label: const Text('EDIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9), // ⭐ Suitable padding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showStatusDialog(appointment),
                      icon: const Icon(BootstrapIcons.arrow_repeat, size: 12),
                      label: const Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9), // ⭐ Suitable padding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: () => _deleteAppointment(appointment),
                    icon: const Icon(BootstrapIcons.trash, size: 14, color: Colors.white),
                    padding: const EdgeInsets.all(9), // ⭐ Suitable padding
                    constraints: const BoxConstraints(minWidth: 38, minHeight: 38), // ⭐ Suitable size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to determine if a color is light
  bool _isLightColor(Color color) {
    // Calculate relative luminance
    final double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5; // If luminance > 0.5, it's a light color
  }

  String _formatPhoneNumber(String phone) {
    // Remove any existing formatting
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Format as 012-3456789
    if (phone.length >= 10) {
      return '${phone.substring(0, 3)}-${phone.substring(3)}';
    } else if (phone.length >= 3) {
      return '${phone.substring(0, 3)}-${phone.substring(3)}';
    }
    return phone;
  }

  Widget _buildCompactDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label, 
                style: TextStyle(
                  color: const Color(0xFFFFD700).withOpacity(0.7), // ✅ Shallow/lighter gold
                  fontSize: 11, 
                  fontWeight: FontWeight.normal, // ✅ NOT bold
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFFFD700), // ✅ Full gold color
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, // ✅ BOLD
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(d);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  String _formatBranch(String branchID) {
    if (branchID.toLowerCase().contains('melaka')) return 'Melaka';
    if (branchID.toLowerCase().contains('seremban')) return 'Seremban 2';
    return branchID;
  }

  void _viewAppointment(AppointmentModel appointment) {
    final isCompleted = appointment.status.toLowerCase() == 'completed';
    final isInProgress = appointment.status.toLowerCase() == 'in-progress';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                  border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 3)),
                ),
                child: Row(
                  children: [
                    const Icon(BootstrapIcons.eye, color: Color(0xFFFFD700), size: 24),
                    const SizedBox(width: 12),
                    const Text('APPOINTMENT DETAILS', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Customer Information Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(BootstrapIcons.person_circle, color: Colors.black, size: 20),
                            SizedBox(width: 12),
                            Text('CUSTOMER INFORMATION', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildViewRow('NAME:', appointment.customerName),
                      const SizedBox(height: 12),
                      _buildViewRow('PHONE:', _formatPhoneNumber(appointment.customerPhone ?? 'N/A')),
                      
                      const SizedBox(height: 24),
                      
                      // Vehicle Information Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(BootstrapIcons.car_front_fill, color: Colors.black, size: 20),
                            SizedBox(width: 12),
                            Text('VEHICLE INFORMATION', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildViewRow('CAR MODEL:', '${appointment.vehicleBrand} ${appointment.vehicleModel}'),
                      const SizedBox(height: 12),
                      _buildViewRow('CAR PLATE:', appointment.vehiclePlate),
                      
                      const SizedBox(height: 24),
                      
                      // Appointment Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(BootstrapIcons.calendar_check, color: Colors.black, size: 20),
                            SizedBox(width: 12),
                            Text('APPOINTMENT DETAILS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildViewRow('DATE:', _formatDate(appointment.appointmentDate)),
                      const SizedBox(height: 12),
                      _buildViewRow('TIME:', _formatTime(appointment.appointmentTime)),
                      const SizedBox(height: 12),
                      _buildViewRow('PACKAGE:', appointment.packageName),
                      const SizedBox(height: 12),
                      _buildViewRow('PRICE:', 'RM ${appointment.totalPrice?.toStringAsFixed(2) ?? '0.00'}'),
                      const SizedBox(height: 12),
                      _buildViewRow('STATUS:', isInProgress ? 'IN-PROGRESS' : appointment.status.toUpperCase()),
                      
                      // Show finish time for completed appointments
                      if (isCompleted) ...[
                        const SizedBox(height: 12),
                        _buildViewRow('FINISH SERVICE TIME:', appointment.updatedAt != null 
                            ? DateFormat('dd/MM/yyyy hh:mm a').format(appointment.updatedAt!)
                            : 'N/A'),
                      ],
                      
                      if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildViewRow('NOTES:', appointment.notes!),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(13), bottomRight: Radius.circular(13)),
                  border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    // Hide Edit button for completed and in-progress
                    if (!isCompleted && !isInProgress)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editAppointment(appointment);
                        },
                        icon: const Icon(BootstrapIcons.pencil),
                        label: const Text('EDIT APPOINTMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.2), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _editAppointment(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => _EditAppointmentDialog(appointment: appointment, branchID: appointment.branchID),
    );
  }

  void _showStatusDialog(AppointmentModel appointment) {
    final currentStatus = appointment.status.toLowerCase();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Change Status',
                      style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFFFD700)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Status options in black box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (currentStatus != 'pending')
                      _buildStatusChangeOption(
                        appointment,
                        'SET PENDING',
                        'pending',
                        BootstrapIcons.clock,
                        const Color(0xFFFFC107),
                      ),
                    if (currentStatus != 'confirmed')
                      _buildStatusChangeOption(
                        appointment,
                        'MARK CONFIRMED',
                        'confirmed',
                        BootstrapIcons.check_circle,
                        const Color(0xFF4CAF50),
                      ),
                    // Don't show in-progress - only staff can set this
                    if (currentStatus != 'completed')
                      _buildStatusChangeOption(
                        appointment,
                        'MARK COMPLETED',
                        'completed',
                        BootstrapIcons.check_all,
                        const Color(0xFF9E9E9E),
                      ),
                    if (currentStatus != 'cancelled')
                      _buildStatusChangeOption(
                        appointment,
                        'CANCEL',
                        'cancelled',
                        BootstrapIcons.x_circle,
                        const Color(0xFFF44336),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChangeOption(
    AppointmentModel appointment,
    String label,
    String newStatus,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _confirmStatusChange(appointment, newStatus, label);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmStatusChange(AppointmentModel appointment, String newStatus, String label) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFC107), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amber Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFA000)]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                ),
                child: const Row(
                  children: [
                    Icon(BootstrapIcons.exclamation_triangle, color: Colors.black, size: 24),
                    SizedBox(width: 12),
                    Text('CONFIRM STATUS CHANGE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Are you sure you want to change the appointment status?',
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Status Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CURRENT STATUS:',
                                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                appointment.status.toUpperCase(),
                                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'NEW STATUS:',
                                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                newStatus.toUpperCase(),
                                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('CONFIRM CHANGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await AppointmentService().updateAppointmentStatus(
          appointmentID: appointment.appointmentID,
          newStatus: newStatus,
        );
        
        if (mounted) {
          final authProvider = context.read<AuthProvider>();
          final managerProvider = context.read<ManagerProvider>();
          await managerProvider.fetchAppointments(authProvider.branchID!);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to ${newStatus.toUpperCase()}'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteAppointment(AppointmentModel appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF44336), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFF44336), Color(0xFFD32F2F)]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                ),
                child: const Row(
                  children: [
                    Icon(BootstrapIcons.trash, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text('DELETE APPOINTMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Are you sure you want to delete this appointment?',
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Warning Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF44336), width: 2),
                      ),
                      child: const Row(
                        children: [
                          Icon(BootstrapIcons.exclamation_triangle, color: Color(0xFFF44336), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This action cannot be undone.',
                              style: TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Appointment Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('CUSTOMER:', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(appointment.customerName, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('DATE:', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${_formatDate(appointment.appointmentDate)} at ${_formatTime(appointment.appointmentTime)}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context, true),
                            icon: const Icon(BootstrapIcons.trash),
                            label: const Text('DELETE APPOINTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF44336),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await AppointmentService().deleteAppointment(appointment.appointmentID);
        
        final authProvider = context.read<AuthProvider>();
        final managerProvider = context.read<ManagerProvider>();
        await managerProvider.fetchAppointments(authProvider.branchID!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment deleted successfully'), backgroundColor: Color(0xFFF44336)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showNewAppointmentDialog() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.branchID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Branch ID not found'), backgroundColor: Colors.red),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => NewAppointmentDialog(branchID: authProvider.branchID!),
    );
  }
}

// EDIT APPOINTMENT DIALOG
class _EditAppointmentDialog extends StatefulWidget {
  final AppointmentModel appointment;
  final String branchID;
  
  const _EditAppointmentDialog({required this.appointment, required this.branchID});

  @override
  State<_EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<_EditAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentService _appointmentService = AppointmentService();
  final PackageService _packageService = PackageService();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _plateController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedBrand;
  late String _selectedModel;
  
  List<TintPackageModel> _packages = [];
  TintPackageModel? _selectedPackage;
  bool _isLoadingPackages = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.appointment.customerName);
    _phoneController = TextEditingController(text: widget.appointment.customerPhone ?? '');
    _plateController = TextEditingController(text: widget.appointment.vehiclePlate);
    _notesController = TextEditingController(text: widget.appointment.notes ?? '');
    
    _selectedDate = DateTime.parse(widget.appointment.appointmentDate);
    final timeParts = widget.appointment.appointmentTime.split(':');
    _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    
    _selectedBrand = widget.appointment.vehicleBrand;
    _selectedModel = widget.appointment.vehicleModel;
    
    _loadPackages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await _packageService.getAllPackages();
      setState(() {
        _packages = packages;
        _isLoadingPackages = false;
        _selectedPackage = packages.firstWhere(
          (p) => p.packageName == widget.appointment.packageName,
          orElse: () => packages.first,
        );
      });
    } catch (e) {
      setState(() => _isLoadingPackages = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 750),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.pencil, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  const Text('EDIT APPOINTMENT', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFFFFD700)),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: _isLoadingPackages
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditField(
                              'CUSTOMER NAME', 
                              _nameController, 
                              BootstrapIcons.person_fill,
                              formatters: [
                                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                                LengthLimitingTextInputFormatter(50)
                              ],
                              validator: (v) => v == null || v.isEmpty ? 'Required' : v.length < 2 ? 'At least 2 characters' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            _buildEditField(
                              'PHONE NUMBER', 
                              _phoneController, 
                              BootstrapIcons.telephone_fill,
                              keyboardType: TextInputType.phone,
                              formatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(11)
                              ],
                              validator: (v) => v == null || v.isEmpty ? 'Required' : v.length < 10 ? 'At least 10 digits' : !v.startsWith('01') ? 'Must start with 01' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            _buildEditField(
                              'CAR PLATE NUMBER', 
                              _plateController, 
                              BootstrapIcons.car_front_fill,
                              formatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
                                LengthLimitingTextInputFormatter(10),
                                TextInputFormatter.withFunction((old, newValue) => 
                                  TextEditingValue(
                                    text: newValue.text.toUpperCase(), 
                                    selection: newValue.selection
                                  )
                                )
                              ],
                              validator: (v) => v == null || v.isEmpty ? 'Required' : v.length < 4 ? 'Invalid plate number' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            // Car Model (read-only)
                            _buildReadOnlyField('CAR MODEL', '$_selectedBrand $_selectedModel', BootstrapIcons.car_front_fill),
                            const SizedBox(height: 16),
                            
                            // Date Picker
                            _buildDatePicker(),
                            const SizedBox(height: 16),
                            
                            // Time Picker
                            _buildTimePicker(),
                            const SizedBox(height: 16),
                            
                            // Branch (read-only)
                            _buildReadOnlyField('BRANCH', widget.branchID == 'melaka' ? 'Melaka' : 'Seremban 2', BootstrapIcons.geo_alt_fill),
                            const SizedBox(height: 16),
                            
                            // Package Dropdown
                            if (_packages.isNotEmpty) _buildPackageDropdown(),
                            const SizedBox(height: 16),
                            
                            // Notes
                            _buildEditField(
                              'SPECIAL NOTES', 
                              _notesController, 
                              BootstrapIcons.sticky, 
                              maxLines: 3,
                              formatters: [LengthLimitingTextInputFormatter(200)],
                            ),

                            // ⭐ ADD CHARACTER COUNTER for Notes
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${_notesController.text.length}/200',
                                  style: TextStyle(
                                    color: _notesController.text.length > 200 
                                      ? Colors.red 
                                      : const Color(0xFFFFD700).withOpacity(0.6), 
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w600
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(13), bottomRight: Radius.circular(13)),
                border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveChanges,
                    icon: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                        : const Icon(BootstrapIcons.download),
                    label: Text(_isSaving ? 'SAVING...' : 'SAVE CHANGES', style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {
    int maxLines = 1,
    List<TextInputFormatter>? formatters,  
    String? Function(String?)? validator,  
    TextInputType? keyboardType, 
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isSaving,
          maxLines: maxLines,
          keyboardType: keyboardType,           
          inputFormatters: formatters,          
          validator: validator,                 
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Color(0xFFFFD700)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 20),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD700).withOpacity(0.5), size: 20),
              const SizedBox(width: 12),
              Text(value, style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.7), fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('APPOINTMENT DATE', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving ? null : () async {
            // ⭐ FIX: Store context before async gap
            final pickerContext = context;
            
            final DateTime? pickedDate = await showDatePicker(
              context: pickerContext,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFFFFD700),
                      onPrimary: Colors.black,
                      surface: Color(0xFF1A1A1A),
                      onSurface: Color(0xFFFFD700),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            
            if (pickedDate != null && mounted) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.calendar3, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(BootstrapIcons.calendar_event, color: Color(0xFFFFD700), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('APPOINTMENT TIME', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving ? null : () async {
            const openingTime = TimeOfDay(hour: 9, minute: 0);
            const closingTime = TimeOfDay(hour: 19, minute: 0);
            
            final appointmentDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
            final estimatedDuration = VehicleDatabase.getMinutes(_selectedModel);
            
            // ⭐ FIX: Use ThirtyMinuteTimePicker instead of native picker
            final TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext dialogContext) => ThirtyMinuteTimePicker(
                initialTime: _selectedTime,
                minTime: openingTime,
                maxTime: closingTime,
                isWalkIn: false, // Edit is never walk-in
                appointmentDate: appointmentDateStr,
                branchID: widget.branchID,
                estimatedDuration: estimatedDuration,
              ),
            );
            
            // ⭐ FIX: Update state if time was selected
            if (selectedTime != null) {
              setState(() {
                _selectedTime = selectedTime;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.clock, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(BootstrapIcons.clock_fill, color: Color(0xFFFFD700), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SERVICE PACKAGE', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<TintPackageModel>(
          value: _selectedPackage,
          onChanged: _isSaving ? null : (value) => setState(() => _selectedPackage = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(BootstrapIcons.box_seam, color: Color(0xFFFFD700), size: 20),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
          ),
          dropdownColor: const Color(0xFF0A0A0A),
          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600),
          items: _packages.map((package) => DropdownMenuItem(value: package, child: Text(package.packageName))).toList(),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    try {
      final hour = _selectedTime.hour.toString().padLeft(2, '0');
      final minute = _selectedTime.minute.toString().padLeft(2, '0');
      final appointmentTime = '$hour:$minute';
      final appointmentDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      await _appointmentService.updateAppointment(
        appointmentID: widget.appointment.appointmentID,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        vehiclePlate: _plateController.text.trim(),
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        packageID: _selectedPackage?.packageID ?? widget.appointment.packageID,
        packageName: _selectedPackage?.packageName ?? widget.appointment.packageName,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
        
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment updated successfully!'), backgroundColor: Color(0xFF4CAF50)),
        );
          
        final manager = context.read<ManagerProvider>();
        await manager.fetchAppointments(widget.branchID);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// NEW APPOINTMENT DIALOG
class NewAppointmentDialog extends StatefulWidget {
  final String branchID;
  
  const NewAppointmentDialog({super.key, required this.branchID});

  @override
  State<NewAppointmentDialog> createState() => _NewAppointmentDialogState();
}

class _NewAppointmentDialogState extends State<NewAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentService _appointmentService = AppointmentService();
  final PackageService _packageService = PackageService();
  
  String _appointmentType = 'scheduled';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _plateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  String? _selectedBrand;
  String? _selectedModel;
  List<String> _availableModels = [];
  String _detectedCarType = '';
  int _estimatedMinutes = 0;
  
  List<TintPackageModel> _packages = [];
  TintPackageModel? _selectedPackage;
  bool _isLoadingPackages = true;
  double _calculatedPrice = 0.0;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPackages();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await _packageService.getAllPackages();
      setState(() {
        _packages = packages;
        _isLoadingPackages = false;
        if (_packages.isNotEmpty) {
          _selectedPackage = _packages.first;
          _updatePrice();
        }
      });
    } catch (e) {
      setState(() => _isLoadingPackages = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load packages: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onBrandChanged(String? brand) {
    if (brand != null) {
      setState(() {
        _selectedBrand = brand;
        _selectedModel = null;
        _availableModels = VehicleDatabase.getModelsByBrand(brand);
        _detectedCarType = '';
        _estimatedMinutes = 0;
        _calculatedPrice = 0.0;
      });
    }
  }

  void _onModelChanged(String? model) {
    if (model != null) {
      setState(() {
        _selectedModel = model;
        _detectedCarType = VehicleDatabase.getType(model);
        _estimatedMinutes = VehicleDatabase.getMinutes(model);
        _updatePrice();
      });
    }
  }

  void _onPackageChanged(TintPackageModel? package) {
    if (package != null) {
      setState(() {
        _selectedPackage = package;
        _updatePrice();
      });
    }
  }

  void _updatePrice() {
    if (_selectedPackage != null && _detectedCarType.isNotEmpty) {
      setState(() {
        _calculatedPrice = _selectedPackage!.getPriceForVehicle(_detectedCarType);
        final packageDuration = _selectedPackage!.getDurationForVehicle(_detectedCarType);
        if (packageDuration > 0) {
          _estimatedMinutes = packageDuration;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 750),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A), Colors.black]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.plus_circle, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  const Text('CREATE NEW APPOINTMENT', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context), 
                    icon: const Icon(Icons.close, color: Color(0xFFFFD700))
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: _isLoadingPackages
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildTypeOption('scheduled', 'Scheduled', BootstrapIcons.calendar_check)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTypeOption('walk-in', 'Walk-In', BootstrapIcons.person_walking)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            _buildTextField(_nameController, 'Customer Name', BootstrapIcons.person_fill, 'Ahmad Ibrahim', 
                              [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")), LengthLimitingTextInputFormatter(50)],
                              (v) => v == null || v.isEmpty ? 'Required' : v.length < 2 ? 'At least 2 characters' : null),
                            const SizedBox(height: 16),
                            
                            _buildTextField(_phoneController, 'Phone Number', BootstrapIcons.telephone_fill, '0123456789',
                              [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), LengthLimitingTextInputFormatter(11)],
                              (v) => v == null || v.isEmpty ? 'Required' : v.length < 10 ? 'At least 10 digits' : !v.startsWith('01') ? 'Must start with 01' : null,
                              keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            
                            _buildTextField(_plateController, 'Vehicle Plate', BootstrapIcons.car_front_fill, 'ABC 1234',
                              [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')), LengthLimitingTextInputFormatter(10),
                               TextInputFormatter.withFunction((old, newValue) => TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection))],
                              (v) => v == null || v.isEmpty ? 'Required' : v.length < 4 ? 'Invalid' : null),
                            const SizedBox(height: 16),
                            
                            _buildSmartDropdown(value: _selectedBrand, label: 'Vehicle Brand', icon: BootstrapIcons.car_front, hint: 'Select brand',
                              items: VehicleDatabase.getAllBrands(), onChanged: _onBrandChanged, validator: (v) => v == null ? 'Select a brand' : null),
                            const SizedBox(height: 16),
                            
                            _buildSmartDropdown(value: _selectedModel, label: 'Vehicle Model', icon: BootstrapIcons.car_front_fill, hint: 'Select model',
                              items: _availableModels, onChanged: _onModelChanged, enabled: _selectedBrand != null, validator: (v) => v == null ? 'Select a model' : null),
                            
                            if (_detectedCarType.isNotEmpty) ...[const SizedBox(height: 16), _buildDetectedInfo()],
                            if (_appointmentType == 'scheduled') ...[const SizedBox(height: 16), _buildDatePicker()],
                            const SizedBox(height: 16),
                            _buildTimePicker(),
                            const SizedBox(height: 16),
                            
                            _buildPackageDropdown(),
                            const SizedBox(height: 16),
                            
                            if (_calculatedPrice > 0) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CC)]),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(BootstrapIcons.cash_stack, color: Color(0xFFFFD700), size: 20),
                                        SizedBox(width: 8),
                                        Text('Total Price', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                    Text('RM ${_calculatedPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            _buildTextField(_notesController, 'Notes (Optional - Max 200 characters)', BootstrapIcons.sticky, 'Add any special requests...',
                              [LengthLimitingTextInputFormatter(200)], null, keyboardType: TextInputType.multiline, maxLines: 3),
                            
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('${_notesController.text.length}/200',
                                  style: TextStyle(color: _notesController.text.length > 200 ? Colors.red : const Color(0xFFFFD700).withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(13), bottomRight: Radius.circular(13)),
                border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveAppointment,
                    icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                        : const Icon(BootstrapIcons.check_circle),
                    label: Text(_isSaving ? 'Creating...' : 'Create Appointment'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    final isSelected = _appointmentType == value;
    return InkWell(
      onTap: () => setState(() => _appointmentType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]) : null,
          color: isSelected ? null : Colors.black,
          border: Border.all(color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFFFD700).withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.black : const Color(0xFFFFD700), size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.black : const Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String hint, List<TextInputFormatter> formatters,
    String? Function(String?)? validator, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          validator: validator,
          maxLines: maxLines,
          enabled: !_isSaving,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.4)),
            prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 2)),
          ),
          style: const TextStyle(color: Color(0xFFFFD700)),
        ),
      ],
    );
  }

  Widget _buildSmartDropdown({required String? value, required String label, required IconData icon, required String hint, required List<String> items,
    required void Function(String?) onChanged, bool enabled = true, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: enabled && !_isSaving ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.4)),
            prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 20),
            filled: true,
            fillColor: enabled ? Colors.black : Colors.black.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3), width: 2)),
          ),
          dropdownColor: const Color(0xFF0A0A0A),
          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700), size: 24),
          isExpanded: true,
          menuMaxHeight: 300,
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
        ),
      ],
    );
  }

  Widget _buildPackageDropdown() {
    if (_packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red, width: 2)),
        child: const Row(
          children: [
            Icon(BootstrapIcons.exclamation_triangle, color: Colors.red),
            SizedBox(width: 12),
            Expanded(child: Text('No packages available. Please add packages first.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Service Package', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<TintPackageModel>(
          value: _selectedPackage,
          onChanged: _isSaving ? null : _onPackageChanged,
          decoration: InputDecoration(
            hintText: 'Select package',
            hintStyle: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.4)),
            prefixIcon: const Icon(BootstrapIcons.box_seam, color: Color(0xFFFFD700), size: 20),
            filled: true,
            fillColor: Colors.black,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2)),
          ),
          dropdownColor: const Color(0xFF0A0A0A),
          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700), size: 24),
          isExpanded: true,
          menuMaxHeight: 300,
          items: _packages.map((package) => DropdownMenuItem<TintPackageModel>(value: package, child: Text(package.packageName))).toList(),
        ),
      ],
    );
  }

  Widget _buildDetectedInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CC)]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.info_circle, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text('Auto-Detected', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoChip('Type', _detectedCarType, BootstrapIcons.car_front_fill)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoChip('Est. Time', '$_estimatedMinutes min', BootstrapIcons.clock)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFD700))),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Appointment Date', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving ? null : () async {
            // ⭐ FIX: Store context before async gap
            final pickerContext = context;
            
            final DateTime? pickedDate = await showDatePicker(
              context: pickerContext,
              initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFFFFD700),
                      onPrimary: Colors.black,
                      surface: Color(0xFF1A1A1A),
                      onSurface: Color(0xFFFFD700),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            
            if (pickedDate != null && mounted) {
              setState(() {
                _selectedDate = pickedDate;
                // ⭐ ALSO RESET TIME when date changes
                _selectedTime = null;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.calendar3, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null 
                    ? 'Select Date' 
                    : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null 
                      ? const Color(0xFFFFD700).withOpacity(0.4) 
                      : const Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Appointment Time', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
            if (_estimatedMinutes > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD700))),
                child: Text('Allow $_estimatedMinutes min', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving ? null : () async {
            final now = TimeOfDay.now();
            const openingTime = TimeOfDay(hour: 9, minute: 0);
            const closingTime = TimeOfDay(hour: 19, minute: 0);

            final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now()); 
            final selectedDateStr = _selectedDate != null 
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : todayStr;

            final isToday = selectedDateStr == todayStr;

            // Determine minimum time based on appointment type and date
            TimeOfDay minTime;
            if (_appointmentType == 'walk-in') {
              minTime = now;
            } else {
              if (isToday) {
                final nowMinutes = now.hour * 60 + now.minute;
                final openingMinutes = openingTime.hour * 60 + openingTime.minute;
                minTime = nowMinutes > openingMinutes ? now : openingTime;
              } else {
                minTime = openingTime;
              }
            }

            // ⭐ FIX: Properly await the dialog result
            final TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext dialogContext) => ThirtyMinuteTimePicker(
                initialTime: _selectedTime ?? minTime,
                minTime: minTime,
                maxTime: closingTime,
                isWalkIn: _appointmentType == 'walk-in',
                appointmentDate: selectedDateStr,
                branchID: widget.branchID,
                estimatedDuration: _estimatedMinutes > 0 ? _estimatedMinutes : 90,
              ),
            );

            // ⭐ FIX: Check if time was selected
            if (selectedTime != null) {
              final selectionMinutes = selectedTime.hour * 60 + selectedTime.minute;
              final nowMinutes = now.hour * 60 + now.minute;
              final closingMinutes = closingTime.hour * 60 + closingTime.minute;

              // Validate time selection
              if (_appointmentType == 'walk-in' && isToday && selectionMinutes < nowMinutes) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot select past time for walk-in.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              if (selectionMinutes >= closingMinutes) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selected time is outside operating hours.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // ⭐ FIX: Update state with selected time
              setState(() {
                _selectedTime = selectedTime;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.clock, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  _selectedTime == null 
                    ? 'Select Time' 
                    : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _selectedTime == null 
                      ? const Color(0xFFFFD700).withOpacity(0.4) 
                      : const Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedBrand == null || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select vehicle brand and model'), backgroundColor: Colors.red)
      );
      return;
    }
    
    if (_appointmentType == 'scheduled' && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date'), backgroundColor: Colors.red)
      );
      return;
    }
    
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time'), backgroundColor: Colors.red)
      );
      return;
    }
    
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a package'), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final appointmentDate = _appointmentType == 'scheduled' 
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!) 
          : DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final hour = _selectedTime!.hour.toString().padLeft(2, '0');
      final minute = _selectedTime!.minute.toString().padLeft(2, '0');
      final appointmentTime = '$hour:$minute';

      // ⭐ The validation now happens INSIDE createAppointment with transaction
      final appointmentID = await _appointmentService.createAppointment(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        branchID: widget.branchID,
        vehicleBrand: _selectedBrand!,
        vehicleModel: _selectedModel!,
        vehicleType: _detectedCarType,
        vehiclePlate: _plateController.text.trim(),
        packageID: _selectedPackage!.packageID,
        packageName: _selectedPackage!.packageName,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentType: _appointmentType,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        totalPrice: _calculatedPrice,
        estimatedDuration: _estimatedMinutes,
      );

      if (appointmentID != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment created successfully! Vehicle: $_selectedBrand $_selectedModel'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
          ),
        );
        
        final managerProvider = context.read<ManagerProvider>();
        await managerProvider.fetchAppointments(widget.branchID);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        String errorMessage = 'Failed to create appointment';
        
        // ⭐ Check for specific errors
        if (e.toString().contains('TIME_SLOT_FULL')) {
          errorMessage = '⚠️ This time slot is fully booked (max 2 cars). Please select another time.';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Add this helper method
  bool _canAcceptAppointmentCheck(
    List<AppointmentModel> dayAppointments,
    String timeSlot,
    int durationMinutes,
  ) {
    final slotTime = _parseTimeSlotInt(timeSlot);
    final endTime = slotTime + durationMinutes;
    
    final overlappingAppointments = dayAppointments.where((apt) {
      final aptStartTime = _parseTimeSlotInt(apt.appointmentTime);
      final aptDuration = apt.estimatedDuration ?? 90;
      final aptEndTime = aptStartTime + aptDuration;
      
      return (aptStartTime < endTime && aptEndTime > slotTime);
    }).toList();
    
    return overlappingAppointments.length < 2;
  }

  int _parseTimeSlotInt(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }
}

class _HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  // ignore: unused_element_parameter
  const _HoverableCard({required this.child, this.onTap});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}  