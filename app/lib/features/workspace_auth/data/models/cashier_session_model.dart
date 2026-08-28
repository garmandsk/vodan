enum QueueStatus {
  pending,
  approved,
  rejected;

  static QueueStatus fromString(String status) {
    return QueueStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => QueueStatus.pending, // Fallback aman jika terjadi error
    );
  }
}

class CashierSessionModel {
  CashierSessionModel({
    this.workspaceId,
    required this.cashierName,
    this.deviceId, 
    required this.sessionId,
    this.status,
    this.createdAt,
    this.isAdmin = false,
    this.isPinVerified = false
  });

  final String? workspaceId;
  final String cashierName;
  final String? deviceId;
  final String sessionId;
  final QueueStatus? status;
  final DateTime? createdAt;
  final bool isAdmin;
  final bool isPinVerified;

  factory CashierSessionModel.fromJson(Map<String, dynamic> json) {
    return CashierSessionModel(
      workspaceId: json['workspace_id'] as String?,
      cashierName: json['cashier_name'] as String,
      deviceId: json['device_id'] as String?,
      sessionId: json['id'] as String, 
      status: json['status'] != null ? QueueStatus.fromString(json['status'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (workspaceId != null) 'workspace_id': workspaceId,
      'cashier_name': cashierName,
      if (deviceId != null) 'device_id': deviceId,
      if (status != null) 'status': status!.name,
    };
  }

  CashierSessionModel copyWith({
    String? workspaceId,
    String? cashierName,
    String? deviceId,
    String? sessionId,
    QueueStatus? status,
    DateTime? createdAt,
    bool? isAdmin,
    bool? isPinVerified
  }) {
    return CashierSessionModel(
      workspaceId: workspaceId ?? this.workspaceId,
      cashierName: cashierName ?? this.cashierName,
      deviceId: deviceId ?? this.deviceId,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      isPinVerified: isPinVerified ?? this.isPinVerified
    );
  }
}