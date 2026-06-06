import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';
import 'package:royal_tint/admin_web/features/sales_reports/services/sales_pdf_export_service.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';

class SalesReportHeader extends StatelessWidget {
  final VoidCallback onPeriodChanged;
  const SalesReportHeader({super.key, required this.onPeriodChanged});

  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();

    String? customDateLabel;
    String? customDateRangeLabel;
    String? customMonthLabel;
    String? customMonthRangeLabel;
    
    if (provider.dateFilter == 'select_month' && provider.customStartDate != null) {
      customMonthLabel = DateFormat('MMM yyyy').format(provider.customStartDate!);
    } else if (provider.dateFilter == 'month_range' && provider.customStartDate != null && provider.customEndDate != null) {
      customMonthRangeLabel = '${DateFormat('MMM yyyy').format(provider.customStartDate!)} - ${DateFormat('MMM yyyy').format(provider.customEndDate!)}';
    } else if (provider.dateFilter == 'select_date' && provider.customStartDate != null) {
      customDateLabel = DateFormat('dd/MM/yyyy').format(provider.customStartDate!);
    } else if (provider.dateFilter == 'date_range' && provider.customStartDate != null && provider.customEndDate != null) {
      customDateRangeLabel = '${DateFormat('dd/MM/yy').format(provider.customStartDate!)} - ${DateFormat('dd/MM/yy').format(provider.customEndDate!)}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 2),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 16,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(BootstrapIcons.graph_up, color: gold, size: 28),
              SizedBox(width: 16),
              Text(
                'Sales & Reports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gold,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 220,
                child: MenuDropdown<String>(
                  label: '',
                  value: provider.dateFilter,
                  items: [
                    const MenuItem(value: 'all', label: 'All Time'),
                    const MenuItem(value: 'today', label: 'Today'),
                    const MenuItem(value: 'this_week', label: 'This Week'),
                    const MenuItem(value: 'this_month', label: 'This Month'),
                    MenuItem(value: 'select_month', label: customMonthLabel ?? 'Select Month'),
                    MenuItem(value: 'month_range', label: customMonthRangeLabel ?? 'Month Range'),
                    MenuItem(value: 'select_date', label: customDateLabel ?? 'Select Date'),
                    MenuItem(value: 'date_range', label: customDateRangeLabel ?? 'Date Range'),
                  ],
                  onChanged: (val) {
                    if (val == 'select_month') {
                      _pickMonth(context, provider);
                    } else if (val == 'month_range') {
                      _pickMonthRange(context, provider);
                    } else if (val == 'select_date') {
                      _pickDate(context, provider);
                    } else if (val == 'date_range') {
                      _pickDateRange(context, provider);
                    } else if (val != null) {
                      provider.setDateFilter(val);
                      onPeriodChanged();
                    }
                  },
                  hint: 'Filter',
                  icon: BootstrapIcons.calendar_event,
                  labelColor: gold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _exportToPdf(context, provider),
                icon: const Icon(BootstrapIcons.file_earmark_pdf, size: 20),
                label: const Text('Export PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Future<void> _pickDate(BuildContext context, SalesReportProvider provider) async {
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
              primary: gold,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: gold,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDateFilter('select_date', startDate: picked);
      onPeriodChanged();
    }
  }

  Future<void> _pickDateRange(BuildContext context, SalesReportProvider provider) async {
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
              primary: gold,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: gold,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDateFilter('date_range', startDate: picked.start, endDate: picked.end);
      onPeriodChanged();
    }
  }

  Future<void> _pickMonth(BuildContext context, SalesReportProvider provider) async {
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
              title: const Text('Select Month', style: TextStyle(color: gold)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
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
      provider.setDateFilter('select_month', startDate: picked);
      onPeriodChanged();
    }
  }

  Future<void> _pickMonthRange(BuildContext context, SalesReportProvider provider) async {
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
              title: const Text('Select Month Range', style: TextStyle(color: gold)),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Start Month', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
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
                    const Text('End Month', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
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
      provider.setDateFilter('month_range', startDate: picked[0], endDate: picked[1]);
      onPeriodChanged();
    }
  }

  void _exportToPdf(BuildContext context, SalesReportProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF Report...')));
    SalesPdfExportService.exportSalesPdf(provider);
  }
}
