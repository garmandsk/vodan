import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_cart.dart';
import 'package:vodan/core/presentation/widgets/vodan_dropdown.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/utils/app_format.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';
import 'package:vodan/features/workspace/presentation/controllers/cart_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/transaction_controller.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _tableNumberController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  TransactionStatus _selectedTransactionStatus = TransactionStatus.paid;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor Rekening berhasil disalin! 📋'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      )
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _tableNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = context.defaultPadding;
    final isDesktop = context.isDesktop || context.isTablet;

    final cart = ref.watch(cartControllerProvider);
    final subtotal = ref.read(cartControllerProvider.notifier).totalAmount.toDouble();
    
    final grandTotal = subtotal;

    final isLoading = ref.watch(transactionControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface, 
        elevation: 0,
      ),
      body: cart.isNotEmpty 
      ? Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text('Informasi Pelanggan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              VodanTextFormField(
                controller: _customerNameController,
                hintText: 'Nama Pelanggan (Opsional)',
                prefixIcon: Icons.person_outline_rounded,
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daftar Pesanan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => ref.read(cartControllerProvider.notifier).clearCart(), 
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Kosongkan'),
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  )
                ],
              ),
              
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    ...cart.map((item) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 16,
                            children: [
                              ProductIconCart(icon: Icons.shopping_bag_rounded, iconColor: theme.colorScheme.primary,),
                              ProductDetailCart(item: item),
                              ProductPriceCart(item: item)
                            ],
                          ),
                        ),
                        if (item != cart.last) const Divider(height: 1),
                      ],
                    )),
                  ],
                ),
              ),
              
              Text('Ringkasan Pembayaran', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                ),
                child: Column(
                  spacing: 8,
                  children: [
                    _buildSummaryRow(theme, 'Subtotal', AppFormat.currency(ref.read(cartControllerProvider.notifier).totalAmount)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          AppFormat.currency(ref.read(cartControllerProvider.notifier).totalAmount), 
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Text('Status Pembayaran', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              VodanDropdown(
                initialValue: _selectedTransactionStatus.name, 
                labelText: '', 
                icon: Icons.query_stats_rounded, 
                items: TransactionStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status.name, 
                    child: Text(status.capitalizedText),
                  );
                }).toList(), 
                onChanged: (value) {
                  setState(() {
                    _selectedTransactionStatus = TransactionStatus.values.byName(value.toString());
                  });
                },
              ),

              Text('Metode Pembayaran', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              VodanDropdown(
                initialValue: _selectedPaymentMethod.name, 
                labelText: '', 
                icon: Icons.payment_rounded, 
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method.name, 
                    child: Text(method.capitalizedText),
                  );
                }).toList(), 
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.values.byName(value.toString());
                  });
                },
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildPaymentMethodDetails(theme),
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    )
    : _buildEmptyCart(theme),
    floatingActionButtonLocation: isDesktop
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerDocked,
    floatingActionButton: AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      offset: cart.isNotEmpty ? Offset.zero : const Offset(0, 2),
      child: cart.isNotEmpty 
          ? ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 350 : double.infinity),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 0 : 16.0), 
                child: VodanActionButton(
                  text: 'Konfirmasi Pembayaran',
                  isExpanded: true,
                  isLoading: isLoading,
                  extraInfo: AppFormat.currency(grandTotal), 
                  suffixIcon: Icon(Icons.payments_outlined, color: theme.colorScheme.onPrimary),
                  onPressed: () async {
                    final success = await ref.read(transactionControllerProvider.notifier).createTransaction(
                        items: cart,
                        totalPrice: grandTotal,
                        status: _selectedTransactionStatus,
                        paymentMethod: _selectedPaymentMethod,
                      );
                    
                    if (!context.mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaksi Berhasil Disimpan! 🎉'), 
                          backgroundColor: Colors.green
                        ),
                      );
                      PosRoute().go(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Gagal menyimpan transaksi! Silakan coba lagi.'), 
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                ),
              ),
            ) 
          : const SizedBox.shrink(),
    ) 
    );
  }

  Widget _buildPaymentMethodDetails(ThemeData theme) {
    if (_selectedPaymentMethod == PaymentMethod.qris) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white, // Latar wajib putih agar QR mudah dipindai
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('Scan QRIS', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),
            // Simulasi Gambar QR Code (Ganti dengan NetworkImage QR aslimu nanti)
            Icon(Icons.qr_code_2_rounded, size: 200, color: Colors.black87),
            const SizedBox(height: 16),
            Text('a.n. Vodan POS Cabang Medan', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          ],
        ),
      );
    } 
    
    else if (_selectedPaymentMethod == PaymentMethod.transfer) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        child: Column(
          spacing: 12,
          children: [
            _buildBankTransferCard(theme, 'BCA', '1234-5678-90', 'Vodan POS Center'),
            _buildBankTransferCard(theme, 'Mandiri', '098-765-4321', 'Vodan POS Center'),
            _buildBankTransferCard(theme, 'BSI', '5432-1111-00', 'Vodan POS Center'),
          ],
        ),
      );
    }

    // Jika 'cash', tidak usah tampilkan apa-apa
    return const SizedBox.shrink();
  }

  Widget _buildBankTransferCard(ThemeData theme, String bankName, String accountNumber, String accountName) {
    return VodanActionCard(
      title: '$bankName - $accountNumber', 
      subtitle: 'a.n $accountName', 
      prefixIcon: Icons.account_balance_rounded,
      suffixIcon: IconButton(
        icon: const Icon(Icons.copy_rounded),
        onPressed: () => _copy(context, accountNumber), // Panggil fungsi copy
      ), 
      // Coba primaryContainer agar warnanya lebih lembut dan modern
      color: theme.colorScheme.primaryContainer, 
      onTap: () => _copy(context, accountNumber),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart_rounded, size: 80, color: theme.colorScheme.surfaceContainerHighest),
          const SizedBox(height: 16),
          Text('Belum ada pesanan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Silakan pilih produk terlebih dahulu', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali ke Menu'))
        ],
      ),
    );
  }
}