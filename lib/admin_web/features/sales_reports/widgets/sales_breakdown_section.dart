import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';

class SalesBreakdownSection extends StatelessWidget {
  const SalesBreakdownSection({super.key});

  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 2),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: gold,
              unselectedLabelColor: Colors.white54,
              indicatorColor: gold,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'PACKAGES'),
                Tab(text: 'BRANDS'),
                Tab(text: 'MODELS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPackageBreakdown(provider),
                  _buildCountBreakdown(provider, provider.countByCarBrand),
                  _buildModelsBreakdown(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getNiceInterval(double maxVal) {
    if (maxVal <= 5) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    if (maxVal <= 500) return 100;
    if (maxVal <= 1000) return 200;
    if (maxVal <= 2000) return 500;
    if (maxVal <= 5000) return 1000;
    if (maxVal <= 10000) return 2000;
    return 5000;
  }

  Widget _buildSecondaryBarChart(Map<String, dynamic> dataMap, bool isCurrency) {
    if (dataMap.isEmpty) return const SizedBox();

    double maxY = 0;
    for (var d in dataMap.values) {
      final val = d is double ? d : (d as int).toDouble();
      if (val > maxY) maxY = val;
    }
    
    if (maxY == 0) {
       maxY = isCurrency ? 100 : 10;
    } else {
       double bufferMax = maxY * 1.1; // Add 10% headroom
       double niceInterval = isCurrency ? _getNiceInterval(bufferMax) : (bufferMax <= 10 ? 2 : _getNiceInterval(bufferMax));
       maxY = (bufferMax / niceInterval).ceil() * niceInterval;
    }
    double niceInterval = isCurrency ? _getNiceInterval(maxY) : (maxY <= 10 ? 2 : _getNiceInterval(maxY));
    
    final entries = dataMap.entries.toList();

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          groupsSpace: entries.length > 20 ? 12 : (entries.length > 10 ? 24 : 48),
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => gold,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = isCurrency ? 'RM ${rod.toY.toStringAsFixed(2)}' : '${rod.toY.toInt()}';
                return BarTooltipItem(
                  label,
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
                  if (value.toInt() >= 0 && value.toInt() < entries.length) {
                    String label = entries[value.toInt()].key;
                    if (label.contains(' ')) {
                      label = label.replaceFirst(' ', '\n');
                    } else if (label.length > 10) {
                      label = '${label.substring(0, 8)}\n${label.substring(8)}';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(label.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: niceInterval,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  final label = isCurrency ? 'RM ${value.toInt()}' : '${value.toInt()}';
                  return Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: niceInterval,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            final val = entry.value.value is double ? entry.value.value as double : (entry.value.value as int).toDouble();
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: val,
                  color: gold,
                  width: entries.length > 20 ? 12 : (entries.length > 10 ? 16 : 32),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
    );
  }

  Widget _buildPackageBreakdown(SalesReportProvider provider) {
    final data = provider.salesByPackage;
    if (data.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white54)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final entry = data.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Text(
                          'RM ${NumberFormat('#,##0.00').format(entry.value)}',
                          style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: provider.totalSales > 0 ? entry.value / provider.totalSales : 0,
                      backgroundColor: Colors.white12,
                      color: gold,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'PACKAGE BREAKDOWN ${provider.dynamicPeriodLabel.isEmpty ? "" : "(${provider.dynamicPeriodLabel})"}',
              style: const TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 16),
          _buildSecondaryBarChart(data, true),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCountBreakdown(SalesReportProvider provider, Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white54)));
    }
    int total = data.values.fold(0, (sum, val) => sum + val);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final entry = data.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Text(
                          '${entry.value} (${(entry.value / total * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: Colors.white12,
                      color: gold,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'VEHICLE DISTRIBUTION ${provider.dynamicPeriodLabel.isEmpty ? "" : "(${provider.dynamicPeriodLabel})"}',
              style: const TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 16),
          _buildSecondaryBarChart(data, false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildModelsBreakdown(SalesReportProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, right: 24.0, bottom: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 200,
              child: MenuDropdown<String>(
                label: '',
                value: provider.selectedBrandFilter,
                items: provider.availableBrands.map((b) => MenuItem(value: b, label: b.toUpperCase())).toList(),
                onChanged: (val) {
                  if (val != null) provider.setBrandFilter(val);
                },
                hint: 'Filter by Brand',
                icon: BootstrapIcons.filter,
                labelColor: gold,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildCountBreakdown(provider, provider.countByCarModel),
        )
      ],
    );
  }
}
