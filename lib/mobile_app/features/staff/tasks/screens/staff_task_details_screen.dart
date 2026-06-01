import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/data/repositories/staff_repository.dart';
import 'package:royal_tint/data/repositories/staff_task_repository.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/models/staff_task_model.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_header.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/widgets/staff_task_details_widgets.dart';

class StaffTaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const StaffTaskDetailsScreen({super.key, required this.taskId});

  @override
  State<StaffTaskDetailsScreen> createState() => _StaffTaskDetailsScreenState();
}

class _StaffTaskDetailsScreenState extends State<StaffTaskDetailsScreen> {
  final _taskRepo  = StaffTaskRepository();
  final _staffRepo = StaffRepository();

  bool _loading = false;

  Future<void> _handleStartTask(StaffTaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        title: 'Start Task?',
        message:
            'This will change the task and appointment status to In Progress.',
        confirmLabel: 'Start',
        confirmColor: Color(0xFF2196F3),
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await _taskRepo.startTask(task.id, task.appointmentID);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task started! Status changed to In Progress.'),
          backgroundColor: Color(0xFF2196F3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleCompleteTask(StaffTaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        title: 'Complete Task?',
        message: 'This will mark the task and appointment as Completed.',
        confirmLabel: 'Complete',
        confirmColor: Color(0xFF4CAF50),
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final staff = await _staffRepo.getCurrentStaff();
      await _taskRepo.completeTask(task.id, task.appointmentID, staff.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task completed! Great work.'),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          StaffHeader(
            title: 'Task Details',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: StreamBuilder<StaffTaskModel?>(
              stream: _taskRepo.watchTaskById(widget.taskId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: gold));
                }

                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error loading task:\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final task = snap.data;

                if (task == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt_rounded, color: Colors.grey[600], size: 52),
                        const SizedBox(height: 14),
                        Text(
                          'Task not found.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded, color: gold),
                          label: const Text('Go Back',
                              style: TextStyle(color: gold)),
                        ),
                      ],
                    ),
                  );
                }

                return _buildBody(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(StaffTaskModel task) {
    final sections = task.mirrorSection
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final List<String> rawDarkness = task.darkness.split(',').map((d) => d.trim()).toList();
    
    // Map of label -> darkness code
    final Map<String, String> sectionData = {};
    for (int i = 0; i < sections.length; i++) {
      final label = sections[i];
      final key = TintSections.keyByLabel[label] ?? label.toLowerCase();
      final val = i < rawDarkness.length ? rawDarkness[i] : '';
      
      if (val.isEmpty || val == '—') {
        sectionData[label] = '—';
      } else {
        sectionData[label] = mapVLTtoCode(val, task.packageName, sectionKey: key);
      }
    }

    // Sort sections based on preferred order: Front Windscreen, Front Side Windows, Rear Passenger, Rear Windscreen
    final orderedLabels = [
      'Front Windscreen',
      'Front Side Windows',
      'Rear Passenger',
      'Rear Windscreen',
    ];
    
    final sortedSections = orderedLabels.where((l) => sectionData.containsKey(l)).toList();
    // Add any remaining sections that were not in orderedLabels
    for (final s in sections) {
      if (!orderedLabels.contains(s)) sortedSections.add(s);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskStatusBanner(status: task.status),
          const SizedBox(height: 24),

          // ── Vehicle info card (Boxed) ─────────────────────────────────────
          SectionCard(
            icon: Icons.directions_car_rounded,
            title: 'Vehicle Details',
            child: Column(
              children: [
                DetailRow(label: 'Brand',    value: task.carBrand),
                DetailRow(label: 'Model',    value: task.carModel),
                DetailRow(label: 'Plate',    value: task.plateNumber),
                DetailRow(label: 'Customer', value: task.customerName),
                DetailRow(label: 'Package',  value: task.packageName),
              ],
            ),
          ),

          const SizedBox(height: 24),

          MirrorSectionsCard(
            sortedSections: sortedSections,
            sectionData: sectionData,
          ),

          const SizedBox(height: 32),

          // ── Action buttons ────────────────────────────────────────────────
          if (task.isPending)
            ActionButton(
              label: 'START TASK',
              icon: Icons.play_arrow_rounded,
              color: const Color(0xFF2196F3),
              loading: _loading,
              onPressed: () => _handleStartTask(task),
            ),

          if (task.isInProgress)
            ActionButton(
              label: 'COMPLETE TASK',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF4CAF50),
              loading: _loading,
              onPressed: () => _handleCompleteTask(task),
            ),

          if (task.isCompleted)
            const TaskCompletedBanner(),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
