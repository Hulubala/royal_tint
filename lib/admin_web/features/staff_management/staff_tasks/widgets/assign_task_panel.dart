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

class _PendingDistribution {
  final StaffMember staff;
  final List<String> sections;
  final List<String> darknessCodes;

  _PendingDistribution({
    required this.staff,
    required this.sections,
    required this.darknessCodes,
  });
}

class _AssignTaskPanelState extends State<AssignTaskPanel> {
  AppointmentItem? _appt;
  StaffMember? _staff;
  List<String> _selectedSections = [];
  
  final List<_PendingDistribution> _distributions = [];
  Set<String> _assignedSections = {};
  bool _loadingSections = false;

  final _mirrorSections = const [
    'Front Windscreen',
    'Front Side Windows',
    'Rear Passenger',
    'Rear Windscreen',
  ];

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
                  // Step 1: Select Appointment
                  _appointmentDropdown(p.appointments),
                  const SizedBox(height: 20),

                  if (_appt != null) ...[
                    const Divider(color: Color(0xFFFFD700), thickness: 1, height: 40),
                    
                    LayoutBuilder(
                      builder: (context, c) {
                        final isWide = c.maxWidth >= 900;
                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 4, child: _staffDropdown(staffList)),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 6, child: _mirrorSelector()),
                                ],
                              )
                            : Column(
                                children: [
                                  _staffDropdown(staffList),
                                  const SizedBox(height: 20),
                                  _mirrorSelector(),
                                ],
                              );
                      },
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: (_staff == null || _selectedSections.isEmpty) ? null : _addDistribution,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700).withOpacity(0.15),
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
                      _distributionsList(),
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

  void _addDistribution() {
    if (_staff == null || _selectedSections.isEmpty || _appt == null) return;

    List<String> darknessList = [];
    for (var section in _selectedSections) {
      final key = _sectionKeyFromLabel(section);
      String vltValue = (_appt!.tintSelections[key] ?? '').trim();
      final code = mapVLTtoCode(vltValue, _appt!.packageName, sectionKey: key);
      darknessList.add(code);
    }

    setState(() {
      _distributions.add(_PendingDistribution(
        staff: _staff!,
        sections: List.from(_selectedSections),
        darknessCodes: darknessList,
      ));
      _selectedSections = [];
      _staff = null;
    });
  }

  Widget _distributionsList() {
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
        ..._distributions.asMap().entries.map((entry) {
          final idx = entry.key;
          final d = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
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
                  onPressed: () => setState(() => _distributions.removeAt(idx)),
                  icon: const Icon(BootstrapIcons.trash, color: Colors.red, size: 18),
                ),
              ],
            ),
          );
        }),
      ],
    );
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

  Widget _staffDropdown(List<StaffMember> staff) {
    return MenuDropdown<StaffMember>(
      label: 'Select Staff Member',
      icon: BootstrapIcons.person_fill,
      hint: 'Choose staff for these sections',
      value: _staff,
      enabled: staff.isNotEmpty,
      showItemLeading: false,
      items: staff.map((s) {
        final availability = s.isAvailable ? 'Available' : 'Busy';
        return MenuItem<StaffMember>(
          value: s,
          label: '${s.name} • $availability • ${s.currentTaskCount} active tasks',
          leading: Icon(
            s.isAvailable ? BootstrapIcons.check2_circle : BootstrapIcons.slash_circle,
            color: const Color(0xFFFFD700),
            size: 16,
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _staff = v),
    );
  }

  Widget _appointmentDropdown(List<AppointmentItem> appts) {
    return MenuDropdown<AppointmentItem>(
      label: 'STEP 1: Select Appointment',
      icon: BootstrapIcons.calendar_check_fill,
      hint: appts.isEmpty ? 'No appointments for today' : 'Select appointment to distribute tasks',
      value: _appt,
      enabled: appts.isNotEmpty, 
      showItemLeading: false,
      items: appts.map((a) {
        return MenuItem<AppointmentItem>(
          value: a,
          label: a.compactLabel,
          leading: const Icon(BootstrapIcons.car_front_fill, color: Color(0xFFFFD700), size: 16),
        );
      }).toList(),
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
    );
  }

  Widget _mirrorSelector() {
    // Current already distributed sections in this UI session
    final distributedInSession = _distributions.expand((d) => d.sections).toSet();
    
    final available = _appt != null
        ? _mirrorSections.where((s) => !_assignedSections.contains(s) && !distributedInSession.contains(s)).toList()
        : <String>[];

    Widget buildChip(String label) {
      if (!available.contains(label)) return const SizedBox.shrink();

      final isSelected = _selectedSections.contains(label);
      String darknessCode = 'N/A';

      if (_appt != null) {
        final key = _sectionKeyFromLabel(label);
        String vltValue = _appt!.tintSelections[key] ?? '';
        darknessCode = mapVLTtoCode(vltValue, _appt!.packageName, sectionKey: key);
      }

      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              isSelected
                  ? _selectedSections.remove(label)
                  : _selectedSections.add(label);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : const Color(0xFFFFD700).withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? const Color(0xFFFFD700).withOpacity(0.12)
                  : Colors.black.withOpacity(0.3),
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
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
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
            if (_loadingSections) ...[
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
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
          ),
          child: _appt == null
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