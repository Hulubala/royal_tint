import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/controllers/appointment_controller.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/edit_appointment_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/new_appointment_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_calendar_view.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_filters.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_stats_row.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_type_filter.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/view_appointment_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/change_status_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/delete_appointment_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_management_header.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointments_grid.dart';

class AppointmentManagementScreen extends StatefulWidget {
  final String? highlightAppointmentId;

  const AppointmentManagementScreen({super.key, this.highlightAppointmentId});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  bool _showCalendarView = false;
  DateTime _selectedCalendarDate = 
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final AppointmentController _controller = AppointmentController();
  bool _hasHighlighted = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    if (!_initialized && authProvider.isAuthenticated) {
      _loadData();
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(AppointmentManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightAppointmentId != oldWidget.highlightAppointmentId) {
      _hasHighlighted = false;
    }
  }

  void _checkHighlight() {
    if (widget.highlightAppointmentId != null && !_hasHighlighted) {
      _hasHighlighted = true;
      final provider = context.read<AppointmentProvider>();
      try {
        final target = provider.appointments.firstWhere(
          (a) => a.appointmentID == widget.highlightAppointmentId,
        );
        _viewAppointment(target);
      } catch (_) {}
    }
  }

  Future<void> _loadData() async {
    await _refreshAppointments();
    _checkHighlight();
  }

  Future<void> _refreshAppointments() async {
    final branchID = context.read<AuthProvider>().branchID;
    if (branchID == null) return;

    await _controller.load(
      context.read<AppointmentProvider>(),
      branchID: branchID,
    );
    _checkHighlight();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFFFC107);
      case 'confirmed': return const Color(0xFF00BCD4);
      case 'in-progress': return const Color(0xFF2196F3);
      case 'completed': return const Color(0xFF4CAF50);
      case 'cancelled': return const Color(0xFFF44336);
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return BootstrapIcons.clock;
      case 'confirmed': return BootstrapIcons.check_circle;
      case 'completed': return BootstrapIcons.check_all;
      case 'cancelled': return BootstrapIcons.x_circle;
      default: return BootstrapIcons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (widget.highlightAppointmentId != null &&
              !_hasHighlighted &&
              !appointmentProvider.isLoading &&
              appointmentProvider.appointments.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkHighlight();
            });
          }

          if (appointmentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            );
          }
          
          if (appointmentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(BootstrapIcons.exclamation_triangle,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${appointmentProvider.error}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshAppointments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredAppointments = appointmentProvider.filteredAppointments;
          final stats = appointmentProvider.stats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppointmentManagementHeader(
                  onNewAppointment: _showNewAppointmentDialog,
                  showCalendarView: _showCalendarView,
                  onViewToggle: (val) => setState(() => _showCalendarView = val),
                ),
                const SizedBox(height: 24),
                if (!_showCalendarView) ...[
                  AppointmentStatsRow(stats: stats, appointmentStatuses: _appointmentStatuses),
                  const SizedBox(height: 24),
                  AppointmentTypeFilter(appointments: appointmentProvider.appointments),
                  const SizedBox(height: 24),
                  const AppointmentFilters(),
                  const SizedBox(height: 24),
                  AppointmentsGrid(
                    appointments: filteredAppointments,
                    onView: _viewAppointment,
                    onEdit: _editAppointment,
                    onChangeStatus: _showStatusDialog,
                    onDelete: _deleteAppointment,
                  ),
                ] else ...[
                 AppointmentCalendarView(
                  appointments: appointmentProvider.appointments,
                  selectedDate: _selectedCalendarDate,
                  onSelectedDateChanged: (d) => setState(() => _selectedCalendarDate = d),
                  onPickDate: _selectCalendarDate,
                  isSameDay: _isSameDay,
                  getSlotAvailability: _getSlotAvailability,
                  parseTimeSlotLocal: _parseTimeSlotLocal,
                  getStatusColor: _getStatusColor,
                  getStatusIcon: _getStatusIcon,
                ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectCalendarDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final initialDate = _selectedCalendarDate.isBefore(tomorrow)
        ? tomorrow
        : _selectedCalendarDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Color(0xFFFFD700)),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedCalendarDate = date);
  }

  int _parseTimeSlotLocal(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  Map<String, dynamic> _getSlotAvailability(
    List<AppointmentModel> dayAppointments,
    String timeSlot,
  ) {
    final slotTime = _parseTimeSlotLocal(timeSlot);
    final slotEndTime = slotTime + 30;

    final activeAppointments = dayAppointments.where((apt) {
      final aptStartTime = _parseTimeSlotLocal(apt.appointmentTime);
      final aptDuration = apt.estimatedDuration;
      final aptEndTime = aptStartTime + aptDuration;

      final isOverlapping =
          (aptStartTime < slotEndTime && aptEndTime > slotTime);

      return isOverlapping;
    }).toList();

    final availableSlots = 2 - activeAppointments.length;

    return {
      'available': availableSlots > 0,
      'activeAppointments': activeAppointments,
      'availableSlots': availableSlots,
    };
  }

  final List<Map<String, dynamic>> _appointmentStatuses = [
    {
      'key': 'total',
      'label': 'Total',
      'icon': BootstrapIcons.calendar_event_fill,
      'colors': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
    },
    {
      'key': 'pending',
      'label': 'Pending',
      'icon': BootstrapIcons.clock_history,
      'colors': [const Color(0xFFFFC107), const Color(0xFFFF9800)],
    },
    {
      'key': 'confirmed',
      'label': 'Confirmed',
      'icon': BootstrapIcons.check_circle_fill,
      'colors': [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
    },
    {
      'key': 'in-progress',
      'label': 'In-Progress',
      'icon': BootstrapIcons.arrow_repeat,
      'colors': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
    },
    {
      'key': 'completed',
      'label': 'Completed',
      'icon': BootstrapIcons.check_all,
      'colors': [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
    },
    {
      'key': 'cancelled',
      'label': 'Cancelled',
      'icon': BootstrapIcons.x_circle_fill,
      'colors': [const Color(0xFFE53935), const Color(0xFFB71C1C)],
    },
  ];

  void _viewAppointment(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => ViewAppointmentDialog(
        appointment: appointment,
        onEdit: _editAppointment,
        onChangeStatus: _showStatusDialog,
        onRefresh: _refreshAppointments,
      ),
    );
  }

  void _editAppointment(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(
          appointment: appointment, branchID: appointment.branchID, onSaved: _refreshAppointments,),
    );
  }

  void _showStatusDialog(AppointmentModel appointment) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.branchID == null) return;
    
    showDialog(
      context: context,
      builder: (context) => ChangeStatusDialog(
        appointment: appointment,
        branchID: authProvider.branchID!,
        appointmentProvider: context.read<AppointmentProvider>(),
        controller: _controller,
      ),
    );
  }

  Future<void> _deleteAppointment(AppointmentModel appointment) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.branchID == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteAppointmentDialog(
        appointment: appointment,
        branchID: authProvider.branchID!,
        appointmentProvider: context.read<AppointmentProvider>(),
        controller: _controller,
      ),
    );

    if (confirm == true) {
      _refreshAppointments();
    }
  }

  void _showNewAppointmentDialog() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.branchID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Branch ID not found'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) =>
          NewAppointmentDialog(branchID: authProvider.branchID!, onSaved: _refreshAppointments),
    );
  }
}