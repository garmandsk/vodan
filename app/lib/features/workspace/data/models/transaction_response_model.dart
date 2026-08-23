import 'package:vodan/features/workspace/data/models/cart_item_model.dart';

enum PaymentMethod {
  cash,
  qris,
  transfer
}

enum TransactionStatus {
  pending,
  paid, 
  rejected;

  static TransactionStatus fromString(String? value) {
    if (value == 'pending') {
      return TransactionStatus.pending;
    }
    else if (value == 'paid') {
      return TransactionStatus.paid;
    }
    return TransactionStatus.rejected;
  }
}

class TransactionResponseModel {
  TransactionResponseModel({
    required this.id,
    required this.workspaceId,
    required this.transactionTime,
    required this.items,
    required this.totalPrice,
    required this.discount,
    required this.currency,
    required this.paymentMethod,
    required this.cashierName,
    required this.status,
    this.createdAt,
    this.updatedAt
  });

  final String id;
  final String workspaceId;
  final DateTime transactionTime;
  final List<CartItemModel> items;
  final double totalPrice;
  final double discount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String cashierName;
  final TransactionStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionResponseModel copyWith({
    DateTime? transactionTime,
    List<CartItemModel>? items,
    double? totalPrice,
    double? discount,
    String? currency,
    PaymentMethod? paymentMethod,
    String? cashierName,
    TransactionStatus? status,
  }) {
    return TransactionResponseModel(
      id: id,
      workspaceId: workspaceId,
      transactionTime: transactionTime ?? this.transactionTime,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashierName: cashierName ?? this.cashierName,
      status: status ?? this.status,
    );
  }

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json){
    return TransactionResponseModel(
      id: json['id'].toString(),
      workspaceId: json['workspace_id'].toString(),
      transactionTime: DateTime.tryParse(json['transaction_time']?.toString() ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'IDR',
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
      'items': items.map((e) => e.toJson()).toList(),
      'total_price': totalPrice,
      'discount': discount,
      'currency': currency,
      'payment_method': paymentMethod.name,
      'cashier_name': cashierName,
      'status': status.name,
    };
  }
}