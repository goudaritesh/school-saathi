class LeaveModel {
  final String id;
  final String parentId;
  final String driverId;
  final String studentName;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final DateTime createdAt;
  
  // Populated fields
  final String? parentName;
  final String? parentPhone;
  final String? driverName;
  final String? driverPhone;

  LeaveModel({
    required this.id,
    required this.parentId,
    required this.driverId,
    required this.studentName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.parentName,
    this.parentPhone,
    this.driverName,
    this.driverPhone,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['_id'] ?? '',
      parentId: (json['parent'] is Map) ? json['parent']['_id'] : (json['parent'] ?? ''),
      driverId: (json['driver'] is Map) ? json['driver']['_id'] : (json['driver'] ?? ''),
      studentName: json['studentName'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      parentName: (json['parent'] is Map) ? json['parent']['name'] : null,
      parentPhone: (json['parent'] is Map) ? json['parent']['phone'] : null,
      driverName: (json['driver'] is Map) ? json['driver']['name'] : null,
      driverPhone: (json['driver'] is Map) ? json['driver']['phone'] : null,
    );
  }
}
