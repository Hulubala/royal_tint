import 'package:flutter/material.dart';
import 'package:royal_tint/core/widgets/hoverable_card.dart';

class AppointmentStatsRow extends StatelessWidget {
  const AppointmentStatsRow({
    super.key,
    required this.stats,
    required this.appointmentStatuses,
  });

  /// Your provider currently returns Map<String, int>
  final Map<String, int> stats;

  final List<Map<String, dynamic>> appointmentStatuses;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 🖥 Desktop / Web → 6 cards in one row
        if (constraints.maxWidth >= 1100) {
          return Row(
            children: appointmentStatuses.map((status) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _AppointmentStatCard(
                    label: status['label'] as String,
                    count: stats[status['key'] as String] ?? 0,
                    icon: status['icon'] as IconData,
                    gradientColors: (status['colors'] as List<Color>),
                  ),
                ),
              );
            }).toList(),
          );
        }

        // 📱 Tablet → 2 rows (3 + 3)
        if (constraints.maxWidth >= 700) {
          return Column(
            children: [
              Row(
                children: appointmentStatuses.take(3).map((status) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _AppointmentStatCard(
                        label: status['label'] as String,
                        count: stats[status['key'] as String] ?? 0,
                        icon: status['icon'] as IconData,
                        gradientColors: (status['colors'] as List<Color>),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: appointmentStatuses.skip(3).map((status) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _AppointmentStatCard(
                        label: status['label'] as String,
                        count: stats[status['key'] as String] ?? 0,
                        icon: status['icon'] as IconData,
                        gradientColors: (status['colors'] as List<Color>),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }

        // 📲 Mobile → stacked
        return Column(
          children: appointmentStatuses.map((status) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AppointmentStatCard(
                label: status['label'] as String,
                count: stats[status['key'] as String] ?? 0,
                icon: status['icon'] as IconData,
                gradientColors: (status['colors'] as List<Color>),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _AppointmentStatCard extends StatelessWidget {
  const _AppointmentStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.gradientColors,
  });

  final String label;
  final int count;
  final IconData icon;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}