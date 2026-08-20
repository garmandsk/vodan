import 'package:vodan/features/workspace/data/models/cart_item_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';

class TransactionRequestModel {
  const TransactionRequestModel({
    required this.workspaceId,
    required this.items,
    required this.totalPrice,
    this.discount = 0.0,
    this.currency = 'IDR',
    required this.paymentMethod,
    // required String? customerName,
    required this.cashierName,
    required this.status,
  });

  final String workspaceId;
  final List<CartItemModel> items;
  final double totalPrice;
  final double discount;
  final String currency;
  // final String? customerName;
  final PaymentMethod paymentMethod;
  final String cashierName;
  final TransactionStatus status;

  Map<String, dynamic> toJson(){
    return {
      'workspace_id': workspaceId,
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
