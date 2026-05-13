import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/hoverable_card.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key, required this.managerProvider});
  final ManagerProvider managerProvider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget row4() => SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      icon: BootstrapIcons.calendar_check_fill,
                      value: '${managerProvider.todayAppointments}',
                      label: "Today's Appointments",
                      badge: 'Today',
                      gradientColors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBox(
                      icon: BootstrapIcons.clock_history,
                      value: '${managerProvider.pendingTasks}',
                      label: 'Pending Confirmation',
                      badge: 'Pending',
                      gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBox(
                      icon: BootstrapIcons.cash_coin,
                      value: 'RM ${managerProvider.monthlyRevenue.toStringAsFixed(0)}',
                      label: 'Monthly Revenue',
                      badge: 'This Month',
                      gradientColors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBox(
                      icon: BootstrapIcons.people_fill,
                      value: '${managerProvider.activeStaff}',
                      label: 'Active Staff',
                      badge: 'Active',
                      gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
                    ),
                  ),
                ],
              ),
            );

        Widget grid2x2() => Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: BootstrapIcons.calendar_check_fill,
                          value: '${managerProvider.todayAppointments}',
                          label: "Today's Appointments",
                          badge: 'Today',
                          gradientColors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatBox(
                          icon: BootstrapIcons.clock_history,
                          value: '${managerProvider.pendingTasks}',
                          label: 'Pending Confirmation',
                          badge: 'Pending',
                          gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: BootstrapIcons.cash_coin,
                          value: 'RM ${managerProvider.monthlyRevenue.toStringAsFixed(0)}',
                          label: 'Monthly Revenue',
                          badge: 'This Month',
                          gradientColors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatBox(
                          icon: BootstrapIcons.people_fill,
                          value: '${managerProvider.activeStaff}',
                          label: 'Active Staff',
                          badge: 'Active',
                          gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

        Widget stacked() => Column(
              children: [
                SizedBox(
                  height: 100,
                  child: _StatBox(
                    icon: BootstrapIcons.calendar_check_fill,
                    value: '${managerProvider.todayAppointments}',
                    label: "Today's Appointments",
                    badge: 'Today',
                    gradientColors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: _StatBox(
                    icon: BootstrapIcons.clock_history,
                    value: '${managerProvider.pendingTasks}',
                    label: 'Pending Confirmation',
                    badge: 'Pending',
                    gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: _StatBox(
                    icon: BootstrapIcons.cash_coin,
                    value: 'RM ${managerProvider.monthlyRevenue.toStringAsFixed(0)}',
                    label: 'Monthly Revenue',
                    badge: 'This Month',
                    gradientColors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: _StatBox(
                    icon: BootstrapIcons.people_fill,
                    value: '${managerProvider.activeStaff}',
                    label: 'Active Staff',
                    badge: 'Active',
                    gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
                  ),
                ),
              ],
            );

        if (constraints.maxWidth > 1200) return row4();
        if (constraints.maxWidth > 800) return grid2x2();
        return stacked();
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.badge,
    required this.gradientColors,
  });

  final IconData icon;
  final String value;
  final String label;
  final String badge;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFFE0E0E0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 2),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}