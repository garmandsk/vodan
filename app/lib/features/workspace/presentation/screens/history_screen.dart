import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/transaction_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_category.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';
import 'package:vodan/features/workspace/presentation/controllers/transaction_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['Semua', TransactionStatus.paid.capitalizedText, TransactionStatus.pending.capitalizedText, TransactionStatus.rejected.capitalizedText];

  Future<void> _pickDateRange(BuildContext context, dynamic transactionNotifier) async {
    final theme = Theme.of(context);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      // Batas awal kalender 
      firstDate: DateTime(2023), 
      // Batas akhir (hari ini)
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
      // Teks kustom
      helpText: 'Pilih Rentang Waktu Transaksi',
      cancelText: 'Batal',
      confirmText: 'Terapkan',
    );

    if (picked != null) {
      transactionNotifier.updateDateRange(picked.start, picked.end);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = context.isDesktop || context.isTablet;
    final padding = context.defaultPadding;

    final transactionState = ref.watch(transactionControllerProvider);
    final transactionNotifier = ref.read(transactionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // 1. SEARCH BAR
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: VodanTextFormField(
                    hintText: 'Cari pesanan...',
                    prefixIcon: Icons.search,
                    controller: _searchController,
                    onChanged: (newQuery) => transactionNotifier.updateSearch(newQuery),
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Reset Filter',
                onPressed: () {
                  // Hapus teks pencarian jika perlu
                  // _searchController.clear();
                  // transactionNotifier.updateSearch('');
                  
                  // Reset waktu
                  transactionNotifier.updateDateRange(null, null); 
                },
              ),
              
              // TOMBOL KALENDER
              Padding(
                padding: const EdgeInsets.only(right: 16.0), 
                child: IconButton(
                  icon: Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
                  tooltip: 'Filter Tanggal',
                  onPressed: () => _pickDateRange(context, transactionNotifier),
                ),
              ),
            ],
          ),

          // 2. FILTER CHIPS
          VodanFilterChips(
            padding: EdgeInsets.symmetric(horizontal: padding),
            items: _filters, 
            selectedItem: transactionNotifier.selectedStatus == null
                ? 'Semua'
                : '${transactionNotifier.selectedStatus![0].toUpperCase()}${transactionNotifier.selectedStatus!.substring(1).toLowerCase()}', 
            onSelected: (newStatus) {
              if (newStatus == 'Semua') {
                transactionNotifier.updateStatus(null);
              } else {
                final enumValue = TransactionStatus.values.firstWhere(
                  (e) => e.name == newStatus.toLowerCase(),
                  orElse: () => TransactionStatus.pending
                ); 
                transactionNotifier.updateStatus(enumValue);
              }
            }
          ),

          // 3. JUMLAH HASIL
          Expanded(
            child: transactionState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Terjadi Kesalahan:\n$error')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(child: Text('Belum ada transaksi.'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${transactions.length} Hasil', 
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // LIST PESANAN
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 2 : 1,
                          crossAxisSpacing: 16.0, 
                          mainAxisSpacing: 16.0, 
                          mainAxisExtent: 320, 
                        ),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index]; 
                          return TransactionCard(transaction: transaction); 
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}