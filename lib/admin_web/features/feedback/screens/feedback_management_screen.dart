import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/admin_web/features/feedback/providers/feedback_provider.dart';
import 'package:royal_tint/admin_web/features/feedback/models/feedback_item.dart';
import 'package:royal_tint/admin_web/features/feedback/widgets/feedback_statistics_section.dart';
import 'package:royal_tint/admin_web/features/feedback/widgets/feedback_filter_bar.dart';
import 'package:royal_tint/admin_web/features/feedback/widgets/feedback_grid.dart';
import 'package:royal_tint/admin_web/features/feedback/widgets/feedback_overview_chart.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:intl/intl.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  bool _initialized = false;
  String _selectedCategory = 'all';
  String _dateFilter = 'all';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    if (!_initialized && authProvider.isAuthenticated) {
      final branchID = authProvider.branchID;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<FeedbackProvider>().loadFeedback(branchID);
        }
      });
      _initialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _confirmDelete(FeedbackItem item) async {
    const gold = Color(0xFFFFD700);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[950],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: gold, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(BootstrapIcons.trash, color: Colors.red, size: 22),
            SizedBox(width: 10),
            Text(
              'Delete Feedback',
              style: TextStyle(color: gold, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete this feedback from ${item.customerName}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await context.read<FeedbackProvider>().removeFeedback(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback deleted successfully.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final minDate = DateTime(2026, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: minDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Color(0xFFFFD700),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateFilter = 'select_date';
        _customStartDate = picked;
        _customEndDate = null;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final minDate = DateTime(2026, 1, 1);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      firstDate: minDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Color(0xFFFFD700),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateFilter = 'date_range';
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    }
  }

  Future<void> _pickMonth() async {
    // Simple mock dialog for month picking. Default to current month for simplicity.
    // To ensure full functionality, a robust dialog should be built, but we'll use a direct assignment for demonstration if a simple picker is unavailable.
    // Since Flutter doesn't have showMonthPicker, we will build a minimal dialog.
    final now = DateTime.now();
    final currentYear = now.year;
    final years = [for (var y = 2026; y <= currentYear; y++) y];
    
    int selectedMonth = now.month;
    int selectedYear = currentYear;
    
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Select Month', style: TextStyle(color: Color(0xFFFFD700))),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MenuDropdown<int>(
                          label: '',
                          hint: 'Month',
                          value: selectedMonth,
                          items: List.generate(12, (i) {
                            final monthNum = i + 1;
                            return MenuItem<int>(
                              value: monthNum,
                              label: DateFormat('MMMM').format(DateTime(2026, monthNum)),
                            );
                          }),
                          onChanged: (val) { if(val!=null) setDialogState(() => selectedMonth = val); },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MenuDropdown<int>(
                          label: '',
                          hint: 'Year',
                          value: selectedYear,
                          items: years.map((y) => MenuItem<int>(value: y, label: y.toString())).toList(),
                          onChanged: (val) { if(val!=null) setDialogState(() => selectedYear = val); },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                  onPressed: () => Navigator.pop(context, DateTime(selectedYear, selectedMonth, 1)),
                  child: const Text('Select'),
                )
              ],
            );
          }
        );
      }
    );

    if (picked != null) {
      setState(() {
        _dateFilter = 'select_month';
        _customStartDate = picked;
        _customEndDate = null;
      });
    }
  }

  Future<void> _pickMonthRange() async {
    final now = DateTime.now();
    final currentYear = now.year;
    final years = [for (var y = 2026; y <= currentYear; y++) y];

    int startMonth = now.month;
    int startYear = currentYear;
    int endMonth = now.month;
    int endYear = currentYear;

    final picked = await showDialog<List<DateTime>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Select Month Range', style: TextStyle(color: Color(0xFFFFD700))),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const Text('Start Month', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MenuDropdown<int>(
                          label: '',
                          hint: 'Month',
                          value: startMonth,
                          items: List.generate(12, (i) => MenuItem<int>(value: i+1, label: DateFormat('MMM').format(DateTime(2026, i+1)))),
                          onChanged: (val) { if(val!=null) setDialogState(() => startMonth = val); },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MenuDropdown<int>(
                          label: '',
                          hint: 'Year',
                          value: startYear,
                          items: years.map((y) => MenuItem<int>(value: y, label: y.toString())).toList(),
                          onChanged: (val) { if(val!=null) setDialogState(() => startYear = val); },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('End Month', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MenuDropdown<int>(
                          label: '',
                          hint: 'Month',
                          value: endMonth,
                          items: List.generate(12, (i) => MenuItem<int>(value: i+1, label: DateFormat('MMM').format(DateTime(2026, i+1)))),
                          onChanged: (val) { if(val!=null) setDialogState(() => endMonth = val); },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MenuDropdown<int>(
                          label: '',
                          hint: 'Year',
                          value: endYear,
                          items: years.map((y) => MenuItem<int>(value: y, label: y.toString())).toList(),
                          onChanged: (val) { if(val!=null) setDialogState(() => endYear = val); },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                  onPressed: () {
                    final start = DateTime(startYear, startMonth, 1);
                    final end = DateTime(endYear, endMonth, 1);
                    if (start.isAfter(end)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start month must be before end month')));
                      return;
                    }
                    Navigator.pop(context, [start, end]);
                  },
                  child: const Text('Select'),
                )
              ],
            );
          }
        );
      }
    );

    if (picked != null && picked.length == 2) {
      setState(() {
        _dateFilter = 'month_range';
        _customStartDate = picked[0];
        _customEndDate = picked[1];
      });
    }
  }

  void _showFeedbackDialog(String categoryFilter, String dialogTitle, List<FeedbackItem> filteredFeedbacks, bool isLoading) {
    final displayFeedbacks = filteredFeedbacks.where((f) => categoryFilter == 'all' || f.category.toLowerCase() == categoryFilter.toLowerCase()).toList();
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 1000,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dialogTitle,
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFFFD700)),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: displayFeedbacks.isEmpty 
                    ? const Center(child: Text('No feedback found for this selection.', style: TextStyle(color: Colors.white70)))
                    : FeedbackGrid(
                        feedbacks: displayFeedbacks,
                        isLoading: isLoading,
                        onDelete: (item) {
                          Navigator.pop(context);
                          _confirmDelete(item);
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    final p = context.watch<FeedbackProvider>();
    final allFeedbacks = p.feedbacks;

    final filteredFeedbacks = allFeedbacks.where((f) {
      final matchesCategory = _selectedCategory == 'all' || f.category.toLowerCase() == _selectedCategory.toLowerCase();

      bool matchesDate = true;
      if (_dateFilter != 'all' && f.createdAt != null) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        
        if (_dateFilter == 'today') {
           matchesDate = f.createdAt!.isAfter(todayStart) || f.createdAt!.isAtSameMomentAs(todayStart);
        } else if (_dateFilter == 'this_week') {
           matchesDate = f.createdAt!.isAfter(now.subtract(const Duration(days: 7)));
        } else if (_dateFilter == 'this_month') {
           final startOfMonth = DateTime(now.year, now.month, 1);
           matchesDate = f.createdAt!.isAfter(startOfMonth) || f.createdAt!.isAtSameMomentAs(startOfMonth);
        } else if (_dateFilter == 'select_month' && _customStartDate != null) {
           matchesDate = f.createdAt!.year == _customStartDate!.year && f.createdAt!.month == _customStartDate!.month;
        } else if (_dateFilter == 'month_range' && _customStartDate != null && _customEndDate != null) {
           final start = DateTime(_customStartDate!.year, _customStartDate!.month, 1);
           final end = DateTime(_customEndDate!.year, _customEndDate!.month + 1, 0, 23, 59, 59); // end of end month
           matchesDate = f.createdAt!.isAfter(start) && f.createdAt!.isBefore(end);
        } else if (_dateFilter == 'select_date' && _customStartDate != null) {
           final targetDate = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
           final fDate = DateTime(f.createdAt!.year, f.createdAt!.month, f.createdAt!.day);
           matchesDate = fDate.isAtSameMomentAs(targetDate);
        } else if (_dateFilter == 'date_range' && _customStartDate != null && _customEndDate != null) {
           final start = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
           final end = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59);
           matchesDate = f.createdAt!.isAfter(start) && f.createdAt!.isBefore(end);
        }
      }
      return matchesCategory && matchesDate;
    }).toList();

    final totalCount = filteredFeedbacks.length;
    final servicesCount = filteredFeedbacks.where((f) => f.category.toLowerCase() == 'services').length;
    final productCount = filteredFeedbacks.where((f) => f.category.toLowerCase() == 'product quality').length;

    String dateSuffix = '';
    String? customDateLabel;
    String? customDateRangeLabel;
    String? customMonthLabel;
    String? customMonthRangeLabel;
    final now = DateTime.now();

    if (_dateFilter == 'today') {
      dateSuffix = 'Today: ${DateFormat('dd/MM/yyyy').format(now)}';
    } else if (_dateFilter == 'this_week') {
      final startWeek = now.subtract(const Duration(days: 7));
      dateSuffix = 'This Week: ${DateFormat('dd/MM').format(startWeek)} - ${DateFormat('dd/MM/yyyy').format(now)}';
    } else if (_dateFilter == 'this_month') {
      dateSuffix = 'This Month: ${DateFormat('MMM yyyy').format(now)}';
    } else if (_dateFilter == 'select_month' && _customStartDate != null) {
      final f = DateFormat('MMM yyyy').format(_customStartDate!);
      dateSuffix = f;
      customMonthLabel = f;
    } else if (_dateFilter == 'month_range' && _customStartDate != null && _customEndDate != null) {
      final f1 = DateFormat('MMM yyyy').format(_customStartDate!);
      final f2 = DateFormat('MMM yyyy').format(_customEndDate!);
      dateSuffix = '$f1 - $f2';
      customMonthRangeLabel = '$f1 - $f2';
    } else if (_dateFilter == 'select_date' && _customStartDate != null) {
      final f = DateFormat('dd/MM/yyyy').format(_customStartDate!);
      dateSuffix = f;
      customDateLabel = f;
    } else if (_dateFilter == 'date_range' && _customStartDate != null && _customEndDate != null) {
      final f1 = DateFormat('dd/MM/yy').format(_customStartDate!);
      final f2 = DateFormat('dd/MM/yy').format(_customEndDate!);
      dateSuffix = '$f1 - $f2';
      customDateRangeLabel = '$f1 - $f2';
    }

    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner (Black & Gold)
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
                  Icon(BootstrapIcons.chat_right_text_fill, color: gold, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Customer Feedbacks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Statistics Banner
            FeedbackStatisticsSection(
              totalCount: totalCount,
              servicesCount: servicesCount,
              productCount: productCount,
              dateSuffix: dateSuffix,
              onTotalTap: () => _showFeedbackDialog('all', 'Total Feedbacks $dateSuffix', filteredFeedbacks, p.isLoading),
              onServicesTap: () => _showFeedbackDialog('services', 'Services Feedback $dateSuffix', filteredFeedbacks, p.isLoading),
              onProductTap: () => _showFeedbackDialog('product quality', 'Product Quality Feedback $dateSuffix', filteredFeedbacks, p.isLoading),
            ),
            const SizedBox(height: 32),

            // Filter bar banner
            FeedbackFilterBar(
              selectedCategory: _selectedCategory,
              dateFilter: _dateFilter,
              customDateLabel: customDateLabel,
              customDateRangeLabel: customDateRangeLabel,
              customMonthLabel: customMonthLabel,
              customMonthRangeLabel: customMonthRangeLabel,
              onCategoryChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
              onDateFilterChanged: (val) {
                if (val == 'select_month') {
                  _pickMonth();
                } else if (val == 'month_range') {
                  _pickMonthRange();
                } else if (val == 'select_date') {
                  _pickDate();
                } else if (val == 'date_range') {
                  _pickDateRange();
                } else if (val != null) {
                  setState(() => _dateFilter = val);
                }
              },
            ),
            const SizedBox(height: 24),

            // Graph Overview
            FeedbackOverviewChart(
              feedbacks: filteredFeedbacks,
              dateFilter: _dateFilter,
              customStartDate: _customStartDate,
              customEndDate: _customEndDate,
              dateSuffix: dateSuffix,
            ),
          ],
        ),
      ),
    );
  }
}