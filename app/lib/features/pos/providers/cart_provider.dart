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

  void addAiOrders(List<dynamic> aiOrders, List<ProductModel> catalog) {
    var currentState = state;

    for (final order in aiOrders) {
      final productId = order['id'] as String;
      final qty = order['qty'] as int;

      final productMatch = catalog.where((p) => p.id == productId).firstOrNull;
      if (productMatch == null) continue;

      final cartIndex = currentState.indexWhere((item) => item.product.id == productId);

      if (cartIndex != -1) {
        currentState = [
          for (int i = 0; i < currentState.length; i++)
            if (i == cartIndex)
              currentState[i].copyWith(quantity: currentState[i].quantity + qty)
            else
              currentState[i]
        ];
      } else {
        currentState = [...currentState, CartItemModel(product: productMatch, quantity: qty)];
      }
    }

    state = currentState;
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