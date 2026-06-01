import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/providers/staff_tasks_provider.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;

  const TaskCard({super.key, required this.task});

  Color _getstatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'IN_PROGRESS':
      case 'IN-PROGRESS':
        return const Color(0xFF2196F3);
      case 'PENDING':
        return const Color(0xFFFFC107);
      case 'CANCELLED':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

@override
  Widget build(BuildContext context) {
    final sc = _getstatusColor(task.status);
    final isCompleted = task.status.toUpperCase() == 'COMPLETED';
    final String cName = task.customerName ?? '';
    final String aTitle = task.appointmentTitle ?? '';
    final String pNum = task.plateNumber ?? '';
    final String cBrand = task.carBrand ?? '';
    final String cModel = task.carModel ?? '';
    final String cInfo = task.carInfo ?? '';
    final String pkgName = task.packageName ?? '';
    final List<String> darknessList = (task.darkness ?? '').split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toList();

    final List<String> mappedDarkness = [];
    for (int i = 0; i < task.mirrorSections.length; i++) {
      final sectionLabel = task.mirrorSections[i];
      final sectionKey = TintSections.keyByLabel[sectionLabel] ?? sectionLabel.toLowerCase();
      final rawVal = i < darknessList.length ? darknessList[i] : '';
      
      if (rawVal.isNotEmpty) {
        mappedDarkness.add(mapVLTtoCode(rawVal, task.packageName ?? '', sectionKey: sectionKey));
      }
    }
    final customerName = cName.isNotEmpty 
        ? cName 
        : (aTitle.isNotEmpty ? aTitle : 'Appointment');
    final carLine = (cBrand.isNotEmpty && cModel.isNotEmpty)
        ? '$cBrand $cModel'
        : (cInfo.isNotEmpty ? cInfo : '-');
    final carInfoLine = [
      if (pkgName.isNotEmpty) pkgName,
      if (pNum.isNotEmpty) pNum,
      if (carLine != '-' && carLine.isNotEmpty) carLine,
    ].join(' • ');

    final sectionsDisplay = 'Section: ${task.mirrorSections.join(", ")}';
    final darknessDisplay = 'Darkness: ${mappedDarkness.isEmpty ? "-" : mappedDarkness.join(", ")}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5), width: 1.5),
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
                  sectionsDisplay,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  darknessDisplay,
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
                  color: sc.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: sc.withValues(alpha: 0.35)),
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
              
              const SizedBox(height: 12),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompleted)
                    IconButton(
                      onPressed: () => _handleComplete(context),
                      icon: const Icon(BootstrapIcons.check_circle_fill, color: Colors.green, size: 20),
                      tooltip: 'Mark as Completed',
                    ),
                  
                  IconButton(
                    onPressed: () => _handleDelete(context),
                    icon: const Icon(BootstrapIcons.trash3_fill, color: Color(0xFFF44336), size: 20),
                    tooltip: 'Remove Task',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleComplete(BuildContext context) {
    if (task.id.isEmpty || task.staffID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing Task or Staff ID')),
      );
      return;
    }
    context.read<StaffTasksProvider>().completeTask(
      task.id,
      task.staffID,
      task.appointmentID,
    );
  }

  void _handleDelete(BuildContext context) {
    if (task.id.isEmpty || task.staffID.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing Task or Staff ID')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.15)),
        ),
        title: const Text('Delete Task', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure?\n\n• Staff workload will be decremented.\n• Appointment will revert to Confirmed so it can be reassigned.',
          style: TextStyle(color: Colors.grey, height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<StaffTasksProvider>().deleteTask(
                task.id,
                task.staffID,
                task.appointmentID,
              );
              Navigator.pop(context);
            }, 
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}
