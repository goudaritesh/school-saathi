class AttendanceReport {
  final int totalRecords;
  final int totalPresent;
  final int totalAbsent;
  final double attendanceRate;

  AttendanceReport({
    required this.totalRecords,
    required this.totalPresent,
    required this.totalAbsent,
    required this.attendanceRate,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    return AttendanceReport(
      totalRecords: json['totalRecords'] ?? 0,
      totalPresent: json['totalPresent'] ?? 0,
      totalAbsent: json['totalAbsent'] ?? 0,
      attendanceRate: AttendanceReport._parseDouble(json['attendanceRate']),
    );
  }

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class FinancialReport {
  final double totalCollected;
  final double totalPending;
  final double totalOverdue;
  final int totalInvoices;

  FinancialReport({
    required this.totalCollected,
    required this.totalPending,
    required this.totalOverdue,
    required this.totalInvoices,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      totalCollected: AttendanceReport._parseDouble(json['totalCollected']),
      totalPending: AttendanceReport._parseDouble(json['totalPending']),
      totalOverdue: AttendanceReport._parseDouble(json['totalOverdue']),
      totalInvoices: json['totalInvoices'] ?? 0,
    );
  }
}

class PerformanceReport {
  final int totalComplaints;
  final int resolvedComplaints;
  final double complaintResolutionRate;
  final int totalLeavesProcessed;
  final int approvedLeaves;

  PerformanceReport({
    required this.totalComplaints,
    required this.resolvedComplaints,
    required this.complaintResolutionRate,
    required this.totalLeavesProcessed,
    required this.approvedLeaves,
  });

  factory PerformanceReport.fromJson(Map<String, dynamic> json) {
    return PerformanceReport(
      totalComplaints: json['totalComplaints'] ?? 0,
      resolvedComplaints: json['resolvedComplaints'] ?? 0,
      complaintResolutionRate: AttendanceReport._parseDouble(json['complaintResolutionRate'], 100.0),
      totalLeavesProcessed: json['totalLeavesProcessed'] ?? 0,
      approvedLeaves: json['approvedLeaves'] ?? 0,
    );
  }
}
