class PaymentConfigModel {
  const PaymentConfigModel({
    this.qrisImageUrl,
    this.transferAccounts = const [],
  });

  final String? qrisImageUrl;
  final List<TransferAccountModel> transferAccounts;

  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) {
    final accounts = json['transfer_accounts'] as List<dynamic>? ?? [];
    return PaymentConfigModel(
      qrisImageUrl: json['qris_image_url'] as String?,
      transferAccounts: accounts
          .map((item) =>
              TransferAccountModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TransferAccountModel {
  const TransferAccountModel({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  final String bankName;
  final String accountNumber;
  final String accountName;

  factory TransferAccountModel.fromJson(Map<String, dynamic> json) {
    return TransferAccountModel(
      bankName: json['bank_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_name': accountName,
      };
}
