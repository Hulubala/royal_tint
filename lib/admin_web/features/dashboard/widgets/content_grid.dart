import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/recent_activities.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/upcoming_appointments.dart';

class ContentGrid extends StatelessWidget {
  const ContentGrid({super.key, required this.managerProvider});
  final ManagerProvider managerProvider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: UpcomingAppointments(managerProvider: managerProvider)),
              const SizedBox(width: 20),
              Expanded(child: RecentActivities(managerProvider: managerProvider)),
            ],
          );
        }

        return Column(
          children: [
            UpcomingAppointments(managerProvider: managerProvider),
            const SizedBox(height: 20),
            RecentActivities(managerProvider: managerProvider),
          ],
        );
      },
    );
  }
}