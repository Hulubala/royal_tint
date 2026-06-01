import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class AppointmentManagementHeader extends StatelessWidget {
  final VoidCallback onNewAppointment;
  final bool showCalendarView;
  final ValueChanged<bool> onViewToggle;

  const AppointmentManagementHeader({
    super.key,
    required this.onNewAppointment,
    required this.showCalendarView,
    required this.onViewToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPageHeader(),
        const SizedBox(height: 24),
        _buildViewToggle(),
      ],
    );
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
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
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
            onPressed: onNewAppointment,
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
              onTap: () => onViewToggle(false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: !showCalendarView
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFC700)])
                      : null,
                  color: !showCalendarView ? null : Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.grid_3x3_gap_fill,
                        color: !showCalendarView
                            ? Colors.black
                            : const Color(0xFFFFD700),
                        size: 18),
                    const SizedBox(width: 8),
                    Text('Grid View',
                        style: TextStyle(
                            color: !showCalendarView
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
              onTap: () => onViewToggle(true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: showCalendarView
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFC700)])
                      : null,
                  color: showCalendarView ? null : Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.calendar3,
                        color: showCalendarView
                            ? Colors.black
                            : const Color(0xFFFFD700),
                        size: 18),
                    const SizedBox(width: 8),
                    Text('Calendar View',
                        style: TextStyle(
                            color: showCalendarView
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
}
