import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_category.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/vodan_quantity_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/utils/app_format.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/workspace/data/models/product_model.dart';
import 'package:vodan/features/workspace/presentation/controllers/cart_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/product_controller.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = context.isDesktop || context.isTablet;
    final gridColumns = context.posGridColumns;
    final padding = context.defaultPadding;

    // final workspaceId = ref.read(currentWorkspaceIdProvider);

    final cart = ref.watch(cartControllerProvider);
    final totalItems = cart.fold(0, (sum, item) => sum + item.quantity);
    final totalAmount = ref.read(cartControllerProvider.notifier).totalAmount;

    final productState = ref.watch(productControllerProvider);
    final productNotifier = ref.read(productControllerProvider.notifier);

    final categoriesAsync = ref.watch(productCategoriesProvider);
    final categoryList = categoriesAsync.value ?? ['Semua'];

    return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Search
            Padding(
              padding: EdgeInsets.only(
                  left: padding, right: padding, top: 16.0, bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: VodanTextFormField(
                      controller: _searchController,
                      hintText: 'Cari makanan, minuman...',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (newQuery) => productNotifier.updateSearch(newQuery)
                    ),
                  ),
                ],
              ),
            ),

            // Filtering
            VodanFilterChips(
              padding: EdgeInsets.symmetric(horizontal: padding),
              items: categoryList,
              selectedItem: productNotifier.selectedCategory,
              onSelected: (newCategory) => productNotifier.updateCategory(newCategory)
            ),

            // Grid Produk
            Expanded(
              child: productState.when(
                skipLoadingOnReload: true, 
                
                data: (products) {
                  if (products.isEmpty && !productState.isLoading) {
                    return _buildEmptyState(theme);
                  }

                  return Stack(
                    children: [
                      AnimatedOpacity(
                        opacity: productState.isLoading ? 0.4 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 120),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridColumns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final cartItem = cart
                                .where((item) => item.product.id == product.id)
                                .firstOrNull;
                            final qty = cartItem?.quantity ?? 0;

                            return _buildProductCard(theme, product, qty);
                          },
                        ),
                      ),
                      
                      if (productState.isLoading)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  );
                },
                error: (err, stack) => Center(
                  child: Text('Terjadi kesalahan: $err', style: TextStyle(color: theme.colorScheme.error)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              )
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: isDesktop 
              ? EdgeInsetsGeometry.only(left: 16, right: 96, top: 16, bottom: 16)
              : EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  offset: totalItems > 0 ? Offset.zero : const Offset(0, 2),
                  child: totalItems > 0
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: isDesktop ? 350 : double.infinity),
                          child: VodanActionButton(
                            text: 'Proses Pesanan',
                            height: 60,
                            isExpanded: true,
                            extraInfo:
                                '$totalItems item  •  ${AppFormat.currency(totalAmount)}',
                            suffixIcon: Icon(Icons.arrow_forward_rounded,
                                color: theme.colorScheme.onPrimary),
                            onPressed: () => TransactionRoute().push(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (totalItems > 0) const SizedBox(width: 16,),
            ],
          ),
        ));
  }

  // ---------------------------------------------------------
  // KARTU PRODUK DENGAN TOMBOL DINAMIS
  // ---------------------------------------------------------
  Widget _buildProductCard(ThemeData theme, ProductModel product, int qty) {
    if (!product.isActive) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                image: DecorationImage(
                  // Nanti diganti dengan URL gambar asli dari bucket Supabase
                  image: NetworkImage('https://images.unsplash.com/photos/random'),
                  fit: BoxFit.cover,
                ),
              ),
              child: product.stock <= 0 
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
                      ),
                      child: const Center(child: Text('HABIS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ) 
                  : null,
            ),
          ),
          // Info Teks & Harga
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stok: ${product.stock}', 
                      style: theme.textTheme.bodySmall?.copyWith(color: product.stock < 5 ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant)
                    ),
                    Text(
                      '${product.sold} Terjual', 
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                    ),
                  ],
                ),
                const SizedBox(height: 8,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppFormat.currency(product.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    VodanQuantityButton(
                      quantity: qty,
                      onAdd: () {
                        // print('product id: ${product.id}');
                        // print('qty: $qty');
                        // print('product stock: ${product.stock}');
                        
                        if (qty < product.stock - product.sold) {
                          // print('tambah');
                          ref.read(cartControllerProvider.notifier).updateQuantity(product, qty + 1);
                        } else {
                          VodanDialog.show(
                            context: context, 
                            title: 'Stok Habis', 
                            message: 'Stok ${product.name} tidak mencukupi!'
                          );
                        }
                      },
                      onRemove: () => ref
                          .read(cartControllerProvider.notifier)
                          .updateQuantity(product, qty - 1),
                      onChanged: (newQty) {
                        if (newQty <= 0) {
                          VodanDialog.show(
                            context: context, 
                            title: 'Peringatan', 
                            message: 'Kuantitas minimal adalah 1. Gunakan tombol hapus untuk membatalkan pesanan.'
                          );
                          return;
                        }
                        
                        if (newQty <= product.stock - product.sold) {
                          ref.read(cartControllerProvider.notifier).updateQuantity(product, newQty);
                        } else {
                          VodanDialog.show(
                            context: context, 
                            title: 'Stok Habis', 
                            message: 'Sisa stok ${product.name} hanya ${product.stock - product.sold}!'
                          );
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.surfaceContainerHighest),
          const SizedBox(height: 16),
          Text('Produk tidak ditemukan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('Coba gunakan kata kunci lain', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}