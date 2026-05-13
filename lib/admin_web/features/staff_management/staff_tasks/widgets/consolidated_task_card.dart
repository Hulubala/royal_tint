import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/providers/staff_tasks_provider.dart';

class ConsolidatedTaskCard extends StatelessWidget {
  final String appointmentID;
  final List<TaskItem> tasks;

  const ConsolidatedTaskCard({
    super.key,
    required this.appointmentID,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final firstTask = tasks.first;
    
    // Calculate consolidated status
    final bool anyFinalized = tasks.any((t) => t.isFinalized);
    final bool allCompleted = tasks.every((t) => t.status.toLowerCase() == 'completed');
    final bool anyAccepted = tasks.any((t) => t.status.toLowerCase() != 'pending');
    final bool allAccepted = tasks.every((t) => t.status.toLowerCase() != 'pending');

    String consolidatedStatus = 'WAITING STAFF';
    Color statusColor = Colors.amber;
    
    if (anyFinalized) {
      consolidatedStatus = 'FINALIZED';
      statusColor = const Color(0xFFFFD700);
    } else if (allCompleted) {
      consolidatedStatus = 'READY FOR CONFIRMATION';
      statusColor = Colors.green;
    } else if (allAccepted) {
      consolidatedStatus = 'IN-PROGRESS';
      statusColor = Colors.blue;
    } else if (anyAccepted) {
      consolidatedStatus = 'WAITING OTHERS';
      statusColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(consolidatedStatus, statusColor),
          
          // Appointment info row
          _buildAppointmentInfo(firstTask),
          
          const Divider(color: Color(0xFF333333), height: 1),
          
          // Individual tasks list
          ...tasks.map((task) => _buildIndividualTaskRow(context, task, anyFinalized)),

          // Final confirmation button
          if (allCompleted && !anyFinalized)
            _buildFinalizeButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
        border: Border(bottom: BorderSide(color: color.withOpacity(0.3), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(BootstrapIcons.calendar_check, color: Color(0xFFFFD700), size: 16),
              const SizedBox(width: 8),
              const Text(
                'APPOINTMENT TASK',
                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(TaskItem task) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Car icon & info
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
            ),
            child: const Icon(BootstrapIcons.car_front_fill, color: Color(0xFFFFD700), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${task.carBrand} ${task.carModel}',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.plateNumber} • ${task.customerName} • ${task.packageName}',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualTaskRow(BuildContext context, TaskItem task, bool anyFinalized) {
    final bool isCompleted = task.status.toLowerCase() == 'completed';
    final bool isFinalized = task.isFinalized;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      child: Row(
        children: [
          // Staff icon
          CircleAvatar(
            radius: 14,
            backgroundColor: isCompleted ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
            child: Icon(
              isCompleted ? BootstrapIcons.check : BootstrapIcons.person,
              color: isCompleted ? Colors.green : Colors.blue,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          // Staff & Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.staffName,
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                    children: [
                      const TextSpan(text: 'Section: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: task.mirrorSections.join(", ")),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                    children: [
                      const TextSpan(text: 'Darkness: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: task.darkness ?? "—"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Task Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isFinalized ? 'FINALIZED' : task.status.toUpperCase(),
              style: TextStyle(
                color: isFinalized ? const Color(0xFFFFD700) : (isCompleted ? Colors.green : Colors.blue),
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Delete button (Hidden if completed or finalized)
          if (!isCompleted && !anyFinalized)
            IconButton(
              onPressed: () => _handleDeleteTask(context, task),
              icon: const Icon(BootstrapIcons.trash, color: Colors.red, size: 14),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remove Task',
            ),
        ],
      ),
    );
  }

  Widget _buildFinalizeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handleFinalize(context),
          icon: const Icon(BootstrapIcons.check_all, size: 16),
          label: const Text('CONFIRM COMPLETION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  void _handleDeleteTask(BuildContext context, TaskItem task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Remove Task?', style: TextStyle(color: Colors.white)),
        content: Text('Delete task assigned to ${task.staffName}?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<StaffTasksProvider>().deleteTask(task.id, task.staffID, task.appointmentID);
    }
  }

  void _handleFinalize(BuildContext context) async {
    final provider = context.read<StaffTasksProvider>();
    final branchID = context.read<AuthProvider>().branchID;
    
    if (branchID == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Confirm Completion?', style: TextStyle(color: Color(0xFFFFD700))),
        content: const Text(
          'All staff have finished their sections. Do you want to mark the whole appointment as completed?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
            child: const Text('Finalize'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await provider.finalizeAppointment(appointmentID, branchID);
    }
  }
}
