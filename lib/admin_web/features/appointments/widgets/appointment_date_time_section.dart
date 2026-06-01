import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../dialogs/thirty_minute_time_picker.dart';

class AppointmentDateTimeSection extends StatelessWidget {
  final bool isSaving;
  final String appointmentType;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int estimatedMinutes;
  final String branchID;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;

  const AppointmentDateTimeSection({
    super.key,
    required this.isSaving,
    required this.appointmentType,
    required this.selectedDate,
    required this.selectedTime,
    required this.estimatedMinutes,
    required this.branchID,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (appointmentType == 'scheduled') ...[
          _buildDatePicker(context),
          const SizedBox(height: 16),
        ],
        _buildTimePicker(context),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Appointment Date',
            style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: isSaving
              ? null
              : () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ??
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFFFD700),
                            onPrimary: Colors.black,
                            surface: Color(0xFF1A1A1A),
                            onSurface: Color(0xFFFFD700),
                          ),
                          inputDecorationTheme: const InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.black,
                            labelStyle: TextStyle(color: Color(0xFFFFD700)),
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700), width: 2)),
                          ),
                          textTheme: const TextTheme(
                            titleMedium: TextStyle(color: Color(0xFFFFD700)),
                            bodyLarge: TextStyle(color: Color(0xFFFFD700)),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    onDateChanged(pickedDate);
                  }
                },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.calendar3, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('EEEE, MMM dd, yyyy').format(selectedDate!),
                  style: TextStyle(
                    color: selectedDate == null
                        ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                        : const Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Appointment Time',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            if (estimatedMinutes > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700))),
                child: Text('Allow $estimatedMinutes min',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isSaving
              ? null
              : () async {
                  final now = TimeOfDay.now();
                  const openingTime = TimeOfDay(hour: 9, minute: 0);
                  const closingTime = TimeOfDay(hour: 19, minute: 0);

                  final todayStr =
                      DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final selectedDateStr = selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : todayStr;

                  final isToday = selectedDateStr == todayStr;

                  TimeOfDay minTime;
                  final nowMinutes = now.hour * 60 + now.minute;
                  final openingMinutes = openingTime.hour * 60 + openingTime.minute;

                  if (appointmentType == 'walk-in') {
                    minTime = nowMinutes > openingMinutes ? now : openingTime;
                  } else {
                    if (isToday) {
                      minTime = nowMinutes > openingMinutes ? now : openingTime;
                    } else {
                      minTime = openingTime;
                    }
                  }

                  final TimeOfDay? newTime = await showDialog<TimeOfDay>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext dialogContext) =>
                        ThirtyMinuteTimePicker(
                      initialTime: selectedTime ?? minTime,
                      minTime: minTime,
                      maxTime: closingTime,
                      isWalkIn: appointmentType == 'walk-in',
                      appointmentDate: selectedDateStr,
                      branchID: branchID,
                      estimatedDuration:
                          estimatedMinutes > 0 ? estimatedMinutes : 90,
                    ),
                  );

                  if (newTime != null) {
                    final selectionMinutes =
                        newTime.hour * 60 + newTime.minute;
                    final closingMinutes =
                        closingTime.hour * 60 + closingTime.minute;

                    if (!context.mounted) return;
                    if (appointmentType == 'walk-in' &&
                        isToday &&
                        selectionMinutes < nowMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Cannot select past time for walk-in.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectionMinutes >= closingMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Selected time is outside operating hours.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    onTimeChanged(newTime);
                  }
                },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.clock, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  selectedTime == null
                      ? 'Select Time'
                      : _formatTime(selectedTime!),
                  style: TextStyle(
                    color: selectedTime == null
                        ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                        : const Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
