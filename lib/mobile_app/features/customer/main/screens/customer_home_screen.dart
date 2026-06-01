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
                          final apts = allApts.where((a) => !a.isBranchSwap).toList();
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
