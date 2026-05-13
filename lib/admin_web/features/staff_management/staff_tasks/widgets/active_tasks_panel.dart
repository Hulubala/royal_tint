import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/providers/staff_tasks_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/staff_tasks_panel_decoration.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/consolidated_task_card.dart';

class ActiveTasksPanel extends StatelessWidget {
  const ActiveTasksPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = context.watch<StaffTasksProvider>().activeTasksStream;

    return Container(
      decoration: staffTasksPanelDecoration(),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow(),
          const SizedBox(height: 18),

          // Handle the loading state
          if (stream == null)
            Text(
              'Loading tasks...',
              style: TextStyle(color: Colors.grey[400]),
            )
          else
            StreamBuilder<List<TaskItem>>(
              stream: stream, // Use the stream to retrieve active tasks
              builder: (context, snapshot) {
                // Handle stream errors
                if (snapshot.hasError) {
                  return Text(
                    'Failed to load tasks: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[300]),
                  );
                }

                // While the stream is loading, show a progress indicator
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!;
                if (tasks.isEmpty) {
                  return Text(
                    'No active tasks yet.',
                    style: TextStyle(color: Colors.grey[400]),
                  );
                }

                // 📦 GROUP TASKS BY APPOINTMENT ID
                final Map<String, List<TaskItem>> grouped = {};
                for (var t in tasks) {
                  grouped.putIfAbsent(t.appointmentID, () => []).add(t);
                }

                // Render a list of ConsolidatedTaskCards
                return Column(
                  children: grouped.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ConsolidatedTaskCard(
                        appointmentID: entry.key,
                        tasks: entry.value,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  // The title of the Active Tasks Panel
  Widget _titleRow() {
    return Row(
      children: [
        const Icon(
          BootstrapIcons.list_task,
          color: Color(0xFFFFD700),
          size: 18,
        ),
        const SizedBox(width: 10),
        const Text(
          'Active Tasks',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Track task progress assigned to staff',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}