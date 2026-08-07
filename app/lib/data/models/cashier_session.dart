enum QueueStatus {
  pending,
  approved,
  rejected
}

class CashierSession {
  CashierSession({
    required this.workspaceId,
    required this.cashierName,
    required this.deviceId,
    required this.status
  });

  final String workspaceId;
  final String cashierName;
  final String deviceId;
  final QueueStatus status;

  CashierSession copyWith({
    String? workspaceId,
    String? cashierName,
    String? deviceId,
    QueueStatus? status
  }) {
    return CashierSession(
      workspaceId: workspaceId ?? this.workspaceId,
      cashierName: cashierName ?? this.cashierName,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status
    );
  }
}