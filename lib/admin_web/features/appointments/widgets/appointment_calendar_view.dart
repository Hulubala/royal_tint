import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:royal_tint/domain/models/appointment_model.dart';

class AppointmentCalendarView extends StatelessWidget {
  const AppointmentCalendarView({
    super.key,
    required this.appointments,
    required this.selectedDate,
    required this.onSelectedDateChanged,
    required this.onPickDate,
    required this.isSameDay,
    required this.getSlotAvailability,
    required this.parseTimeSlotLocal,
    required this.getStatusColor,
    required this.getStatusIcon,
  });

  final List<AppointmentModel> appointments;

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectedDateChanged;
  final Future<void> Function() onPickDate;

  final bool Function(DateTime a, DateTime b) isSameDay;

  /// Must return: {'activeAppointments': List<AppointmentModel>, 'availableSlots': int}
  final Map<String, dynamic> Function(List<AppointmentModel> dayAppointments, String timeSlot) getSlotAvailability;

  /// Returns minutes-from-midnight
  final int Function(String time) parseTimeSlotLocal;

  final Color Function(String status) getStatusColor;
  final IconData Function(String status) getStatusIcon;

  @override
  Widget build(BuildContext context) {
    final dayAppointments = appointments
        .where((apt) => isSameDay(DateTime.parse(apt.appointmentDate), selectedDate))
        .toList();

    return Column(
      children: [
        // Calendar Date Selector
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onSelectedDateChanged(selectedDate.subtract(const Duration(days: 1))),
                icon: const Icon(BootstrapIcons.chevron_left, color: Color(0xFFFFD700)),
              ),
              InkWell(
                onTap: onPickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(BootstrapIcons.calendar3, color: Colors.black),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onSelectedDateChanged(selectedDate.add(const Duration(days: 1))),
                icon: const Icon(BootstrapIcons.chevron_right, color: Color(0xFFFFD700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _TimeSlots(
          appointments: dayAppointments,
          getSlotAvailability: getSlotAvailability,
          parseTimeSlotLocal: parseTimeSlotLocal,
          getStatusColor: getStatusColor,
          getStatusIcon: getStatusIcon,
        ),
      ],
    );
  }
}

class _TimeSlots extends StatelessWidget {
  const _TimeSlots({
    required this.appointments,
    required this.getSlotAvailability,
    required this.parseTimeSlotLocal,
    required this.getStatusColor,
    required this.getStatusIcon,
  });

  final List<AppointmentModel> appointments;
  final Map<String, dynamic> Function(List<AppointmentModel>, String) getSlotAvailability;
  final int Function(String) parseTimeSlotLocal;
  final Color Function(String) getStatusColor;
  final IconData Function(String) getStatusIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 2)),
            ),
            child: const Row(
              children: [
                Icon(BootstrapIcons.clock, color: Color(0xFFFFD700)),
                SizedBox(width: 12),
                Text(
                  'AVAILABLE TIME SLOTS (Max 2 cars per time)',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 41,
            separatorBuilder: (_, __) => Divider(color: const Color(0xFFFFD700).withOpacity(0.2), height: 1),
            itemBuilder: (context, index) {
              final totalMinutes = 540 + (index * 30); // 9:00 AM
              if (totalMinutes > 1080) return const SizedBox.shrink(); // after 6:00 PM

              final hour = totalMinutes ~/ 60;
              final minute = totalMinutes % 60;

              final timeSlot = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

              final displayHour = hour > 12 ? hour - 12 : hour;
              final period = hour >= 12 ? 'PM' : 'AM';
              final displayTime = '$displayHour:${minute.toString().padLeft(2, '0')} $period';

              final slotInfo = getSlotAvailability(appointments, timeSlot);
              final activeAppointments = List<AppointmentModel>.from(slotInfo['activeAppointments'] as List);
              final availableSlots = (slotInfo['availableSlots'] as int);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activeAppointments.isEmpty
                      ? null
                      : availableSlots == 0
                          ? Colors.red.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    // Time Display
                    Container(
                      width: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: availableSlots == 0
                              ? Colors.red
                              : availableSlots == 1
                                  ? Colors.orange
                                  : const Color(0xFFFFD700),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayTime,
                        style: TextStyle(
                          color: availableSlots == 0
                              ? Colors.red
                              : availableSlots == 1
                                  ? Colors.orange
                                  : const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: activeAppointments.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(BootstrapIcons.check_circle, color: Color(0xFF4CAF50), size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Available (2 slots free)',
                                    style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                ...activeAppointments.asMap().entries.map((entry) {
                                  final apt = entry.value;
                                  final aptStartTime = parseTimeSlotLocal(apt.appointmentTime);
                                  final aptDuration = apt.estimatedDuration;
                                  final aptEndMinutes = aptStartTime + aptDuration;

                                  final endHour = aptEndMinutes ~/ 60;
                                  final endMinute = aptEndMinutes % 60;

                                  final endTimeStr =
                                      '${endHour > 12 ? endHour - 12 : endHour}:${endMinute.toString().padLeft(2, '0')} ${endHour >= 12 ? 'PM' : 'AM'}';

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: entry.key < activeAppointments.length - 1 ? 8 : 0),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [getStatusColor(apt.status).withOpacity(0.2), Colors.black],
                                        ),
                                        border: Border.all(color: getStatusColor(apt.status), width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(getStatusIcon(apt.status), color: getStatusColor(apt.status), size: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      apt.customerName,
                                                      style: const TextStyle(
                                                        color: Color(0xFFFFD700),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${apt.vehiclePlate} • ${apt.packageName}',
                                                      style: TextStyle(
                                                        color: const Color(0xFFFFD700).withOpacity(0.7),
                                                        fontSize: 12,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: getStatusColor(apt.status),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  apt.status.toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(BootstrapIcons.hourglass_split,
                                                  color: Color(0xFFFFD700), size: 12),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Until $endTimeStr (${aptDuration}min)',
                                                style: TextStyle(
                                                  color: const Color(0xFFFFD700).withOpacity(0.7),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                if (availableSlots > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(BootstrapIcons.plus_circle,
                                            color: Colors.orange.withOpacity(0.7), size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          '1 more slot available',
                                          style: TextStyle(
                                            color: Colors.orange.withOpacity(0.9),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(BootstrapIcons.x_circle, color: Colors.red.withOpacity(0.7), size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'FULLY BOOKED',
                                          style: TextStyle(
                                            color: Colors.red.withOpacity(0.9),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}