import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../models/report_model.dart';
import 'pdf_export_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchAllReports();
    });
  }

  void _exportPdf(ReportProvider provider) async {
    if (provider.attendanceReport == null || provider.financialReport == null || provider.performanceReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reports not fully loaded yet.')));
      return;
    }
    
    await PdfExportHelper.generateAndPrintReport(
      attendance: provider.attendanceReport!,
      financial: provider.financialReport!,
      performance: provider.performanceReport!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Attendance'),
            Tab(text: 'Financials'),
            Tab(text: 'Performance'),
          ],
        ),
        actions: [
          Consumer<ReportProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Export to PDF',
                onPressed: provider.isLoading ? null : () => _exportPdf(provider),
              );
            }
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.attendanceReport == null) {
            return const Center(child: Text('No data available.'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAttendanceTab(provider.attendanceReport!),
              _buildFinancialsTab(provider.financialReport!),
              _buildPerformanceTab(provider.performanceReport!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttendanceTab(AttendanceReport report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('Attendance Rate', '${report.attendanceRate.toStringAsFixed(1)}%', Icons.pie_chart, Colors.blue),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Present', '${report.totalPresent}', Icons.check_circle, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Absent', '${report.totalAbsent}', Icons.cancel, Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialsTab(FinancialReport report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('Total Collected', '${report.totalCollected.toStringAsFixed(2)}', Icons.monetization_on, Colors.green),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending', '${report.totalPending.toStringAsFixed(2)}', Icons.pending_actions, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Overdue', '${report.totalOverdue.toStringAsFixed(2)}', Icons.warning, Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceTab(PerformanceReport report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('Resolution Rate', '${report.complaintResolutionRate.toStringAsFixed(1)}%', Icons.star, Colors.amber),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Complaints', '${report.totalComplaints}', Icons.report_problem, Colors.redAccent)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Leaves Processed', '${report.totalLeavesProcessed}', Icons.event_available, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
