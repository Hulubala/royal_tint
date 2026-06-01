import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';

class SalesReportHeader extends StatelessWidget {
  final VoidCallback onPeriodChanged;
  const SalesReportHeader({super.key, required this.onPeriodChanged});

  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();

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
              _buildDateSelector(context, provider),
              SizedBox(
                width: 180,
                child: MenuDropdown<ReportPeriod>(
                  label: '',
                  value: provider.selectedPeriod,
                  items: const [
                    MenuItem(value: ReportPeriod.daily, label: 'DAILY'),
                    MenuItem(value: ReportPeriod.monthly, label: 'MONTHLY'),
                    MenuItem(value: ReportPeriod.yearly, label: 'YEARLY'),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      provider.setPeriod(val);
                      onPeriodChanged();
                    }
                  },
                  hint: 'Filter',
                  icon: BootstrapIcons.calendar_event,
                  labelColor: gold,
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _buildDateSelector(BuildContext context, SalesReportProvider provider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: gold, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(BootstrapIcons.chevron_left, color: gold, size: 16),
            onPressed: () => provider.navigatePrevious(),
          ),
          InkWell(
            onTap: () => _pickDate(context, provider),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text(
                  provider.periodLabel.toUpperCase(),
                  style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(BootstrapIcons.chevron_right, color: gold, size: 16),
            onPressed: () => provider.navigateNext(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, SalesReportProvider provider) async {
    if (provider.selectedPeriod == ReportPeriod.daily) {
      final date = await showDatePicker(
        context: context,
        initialDate: provider.selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: gold,
                onPrimary: Colors.black,
                surface: Colors.black,
                onSurface: gold,
              ),
            ),
            child: child!,
          );
        },
      );
      if (date != null) provider.setSelectedDate(date);
    } else if (provider.selectedPeriod == ReportPeriod.monthly) {
      _showMonthYearPicker(context, provider, isMonth: true);
    } else {
      _showMonthYearPicker(context, provider, isMonth: false);
    }
  }

  void _showMonthYearPicker(BuildContext context, SalesReportProvider provider, {required bool isMonth}) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedYear = provider.selectedDate.year;
        int selectedMonth = provider.selectedDate.month;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: gold, width: 2),
              ),
              title: Text(
                isMonth ? 'Select Month & Year' : 'Select Year',
                style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: gold),
                        onPressed: () => setState(() => selectedYear--),
                      ),
                      Text(
                        selectedYear.toString(),
                        style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: gold),
                        onPressed: () => setState(() => selectedYear++),
                      ),
                    ],
                  ),
                  if (isMonth) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (index) {
                        final m = index + 1;
                        final isSelected = m == selectedMonth;
                        return InkWell(
                          onTap: () => setState(() => selectedMonth = m),
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? gold : bg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: gold),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('MMM').format(DateTime(2020, m)),
                                style: TextStyle(
                                  color: isSelected ? Colors.black : gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    provider.setSelectedDate(DateTime(selectedYear, selectedMonth, 1));
                    Navigator.pop(context);
                  },
                  child: const Text('OK', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
