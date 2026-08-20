import 'product_model.dart';

class CartItemModel {
  CartItemModel({
    required this.product,
    required this.quantity,
    this.overridePrice
  });

  final ProductModel product;
  final int quantity;
  final double? overridePrice;

  num get totalPrice {
    final effectivePrice = overridePrice ?? product.price;
    return effectivePrice * quantity;
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    double? overridePrice,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      overridePrice: overridePrice ?? this.overridePrice
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel(
        id: json['id'].toString(),
        workspaceId: '', 
        name: json['name'].toString(),
        category: json['category'].toString(),
        nlpAlias: json['nlp_alias'],
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        currency: 'IDR', 
        stock: 0,        
        sold: 0,         
        isActive: false, 
      ),
      quantity: (json['qty'] as num?)?.toInt() ?? 0,
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