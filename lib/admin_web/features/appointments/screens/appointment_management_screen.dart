import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/controllers/appointment_controller.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/edit_appointment_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/new_appointment_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_card.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_calendar_view.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_filters.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_stats_row.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_type_filter.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/view_appointment_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/change_status_dialog.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/delete_appointment_dialog.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshAppointments();
    });
  }

  Future<void> _refreshAppointments() async {
    final branchID = context.read<AuthProvider>().branchID;
    if (branchID == null) return;

    await _controller.load(
      context.read<AppointmentProvider>(),
      branchID: branchID,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFC107); // Amber
      case 'confirmed':
        return const Color(0xFF00BCD4); // Cyan
      case 'in-progress':
        return const Color(0xFF2196F3); // Blue
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BootstrapIcons.clock;
      case 'confirmed':
        return BootstrapIcons.check_circle;
      case 'completed':
        return BootstrapIcons.check_all;
      case 'cancelled':
        return BootstrapIcons.x_circle;
      default:
        return BootstrapIcons.circle;
    }
  }

  Color _getCardBorderColor(int index) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFC107),
      const Color(0xFF00BCD4),
      const Color(0xFF9C27B0),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          
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
                _buildPageHeader(),
                const SizedBox(height: 24),
                _buildViewToggle(),
                const SizedBox(height: 24),
                if (!_showCalendarView) ...[
                  AppointmentStatsRow(stats: stats, appointmentStatuses: _appointmentStatuses),
                  const SizedBox(height: 24),
                  AppointmentTypeFilter(appointments: appointmentProvider.appointments),
                  const SizedBox(height: 24),
                  const AppointmentFilters(),
                  const SizedBox(height: 24),
                  _buildAppointmentsGrid(filteredAppointments),
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

  // 📅 VIEW TOGGLE
  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showCalendarView = false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: !_showCalendarView
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFC700)])
                      : null,
                  color: !_showCalendarView ? null : Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.grid_3x3_gap_fill,
                        color: !_showCalendarView
                            ? Colors.black
                            : const Color(0xFFFFD700),
                        size: 18),
                    const SizedBox(width: 8),
                    Text('Grid View',
                        style: TextStyle(
                            color: !_showCalendarView
                                ? Colors.black
                                : const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showCalendarView = true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: _showCalendarView
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFC700)])
                      : null,
                  color: _showCalendarView ? null : Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.calendar3,
                        color: _showCalendarView
                            ? Colors.black
                            : const Color(0xFFFFD700),
                        size: 18),
                    const SizedBox(width: 8),
                    Text('Calendar View',
                        style: TextStyle(
                            color: _showCalendarView
                                ? Colors.black
                                : const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      firstDate:
          tomorrow, // First selectable date is tomorrow (no past, no today)
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

  // ⭐ NEW: Parse time slot to minutes since midnight
  int _parseTimeSlotLocal(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  // ⭐ NEW: Get slot availability status
  Map<String, dynamic> _getSlotAvailability(
    List<AppointmentModel> dayAppointments,
    String timeSlot,
  ) {
    final slotTime = _parseTimeSlotLocal(timeSlot);
    final slotEndTime = slotTime + 30; // Each slot is 30 minutes

    print(
        '[CALENDAR] Checking slot: $timeSlot (range: $slotTime-$slotEndTime min)');

    // ⭐ FIXED: Find appointments that OVERLAP with this 30-minute slot
    final activeAppointments = dayAppointments.where((apt) {
      final aptStartTime = _parseTimeSlotLocal(apt.appointmentTime);
      final aptDuration = apt.estimatedDuration;
      final aptEndTime = aptStartTime + aptDuration;

      // ⭐ CRITICAL FIX: Check if appointment overlaps with THIS slot
      // Overlap occurs if:
      // 1. Appointment starts before slot ends AND
      // 2. Appointment ends after slot starts
      final isOverlapping =
          (aptStartTime < slotEndTime && aptEndTime > slotTime);

      if (isOverlapping) {
        print(
            '[CALENDAR]   ✓ Overlaps: ${apt.appointmentTime} (${apt.vehicleBrand} ${apt.vehicleModel}, $aptStartTime-$aptEndTime, ${aptDuration}min)');
      }

      return isOverlapping;
    }).toList();

    final availableSlots = 2 - activeAppointments.length;
    print(
        '[CALENDAR] Result: ${activeAppointments.length} appointments overlap, $availableSlots slots available');

    return {
      'available': availableSlots > 0,
      'activeAppointments': activeAppointments,
      'availableSlots': availableSlots,
    };
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(BootstrapIcons.calendar_check,
              color: Color(0xFFFFD700), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointment Management',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700))),
                SizedBox(height: 4),
                Text('Monitor walk-in and scheduled customer bookings',
                    style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showNewAppointmentDialog,
            icon: const Icon(BootstrapIcons.plus_circle, size: 20),
            label: const Text('New Appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _appointmentStatuses = [
    {
      'key': 'total',
      'label': 'Total',
      'icon': BootstrapIcons.calendar_event_fill,
      'colors': [Color(0xFF2196F3), Color(0xFF1976D2)],
    },
    {
      'key': 'pending',
      'label': 'Pending',
      'icon': BootstrapIcons.clock_history,
      'colors': [Color(0xFFFFC107), Color(0xFFFF9800)], // Amber
    },
    {
      'key': 'confirmed',
      'label': 'Confirmed',
      'icon': BootstrapIcons.check_circle_fill,
      'colors': [Color(0xFF00BCD4), Color(0xFF0097A7)], // Cyan
    },
    {
      'key': 'in-progress',
      'label': 'In-Progress',
      'icon': BootstrapIcons.arrow_repeat,
      'colors': [Color(0xFF2196F3), Color(0xFF1976D2)], // Blue
    },
    {
      'key': 'completed',
      'label': 'Completed',
      'icon': BootstrapIcons.check_all,
      'colors': [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Green
    },
    {
      'key': 'cancelled',
      'label': 'Cancelled',
      'icon': BootstrapIcons.x_circle_fill,
      'colors': [Color(0xFFE53935), Color(0xFFB71C1C)],
    },
  ];
  
  Widget _buildAppointmentsGrid(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(BootstrapIcons.calendar_x,
                  color: const Color(0xFFFFD700).withOpacity(0.5), size: 64),
              const SizedBox(height: 16),
              const Text('No appointments found',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Try adjusting your filters',
                  style: TextStyle(
                      color: const Color(0xFFFFD700).withOpacity(0.7),
                      fontSize: 14)),
            ],
          ),
        ),
      );
    }

    // 🔧 RESPONSIVE GRID: Narrower and shorter cards with suitable height
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxCardWidth;

        // Calculate optimal columns based on available width
        if (constraints.maxWidth < 600) {
          maxCardWidth = constraints.maxWidth; // 1 column
        } else if (constraints.maxWidth < 900) {
          maxCardWidth = 500; // 2 columns
        } else if (constraints.maxWidth < 1400) {
          maxCardWidth = 420; // 3 columns
        } else {
          maxCardWidth = 380; // 4 columns
        }

        return GridView.builder(
          shrinkWrap: true, // ⭐ REQUIRED
          physics: const NeverScrollableScrollPhysics(), // ⭐ REQUIRED
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCardWidth,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 350,
          ),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final apt = appointments[index];

            return AppointmentCard(
              appointment: apt,
              index: index,
              borderColor: _getCardBorderColor(index),
              statusColor: _getStatusColor(apt.status),
              formatPhoneNumber: _formatPhoneNumber,
              formatDate: _formatDate,
              formatTime: _formatTime,
              formatBranch: _formatBranch,
              isLightColor: _isLightColor,
              onView: () => _viewAppointment(apt),
              onEdit: () => editAppointment(apt),
              onChangeStatus: () => _showStatusDialog(apt),
              onDelete: () => _deleteAppointment(apt),
            );
          },
        );
      },
    );
  }

  // Helper function to determine if a color is light
  bool _isLightColor(Color color) {
    // Calculate relative luminance
    final double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5; // If luminance > 0.5, it's a light color
  }

  String _formatPhoneNumber(String phone) {
    // Remove any existing formatting
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Format as 012-3456789
    if (phone.length >= 10) {
      return '${phone.substring(0, 3)}-${phone.substring(3)}';
    } else if (phone.length >= 3) {
      return '${phone.substring(0, 3)}-${phone.substring(3)}';
    }
    return phone;
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(d);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  String _formatBranch(String branchID) {
    if (branchID.toLowerCase().contains('melaka')) return 'Melaka';
    if (branchID.toLowerCase().contains('seremban')) return 'Seremban 2';
    return branchID;
  }

  void _viewAppointment(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => ViewAppointmentDialog(
        appointment: appointment,
        onEdit: editAppointment,
        onRefresh: _refreshAppointments,
      ),
    );
  }

  void editAppointment(AppointmentModel appointment) {
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