import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';

part 'cart_provider.g.dart';

@riverpod 
class Cart extends _$Cart {
  @override 
  List<CartItemModel> build() {
    return [];
  }

  void addProduct(ProductModel product) {
    final index = state.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      state = [...state, CartItemModel(product: product, quantity: 1)];
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      state = state.where((item) => item.product.id != productId).toList();
      return;
    }

    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item
    ];
  }

  void setOverridePrice(String productId, int newPrice) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(overridePrice: newPrice)
        else
          item
    ];
  }

  void clearCart() {
    state = [];
  }

  int get totalAmount {
    return state.fold(0, (sum, item) => sum + item.totalPrice);
  }
}