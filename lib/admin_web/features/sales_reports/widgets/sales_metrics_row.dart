import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';

class SalesMetricsRow extends StatelessWidget {
  const SalesMetricsRow({super.key});

  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        
        final children = [
          _buildMetricCard(
            title: 'TOTAL SALES ${provider.dynamicPeriodLabel.isEmpty ? "" : "(${provider.dynamicPeriodLabel})"}',
            value: 'RM ${NumberFormat('#,##0.00').format(provider.totalSales)}',
            icon: BootstrapIcons.cash_stack,
          ),
          if (isNarrow) const SizedBox(height: 16) else const SizedBox(width: 24),
          _buildMetricCard(
            title: 'COMPLETED APPOINTMENTS ${provider.dynamicPeriodLabel.isEmpty ? "" : "(${provider.dynamicPeriodLabel})"}',
            value: '${provider.totalCompletedAppointments}',
            icon: BootstrapIcons.check_circle_fill,
          ),
        ];
        
        if (isNarrow) {
          return Column(children: children);
        } else {
          return Row(
            children: [
              Expanded(child: children[0]),
              children[1],
              Expanded(child: children[2]),
            ],
          );
        }
      }
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: gold, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: gold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
