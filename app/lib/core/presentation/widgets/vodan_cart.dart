import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/vodan_quantity_button.dart';
import 'package:vodan/core/utils/app_format.dart';
import 'package:vodan/features/workspace/data/models/cart_item_model.dart';
import 'package:vodan/features/workspace/presentation/controllers/cart_controller.dart';

class ProductIconCart extends StatelessWidget {
  const ProductIconCart({
    super.key,
    required this.icon,
    this.iconColor,
    this.width,
    this.height,
    this.radius
  });

  final IconData icon;
  final Color? iconColor;
  final double? width;
  final double? height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width ?? 48,
      height: height ?? 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius ?? 8),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

class ProductDetailCart extends StatelessWidget {
  const ProductDetailCart({
    super.key,
    required this.item,
  });

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${AppFormat.currency(item.product.price)} / item', 
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
          ),
        ],
      ),
    );
  }
}

class ProductPriceCart extends ConsumerStatefulWidget {
  const ProductPriceCart({
    super.key,
    required this.item,
  });

  final CartItemModel item;

  @override
  ConsumerState<ProductPriceCart> createState() => _ProductPriceCartState();
}

class _ProductPriceCartState extends ConsumerState<ProductPriceCart> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.item.product;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end, 
      children: [
        IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
          tooltip: 'Hapus Barang',
          onPressed: () {
            ref.read(cartControllerProvider.notifier).updateQuantity(product, 0);
          },
        ),
        
        Text(
          AppFormat.currency(product.price * widget.item.quantity),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        VodanQuantityButton(
          quantity: widget.item.quantity,
          onAdd: () {
            if (widget.item.quantity < product.stock - product.sold) {
              ref.read(cartControllerProvider.notifier).updateQuantity(product, widget.item.quantity + 1);
            } else {
              VodanDialog.show(
                context: context, 
                title: 'Stok Habis', 
                message: 'Stok ${product.name} tidak mencukupi!'
              );
            }
          },
          onRemove: () {
            if (widget.item.quantity > 1) {
              ref.read(cartControllerProvider.notifier).updateQuantity(product, widget.item.quantity - 1);
            } else {
              VodanDialog.show(
                context: context, 
                title: 'Peringatan', 
                message: 'Gunakan tombol Tong Sampah di atas untuk menghapus barang dari keranjang.'
              );
            }
          },
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
    );
  }
}