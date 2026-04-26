import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/appointment_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/staff_member.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/providers/staff_tasks_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/staff_tasks_panel_decoration.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
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
  StaffMember? _staff;
  AppointmentItem? _appt;
  String? _mirrorSection;
  Set<String> _assignedSections = {};
  bool _loadingSections = false;

  final _mirrorSections = const [
    'Front Windshield',
    'Rear Windshield',
    'Left Side',
    'Right Side',
  ];

  String _sectionKeyFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'front windshield':
        return 'frontWindshield';
      case 'rear windshield':
        return 'rearWindshield';
      case 'left side':
        return 'leftSide';
      case 'right side':
        return 'rightSide';
      default:
        return ''; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StaffTasksProvider>();

    debugPrint('Staff: $_staff');
    debugPrint('Appointment: $_appt');
    debugPrint('Mirror Section: $_mirrorSection');

    return Container(
      decoration: staffTasksPanelDecoration(),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow('Assign New Task', BootstrapIcons.plus_circle_fill),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 900;
              return isWide
                  ? _wideRow(p.staff, p.appointments, p.isAssigning)
                  : _narrowColumn(p.staff, p.appointments, p.isAssigning);
            },
          ),
        ],
      ),
    );
  }

  Widget _wideRow(
    List<StaffMember> staff,
    List<AppointmentItem> appts,
    bool isAssigning,
  ) {
    return Row(
      children: [
        Expanded(child: _staffDropdown(staff)),
        const SizedBox(width: 14),
        Expanded(child: _appointmentDropdown(appts)),
        const SizedBox(width: 14),
        Expanded(child: _mirrorDropdown()),
        const SizedBox(width: 14),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: (!_canAssign() || isAssigning) ? null : _assign,
            icon: isAssigning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(BootstrapIcons.send_fill),
            label: const Text(
              'Assign Task',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowColumn(
    List<StaffMember> staff,
    List<AppointmentItem> appts,
    bool isAssigning,
  ) {
    return Column(
      children: [
        _staffDropdown(staff),
        const SizedBox(height: 14),
        _appointmentDropdown(appts),
        const SizedBox(height: 14),
        _mirrorDropdown(),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: (!_canAssign() || isAssigning) ? null : _assign,
            icon: isAssigning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(BootstrapIcons.send_fill),
            label: const Text(
              'Assign Task',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  bool _canAssign() => _staff != null && _appt != null && _mirrorSection != null;

  Future<void> _assign() async {
  if (_staff == null || _appt == null || _mirrorSection == null) {
      widget.onError('Please ensure you select staff, appointment, and mirror section.');
      return;
    }

    final staff = _staff!;
    final appt = _appt!;
    final mirror = _mirrorSection!;

    debugPrint('Selected Staff: ${staff.name}');
    debugPrint('Selected Appointment: ${appt.compactLabel}');
    debugPrint('Selected Mirror Section: $mirror');

    final sectionKey = _sectionKeyFromLabel(mirror);
    if (sectionKey.isEmpty) {
      widget.onError('Invalid mirror section selected.');
      return;
    }

    debugPrint('Section Key: $sectionKey');

    final darknessCode = mapVLTtoCode(appt.tintSelections[sectionKey] ?? '', appt.packageType);

    debugPrint('Darkness Code: $darknessCode');

    // Assign task via provider
    try{
      final err = await context.read<StaffTasksProvider>().assign(
          branchID: widget.branchID,
          createdByManagerUid: widget.managerUid,
          staffMember: staff,
          appointment: appt,
          mirrorSection: mirror,
          darknessCode: darknessCode,
      );

    if (!mounted) return;

    if (err == null) {
      widget.onSuccess('Task assigned to ${staff.name}.');
      setState(() {
        _staff = null;
        _appt = null;
        _mirrorSection = null;
        _assignedSections = {};
        _loadingSections = false;
      });
    } else {
      widget.onError(err); 
      }
    } catch (e) {
    widget.onError('An unexpected error occurred.'); // Catch potential runtime errors
    debugPrint('Error in _assign: $e');
  }
}

  Widget _titleRow(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Choose staff, appointment and mirror section',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _staffDropdown(List<StaffMember> staff) {
    return MenuDropdown<StaffMember>(
      label: 'Select Staff Member',
      icon: BootstrapIcons.person_fill,
      hint: staff.isEmpty ? 'No staff available' : 'Choose staff',
      value: _staff,
      enabled: staff.isNotEmpty, // Disable if no staff available
      showItemLeading: false,
      items: staff.map((s) {
        final availability = s.isAvailable ? 'Available' : 'Busy';
        return MenuItem<StaffMember>(
          value: s,
          label: '${s.name} • $availability • ${s.currentTaskCount} tasks',
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: Icon(
              s.isAvailable ? BootstrapIcons.check2_circle : BootstrapIcons.slash_circle,
              color: const Color(0xFFFFD700),
              size: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _staff = v),
    );
  }

  Widget _appointmentDropdown(List<AppointmentItem> appts) {
    return MenuDropdown<AppointmentItem>(
      label: 'Select Appointment',
      icon: BootstrapIcons.calendar_check_fill,
      hint: appts.isEmpty ? 'No appointments available' : 'Plate • Package • Date Time',
      value: _appt,
      enabled: appts.isNotEmpty, // Disable if no appointments available
      showItemLeading: false,
      items: appts.map((a) {
        return MenuItem<AppointmentItem>(
          value: a,
          label: a.compactLabel, // plate • package • date time
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: const Icon(
              BootstrapIcons.car_front_fill,
              color: Color(0xFFFFD700),
              size: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: (v) async {
        setState(() {
          _appt = v;
          _mirrorSection = null;
          _assignedSections = {};
          _loadingSections = v != null;
        });

        if (v == null) return;

        // Fetch assigned sections for the selected appointment
        final assigned = await context
            .read<StaffTasksProvider>()
            .getAssignedSectionsForAppointment(v.id);

        if (!mounted) return;
        setState(() {
          _assignedSections = assigned;
          _loadingSections = false;
        });
      },
    );
  }

  Widget _mirrorDropdown() {
    final available = _appt != null
        ? _mirrorSections.where((s) => !_assignedSections.contains(s)).toList()
        : [];

    return MenuDropdown<String>(
      label: 'Select Mirror Section',
      icon: BootstrapIcons.grid_3x3_gap_fill,
      hint: _appt == null
          ? 'Select appointment first'
          : (_loadingSections
              ? 'Loading...'
              : (available.isEmpty ? 'All sections assigned' : 'Choose section')),
      value: _mirrorSection,
      enabled: _appt != null && !_loadingSections && available.isNotEmpty,
      showItemLeading: false,
      items: available.map((m) {
        String darknessCode = 'N/A'; 
        if (_appt != null) {
          final sectionKey = _sectionKeyFromLabel(m);
          if (sectionKey.isNotEmpty && _appt!.tintSelections.containsKey(sectionKey)) {
            darknessCode = mapVLTtoCode(
              _appt!.tintSelections[sectionKey] ?? '',
              _appt!.packageType,
            );
          }
        }

        return MenuItem<String>(
          value: m,
          label: '$m: $darknessCode', 
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: const Icon(
              BootstrapIcons.grid_3x3_gap_fill,
              color: Color(0xFFFFD700),
              size: 14,
            ),
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _mirrorSection = v),
    ); 
  }
}