import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/relative_time.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/section_container.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key, required this.managerProvider});
  final ManagerProvider managerProvider;

  @override
  Widget build(BuildContext context) {
    // Build a small activity list derived from appointments
    final apts = managerProvider.appointments;
    final activities = apts.take(4).map((apt) {
      // IMPORTANT: apt.appointmentDate type depends on your model.
      // If your model has `DateTime appointmentDate`, this works.
      // If it’s Timestamp, convert in model first.
      final DateTime? dt = (apt.appointmentDate is DateTime) ? apt.appointmentDate as DateTime : null;

      return _Activity(
        icon: BootstrapIcons.calendar_check_fill,
        iconGradient: const [Color(0xFF2196F3), Color(0xFF1976D2)],
        title: '${apt.customerName} booked an appointment',
        subtitle: '${apt.packageName} • ${apt.vehicleDisplay}',
        time: formatRelativeTime(apt.createdAt),
      );
    }).toList();

    return SectionContainer(
      title: 'Recent Activities',
      icon: BootstrapIcons.activity,
      child: _Body(activities: activities),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.activities});
  final List<_Activity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(BootstrapIcons.clock_history, color: Colors.grey[400], size: 48),
            const SizedBox(height: 12),
            Text('No recent activities', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.25), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: activity.iconGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(activity.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.subtitle,
                      style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                activity.time,
                style: TextStyle(
                  color: const Color(0xFFFFD700).withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Activity {
  _Activity({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;
  final String time;
}