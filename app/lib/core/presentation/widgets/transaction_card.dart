import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/transaction_detail_dialog.dart';
import 'package:vodan/core/utils/app_format.dart'; 
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';

class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    super.key,
    required this.transaction
  });

  final TransactionResponseModel transaction; 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusStyle = _getStatusStyle(transaction.status);
    final shortId = transaction.id.length > 6 
        ? transaction.id.substring(0, 6).toUpperCase() 
        : transaction.id.toUpperCase();

    return InkWell(
      onTap: () {
        showDialog(
          context: context, 
          builder: (context) => TransactionDetailDialog(transaction: transaction)
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER KARTU (ID & Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID #$shortId',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                _buildBadge(context, statusStyle.$1, statusStyle.$2, statusStyle.$3),
              ],
            ),
            const SizedBox(height: 4),
            
            // TANGGAL & KASIR
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.0, 
              runSpacing: 4.0,
              children: [
                Text(
                  // Format tanggal: Sel, 10 Des 2024 • 11:51 am
                  AppFormat.dateTime(transaction.transactionTime.toLocal()), 
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                ),
                Text(
                  'Kasir: ${transaction.cashierName}', 
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1, thickness: 0.5),
            ),
      
            // DAFTAR ITEM DINAMIS
            ...transaction.items.take(2).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildOrderItem(theme, item.product.name, item.product.price, item.quantity), 
              );
            }),
      
            if (transaction.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      '+ ${transaction.items.length - 2} item lainnya',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: theme.colorScheme.primary),
                  ],
                ),
              ),
      
            const Spacer(),
            
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),
      
            // RINGKASAN PEMBAYARAN
            _buildSummaryRow(theme, 'Total Harga', AppFormat.currency(transaction.totalPrice)),
            const SizedBox(height: 4),
            if (transaction.discount > 0) ...[
              _buildSummaryRow(theme, 'Diskon', '-${AppFormat.currency(transaction.discount)}', isDiscount: true),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Metode Bayar', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Row(
                  children: [
                    Text('${_getPaymentName(transaction.paymentMethod)} ', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // Komponen Item Pembelian
  Widget _buildOrderItem(ThemeData theme, String name, double price, int qty) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=100'), // Nanti ganti dengan gambar produk
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(AppFormat.currency(price), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
        ),
        Text('Qty : $qty Item', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  // Komponen Ringkasan Baris
  Widget _buildSummaryRow(ThemeData theme, String title, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold, 
          color: isDiscount ? Colors.red : theme.colorScheme.onSurface
        )),
      ],
    );
  }

  // Komponen Lencana Status (Badge)
  Widget _buildBadge(BuildContext context, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // HELPER: Fungsi Penerjemah Status (Mengembalikan Teks, Warna BG, Warna Teks)
  // Sesuaikan case ini jika kamu menggunakan enum lain (misal: completed, cancelled)
  (String, Color, Color) _getStatusStyle(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending: // Dipesan
        return (status.capitalizedText, const Color(0xFFFFF3E0), const Color(0xFFF57C00));
      case TransactionStatus.paid: // Dibayar
        return (status.capitalizedText, const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case TransactionStatus.rejected: // Ditolak
        return (status.capitalizedText, const Color(0xFFFFEBEE), const Color(0xFFC62828));
    }
  }

  // HELPER: Fungsi Penerjemah Metode Bayar
  String _getPaymentName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash: return method.capitalizedText;
      case PaymentMethod.qris: return method.capitalizedText;
      case PaymentMethod.transfer: return method.capitalizedText;
    }
  }
}