import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/appointment_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/staff_member.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';

class PendingDistribution {
  final StaffMember staff;
  final List<String> sections;
  final List<String> darknessCodes;

  PendingDistribution({
    required this.staff,
    required this.sections,
    required this.darknessCodes,
  });
}

class AssignTaskAppointmentDropdown extends StatelessWidget {
  final List<AppointmentItem> appts;
  final AppointmentItem? selectedAppt;
  final ValueChanged<AppointmentItem?> onChanged;

  const AssignTaskAppointmentDropdown({
    super.key,
    required this.appts,
    required this.selectedAppt,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MenuDropdown<AppointmentItem>(
      label: 'STEP 1: Select Appointment',
      icon: BootstrapIcons.calendar_check_fill,
      hint: appts.isEmpty ? 'No appointments for today' : 'Select appointment to distribute tasks',
      value: selectedAppt,
      enabled: appts.isNotEmpty, 
      showItemLeading: false,
      items: appts.map((a) {
        return MenuItem<AppointmentItem>(
          value: a,
          label: a.compactLabel,
          leading: const Icon(BootstrapIcons.car_front_fill, color: Color(0xFFFFD700), size: 16),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class AssignTaskStaffDropdown extends StatelessWidget {
  final List<StaffMember> staff;
  final StaffMember? selectedStaff;
  final AppointmentItem? appt;
  final bool Function(StaffMember s, AppointmentItem appt) hasOverlappingTask;
  final ValueChanged<StaffMember?> onChanged;

  const AssignTaskStaffDropdown({
    super.key,
    required this.staff,
    required this.selectedStaff,
    required this.appt,
    required this.hasOverlappingTask,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MenuDropdown<StaffMember>(
      label: 'Select Staff Member',
      icon: BootstrapIcons.person_fill,
      hint: 'Choose staff for these sections',
      value: selectedStaff,
      enabled: staff.isNotEmpty,
      showItemLeading: false,
      items: staff.map((s) {
        final hasOverlap = appt != null && hasOverlappingTask(s, appt!);
        final availability = hasOverlap ? 'Busy (Overlapping Task)' : (s.isAvailable ? 'Available' : 'Busy');
        return MenuItem<StaffMember>(
          value: s,
          label: '${s.name} • $availability • ${s.currentTaskCount} active tasks',
          enabled: !hasOverlap,
          leading: Icon(
            hasOverlap ? BootstrapIcons.exclamation_triangle_fill : (s.isAvailable ? BootstrapIcons.check2_circle : BootstrapIcons.slash_circle),
            color: hasOverlap ? Colors.red : const Color(0xFFFFD700),
            size: 16,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class AssignTaskMirrorSelector extends StatelessWidget {
  final AppointmentItem? appt;
  final List<String> mirrorSections;
  final Set<String> assignedSections;
  final List<PendingDistribution> distributions;
  final List<String> selectedSections;
  final bool loadingSections;
  final String Function(String label) sectionKeyFromLabel;
  final void Function(String label) onToggleSection;

  const AssignTaskMirrorSelector({
    super.key,
    required this.appt,
    required this.mirrorSections,
    required this.assignedSections,
    required this.distributions,
    required this.selectedSections,
    required this.loadingSections,
    required this.sectionKeyFromLabel,
    required this.onToggleSection,
  });

  @override
  Widget build(BuildContext context) {
    // Current already distributed sections in this UI session
    final distributedInSession = distributions.expand((d) => d.sections).toSet();
    
    final available = appt != null
        ? mirrorSections.where((s) => !assignedSections.contains(s) && !distributedInSession.contains(s)).toList()
        : <String>[];

    Widget buildChip(String label) {
      if (!available.contains(label)) return const SizedBox.shrink();

      final isSelected = selectedSections.contains(label);
      String darknessCode = 'N/A';

      if (appt != null) {
        final key = sectionKeyFromLabel(label);
        String vltValue = appt!.tintSelections[key] ?? '';
        darknessCode = mapVLTtoCode(vltValue, appt!.packageName, sectionKey: key);
      }

      return Expanded(
        child: GestureDetector(
          onTap: () => onToggleSection(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : const Color(0xFFFFD700).withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFD700) : Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    darknessCode.isEmpty ? '—' : darknessCode,
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(BootstrapIcons.grid_1x2_fill, color: Color(0xFFFFD700), size: 14),
            const SizedBox(width: 8),
            const Text(
              'Select Mirror Sections',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            if (loadingSections) ...[
              const SizedBox(width: 8),
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFFFD700))),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
          ),
          child: appt == null
              ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Select Step 1 first', style: TextStyle(color: Colors.grey[600]))))
              : available.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('All sections distributed', style: TextStyle(color: Colors.grey[600]))))
                  : Column(
                      children: [
                        Row(
                          children: [
                            buildChip('Front Windscreen'),
                            const SizedBox(width: 10),
                            buildChip('Front Side Windows'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            buildChip('Rear Passenger'),
                            const SizedBox(width: 10),
                            buildChip('Rear Windscreen'),
                          ],
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class AssignTaskDistributionList extends StatelessWidget {
  final List<PendingDistribution> distributions;
  final void Function(int index) onRemove;

  const AssignTaskDistributionList({
    super.key,
    required this.distributions,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(BootstrapIcons.list_task, color: Color(0xFFFFD700), size: 16),
            SizedBox(width: 8),
            Text(
              'Pending Work Distribution',
              style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...distributions.asMap().entries.map((entry) {
          final idx = entry.key;
          final d = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFFD700),
                  radius: 12,
                  child: Text('${idx + 1}', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.staff.name, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        d.sections.asMap().entries.map((e) => '${e.value} (${d.darknessCodes[e.key]})').join(', '),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(idx),
                  icon: const Icon(BootstrapIcons.trash, color: Colors.red, size: 18),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
