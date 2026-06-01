import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';

class FeedbackFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final String dateFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onDateFilterChanged;

  const FeedbackFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.dateFilter,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onDateFilterChanged,
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

          final searchField = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 56,
                child: TextField(
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search feedbacks by name, phone, plate...',
                    hintStyle: TextStyle(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                    prefixIcon: const Icon(BootstrapIcons.search, color: Color(0xFFFFD700)),
                    prefixIconConstraints: const BoxConstraints(minHeight: 56, minWidth: 48),
                    filled: true,
                    fillColor: Colors.black,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFFFC700), width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

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
            label: 'Date',
            icon: BootstrapIcons.calendar,
            hint: 'All Time',
            value: dateFilter,
            items: const [
              MenuItem(value: 'all', label: 'All Time'),
              MenuItem(value: 'today', label: 'Today'),
              MenuItem(value: 'this_week', label: 'Last 7 Days'),
              MenuItem(value: 'this_month', label: 'Last 30 Days'),
            ],
            onChanged: onDateFilterChanged,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 16),
                categoryDropdown,
                const SizedBox(height: 16),
                dateDropdown,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 2, child: searchField),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: categoryDropdown),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: dateDropdown),
            ],
          );
        },
      ),
    );
  }
}
