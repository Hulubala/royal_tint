import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';

class AppointmentTypeFilter extends StatelessWidget {
  const AppointmentTypeFilter({
    super.key,
    required this.appointments,
  });

  final List<AppointmentModel> appointments;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppointmentProvider>();

    final filteredByStatus = p.selectedStatus == 'all'
        ? appointments
        : appointments
            .where((apt) => apt.status.toLowerCase() == p.selectedStatus)
            .toList();

    final allCount = filteredByStatus.length;

    final walkInCount = filteredByStatus
        .where((apt) => apt.appointmentType.toLowerCase() == 'walk-in')
        .length;

    final scheduledCount = filteredByStatus
        .where((apt) => apt.appointmentType.toLowerCase() == 'scheduled')
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Row(
        children: [
          Expanded(child: _TypeChip(label: 'All', value: 'all', icon: Icons.grid_view, count: allCount)),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeChip(
              label: 'Walk-In',
              value: 'walk-in',
              icon: Icons.person_outline,
              count: walkInCount,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeChip(
              label: 'Scheduled',
              value: 'scheduled',
              icon: Icons.calendar_month_outlined,
              count: scheduledCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.count,
  });

  final String label;
  final String value;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppointmentProvider>();
    final isSelected = p.selectedType == value;

    return InkWell(
      onTap: () => context.read<AppointmentProvider>().setSelectedType(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)])
              : null,
          color: isSelected ? null : Colors.black,
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFFFD700).withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.black : const Color(0xFFFFD700), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}