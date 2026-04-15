import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/section_container.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/status_color.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';

class UpcomingAppointments extends StatelessWidget {
  const UpcomingAppointments({super.key, required this.managerProvider});
  final ManagerProvider managerProvider;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Upcoming Appointments',
      icon: BootstrapIcons.calendar3,
      trailing: GestureDetector(
        onTap: () => context.go('/manager/appointments'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Row(
            children: [
              Text(
                'VIEW ALL',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 4),
              Icon(BootstrapIcons.arrow_right, color: Color(0xFFFFD700), size: 12),
            ],
          ),
        ),
      ),
      child: _Body(appointments: managerProvider.appointments),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.appointments});
  final List <AppointmentModel> appointments; 

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(BootstrapIcons.calendar_x, color: Colors.grey[400], size: 48),
            const SizedBox(height: 12),
            Text('No appointments today', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    final sorted = [...appointments]
      ..sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
    
    final items = sorted.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final apt = items[index]; 

        final statusColor = getStatusColor(apt.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt.customerName,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                     Row(
                      children: [
                        const Icon(BootstrapIcons.box_seam, color: Color(0xFFFFD700), size: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            apt.packageName,
                            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(BootstrapIcons.car_front_fill, color: Color(0xFFFFD700), size: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            apt.vehicleDisplay,
                            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(BootstrapIcons.clock, color: Color(0xFFFFD700), size: 12),
                        const SizedBox(width: 6),
                        Text(
                          apt.appointmentTime,
                          style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Text(
                  apt.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}