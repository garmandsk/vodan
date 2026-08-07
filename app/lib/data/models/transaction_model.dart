enum PaymentMethod {
  cash,
  qris,
  transfer
}

enum TransactionStatus {
  pending,
  paid, 
  rejected
}

class TransactionModel {
  TransactionModel({
    required this.id,
    required this.workspaceId,
    required this.transactionTime,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
    required this.cashierName,
    required this.status,
  });

  final String id;
  final String workspaceId;
  final DateTime transactionTime;
  final List<dynamic> items;
  final int totalPrice;
  final PaymentMethod paymentMethod;
  final String cashierName;
  final TransactionStatus status;

  TransactionModel copyWith({
    DateTime? transactionTime,
    List<dynamic>? items,
    int? totalPrice,
    PaymentMethod? paymentMethod,
    String? cashierName,
    TransactionStatus? status
  }) {
    return TransactionModel(
      id: id,
      workspaceId: workspaceId,
      transactionTime: transactionTime ?? this.transactionTime,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashierName: cashierName ?? this.cashierName,
      status: status ?? this.status
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json){
    return TransactionModel(
      id: json['id'].toString(),
      workspaceId: json['workspace_id'].toString(),
      transactionTime: DateTime.parse(json['transaction_time']),
      items: json['items'] ?? [],
      totalPrice: (json['total_price'] ?? 0).toInt(),
      paymentMethod: PaymentMethod.values.asNameMap()[json['payment_method']] ?? PaymentMethod.cash,
      cashierName: json['cashier_name'].toString(),
      status: TransactionStatus.values.asNameMap()[json['status']] ?? TransactionStatus.pending,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'workspace_id': workspaceId,
      'transaction_time': transactionTime.toIso8601String(),
      'items': items,
      'total_price': totalPrice,
      'payment_method': paymentMethod.name,
      'cashier_name': cashierName,
      'status': status.name,
    };
  }
}