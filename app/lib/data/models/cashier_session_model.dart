enum QueueStatus {
  pending,
  approved,
  rejected
}

class CashierSessionModel {
  CashierSessionModel({
    required this.workspaceId,
    required this.cashierName,
    required this.deviceId,
    required this.status
  });

  final String workspaceId;
  final String cashierName;
  final String deviceId;
  final QueueStatus status;

  CashierSessionModel copyWith({
    String? workspaceId,
    String? cashierName,
    String? deviceId,
    QueueStatus? status
  }) {
    return CashierSessionModel(
      workspaceId: workspaceId ?? this.workspaceId,
      cashierName: cashierName ?? this.cashierName,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status
    );
  }
}