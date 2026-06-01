import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/appointment_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/staff_member.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/providers/staff_tasks_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/staff_tasks_panel_decoration.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/assign_task_widgets.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';

class AssignTaskPanel extends StatefulWidget {
  final String branchID;
  final String managerUid;
  final void Function(String message) onSuccess;
  final void Function(String message) onError;
  
  const AssignTaskPanel({
    super.key,
    required this.branchID,
    required this.managerUid,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<AssignTaskPanel> createState() => _AssignTaskPanelState();
}

class _AssignTaskPanelState extends State<AssignTaskPanel> {
  AppointmentItem? _appt;
  StaffMember? _staff;
  List<String> _selectedSections = [];
  
  final List<PendingDistribution> _distributions = [];
  Set<String> _assignedSections = {};
  bool _loadingSections = false;

  final _mirrorSections = const [
    'Front Windscreen',
    'Front Side Windows',
    'Rear Passenger',
    'Rear Windscreen',
  ];

  int? _parseTimeToMinutes(String timeStr) {
    try {
      final t = timeStr.trim().toUpperCase();
      // Handle standard 12-hour formats like "10:30 AM" or "02:00 PM"
      final ampmRegex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$');
      final ampmMatch = ampmRegex.firstMatch(t);
      if (ampmMatch != null) {
        var hour = int.parse(ampmMatch.group(1)!);
        final min = int.parse(ampmMatch.group(2)!);
        final ap = ampmMatch.group(3)!;
        if (ap == 'PM' && hour != 12) hour += 12;
        if (ap == 'AM' && hour == 12) hour = 0;
        return hour * 60 + min;
      }

      // Handle 24-hour formats like "14:30" or "09:00"
      final militaryRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
      final militaryMatch = militaryRegex.firstMatch(t);
      if (militaryMatch != null) {
        final hour = int.parse(militaryMatch.group(1)!);
        final min = int.parse(militaryMatch.group(2)!);
        return hour * 60 + min;
      }
    } catch (e) {
      print('Error parsing time string $timeStr: $e');
    }
    return null;
  }

  bool _hasOverlappingTask(StaffMember s, AppointmentItem currentAppt, List<TaskItem> activeTasks) {
    final apptStartMin = _parseTimeToMinutes(currentAppt.appointmentTime);
    if (apptStartMin == null) return false;
    
    final apptDuration = currentAppt.estimatedDuration;
    final apptEndMin = apptStartMin + apptDuration;

    for (final task in activeTasks) {
      if (task.staffID != s.id) continue;
      if (task.appointmentID == currentAppt.id) continue;
      
      final status = task.status.toUpperCase();
      if (status == 'CANCELLED' || status == 'COMPLETED' || status == 'COMPLETE') continue;

      final taskDateStr = task.appointmentDate ?? (task.createdAt != null ? DateFormat('yyyy-MM-dd').format(task.createdAt!) : '');
      if (taskDateStr != currentAppt.appointmentDate) continue;

      int? taskStartMin;
      int taskDuration = 120; // Default 2 hours

      if (task.appointmentTime != null) {
        taskStartMin = _parseTimeToMinutes(task.appointmentTime!);
        taskDuration = task.estimatedDuration ?? 120;
      } else if (task.createdAt != null) {
        taskStartMin = task.createdAt!.hour * 60 + task.createdAt!.minute;
      }

      if (taskStartMin == null) continue;
      final taskEndMin = taskStartMin + taskDuration;

      final startMax = apptStartMin > taskStartMin ? apptStartMin : taskStartMin;
      final endMin = apptEndMin < taskEndMin ? apptEndMin : taskEndMin;

      if (startMax < endMin) {
        return true; 
      }
    }

    return false;
  }

  String _sectionKeyFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'front windscreen':
        return 'frontWindScreen';
      case 'front side windows':
        return 'frontSideWindows';
      case 'rear passenger':
        return 'rearPassenger';
      case 'rear windscreen':
        return 'rearWindscreen';
      default:
        return '';
    }
  }

