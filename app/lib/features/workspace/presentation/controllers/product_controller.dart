import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/features/workspace/data/repositories/product_repository.dart';
import 'package:vodan/features/workspace/data/repositories/workspace_repository.dart';
import '../../data/models/product_model.dart';

part 'product_controller.g.dart';

@Riverpod(keepAlive: true)
FutureOr<List<String>> productCategories(Ref ref) async {
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null || workspaceId.isEmpty) return ['Semua'];

  final repo = ref.watch(productRepositoryProvider);
  return await repo.getAvailableCategories(workspaceId);
}

@Riverpod(keepAlive: true)
class ProductController extends _$ProductController {
  Timer? _debounceTimer;

  String _currentQuery = '';
  String _currentCategory = 'Semua';

  String get selectedCategory => _currentCategory;

  @override
  FutureOr<List<ProductModel>> build() async {
    return _getProduct();
  }

  Future<List<ProductModel>> _getProduct() async {
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null || workspaceId.isEmpty) return [];

    try {
      final productRepo = ref.read(productRepositoryProvider);
      final products = await productRepo.getProducts(workspaceId: workspaceId, query: _currentQuery, category: _currentCategory);

      if (products.isEmpty) {
        final workspaceRepo = ref.read(workspaceRepositoryProvider);
        final isExists = await workspaceRepo.checkWorkspaceExists(workspaceId);

        if (!isExists) {
          ref.read(currentWorkspaceIdProvider.notifier).clearWorkspaceId();
          throw Exception('Lapak tidak ditemukan!');
        }
      }

      return products;
    } catch (e) {
      throw Exception('Workspace tidak ditemukan.');
    }
  }

  void updateSearch(String query) {
    if (_currentQuery == query) return;
    _currentQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      ref.invalidateSelf();
    });
  }

  void updateCategory(String category) async {
    if (_currentCategory == category) return;
    _currentCategory = category;

    _debounceTimer?.cancel();

    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidate(productCategoriesProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _getProduct());
  }
}
