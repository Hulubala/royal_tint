import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/relative_time.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/section_container.dart';
import 'package:royal_tint/domain/models/task_model.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key, required this.managerProvider});
  final ManagerProvider managerProvider;

  @override
  Widget build(BuildContext context) {
    final rawTasks = managerProvider.tasks;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final activities = rawTasks.where((t) {
      if (t is! TaskModel) return false;
      
      final s = t.status.toUpperCase();
      final isFinalized = t.isFinalized;
      
      // Filter by today only
      final updatedAt = t.updatedAt;
      if (updatedAt.isBefore(todayStart)) return false;

      // Show staff activity: when they start (IN_PROGRESS), complete (COMPLETED), or when finalized
      return s == 'IN_PROGRESS' || s == 'IN-PROGRESS' || s == 'COMPLETED' || isFinalized;
    }).take(8).map((t) {
      final task = t as TaskModel;
      final s = task.status.toUpperCase();
      final isFinalized = task.isFinalized;
      
      IconData icon = BootstrapIcons.play_circle_fill;
      List<Color> gradient = const [Color(0xFF2196F3), Color(0xFF1976D2)]; // Blue for start
      String action = 'accepted';
      
      if (isFinalized) {
        icon = BootstrapIcons.award_fill;
        gradient = const [Color(0xFFFFD700), Color(0xFFB8860B)]; // Gold for finalized
        action = 'finalized';
      } else if (s == 'COMPLETED') {
        icon = BootstrapIcons.check2_circle;
        gradient = const [Color(0xFF4CAF50), Color(0xFF388E3C)]; // Green for completed
        action = 'completed';
      } else if (s == 'CANCELLED') {
        icon = BootstrapIcons.x_circle_fill;
        gradient = const [Color(0xFFF44336), Color(0xFFD32F2F)]; // Red for rejected
        action = 'rejected';
      }

      String title = '${task.assignedStaffName} has $action ${task.carBrand} ${task.carModel} task';
      if (isFinalized) title = 'Task finalized by Manager';

      return _Activity(
        icon: icon,
        iconGradient: gradient,
        title: title,
        subtitle: '${task.plateNumber} • ${task.packageName} • ${task.mirrorSection}',
        time: formatRelativeTime(task.updatedAt),
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
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
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