// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Cart)
final cartProvider = CartProvider._();

final class CartProvider extends $NotifierProvider<Cart, List<CartItemModel>> {
  CartProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartItemModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartItemModel>>(value),
    );
  }
}

String _$cartHash() => r'5ad6e6694204e698d630edae6366fd8dd1cc1045';

abstract class _$Cart extends $Notifier<List<CartItemModel>> {
  List<CartItemModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<CartItemModel>, List<CartItemModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<CartItemModel>, List<CartItemModel>>,
        List<CartItemModel>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
