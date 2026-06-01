import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/data/services/staff_service.dart';
import 'package:royal_tint/domain/models/user/staff_model.dart';
import 'package:intl/intl.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final StaffService _staffService = StaffService();
  List<StaffModel> _staffList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final list = await _staffService.getAllStaff();
    // Sort staff alphabetically
    list.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _staffList = list;
      _isLoading = false;
    });
  }

  String _getTodayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _toggleAbsence(StaffModel staff) async {
    final todayStr = _getTodayString();
    final isCurrentlyAbsent = staff.absentDates.contains(todayStr);
    
    setState(() => _isLoading = true);
    try {
      await _staffService.setStaffAbsence(staff.id, todayStr, !isCurrentlyAbsent);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${staff.name} marked as ${!isCurrentlyAbsent ? 'Absent' : 'Present'} for today.')),
      );
      _loadStaff();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update staff attendance status.')),
      );
    }
  }

  void _deleteStaff(StaffModel staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to permanently delete ${staff.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _staffService.deleteStaff(staff.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${staff.name} deleted successfully.')),
        );
        _loadStaff();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete staff.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    final todayStr = _getTodayString();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
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
            child: const Row(
              children: [
                Icon(BootstrapIcons.people_fill, color: gold, size: 28),
                SizedBox(width: 16),
                Text(
                  'Staff Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Table Section (Pure Black with Gold Border)
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    border: Border(bottom: BorderSide(color: gold, width: 2)),
                  ),
                  child: const Text(
                    'Staff Directory & Today\'s Availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
                ),

                // Table Content
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Center(
                          child: CircularProgressIndicator(color: gold),
                        ),
                      )
                    : _staffList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(48.0),
                            child: Center(
                              child: Text(
                                'No staff members registered.',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    headingRowColor: WidgetStateProperty.all(Colors.black),
                                    dataRowMaxHeight: 75,
                                    dataRowMinHeight: 65,
                                    columns: const [
                                      DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: gold))),
                                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: gold))),
                                      DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, color: gold))),
                                      DataColumn(label: Text('Today Status', style: TextStyle(fontWeight: FontWeight.bold, color: gold))),
                                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: gold))),
                                    ],
                                    rows: _staffList.map((staff) {
                                      final isAbsentToday = staff.absentDates.contains(todayStr);
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              staff.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              staff.email,
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              staff.phone,
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isAbsentToday ? Colors.red : Colors.green,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  isAbsentToday ? 'Absent' : 'Present',
                                                  style: TextStyle(
                                                    color: isAbsentToday ? Colors.redAccent : Colors.greenAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Toggle Attendance Switch
                                                IconButton(
                                                  tooltip: isAbsentToday ? 'Mark Present' : 'Mark Absent',
                                                  icon: Icon(
                                                    isAbsentToday ? BootstrapIcons.check_circle_fill : BootstrapIcons.x_circle_fill,
                                                    color: isAbsentToday ? Colors.green : Colors.orange,
                                                    size: 20,
                                                  ),
                                                  onPressed: () => _toggleAbsence(staff),
                                                ),
                                                const SizedBox(width: 8),
                                                // View Schedule Link
                                                IconButton(
                                                  tooltip: 'View Schedule',
                                                  icon: const Icon(BootstrapIcons.calendar3, color: gold, size: 20),
                                                  onPressed: () {
                                                    context.go('/manager/staff-schedule/${staff.id}');
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                // Delete button
                                                IconButton(
                                                  tooltip: 'Delete Staff',
                                                  icon: const Icon(BootstrapIcons.trash, color: Colors.red, size: 20),
                                                  onPressed: () => _deleteStaff(staff),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}