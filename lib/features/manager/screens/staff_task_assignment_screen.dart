import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';
import 'package:royal_tint/data/models/appointment_model.dart';
import 'package:royal_tint/data/models/staff_model.dart';
import 'package:royal_tint/data/models/task_model.dart';
import 'package:royal_tint/data/repositories/task_repository.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/features/manager/providers/manager_provider.dart';

class StaffTaskAssignmentScreen extends StatefulWidget {
  const StaffTaskAssignmentScreen({super.key});

  @override
  State<StaffTaskAssignmentScreen> createState() =>
      _StaffTaskAssignmentScreenState();
}

class _StaffTaskAssignmentScreenState extends State<StaffTaskAssignmentScreen> {
  final _taskRepository = TaskRepository();

  bool _isLoading = false;
  String? _errorMessage;

  // ── Colours ────────────────────────────────────────────────────────────
  static const _gold = Color(0xFFFFD700);
  static const _darkBg = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final manager = context.read<ManagerProvider>();
    if (auth.branchID == null) return;
    await Future.wait([
      manager.fetchAppointments(auth.branchID!),
      manager.fetchStaff(auth.branchID!),
    ]);
  }

  // ── Assign task dialog ─────────────────────────────────────────────────

  Future<void> _showAssignDialog(AppointmentModel appointment) async {
    final manager = context.read<ManagerProvider>();
    final auth = context.read<AuthProvider>();

    // Only active staff can be assigned tasks
    final activeStaff = manager.staff.where((s) => s.isActive).toList();
    if (activeStaff.isEmpty) {
      _showSnack('No active staff available.', isError: true);
      return;
    }

    StaffModel? selectedStaff;
    String selectedPriority = TaskPriority.medium;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 480,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Colors.black]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFC107)]),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: const Row(
                    children: [
                      Icon(BootstrapIcons.person_check_fill,
                          color: Colors.black, size: 24),
                      SizedBox(width: 12),
                      Text('ASSIGN TASK',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appointment summary
                      _dialogInfoRow('Customer',
                          appointment.customerName),
                      const SizedBox(height: 8),
                      _dialogInfoRow('Vehicle',
                          '${appointment.vehicleBrand} ${appointment.vehicleModel} • ${appointment.vehiclePlate}'),
                      const SizedBox(height: 8),
                      _dialogInfoRow(
                          'Package', appointment.packageName),
                      const SizedBox(height: 8),
                      _dialogInfoRow('Date / Time',
                          '${appointment.appointmentDate}  ${appointment.appointmentTime}'),

                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFF333333)),
                      const SizedBox(height: 16),

                      // Staff dropdown
                      const Text('Assign to Staff',
                          style: TextStyle(
                              color: _gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<StaffModel>(
                        value: selectedStaff,
                        hint: const Text('Select staff member',
                            style: TextStyle(color: Colors.grey)),
                        onChanged: (v) =>
                            setDialogState(() => selectedStaff = v),
                        items: activeStaff.map((staff) {
                          return DropdownMenuItem(
                            value: staff,
                            child: Row(
                              children: [
                                const Icon(BootstrapIcons.person_fill,
                                    color: _gold, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    staff.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: staff.currentTaskCount > 3
                                        ? const Color(0xFFF44336)
                                            .withOpacity(0.2)
                                        : _gold.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                      color: staff.currentTaskCount > 3
                                          ? const Color(0xFFF44336)
                                          : _gold,
                                    ),
                                  ),
                                  child: Text(
                                    '${staff.currentTaskCount} task${staff.currentTaskCount == 1 ? '' : 's'}',
                                    style: TextStyle(
                                      color: staff.currentTaskCount > 3
                                          ? const Color(0xFFF44336)
                                          : _gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        decoration: _dropdownDecoration(),
                        dropdownColor: const Color(0xFF0A0A0A),
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 16),

                      // Priority dropdown
                      const Text('Priority',
                          style: TextStyle(
                              color: _gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        onChanged: (v) =>
                            setDialogState(() => selectedPriority = v!),
                        items: TaskPriority.all
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                ))
                            .toList(),
                        decoration: _dropdownDecoration(),
                        dropdownColor: const Color(0xFF0A0A0A),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CANCEL'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedStaff == null
                              ? null
                              : () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('ASSIGN',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || selectedStaff == null) return;

    await _assignTask(
      appointment: appointment,
      staff: selectedStaff!,
      priority: selectedPriority,
      managerID: auth.uid,
      managerName: auth.name,
    );

    // Refresh staff list to reflect updated task counts
    if (auth.branchID != null) {
      await context.read<ManagerProvider>().fetchStaff(auth.branchID!);
    }
  }

  Future<void> _assignTask({
    required AppointmentModel appointment,
    required StaffModel staff,
    required String priority,
    String? managerID,
    String? managerName,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final task = TaskModel(
        taskID: '',
        branchID: appointment.branchID,
        title:
            '${appointment.packageName} – ${appointment.vehicleBrand} ${appointment.vehicleModel}',
        description:
            'Tint installation for ${appointment.customerName} | ${appointment.vehiclePlate}',
        assignedStaffID: staff.id,
        assignedStaffName: staff.name,
        assignedByManagerID: managerID,
        assignedByManagerName: managerName,
        appointmentID: appointment.appointmentID,
        customerName: appointment.customerName,
        vehicleModel:
            '${appointment.vehicleBrand} ${appointment.vehicleModel}',
        packageName: appointment.packageName,
        status: TaskStatus.pending,
        priority: priority,
        dueDate: DateTime.now().add(const Duration(hours: 8)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _taskRepository.createTask(task);

      _showSnack('Task assigned to ${staff.name}');
    } catch (e) {
      setState(() => _errorMessage = 'Failed to assign task: $e');
      _showSnack('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _gold, width: 2),
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text('$label:',
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
    ));
  }

  // ── Status badge ───────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'in_progress':
        return const Color(0xFF2196F3);
      case 'completed':
        return const Color(0xFF9E9E9E);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFFFC107); // pending
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer2<ManagerProvider, AuthProvider>(
      builder: (context, manager, auth, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.black, _darkBg, Colors.black]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: _gold.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(BootstrapIcons.list_task,
                        color: _gold, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Staff Task Assignment',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _gold)),
                          SizedBox(height: 4),
                          Text(
                              'Assign appointments to staff members',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(BootstrapIcons.arrow_clockwise,
                          color: _gold),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Error message ───────────────────────────────────────────
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF44336)),
                  ),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Color(0xFFF44336))),
                ),

              // ── Staff summary cards ─────────────────────────────────────
              if (manager.staff.isNotEmpty) ...[
                const Text('STAFF OVERVIEW',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: manager.staff.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final s = manager.staff[i];
                      return _StaffCard(staff: s);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Appointments list ───────────────────────────────────────
              const Text('APPOINTMENTS – ASSIGN TASKS',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 10),

              if (manager.isLoading)
                const Center(
                    child: CircularProgressIndicator(
                        color: _gold))
              else if (manager.appointments.isEmpty)
                _emptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: manager.appointments.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final apt = manager.appointments[i];
                    return _AppointmentTaskCard(
                      appointment: apt,
                      statusColor: _statusColor(apt.status),
                      isAssigning: _isLoading,
                      onAssign: () => _showAssignDialog(apt),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Colors.black, _darkBg]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(BootstrapIcons.calendar_x,
                color: Colors.grey, size: 40),
            SizedBox(height: 12),
            Text('No appointments found',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ── Staff summary card ────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  const _StaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    final count = staff.currentTaskCount;
    final busy = count > 3;
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: busy
                ? const Color(0xFFF44336)
                : const Color(0xFFFFD700),
            width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            staff.name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(BootstrapIcons.list_task,
                  size: 12,
                  color: busy
                      ? const Color(0xFFF44336)
                      : const Color(0xFFFFD700)),
              const SizedBox(width: 4),
              Text(
                '$count task${count == 1 ? '' : 's'}',
                style: TextStyle(
                    color: busy
                        ? const Color(0xFFF44336)
                        : const Color(0xFFFFD700),
                    fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Appointment task card ─────────────────────────────────────────────────

class _AppointmentTaskCard extends StatelessWidget {
  final AppointmentModel appointment;
  final Color statusColor;
  final bool isAssigning;
  final VoidCallback onAssign;

  const _AppointmentTaskCard({
    required this.appointment,
    required this.statusColor,
    required this.isAssigning,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.customerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  '${appointment.vehicleBrand} ${appointment.vehicleModel} • ${appointment.vehiclePlate}',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(BootstrapIcons.box_seam,
                        color: Color(0xFFFFD700), size: 12),
                    const SizedBox(width: 4),
                    Text(appointment.packageName,
                        style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(BootstrapIcons.clock,
                        color: Colors.grey, size: 12),
                    const SizedBox(width: 4),
                    Text(
                        '${appointment.appointmentDate}  ${appointment.appointmentTime}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              appointment.status.toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 12),

          // Assign button
          ElevatedButton.icon(
            onPressed: isAssigning ? null : onAssign,
            icon: const Icon(BootstrapIcons.person_plus_fill,
                size: 14),
            label: const Text('Assign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