  void _addDistribution() {
    if (_staff == null || _selectedSections.isEmpty || _appt == null) return;

    final activeTasks = context.read<StaffTasksProvider>().activeTasks;
    if (_hasOverlappingTask(_staff!, _appt!, activeTasks)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[950],
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(BootstrapIcons.exclamation_triangle_fill, color: Colors.red, size: 22),
              SizedBox(width: 10),
              Text('Schedule Conflict', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            '${_staff!.name} is already assigned to another active task during this time slot on ${_appt!.appointmentDate}.\n\nPlease select another staff member or adjust the schedule.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    List<String> darknessList = [];
    for (var section in _selectedSections) {
      final key = _sectionKeyFromLabel(section);
      String vltValue = (_appt!.tintSelections[key] ?? '').trim();
      final code = mapVLTtoCode(vltValue, _appt!.packageName, sectionKey: key);
      darknessList.add(code);
    }

    setState(() {
      _distributions.add(PendingDistribution(
        staff: _staff!,
        sections: List.from(_selectedSections),
        darknessCodes: darknessList,
      ));
      _selectedSections = [];
      _staff = null;
    });
  }

  Future<void> _submitAll() async {
    if (_distributions.isEmpty || _appt == null) return;

    try {
      for (final d in _distributions) {
        final combinedSections = d.sections.join(', ');
        final combinedDarkness = d.darknessCodes.join(', ');

        await context.read<StaffTasksProvider>().assign(
          branchID: widget.branchID,
          createdByManagerUid: widget.managerUid,
          staffMember: d.staff,
          appointment: _appt!,
          mirrorSection: combinedSections,
          darknessCode: combinedDarkness,
        );
      }

      widget.onSuccess('All tasks successfully distributed!');
      _resetSelection();
    } catch (e) {
      widget.onError('Error during assignment: $e');
    }
  }

  void _resetSelection() {
    setState(() {
      _staff = null;
      _appt = null;
      _selectedSections = [];
      _distributions.clear();
      _assignedSections = {};
    });
  }

  Widget _titleRow(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StaffTasksProvider>();

    return Container(
      decoration: staffTasksPanelDecoration(),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow('Assign Task Workflow', BootstrapIcons.plus_circle_fill),
          const SizedBox(height: 24),

          StreamBuilder<List<StaffMember>>(
            stream: p.staffStream,
            builder: (context, snapshot) {
              final staffList = snapshot.data ?? p.staff;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AssignTaskAppointmentDropdown(
                    appts: p.appointments,
                    selectedAppt: _appt,
                    onChanged: (v) async {
                      setState(() {
                        _appt = v;
                        _selectedSections = [];
                        _distributions.clear();
                        _assignedSections = {};
                        _loadingSections = v != null;
                      });

                      if (v == null) return;

                      final assigned = await context
                          .read<StaffTasksProvider>()
                          .getAssignedSectionsForAppointment(v.id);

                      if (!mounted) return;
                      setState(() {
                        _assignedSections = assigned;
                        _loadingSections = false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  if (_appt != null) ...[
                    const Divider(color: Color(0xFFFFD700), thickness: 1, height: 40),
                    
                    LayoutBuilder(
                      builder: (context, c) {
                        final isWide = c.maxWidth >= 900;
                        final activeTasks = context.read<StaffTasksProvider>().activeTasks;
                        
                        final staffDropdown = AssignTaskStaffDropdown(
                          staff: staffList,
                          selectedStaff: _staff,
                          appt: _appt,
                          hasOverlappingTask: (s, appt) => _hasOverlappingTask(s, appt, activeTasks),
                          onChanged: (v) => setState(() => _staff = v),
                        );

                        final mirrorSelector = AssignTaskMirrorSelector(
                          appt: _appt,
                          mirrorSections: _mirrorSections,
                          assignedSections: _assignedSections,
                          distributions: _distributions,
                          selectedSections: _selectedSections,
                          loadingSections: _loadingSections,
                          sectionKeyFromLabel: _sectionKeyFromLabel,
                          onToggleSection: (label) {
                            setState(() {
                              _selectedSections.contains(label)
                                  ? _selectedSections.remove(label)
                                  : _selectedSections.add(label);
                            });
                          },
                        );

                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 4, child: staffDropdown),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 6, child: mirrorSelector),
                                ],
                              )
                            : Column(
                                children: [
                                  staffDropdown,
                                  const SizedBox(height: 20),
                                  mirrorSelector,
                                ],
                              );
                      },
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: (_staff == null || _selectedSections.isEmpty) ? null : _addDistribution,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          foregroundColor: const Color(0xFFFFD700),
                          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        icon: const Icon(BootstrapIcons.plus_circle),
                        label: const Text('Add to Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),

                    if (_distributions.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      AssignTaskDistributionList(
                        distributions: _distributions,
                        onRemove: (idx) => setState(() => _distributions.removeAt(idx)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: p.isAssigning ? null : _submitAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: p.isAssigning 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : const Icon(BootstrapIcons.send_check_fill),
                          label: Text(
                            'Assign All Tasks (${_distributions.length})',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
