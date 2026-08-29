class TicketModel {
  TicketModel({
    required this.passCode,
    required this.expiresAt,
  });

  final String passCode;
  final DateTime expiresAt;

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final expiresAtRaw = json['expires_at'];

    return TicketModel(
      passCode: json['pass_code'] as String,
      expiresAt: expiresAtRaw is DateTime
          ? expiresAtRaw
          : DateTime.parse(expiresAtRaw as String),
    );
  }
}
