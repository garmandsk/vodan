import 'package:vodan/features/workspace/data/models/cart_item_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';

class TransactionUpdateRequestModel {
  const TransactionUpdateRequestModel({
    this.status,
    this.items,
    this.totalPrice,
    this.discount,
    this.paymentMethod,
    this.cashierName
  });

  final TransactionStatus? status;
  final List<CartItemModel>? items;
  final double? totalPrice;
  final double? discount;
  final PaymentMethod? paymentMethod;
  final String? cashierName;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (status != null) data['status'] = status!.name;
    if (items != null) data['items'] = items!.map((e) => e.toJson()).toList();
    if (totalPrice != null) data['total_price'] = totalPrice;
    if (discount != null) data['discount'] = discount;
    if (paymentMethod != null) data['payment_method'] = paymentMethod!.name;
    if (cashierName != null) data['cashier_name'] = cashierName;

    return data;
  }
}