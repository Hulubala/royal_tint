import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/data/repositories/staff_repository.dart';
import 'package:royal_tint/data/repositories/staff_task_repository.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/models/staff_task_model.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_header.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  final _staffRepo = StaffRepository();
  final _taskRepo  = StaffTaskRepository();

  // ── Colours ──────────────────────────────────────────────────────────────────
  static const _bg      = Colors.white;
  static const _surface = Colors.black;
  static const _gold    = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final hour   = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // ── Header Section (Boxed) ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: StaffHeader(title: 'Home', showStaffInfo: true),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Today's Schedule Section (Boxed) ───────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centered content
                  children: [
                    _SectionHeader(
                      icon: Icons.calendar_today_rounded,
                      title: "Today's Schedule",
                      subtitle: _todayLabel(now),
                    ),
                    const SizedBox(height: 24),
                    StreamBuilder<List<StaffTaskModel>>(
                      stream: _taskRepo.watchTodayTasksForCurrentStaff(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return _ErrorTile(message: snap.error.toString());
                        }
                        if (!snap.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: _gold),
                            ),
                          );
                        }

                        final tasks = snap.data!;
                        if (tasks.isEmpty) {
                          return const _EmptyState(
                            icon: Icons.sentiment_satisfied_alt_rounded,
                            message: 'No tasks scheduled for today.\nYou\'re all caught up!',
                          );
                        }

                        return Column(
                          children: tasks
                              .map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _TodayTaskCard(task: t),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  String _todayLabel(DateTime now) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

// ── Quick action card ─────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1400),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: _gold.withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centered Row
      children: [
        Icon(icon, color: _gold, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centered Column
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _gold,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Today task compact card ───────────────────────────────────────────────────
class _TodayTaskCard extends StatelessWidget {
  final StaffTaskModel task;
  const _TodayTaskCard({required this.task});

  static const _gold = Color(0xFFFFD700);
  static const _card = Colors.black;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task.status);
    final statusLabel = _statusLabel(task.status);

    return GestureDetector(
      onTap: () => context.push('/staff/tasks/${task.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Status strip
              Container(
                width: 6,
                height: 100,
                color: statusColor,
              ),
              // Car icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded, color: _gold, size: 24),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${task.carBrand} ${task.carModel}',
                        style: const TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Status chip
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':     return const Color(0xFFFFB300); // Amber/Deep Gold for Pending
      case 'IN_PROGRESS': 
      case 'IN-PROGRESS': return const Color(0xFF2196F3); // Blue for In Progress
      case 'COMPLETED':   return const Color(0xFF4CAF50); // Green for Completed
      default:            return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':     return 'Pending';
      case 'IN_PROGRESS': return 'In Progress';
      case 'COMPLETED':   return 'Completed';
      default:            return status;
    }
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252525)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[700], size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error tile ────────────────────────────────────────────────────────────────
class _ErrorTile extends StatelessWidget {
  final String message;
  const _ErrorTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
