import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/section_container.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Quick Actions',
      icon: BootstrapIcons.lightning_charge_fill,
      minBodyHeight: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 900;

          final actions = <_Action>[
            _Action(
              icon: BootstrapIcons.calendar_plus,
              label: 'NEW BOOKING',
              route: '/manager/appointments',
            ),
            _Action(
              icon: BootstrapIcons.list_task,
              label: 'ASSIGN TASK',
              route: '/manager/staff-tasks',
            ),
            _Action(
              icon: BootstrapIcons.receipt,
              label: 'RECORD SALE',
              route: '/manager/sales-reports',
            ),
            _Action(
              icon: BootstrapIcons.box_seam,
              label: 'MANAGE STOCK',
              route: '/manager/edit-package',
            ),
          ];

          if (isNarrow) {
            // 2x2 grid on smaller screens
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: actions.map((a) {
                return SizedBox(
                  width: (c.maxWidth - 16) / 2,
                  child: _QuickActionButton(
                    icon: a.icon,
                    label: a.label,
                    onTap: () => context.go(a.route),
                  ),
                );
              }).toList(),
            );
          }

          // 4 in a row on wide screens
          return Row(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                Expanded(
                  child: _QuickActionButton(
                    icon: actions[i].icon,
                    label: actions[i].label,
                    onTap: () => context.go(actions[i].route),
                  ),
                ),
                if (i != actions.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Action {
  const _Action({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}