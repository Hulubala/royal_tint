import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;

  const TaskCard({super.key, required this.task});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0xFF4CAF50);
      case 'confirmed':  
      case 'in-progress':
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Color(0xFFFFC107);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(task.status);

    final customerName = (task.customerName?.isNotEmpty ?? false)
        ? task.customerName!
        : (task.appointmentTitle.isNotEmpty ? task.appointmentTitle : 'Appointment');

    final plate = (task.plateNumber?.isNotEmpty ?? false) ? task.plateNumber! : '';
    final carLine = (task.carBrand != null && task.carModel != null)
        ? '${task.carBrand} ${task.carModel}'
        : (task.carInfo.isNotEmpty ? task.carInfo : '-');

    final packageName = task.packageName ?? '';
    final darkness = (task.darkness ?? '').trim();

    final carInfoLine = [
      if (packageName.isNotEmpty) packageName,
      if (plate.isNotEmpty) plate,
      if (carLine.isNotEmpty) carLine,
    ].join(' • ');

    final sectionLine = darkness.isEmpty
        ? 'Section: ${task.mirrorSection}'
        : 'Section: ${task.mirrorSection} • Darkness: $darkness';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFFFC107), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(BootstrapIcons.car_front_fill, color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        carInfoLine.isEmpty ? '-' : carInfoLine,
                        style: TextStyle(color: Colors.grey[300], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                sectionLine,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Assigned to', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                task.staffName.isEmpty ? '-' : task.staffName,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: sc.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: sc.withOpacity(0.35)),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    color: sc,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}