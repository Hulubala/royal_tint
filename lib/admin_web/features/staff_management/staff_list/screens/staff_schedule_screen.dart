import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/data/services/staff_service.dart';
import 'package:royal_tint/domain/models/user/staff_model.dart';
import 'package:royal_tint/domain/models/task_model.dart';

class StaffScheduleScreen extends StatefulWidget {
  final String staffId;
  const StaffScheduleScreen({super.key, required this.staffId});

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> {
  final StaffService _staffService = StaffService();
  StaffModel? _staff;
  DateTime _selectedDate = DateTime.now();
  List<TaskModel> _tasks = [];
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  // 9:00 AM to 6:00 PM in 30-min increments
  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM',
    '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM',
    '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM',
    '05:00 PM', '05:30 PM',
    '06:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    // Normalize date to today if it's in the past
    final today = DateTime.now();
    if (_selectedDate.isBefore(DateTime(today.year, today.month, today.day))) {
      _selectedDate = DateTime(today.year, today.month, today.day);
    }
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    setState(() => _isLoading = true);
    final staffData = await _staffService.getStaffById(widget.staffId);
    
    if (staffData != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final appts = await _staffService.getAppointmentsForStaffOnDate(widget.staffId, dateStr);
      final tasksData = await _staffService.getTasksForStaffOnDate(widget.staffId, _selectedDate);
      
      setState(() {
        _staff = staffData;
        _appointments = appts;
        _tasks = tasksData;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Parse time slot to minute offset from midnight for calculations
  int _parseSlotToMinutes(String slot) {
    final format = DateFormat('hh:mm a');
    final dt = format.parse(slot);
    return dt.hour * 60 + dt.minute;
  }

  // Parse appointment/task time to minute offset from midnight
  int? _parseTimeToMinutes(String timeStr) {
    try {
      final t = timeStr.trim().toUpperCase();
      // Handle standard 12-hour formats like "10:30 AM" or "02:00 PM"
      final ampmRegex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$');
      final ampmMatch = ampmRegex.firstMatch(t);
      if (ampmMatch != null) {
        var hour = int.parse(ampmMatch.group(1)!);
        final min = int.parse(ampmMatch.group(2)!);
        final ap = ampmMatch.group(3)!;
        if (ap == 'PM' && hour != 12) hour += 12;
        if (ap == 'AM' && hour == 12) hour = 0;
        return hour * 60 + min;
      }

      // Handle 24-hour formats like "14:30" or "09:00"
      final militaryRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
      final militaryMatch = militaryRegex.firstMatch(t);
      if (militaryMatch != null) {
        final hour = int.parse(militaryMatch.group(1)!);
        final min = int.parse(militaryMatch.group(2)!);
        return hour * 60 + min;
      }
    } catch (e) {
      print('Error parsing time string $timeStr: $e');
    }
    return null;
  }

  // Check if a time slot is busy
  bool _isSlotBusy(String slot) {
    final slotMinutes = _parseSlotToMinutes(slot);

    // 1. Check active appointments
    for (final appt in _appointments) {
      final status = (appt['status'] ?? '').toString().toUpperCase();
      if (status == 'CANCELLED' || status == 'COMPLETED' || status == 'COMPLETE') continue;

      final apptTimeStr = (appt['appointmentTime'] ?? '').toString();
      final apptMinutes = _parseTimeToMinutes(apptTimeStr);
      if (apptMinutes != null) {
        // Assume default duration is 60 mins if estimatedDuration is 0 or null
        final duration = (appt['estimatedDuration'] as num?)?.toInt() ?? 60;
        final endMinutes = apptMinutes + duration;

        if (slotMinutes >= apptMinutes && slotMinutes < endMinutes) {
          return true;
        }
      }
    }

    // 2. Check active tasks
    for (final task in _tasks) {
      if (task.status.toUpperCase() == 'CANCELLED' || task.status.toUpperCase() == 'COMPLETED') continue;

      final taskMinutes = task.dueDate.hour * 60 + task.dueDate.minute;
      // Tasks are assigned with a 2-hour duration in our service, let's assume they occupy [taskMinutes - 120, taskMinutes]
      final startMinutes = taskMinutes - 120;
      
      if (slotMinutes >= startMinutes && slotMinutes <= taskMinutes) {
        return true;
      }
    }

    return false;
  }

  // Date selection helper
  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: normalizedToday,
      lastDate: normalizedToday.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            onPrimary: Colors.black,
            surface: Color(0xFF1A1A1A),
            onSurface: Color(0xFFFFD700),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadScheduleData();
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final isAbsent = _staff?.absentDates.contains(dateStr) ?? false;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : _staff == null
              ? const Center(child: Text('Staff member not found.', style: TextStyle(fontSize: 18, color: Colors.black)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section (Pure Black with Gold Border)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold, width: 2),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(BootstrapIcons.arrow_left, color: gold),
                            onPressed: () => context.go('/manager/staff-list'),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_staff!.name}\'s Schedule',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Phone: ${_staff!.phone}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Date Picker Controls
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: gold),
                                onPressed: () {
                                  final today = DateTime.now();
                                  final normalizedToday = DateTime(today.year, today.month, today.day);
                                  final prevDate = _selectedDate.subtract(const Duration(days: 1));
                                  if (!prevDate.isBefore(normalizedToday)) {
                                    setState(() => _selectedDate = prevDate);
                                    _loadScheduleData();
                                  }
                                },
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                icon: const Icon(BootstrapIcons.calendar_event),
                                label: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                                onPressed: () => _selectDate(context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: gold),
                                onPressed: () {
                                  setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                                  _loadScheduleData();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Status Indicator Panel
                    Row(
                      children: [
                        _buildStatusIndicator('Free Slot', Colors.green),
                        const SizedBox(width: 24),
                        _buildStatusIndicator('Busy / Occupied', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Schedule Time Table Container (Pure Black with Gold Border)
                    SizedBox(
                      height: 600,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: gold, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Banner
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                border: Border(bottom: BorderSide(color: gold, width: 2)),
                              ),
                              child: Text(
                                isAbsent 
                                    ? 'STAFF OUT OF OFFICE (ABSENT TODAY)' 
                                    : 'TIME SLOTS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isAbsent ? Colors.redAccent : gold,
                                ),
                              ),
                            ),

                            // Grid of Slots
                            Expanded(
                              child: isAbsent
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(BootstrapIcons.x_circle_fill, color: Colors.red[400], size: 64),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'This staff member is marked ABSENT on this day.',
                                            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'No schedules or tasks can be checked.',
                                            style: TextStyle(color: Colors.white54, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: GridView.builder(
                                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 220,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                          childAspectRatio: 2.2,
                                        ),
                                        itemCount: _timeSlots.length,
                                        itemBuilder: (context, index) {
                                          final slot = _timeSlots[index];
                                          final isBusy = _isSlotBusy(slot);
                                          final bgColor = isBusy ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2);
                                          final borderColor = isBusy ? Colors.red : Colors.green;
                                          final textColor = isBusy ? Colors.redAccent : Colors.greenAccent;
                                          
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: bgColor,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: borderColor, width: 1.5),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  slot,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  isBusy ? 'BUSY' : 'FREE',
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatusIndicator(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
