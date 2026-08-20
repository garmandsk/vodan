enum QueueStatus {
  pending,
  approved,
  rejected
}

class CashierSessionModel {
  CashierSessionModel({
    this.workspaceId,
    required this.cashierName,
    this.deviceId,
    required this.sessionId,
    this.status
  });

  final String? workspaceId;
  final String cashierName;
  final String? deviceId;
  final String sessionId;
  final QueueStatus? status;

  CashierSessionModel copyWith({
    String? workspaceId,
    String? cashierName,
    String? deviceId,
    String? sessionId,
    QueueStatus? status
  }) {
    return CashierSessionModel(
      workspaceId: workspaceId ?? this.workspaceId,
      cashierName: cashierName ?? this.cashierName,
      deviceId: deviceId ?? this.deviceId,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status
    );
  }
}