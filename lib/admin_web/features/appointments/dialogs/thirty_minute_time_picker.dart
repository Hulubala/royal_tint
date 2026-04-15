import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';

// ⭐ NEW: 30-Minute Time Picker Widget
class ThirtyMinuteTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final bool isWalkIn;
  final String? appointmentDate;
  final String? branchID;
  final int estimatedDuration;

  const ThirtyMinuteTimePicker({
    super.key,
    required this.initialTime,
    required this.minTime,
    required this.maxTime,
    this.isWalkIn = false,
    this.appointmentDate,
    this.branchID,
    this.estimatedDuration = 90,
  });

  @override
  State<ThirtyMinuteTimePicker> createState() => _ThirtyMinuteTimePickerState();
}

class _ThirtyMinuteTimePickerState extends State<ThirtyMinuteTimePicker> {
  late TimeOfDay _selectedTime;
  List<String> _fullyBookedSlots = [];
  bool _isLoadingSlots = true;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _loadBookedSlots();
  }

  /// Load fully booked slots
  Future<void> _loadBookedSlots() async {
    if (widget.appointmentDate == null || widget.branchID == null) {
      setState(() => _isLoadingSlots = false);
      return;
    }

    try {
      print(
          '[TIME_PICKER] Loading booked slots for date: ${widget.appointmentDate}, duration: ${widget.estimatedDuration}min');

      final appointments = await AppointmentService().getAppointmentsByDate(
        branchID: widget.branchID!,
        date: widget.appointmentDate!,
      );

      print(
          '[TIME_PICKER] Loaded ${appointments.length} appointments for this date');

      final bookedSlots = <String>[];

      // Check each time slot
      for (int i = 0; i < 19; i++) {
        final totalMinutes = 540 + (i * 30);
        final hour = totalMinutes ~/ 60;
        final minute = totalMinutes % 60;
        final timeSlot =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

        // Check if this slot is fully booked
        if (!_canAcceptAppointment(
            appointments, timeSlot, widget.estimatedDuration)) {
          bookedSlots.add(timeSlot);
          print('[TIME_PICKER]   ❌ BOOKED: $timeSlot');
        } else {
          print('[TIME_PICKER]   ✅ AVAILABLE: $timeSlot');
        }
      }

      print(
          '[TIME_PICKER] Summary: ${bookedSlots.length} fully booked slots, ${19 - bookedSlots.length} available');

      if (mounted) {
        setState(() {
          _fullyBookedSlots = bookedSlots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      print('Error loading booked slots: $e');

      // ⭐ FIX: Show error message to user if it's an index error
      if (e.toString().contains('index')) {
        print(
            '⚠️ FIRESTORE INDEX REQUIRED - Please create the index in Firebase Console');
        print('Error details: $e');
      }

      if (mounted) {
        setState(() {
          _fullyBookedSlots =
              []; // Allow all slots if we can't check availability
          _isLoadingSlots = false;
        });
      }
    }
  }

  /// Check if slot can accept appointment
  bool _canAcceptAppointment(
    List<AppointmentModel> dayAppointments,
    String timeSlot,
    int durationMinutes,
  ) {
    final slotTime = _parseTimeSlotInt(timeSlot);
    final endTime = slotTime + durationMinutes;

    final overlappingCount = dayAppointments.where((apt) {
      final aptStartTime = _parseTimeSlotInt(apt.appointmentTime);
      final aptDuration = apt.estimatedDuration;
      final aptEndTime = aptStartTime + aptDuration;

      return (aptStartTime < endTime && aptEndTime > slotTime);
    }).length;

    return overlappingCount < 2;
  }

  int _parseTimeSlotInt(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  List<TimeOfDay> _getAvailableTimeSlots() {
    const int interval = 30;
    final List<TimeOfDay> slots = [];

    final minMinutes = widget.minTime.hour * 60 + widget.minTime.minute;
    final maxMinutes = widget.maxTime.hour * 60 + widget.maxTime.minute;

    // Check if selected date is today
    final now = DateTime.now();
    final selectedDate = widget.appointmentDate != null
        ? DateTime.parse(widget.appointmentDate!)
        : now;
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    // Current time in minutes (only relevant for today)
    final currentMinutes = now.hour * 60 + now.minute;

    // ⭐ FIXED: Start from opening time (9:00 AM = 540 minutes)
    for (int minutes = minMinutes; minutes < maxMinutes; minutes += interval) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;

      // ⭐ CRITICAL FIX: For scheduled appointments on FUTURE dates, show ALL slots
      // Only restrict current time for TODAY's appointments
      if (isToday) {
        // For walk-in on today: must be from NOW onwards
        if (widget.isWalkIn && minutes < currentMinutes) {
          continue;
        }
        // For scheduled on today: must be at least 30min from now (give prep time)
        if (!widget.isWalkIn && minutes < currentMinutes + 30) {
          continue;
        }
      }

      // ⛔ Skip slots that would overflow past closing time
      if (minutes + widget.estimatedDuration > maxMinutes) {
        continue;
      }

      slots.add(TimeOfDay(hour: hour, minute: minute));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _getAvailableTimeSlots();

    if (timeSlots.isEmpty && widget.isWalkIn) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(BootstrapIcons.exclamation_triangle,
                  color: Color(0xFFFFC107), size: 48),
              const SizedBox(height: 16),
              const Text(
                'No Available Time Slots',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Shop is closed for today. Please try tomorrow.',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('OK',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13)),
                border: Border(
                    bottom: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.clock,
                      color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.isWalkIn ? 'SELECT TIME (FROM NOW)' : 'SELECT TIME',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFFFFD700)),
                  ),
                ],
              ),
            ),
            if (_isLoadingSlots)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Checking availability...',
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    final time = timeSlots[index];
                    final isSelected = time.hour == _selectedTime.hour &&
                        time.minute == _selectedTime.minute;

                    final timeString =
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    final isFullyBooked =
                        _fullyBookedSlots.contains(timeString);

                    return InkWell(
                      onTap: isFullyBooked
                          ? null
                          : () => setState(() => _selectedTime = time),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFC700)
                                ])
                              : null,
                          color: isSelected
                              ? null
                              : isFullyBooked
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.black,
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : isFullyBooked
                                      ? Colors.red.withOpacity(0.5)
                                      : const Color(0xFFFFD700)
                                          .withOpacity(0.3),
                              width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                isFullyBooked
                                    ? BootstrapIcons.x_circle
                                    : BootstrapIcons.clock,
                                color: isSelected
                                    ? Colors.black
                                    : isFullyBooked
                                        ? Colors.red
                                        : const Color(0xFFFFD700),
                                size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatTime(time),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : isFullyBooked
                                          ? Colors.red
                                          : const Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: isFullyBooked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            if (isFullyBooked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'FULL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(13),
                    bottomRight: Radius.circular(13)),
                border:
                    Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CANCEL',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, _selectedTime),
                    icon: const Icon(BootstrapIcons.check_circle),
                    label: const Text('CONFIRM',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}