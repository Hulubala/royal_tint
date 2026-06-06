import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/admin_web/features/feedback/models/feedback_item.dart';

class FeedbackOverviewChart extends StatelessWidget {
  final List<FeedbackItem> feedbacks;
  final String dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String dateSuffix;

  const FeedbackOverviewChart({
    super.key,
    required this.feedbacks,
    required this.dateFilter,
    this.customStartDate,
    this.customEndDate,
    required this.dateSuffix,
  });

  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  List<MapEntry<String, int>> _generateChartData() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    Map<String, int> counts = {};

    if (dateFilter == 'today' || (dateFilter == 'select_date' && customStartDate != null && customStartDate!.isAtSameMomentAs(todayStart))) {
      // Group by hour
      for (int i = 9; i <= 18; i++) {
        counts['${i.toString().padLeft(2, '0')}:00'] = 0;
      }
      for (var f in feedbacks) {
        if (f.createdAt != null) {
          final hourStr = '${f.createdAt!.hour.toString().padLeft(2, '0')}:00';
          if (counts.containsKey(hourStr)) {
            counts[hourStr] = counts[hourStr]! + 1;
          }
        }
      }
    } else if (dateFilter == 'this_week') {
      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        counts[DateFormat('E').format(d)] = 0;
      }
      for (var f in feedbacks) {
        if (f.createdAt != null) {
          final dayStr = DateFormat('E').format(f.createdAt!);
          if (counts.containsKey(dayStr)) {
            counts[dayStr] = counts[dayStr]! + 1;
          }
        }
      }
    } else if (dateFilter == 'this_month' || dateFilter == 'select_month') {
      // Last 4 weeks approximately
      counts['Week 1'] = 0;
      counts['Week 2'] = 0;
      counts['Week 3'] = 0;
      counts['Week 4'] = 0;
      final startOfMonth = dateFilter == 'this_month' 
          ? DateTime(now.year, now.month, 1) 
          : DateTime(customStartDate!.year, customStartDate!.month, 1);
          
      for (var f in feedbacks) {
        if (f.createdAt != null && (f.createdAt!.isAfter(startOfMonth) || f.createdAt!.isAtSameMomentAs(startOfMonth))) {
          final daysDiff = f.createdAt!.difference(startOfMonth).inDays;
          if (daysDiff < 7) {
            counts['Week 1'] = counts['Week 1']! + 1;
          } else if (daysDiff < 14) counts['Week 2'] = counts['Week 2']! + 1;
          else if (daysDiff < 21) counts['Week 3'] = counts['Week 3']! + 1;
          else counts['Week 4'] = counts['Week 4']! + 1;
        }
      }
    } else if (dateFilter == 'all' || dateFilter == 'month_range') {
      // Group by month
      if (dateFilter == 'all') {
        for (int i = 5; i >= 0; i--) {
          final m = DateTime(now.year, now.month - i, 1);
          counts[DateFormat('MMM').format(m)] = 0;
        }
      } else {
        // month range
        DateTime curr = DateTime(customStartDate!.year, customStartDate!.month, 1);
        final end = DateTime(customEndDate!.year, customEndDate!.month, 1);
        int maxMonths = 12;
        while ((curr.isBefore(end) || curr.isAtSameMomentAs(end)) && maxMonths > 0) {
          counts[DateFormat('MMM').format(curr)] = 0;
          curr = DateTime(curr.year, curr.month + 1, 1);
          maxMonths--;
        }
      }

      for (var f in feedbacks) {
        if (f.createdAt != null) {
          final mStr = DateFormat('MMM').format(f.createdAt!);
          if (counts.containsKey(mStr)) {
            counts[mStr] = counts[mStr]! + 1;
          }
        }
      }
    } else {
      // Date range or custom date generic fallback
      counts['Total'] = feedbacks.length;
    }

    return counts.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _generateChartData();
    double maxDataValue = 0;
    for (var d in chartData) {
      if (d.value > maxDataValue) maxDataValue = d.value.toDouble();
    }
    double maxY = maxDataValue > 0 ? maxDataValue * 1.5 : 10;

    final suffix = dateSuffix.isEmpty ? '' : ' ($dateSuffix)';
    final title = 'FEEDBACK OVERVIEW$suffix'.toUpperCase();

    return Container(
      height: 400,
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
            title,
            style: const TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: maxDataValue == 0 
              ? const Center(
                  child: Text(
                    'No data found for this selection.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : BarChart(
                  swapAnimationDuration: Duration.zero,
                  BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => gold,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} feedbacks',
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value % 1 != 0) return const SizedBox.shrink();
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold));
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
                        toY: entry.value.value.toDouble(),
                        color: gold,
                        width: chartData.length > 10 ? 12 : 24,
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
