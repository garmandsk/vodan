// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductList)
final productListProvider = ProductListFamily._();

final class ProductListProvider
    extends $AsyncNotifierProvider<ProductList, List<ProductModel>> {
  ProductListProvider._(
      {required ProductListFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'productListProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$productListHash();

  @override
  String toString() {
    return r'productListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductList create() => ProductList();

  @override
  bool operator ==(Object other) {
    return other is ProductListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productListHash() => r'f90e6c1c47f7cdead14f42e8abe7d61083624474';

final class ProductListFamily extends $Family
    with
        $ClassFamilyOverride<ProductList, AsyncValue<List<ProductModel>>,
            List<ProductModel>, FutureOr<List<ProductModel>>, String> {
  ProductListFamily._()
      : super(
          retry: null,
          name: r'productListProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  ProductListProvider call(
    String workspaceId,
  ) =>
      ProductListProvider._(argument: workspaceId, from: this);

  @override
  String toString() => r'productListProvider';
}

abstract class _$ProductList extends $AsyncNotifier<List<ProductModel>> {
  late final _$args = ref.$arg as String;
  String get workspaceId => _$args;

  FutureOr<List<ProductModel>> build(
    String workspaceId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ProductModel>>, List<ProductModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ProductModel>>, List<ProductModel>>,
        AsyncValue<List<ProductModel>>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
