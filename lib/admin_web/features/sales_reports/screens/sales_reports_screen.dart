import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';
import 'package:royal_tint/admin_web/features/sales_reports/widgets/sales_report_header.dart';
import 'package:royal_tint/admin_web/features/sales_reports/widgets/sales_metrics_row.dart';
import 'package:royal_tint/admin_web/features/sales_reports/widgets/sales_data_table.dart';
import 'package:royal_tint/admin_web/features/sales_reports/widgets/sales_overview_chart.dart';
import 'package:royal_tint/admin_web/features/sales_reports/widgets/sales_breakdown_section.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({super.key});

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  static const Color gold = Color(0xFFFFD700);

  bool _initialized = false;
  // Key to force rebuild of DataTable when period changes (resetting sort state)
  Key _tableKey = UniqueKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProv = context.watch<AuthProvider>();
    if (!_initialized && authProv.isAuthenticated) {
      _initialized = true;
      final branchID = authProv.branchID;
      if (branchID != null) {
        final prov = context.read<SalesReportProvider>();
        Future.microtask(() => prov.loadSales(branchID));
      }
    }
  }

  void _onPeriodChanged() {
    setState(() {
      _tableKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();

    return Container(
      color: Colors.white,
      width: double.infinity,
      child: provider.isLoading
          ? const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: gold),
            ))
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SalesReportHeader(onPeriodChanged: _onPeriodChanged),
                    const SizedBox(height: 32),
                    const SalesMetricsRow(),
                    const SizedBox(height: 32),
                    
                    SalesDataTable(key: _tableKey),
                    const SizedBox(height: 32),
                
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        if (isWide) {
                          return const SizedBox(
                            height: 650,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: SalesOverviewChart()),
                                SizedBox(width: 32),
                                Expanded(child: SalesBreakdownSection()),
                              ],
                            ),
                          );
                        } else {
                          return const Column(
                            children: [
                              SizedBox(height: 450, child: SalesOverviewChart()),
                              SizedBox(height: 32),
                              SizedBox(height: 700, child: SalesBreakdownSection()),
                            ],
                          );
                        }
                      }
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
