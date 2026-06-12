import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';

class SalesPdfExportService {
  static Future<void> exportSalesPdf(SalesReportProvider provider) async {
    final pdf = pw.Document();
    
    final List<AppointmentModel> sales = provider.filteredSales;
    final periodLabel = provider.dynamicPeriodLabel.isEmpty ? 'All Time' : provider.dynamicPeriodLabel;
    final totalSales = provider.totalSales;
    final count = provider.totalCompletedAppointments;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(periodLabel),
            pw.SizedBox(height: 24),
            _buildMetrics(totalSales, count),
            pw.SizedBox(height: 24),
            if (sales.isNotEmpty) ...[
              _buildCharts(provider),
              pw.SizedBox(height: 24),
            ],
            _buildTable(sales),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'RoyalTint_SalesReport_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildHeader(String period) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('ROYAL TINT - SALES REPORT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        pw.SizedBox(height: 8),
        pw.Text('Period: $period', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.SizedBox(height: 8),
        pw.Text('Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        pw.Divider(),
      ]
    );
  }

  static pw.Widget _buildMetrics(double total, int count) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _metricBox('TOTAL SALES', 'RM ${total.toStringAsFixed(2)}'),
        _metricBox('COMPLETED APPOINTMENTS', '$count'),
      ]
    );
  }

  static pw.Widget _metricBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        ],
      )
    );
  }

  static pw.Widget _buildTable(List<AppointmentModel> sales) {
    if (sales.isEmpty) {
      return pw.Center(child: pw.Text('No sales data available for this period.'));
    }

    final headers = ['Date', 'Time', 'Customer', 'Car Plate', 'Package', 'Price (RM)'];
    
    // Sort sales by date ascending
    final sortedSales = List.from(sales)..sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));

    final data = sortedSales.map((app) {
      return [
        DateFormat('dd MMM yyyy').format(app.appointmentDateTime),
        DateFormat('hh:mm a').format(app.appointmentDateTime),
        app.customerName,
        app.vehiclePlate.toUpperCase(),
        app.packageName,
        app.totalPrice.toStringAsFixed(2),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFD4AF37)), // Gold-ish
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildCharts(SalesReportProvider provider) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('CHARTS & GRAPHS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        pw.SizedBox(height: 16),
        
        _buildBarChartSection(
          title: 'Sales Overview',
          xLabels: provider.chartData.map((d) => '${d.key.replaceAll('\n', ' ')}\n(RM ${d.value.toStringAsFixed(0)})').toList(),
          yValues: provider.chartData.map((d) => d.value).toList(),
          color: PdfColor.fromInt(0xFFD4AF37), // Gold
          minTicksVal: 100,
        ),
        pw.SizedBox(height: 24),
        
        _buildBarChartSection(
          title: 'Sales By Package',
          xLabels: provider.salesByPackage.entries.map((e) => '${e.key.length > 15 ? '${e.key.substring(0, 15)}...' : e.key}\n(RM ${e.value.toStringAsFixed(0)})').toList(),
          yValues: provider.salesByPackage.values.toList(),
          color: PdfColor.fromInt(0xFF1E88E5), // Blue
          minTicksVal: 100,
        ),
        pw.SizedBox(height: 24),
        
        _buildBarChartSection(
          title: 'Vehicle Brands Distribution',
          xLabels: provider.countByCarBrand.entries.map((e) => '${e.key.length > 15 ? '${e.key.substring(0, 15)}...' : e.key}\n(${e.value})').toList(),
          yValues: provider.countByCarBrand.values.map((v) => v.toDouble()).toList(),
          color: PdfColor.fromInt(0xFF43A047), // Green
          minTicksVal: 5,
        ),
        pw.SizedBox(height: 24),
        
        _buildBarChartSection(
          title: 'Vehicle Models Distribution',
          xLabels: provider.countByCarModel.entries.map((e) => '${e.key.length > 15 ? '${e.key.substring(0, 15)}...' : e.key}\n(${e.value})').toList(),
          yValues: provider.countByCarModel.values.map((v) => v.toDouble()).toList(),
          color: PdfColor.fromInt(0xFFE53935), // Red
          minTicksVal: 5,
        ),
      ]
    );
  }

  static double _getNiceInterval(double maxVal) {
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

  static pw.Widget _buildBarChartSection({
    required String title,
    required List<String> xLabels,
    required List<double> yValues,
    required PdfColor color,
    required int minTicksVal,
  }) {
    double maxVal = 0;
    if (yValues.isNotEmpty) {
      maxVal = yValues.reduce((a, b) => a > b ? a : b);
    }
    
    bool isCurrency = minTicksVal == 100;
    
    double niceInterval = isCurrency ? _getNiceInterval(maxVal) : (maxVal <= 10 ? 2 : _getNiceInterval(maxVal));
    
    if (maxVal == 0) {
       maxVal = isCurrency ? 100 : 10;
       niceInterval = isCurrency ? 20 : 2;
    } else {
       double bufferMax = maxVal * 1.1; // Add 10% headroom
       niceInterval = isCurrency ? _getNiceInterval(bufferMax) : (bufferMax <= 10 ? 2 : _getNiceInterval(bufferMax));
       maxVal = (bufferMax / niceInterval).ceil() * niceInterval;
    }

    final Set<int> uniqueTicks = {};
    for (double i = 0; i <= maxVal; i += niceInterval) {
      uniqueTicks.add(i.toInt());
    }
    final List<int> yTicks = uniqueTicks.toList()..sort();

    final paddedLabels = ['', ...xLabels, ''];
    final shiftedData = List.generate(yValues.length, (i) => pw.PointChartValue(i.toDouble() + 1, yValues[i]));

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 150,
            child: pw.Chart(
              grid: pw.CartesianGrid(
                xAxis: pw.FixedAxis(
                  List.generate(paddedLabels.length, (i) => i),
                  marginStart: 10,
                  marginEnd: 10,
                  ticks: true,
                  buildLabel: (v) => pw.Text(paddedLabels[v.toInt()], textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 6)),
                ),
                yAxis: pw.FixedAxis(
                  yTicks,
                  textStyle: const pw.TextStyle(fontSize: 8),
                  buildLabel: (v) => pw.Text(isCurrency ? 'RM ${v.toInt()}' : v.toInt().toString(), style: const pw.TextStyle(fontSize: 8)),
                ),
              ),
              datasets: [
                pw.BarDataSet(
                  color: color,
                  width: xLabels.length > 10 ? 10 : (xLabels.length == 1 ? 40 : 25),
                  data: shiftedData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
