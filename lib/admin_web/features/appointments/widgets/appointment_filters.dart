import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';

class AppointmentFilters extends StatelessWidget {
  const AppointmentFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(BootstrapIcons.funnel, color: Color(0xFFFFD700), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'FILTER APPOINTMENTS',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.read<AppointmentProvider>().resetFilters(),
                  icon: const Icon(BootstrapIcons.arrow_clockwise, size: 14),
                  label: const Text('Reset All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SearchField(),
                      const SizedBox(height: 12),
                      _DateFilter(
                        onSelectCustomDate: () => _selectCustomDate(context),
                        onSelectDateRange: () => _selectDateRange(context),
                      ),
                      const SizedBox(height: 12),
                      const _StatusDropdown(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(flex: 2, child: _SearchField()),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DateFilter(
                        onSelectCustomDate: () => _selectCustomDate(context),
                        onSelectDateRange: () => _selectDateRange(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: _StatusDropdown()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final p = context.read<AppointmentProvider>();

    final date = await showDatePicker(
      context: context,
      initialDate: p.customDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (date != null) {
      p.setCustomDate(date);
      p.setDateFilter('custom');
    } else {
      p.setDateFilter('all');
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final p = context.read<AppointmentProvider>();

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (range != null) {
      p.setDateRange(range.start, range.end);
      p.setDateFilter('range');
    } else {
      p.setDateFilter('all');
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Column(
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
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14),
            onChanged: (value) =>
                context.read<AppointmentProvider>().setSearchQuery(value),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Name, phone, or car plate...',
              hintStyle: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.4)),
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
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateFilter extends StatelessWidget {
  const _DateFilter({
    required this.onSelectCustomDate,
    required this.onSelectDateRange,
  });

  final Future<void> Function() onSelectCustomDate;
  final Future<void> Function() onSelectDateRange;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppointmentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MenuDropdown<String>(
          label: 'Date',
          icon: BootstrapIcons.calendar3,
          hint: 'All Dates',
          value: p.dateFilter,
          items: [
            const MenuItem(value: 'all', label: 'All Dates'),
            const MenuItem(value: 'today', label: 'Today'),
            const MenuItem(value: 'tomorrow', label: 'Tomorrow'),
            const MenuItem(value: 'week', label: 'This Week'),
            const MenuItem(value: 'month', label: 'This Month'),
            const MenuItem(value: 'custom', label: 'Select Date...'),
            MenuItem(
              value: 'range',
              label: p.startDate != null && p.endDate != null
                  ? '${DateFormat('dd/MM').format(p.startDate!)} - ${DateFormat('dd/MM').format(p.endDate!)}'
                  : 'Date Range...',
            ),
          ],
          onChanged: (value) async {
            if (value == null) return;

            context.read<AppointmentProvider>().setDateFilter(value);

            if (value == 'custom') {
              await onSelectCustomDate();
            } else if (value == 'range') {
              await onSelectDateRange();
            }
          },
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppointmentProvider>();

    return MenuDropdown<String>(
      label: 'Status',
      icon: BootstrapIcons.bookmark,
      hint: 'All Status',
      value: p.selectedStatus,
      items: const [
        MenuItem(value: 'all', label: 'All Status'),
        MenuItem(value: 'pending', label: 'Pending'),
        MenuItem(value: 'confirmed', label: 'Confirmed'),
        MenuItem(value: 'in-progress', label: 'In-Progress'),
        MenuItem(value: 'completed', label: 'Completed'),
        MenuItem(value: 'cancelled', label: 'Cancelled'),
      ],
      onChanged: (value) {
        if (value == null) return;
        context.read<AppointmentProvider>().setSelectedStatus(value);
      },
    );
  }
}