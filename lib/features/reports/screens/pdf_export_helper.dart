import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/report_model.dart';
import 'package:intl/intl.dart';

class PdfExportHelper {
  static Future<void> generateAndPrintReport({
    required AttendanceReport attendance,
    required FinancialReport financial,
    required PerformanceReport performance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('School Sathi - Driver Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('MMM d, yyyy').format(DateTime.now()), style: const pw.TextStyle(fontSize: 14)),
                  ]
                )
              ),
              
              pw.SizedBox(height: 20),
              pw.Text('Attendance Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Bullet(text: 'Total Records: ${attendance.totalRecords}'),
              pw.Bullet(text: 'Present: ${attendance.totalPresent}'),
              pw.Bullet(text: 'Absent: ${attendance.totalAbsent}'),
              pw.Bullet(text: 'Attendance Rate: ${attendance.attendanceRate.toStringAsFixed(1)}%'),
              
              pw.SizedBox(height: 20),
              pw.Text('Financial Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Bullet(text: 'Total Invoices: ${financial.totalInvoices}'),
              pw.Bullet(text: 'Total Collected: \$${financial.totalCollected.toStringAsFixed(2)}'),
              pw.Bullet(text: 'Total Pending: \$${financial.totalPending.toStringAsFixed(2)}'),
              pw.Bullet(text: 'Total Overdue: \$${financial.totalOverdue.toStringAsFixed(2)}'),
              
              pw.SizedBox(height: 20),
              pw.Text('Performance Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Bullet(text: 'Total Complaints: ${performance.totalComplaints}'),
              pw.Bullet(text: 'Resolved Complaints: ${performance.resolvedComplaints}'),
              pw.Bullet(text: 'Resolution Rate: ${performance.complaintResolutionRate.toStringAsFixed(1)}%'),
              pw.Bullet(text: 'Leaves Processed: ${performance.totalLeavesProcessed}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'SchoolSathi_Driver_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf'
    );
  }
}
