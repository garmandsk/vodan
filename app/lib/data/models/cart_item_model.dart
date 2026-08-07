import 'product_model.dart';

class CartItemModel {
  CartItemModel({
    required this.product,
    required this.quantity,
    this.overridePrice
  });

  final ProductModel product;
  final int quantity;
  final int? overridePrice;

  int get totalPrice {
    final effectivePrice = overridePrice ?? product.price;
    return effectivePrice * quantity;
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    int? overridePrice,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      overridePrice: overridePrice ?? this.overridePrice
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': product.id,
      'name': product.name,
      'qty': quantity,
      'price': overridePrice ?? product.price,
      'subtotal': totalPrice
    };
  }
}