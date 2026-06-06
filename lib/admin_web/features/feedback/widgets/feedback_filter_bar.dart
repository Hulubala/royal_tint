import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';

class FeedbackFilterBar extends StatelessWidget {
  final String selectedCategory;
  final String dateFilter;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onDateFilterChanged;
  final String? customDateLabel;
  final String? customDateRangeLabel;
  final String? customMonthLabel;
  final String? customMonthRangeLabel;

  const FeedbackFilterBar({
    super.key,
    required this.selectedCategory,
    required this.dateFilter,
    required this.onCategoryChanged,
    required this.onDateFilterChanged,
    this.customDateLabel,
    this.customDateRangeLabel,
    this.customMonthLabel,
    this.customMonthRangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;



          final categoryDropdown = MenuDropdown<String>(
            label: 'Category',
            icon: BootstrapIcons.funnel,
            hint: 'All Categories',
            value: selectedCategory,
            items: const [
              MenuItem(value: 'all', label: 'All Categories'),
              MenuItem(value: 'services', label: 'Services'),
              MenuItem(value: 'product quality', label: 'Product Quality'),
            ],
            onChanged: onCategoryChanged,
          );

          final dateDropdown = MenuDropdown<String>(
            label: 'Date Filter',
            icon: BootstrapIcons.calendar,
            hint: 'All Time',
            value: dateFilter,
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
            onChanged: onDateFilterChanged,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                categoryDropdown,
                const SizedBox(height: 16),
                dateDropdown,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: categoryDropdown),
              const SizedBox(width: 16),
              Expanded(child: dateDropdown),
            ],
          );
        },
      ),
    );
  }
}
