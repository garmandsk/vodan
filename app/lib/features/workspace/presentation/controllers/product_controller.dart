import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/data/repositories/product_repository.dart';
import '../../../../data/models/product_model.dart';

part 'product_controller.g.dart';

@Riverpod(keepAlive: true)
class ProductListController extends _$ProductListController {
  @override 
  Future<List<ProductModel>> build(String workspaceId) async {
    final repo = ref.read(productRepositoryProvider);
    return await repo.getProducts(workspaceId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(productRepositoryProvider).getProducts(workspaceId));
  }
}