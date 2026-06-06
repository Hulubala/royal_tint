import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';

class SalesOverviewChart extends StatelessWidget {
  const SalesOverviewChart({super.key});

  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();
    final chartData = provider.chartData;
    
    double maxY = 0;
    for (var d in chartData) {
      if (d.value > maxY) maxY = d.value;
    }
    
    bool isEmpty = chartData.every((e) => e.value == 0);
    maxY = maxY > 0 ? maxY * 1.2 : 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALES OVERVIEW ${provider.dynamicPeriodLabel.isEmpty ? "" : "(${provider.dynamicPeriodLabel})"}',
            style: const TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: isEmpty
                ? const Center(
                    child: Text(
                      'No sales data available for this period.',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => gold,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'RM ${rod.toY.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                          final label = chartData[value.toInt()].key;
                          // Format X-axis label font size depending on data density
                          double fontSize = chartData.length > 15 ? 10 : 12;
                          // Replace spaces with newlines to help wrapping
                          final wrappedLabel = label.replaceAll(' ', '\n');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(wrappedLabel, style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text('RM ${value.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: chartData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        color: gold,
                        width: chartData.length > 20 ? 8 : (chartData.length > 10 ? 12 : 24),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
