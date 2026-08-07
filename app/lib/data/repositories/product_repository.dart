import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product_model.dart';

// Identitas dari riverpod_generator
part 'product_repository.g.dart';

class ProductRepository {
  ProductRepository(this._supabase);
  
  final SupabaseClient _supabase;

  Future<List<ProductModel>> getProducts(String workspaceId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('workspace_id', workspaceId)
          .eq('is_active', true)
          .order('name', ascending: true);
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal menarik data produk: $e');
    }
  }
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(Supabase.instance.client);
}