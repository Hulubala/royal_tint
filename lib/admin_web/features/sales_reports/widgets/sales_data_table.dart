import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';

class SalesDataTable extends StatefulWidget {
  const SalesDataTable({super.key});

  @override
  State<SalesDataTable> createState() => _SalesDataTableState();
}

class _SalesDataTableState extends State<SalesDataTable> {
  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();
    final sales = provider.filteredSales;
    final isDaily = provider.selectedPeriod == ReportPeriod.daily;

    List<AppointmentModel> sortedSales = List.from(sales);
    if (_sortColumnIndex != null) {
      final timeIndex = isDaily ? 0 : 1;
      final packageIndex = isDaily ? 3 : 4;

      sortedSales.sort((a, b) {
        if (_sortColumnIndex == timeIndex) {
          return _sortAscending 
              ? a.appointmentDateTime.compareTo(b.appointmentDateTime)
              : b.appointmentDateTime.compareTo(a.appointmentDateTime);
        } else if (_sortColumnIndex == packageIndex) {
          return _sortAscending 
              ? a.packageName.compareTo(b.packageName)
              : b.packageName.compareTo(a.packageName);
        }
        return 0;
      });
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'SALES DATA',
              style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          if (sortedSales.isEmpty)
             const Padding(
               padding: EdgeInsets.all(40.0),
               child: Center(child: Text('No sales data available for this period', style: TextStyle(color: Colors.white54))),
             )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      headingRowColor: const WidgetStatePropertyAll(Color(0xFF1A1A1A)),
                      headingTextStyle: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 14),
                      dataTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
                      dividerThickness: 1,
                      border: TableBorder(
                        horizontalInside: BorderSide(color: Colors.white24.withValues(alpha: 0.1), width: 1),
                      ),
                      columns: [
                        if (!isDaily)
                          const DataColumn(label: Text('DATE')),
                        DataColumn(
                          label: const Text('TIME'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        const DataColumn(label: Text('CUSTOMER')),
                        const DataColumn(label: Text('CAR PLATE')),
                        DataColumn(
                          label: const Text('PACKAGE'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        const DataColumn(label: Text('PRICE')),
                      ],
                      rows: sortedSales.map((app) {
                        final dateStr = DateFormat('dd MMM yyyy').format(app.appointmentDateTime);
                        final timeStr = DateFormat('hh:mm a').format(app.appointmentDateTime);
                        
                        return DataRow(
                          cells: [
                            if (!isDaily)
                              DataCell(Text(dateStr)),
                            DataCell(Text(timeStr)),
                            DataCell(Text(app.customerName)),
                            DataCell(Text(app.vehiclePlate.toUpperCase())),
                            DataCell(Text(app.packageName)),
                            DataCell(Text('RM ${app.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: gold, fontWeight: FontWeight.bold))),
                          ]
                        );
                      }).toList(),
                    ),
                  ),
                );
              }
            ),
        ],
      ),
    );
  }
}
