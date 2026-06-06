import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';

class SalesDataTable extends StatefulWidget {
  const SalesDataTable({super.key});

  @override
  State<SalesDataTable> createState() => _SalesDataTableState();
}

class _SalesDataTableState extends State<SalesDataTable> {
  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Colors.black;

  int _sortColumnIndex = 1; // Default to TIME
  bool _sortAscending = false; // Descending default

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesReportProvider>();
    final sales = provider.filteredSales;
    final isDaily = provider.dateFilter == 'today' || provider.dateFilter == 'select_date';

    List<AppointmentModel> sortedSales = List.from(sales);
    final timeIndex = isDaily ? 0 : 1;
    final dateIndex = isDaily ? -1 : 0;
    
    // Ensure the _sortColumnIndex is always valid depending on whether DATE column exists
    if (_sortColumnIndex != timeIndex && _sortColumnIndex != dateIndex) {
      _sortColumnIndex = timeIndex;
    }

    sortedSales.sort((a, b) {
      if (_sortColumnIndex == timeIndex || _sortColumnIndex == dateIndex) {
          return _sortAscending 
              ? a.appointmentDateTime.compareTo(b.appointmentDateTime)
              : b.appointmentDateTime.compareTo(a.appointmentDateTime);
      }
      return 0;
    });
    
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'SALES DATA ${provider.dynamicPeriodLabel.isEmpty ? "" : "(${provider.dynamicPeriodLabel})"}',
              style: const TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
                          DataColumn(
                            label: Row(
                              children: [
                                const Text('DATE'),
                                if (_sortColumnIndex != dateIndex) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.unfold_more, size: 16, color: Colors.white54),
                                ],
                              ],
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            },
                          ),
                        DataColumn(
                          label: Row(
                            children: [
                              const Text('TIME'),
                              if (_sortColumnIndex != timeIndex) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.unfold_more, size: 16, color: Colors.white54),
                              ],
                            ],
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        const DataColumn(label: Text('CUSTOMER')),
                        const DataColumn(label: Text('CAR PLATE')),
                        const DataColumn(label: Text('PACKAGE')),
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
