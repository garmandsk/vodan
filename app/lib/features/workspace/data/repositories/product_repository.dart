import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import '../models/product_model.dart';

part 'product_repository.g.dart';

class ProductRepository {
  ProductRepository(this._supabase);
  
  final SupabaseClient _supabase;

  Future<List<ProductModel>> getProducts({
    required String workspaceId,
    String query = '',
    String category = 'Semua'
  }) async {
    try {
      var request = _supabase
          .from('products')
          .select()
          .eq('workspace_id', workspaceId)
          .eq('is_active', true);

      if (category != 'Semua') {
        request = request.eq('category', category);
      }

      if (query.isNotEmpty) {
        request = request.ilike('name', '%$query%');
      }

      final response = await request.order('name', ascending: true);

      // print('respons produk: $response');
      
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal menarik data produk: $e');
    }
  }

  Future<List<String>> getAvailableCategories(String workspaceId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('category')
          .eq('workspace_id', workspaceId)
          .eq('is_active', true);

      final uniqueCategories = response
          .map((e) => e['category'])
          .whereType<String>() // Cast dengan aman
          .where((c) => c.trim().isNotEmpty) // Buang yang null/kosong
          .toSet()
          .toList();

      uniqueCategories.sort(); 

      return ['Semua', ...uniqueCategories];
    } catch (e) {
      return ['Semua']; // Fallback jika terjadi error
    }
  }
}

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(supabaseClientProvider));
}