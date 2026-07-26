class ComplaintResponse {
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime createdAt;

  ComplaintResponse({
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.createdAt,
  });

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintResponse(
      senderId: (json['sender'] is Map) ? json['sender']['_id'] : json['sender'],
      senderName: (json['sender'] is Map) ? json['sender']['name'] : 'Unknown',
      senderRole: (json['sender'] is Map) ? json['sender']['role'] : '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class ComplaintModel {
  final String id;
  final String parentId;
  final String? parentName;
  final String driverId;
  final String? driverName;
  final String subject;
  final String description;
  final String? attachmentUrl;
  final String status;
  final List<ComplaintResponse> responses;
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    required this.parentId,
    this.parentName,
    required this.driverId,
    this.driverName,
    required this.subject,
    required this.description,
    this.attachmentUrl,
    required this.status,
    required this.responses,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['_id'] ?? '',
      parentId: (json['parent'] is Map) ? json['parent']['_id'] : (json['parent'] ?? ''),
      parentName: (json['parent'] is Map) ? json['parent']['name'] : null,
      driverId: (json['driver'] is Map) ? json['driver']['_id'] : (json['driver'] ?? ''),
      driverName: (json['driver'] is Map) ? json['driver']['name'] : null,
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      status: json['status'] ?? 'open',
      responses: (json['responses'] as List?)
              ?.map((e) => ComplaintResponse.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
