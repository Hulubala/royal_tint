import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/data/repositories/staff_task_repository.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/models/staff_task_model.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_header.dart';

class StaffTaskListScreen extends StatefulWidget {
  const StaffTaskListScreen({super.key});

  @override
  State<StaffTaskListScreen> createState() => _StaffTaskListScreenState();
}

class _StaffTaskListScreenState extends State<StaffTaskListScreen> {
  final _repo = StaffTaskRepository();

  // ── Colours ──────────────────────────────────────────────────────────────────
  static const _bg      = Colors.white;
  static const _surface = Colors.black;
  static const _gold    = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          const StaffHeader(title: 'Assigned Tasks'),
          Expanded(
            child: StreamBuilder<List<StaffTaskModel>>(
              stream: _repo.watchUpcomingTasksForCurrentStaff(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return _centeredMessage(
                    icon: Icons.error_outline_rounded,
                    message: 'Failed to load tasks:\n${snap.error}',
                    color: Colors.red[400]!,
                  );
                }
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: _gold),
                  );
                }

                final tasks = snap.data!;
                if (tasks.isEmpty) {
                  return _centeredMessage(
                    icon: Icons.assignment_turned_in_rounded,
                    message: 'No active tasks assigned.',
                    color: Colors.grey[400]!,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _TaskCard(task: tasks[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _centeredMessage({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Task card ─────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final StaffTaskModel task;
  const _TaskCard({required this.task});

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header strip
              Container(
                height: 5,
                color: statusColor,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _gold.withOpacity(0.5), width: 1.5),
                      ),
                      child: const Icon(Icons.directions_car_filled_rounded, color: _gold, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${task.carBrand} ${task.carModel}',
                            style: const TextStyle(
                              color: _gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${task.plateNumber.isEmpty ? '—' : task.plateNumber} • ${task.packageName}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    _StatusBadge(label: statusLabel, color: statusColor),
                    const Spacer(),
                    Text('View Details', style: TextStyle(color: _gold.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: _gold.withOpacity(0.7), size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':     return const Color(0xFFFFC107);
      case 'IN_PROGRESS': return const Color(0xFF2196F3);
      case 'COMPLETED':   return const Color(0xFF4CAF50);
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

// ── Small reusable status badge ───────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
