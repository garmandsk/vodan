import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/vodan_dropdown.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/utils/app_format.dart';
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_update_request_model.dart';
import 'package:vodan/features/workspace/presentation/controllers/transaction_controller.dart';

class TransactionDetailDialog extends ConsumerStatefulWidget {
  final TransactionResponseModel transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  ConsumerState<TransactionDetailDialog> createState() => _TransactionDetailDialogState();
}

class _TransactionDetailDialogState extends ConsumerState<TransactionDetailDialog> {
  bool _isEditing = false;

  late TransactionStatus _editedStatus;
  late PaymentMethod _editedPaymentMethod;
  late TextEditingController _cashierController;

  Future<Uint8List> _generateReceiptPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Toko
              pw.Center(
                child: pw.Text('VODAN POS', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text('Cabang Medan', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 0.5),
              
              // Informasi Transaksi
              pw.Text('Order ID : #${widget.transaction.id.length > 6 ? widget.transaction.id.substring(0, 6).toUpperCase() : widget.transaction.id.toUpperCase()}'),
              pw.Text('Waktu    : ${AppFormat.dateTime(widget.transaction.transactionTime.toLocal())}'),
              pw.Text('Kasir    : ${widget.transaction.cashierName}'),
              pw.Text('Status   : ${widget.transaction.status.name.toUpperCase()}'),
              pw.Text('Metode   : ${widget.transaction.paymentMethod.name.toUpperCase()}'),
              
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 5),
              
              // Header Tabel Item
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              
              // Daftar Item Belanjaan
              ...widget.transaction.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text('${item.product.name} (x${item.quantity})'),
                      ),
                      pw.Text(AppFormat.currency(item.product.price * item.quantity)),
                    ],
                  ),
                );
              }),
              
              pw.Divider(thickness: 0.5),
              
              // Total Harga
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Harga', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(AppFormat.currency(widget.transaction.totalPrice), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Footer Struk
              pw.Center(
                child: pw.Text('Terima Kasih Telah Berbelanja!', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _printReceipt() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _generateReceiptPdf(format),
    );
  }

  @override
  void initState() {
    super.initState();
    _editedStatus = widget.transaction.status;
    _editedPaymentMethod = widget.transaction.paymentMethod;
    _cashierController = TextEditingController(text: widget.transaction.cashierName);
  }

  @override
  void dispose() {
    _cashierController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    final bool isStatusChanged = _editedStatus != widget.transaction.status;
    final bool isPaymentChanged = _editedPaymentMethod != widget.transaction.paymentMethod;
    final bool isCashierChanged = _cashierController.text != widget.transaction.cashierName;

    if (!isStatusChanged && !isPaymentChanged && !isCashierChanged) {
      setState(() => _isEditing = false); 
      return;
    }

    final updateModel = TransactionUpdateRequestModel(
      status: isStatusChanged ? _editedStatus : null,
      paymentMethod: isPaymentChanged ? _editedPaymentMethod : null,
      cashierName: isCashierChanged ? _cashierController.text : null,
    );

    await ref.read(transactionControllerProvider.notifier).updateTransaction(widget.transaction.id, updateModel);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortId = widget.transaction.id.length > 6 
        ? widget.transaction.id.substring(0, 6).toUpperCase() 
        : widget.transaction.id.toUpperCase();

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isEditing ? 'Edit Pesanan' : 'Detail Pesanan', 
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // INFO UTAMA & FORM EDIT KASIR
              Text('Order ID #$shortId', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              
              _isEditing 
                ? VodanTextFormField(
                    controller: _cashierController,
                    labelText: 'Nama Kasir',
                    prefixIcon: Icons.person,
                  )
                : Text('Kasir: ${widget.transaction.cashierName}', style: theme.textTheme.bodySmall),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(height: 1, thickness: 0.5),
              ),

              // OPSI EDIT STATUS & METODE BAYAR
              if (_isEditing) ...[
                VodanDropdown(
                  initialValue: _editedStatus.name, 
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
                      _editedStatus = TransactionStatus.values.byName(value.toString());
                    });
                  },
                ),

                VodanDropdown(
                  initialValue: _editedPaymentMethod.name, 
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
                      _editedPaymentMethod = PaymentMethod.values.byName(value.toString());
                    });
                  },
                ),
               
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(height: 1, thickness: 0.5),
                ),
              ],

              // DAFTAR ITEM
              if (!_isEditing) ...[
                Flexible( 
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.transaction.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.transaction.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildOrderItem(theme, item.product.name, item.product.price, item.quantity),
                        );
                      },
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(height: 1, thickness: 0.5),
                ),
              ],

              // TOTAL HARGA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Harga'),
                  Text(AppFormat.currency(widget.transaction.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              
              // DYNAMIC BUTTONS 
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _isEditing 
                ? [
                    // TOMBOL BATAL & KIRIM
                    VodanActionButton(
                      text: 'Batal',
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      height: 40,
                      onPressed: () => setState(() {
                        _editedStatus = widget.transaction.status;
                        _editedPaymentMethod = widget.transaction.paymentMethod;
                        _cashierController.text = widget.transaction.cashierName;
                        _isEditing = false;
                      }),
                    ),
                    const SizedBox(width: 8),
                    VodanActionButton(
                      prefixIcon: Icons.send_rounded,
                      text: 'Kirim',
                      height: 40.0,
                      onPressed: _submitUpdate, 
                    ),
                  ]
                : [
                    // Tombol cetak
                    VodanActionButton(
                      text: 'Cetak',
                      prefixIcon: Icons.print_rounded,
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      height: 40,
                      onPressed: _printReceipt, // 🌟 Panggil fungsi cetak PDF
                    ),
                    const SizedBox(width: 8),
                    // TOMBOL EDIT & HAPUS
                    VodanActionButton(
                      text: 'Edit',
                      prefixIcon: Icons.edit_rounded,
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      height: 40,
                      onPressed: () => setState(() => _isEditing = true), // 
                    ),
                    const SizedBox(width: 8),
                    VodanActionButton(
                      text: 'Hapus',
                      prefixIcon: Icons.delete_outline_rounded, 
                      backgroundColor: theme.colorScheme.error,
                      height: 40,
                      onPressed: () {
                        final transactionNotifier = ref.read(transactionControllerProvider.notifier);
                        final transactionId = widget.transaction.id;
                        final shortIdText = shortId;
                        final parentContext = context;

                        Navigator.pop(parentContext);

                        Future.microtask(() {
                          VodanDialog.show(
                            context: parentContext,
                            title: 'Hapus Transaksi?',
                            message: 'Transaksi ID #$shortIdText akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
                            buttonText: 'Ya, Hapus',
                            icon: Icons.warning_rounded,
                            onPressed: () {
                              // 4. Eksekusi menggunakan notifier yang sudah disimpan (bebas dari error unmounted!)
                              transactionNotifier.deleteTransaction(transactionId);
                            },
                          );
                        });
                      },
                    ),
                ]
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(ThemeData theme, String name, double price, int qty) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
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
}