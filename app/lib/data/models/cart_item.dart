import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
    this.overridePrice
  });

  final Product product;
  final int quantity;
  final int? overridePrice;

  int get totalPrice {
    final effectivePrice = overridePrice ?? product.price;
    return effectivePrice * quantity;
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    int? overridePrice,
  }) {
    return CartItem(
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