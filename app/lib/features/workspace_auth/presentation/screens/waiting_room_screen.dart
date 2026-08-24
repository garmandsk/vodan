import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/cashier_bottom_sheet.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_qr_scanner.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/waiting_room_controller.dart'; // Import tombol buatanmu!

class WaitingRoomScreen extends ConsumerStatefulWidget {
  const WaitingRoomScreen({
    super.key,
    required this.workspaceId,
    required this.cashierName,
  });

  final String workspaceId;
  final String cashierName;

  @override
  ConsumerState<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends ConsumerState<WaitingRoomScreen> {
  late String currentWorkspaceId;
  late String currentCashierName;

  @override
  void initState() {
    super.initState();

    currentWorkspaceId = widget.workspaceId;
    currentCashierName = widget.cashierName;
  }

  void _editCredentials() {
    CashierBottomSheet.show(
      context: context,
      title: 'Edit Data', 
      subtitle: 'Perbarui nama atau pindah ID Lapak.', 
      submitButtonText: 'Simpan Perubahan', 
      initialWorkspaceId: currentWorkspaceId, 
      initialCashierName: currentCashierName, 
      onSubmit: (newWorkspaceId, newCashierName) async {
        // 1. Jalankan fungsi Edit
        await ref.read(waitingRoomControllerProvider.notifier).editData(newCashierName, newWorkspaceId);
    
        // 2. Tampilkan notifikasi sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diperbarui!'), backgroundColor: Colors.green)
          );

          setState(() {
              currentWorkspaceId = newWorkspaceId;
              currentCashierName = newCashierName;
          });
          
          WorkspaceWaitingRoomRoute(
            workspaceId: newWorkspaceId,
            cashierName: newCashierName
          ).replace(context);
        }
      },
    );
  }

  Future<void> _scanQr() async {
    final scannedResult = await Navigator.push<String>(
      context, 
      MaterialPageRoute(builder: (context) => const VodanQrScannerScreen())
    );

    if (scannedResult != null && scannedResult.isNotEmpty) {
      String passCode = scannedResult;
      // print('passcode: $passCode');
      
      try {
        final isValid = await ref.read(waitingRoomControllerProvider.notifier).scanTicket(passCode, currentWorkspaceId);

        if (mounted) {
          if (isValid) {
            ref.read(currentWorkspaceIdProvider.notifier).setWorkspaceId(currentWorkspaceId);
            const PosRoute().go(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tiket tidak valid atau sudah kedaluwarsa!'), 
                backgroundColor: Colors.red
              )
            );
          }
        }
      } catch (e) {
        // Jika internet putus atau database bermasalah
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memvalidasi tiket: $e'), 
              backgroundColor: Theme.of(context).colorScheme.error
            )
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(myStatusStreamProvider, (previous, next) {
      next.whenData((statusData) {
        final status = statusData['status'] ?? '';

        if (status == QueueStatus.approved.name) {
          ref.read(currentWorkspaceIdProvider.notifier).setWorkspaceId(currentWorkspaceId);

          const PosRoute().go(context);
        } else if (status == QueueStatus.rejected.name) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda ditolak untuk memasuki lapak.'), 
              backgroundColor: Theme.of(context).colorScheme.error
            )
          );

          EnterWorkspaceRoute().go(context);
        }
      });
    });

    final otherCashiersAsync = ref.watch(otherCashiersStreamProvider(workspaceId: widget.workspaceId));

    return VodanScaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Bagian Atas (Header, Tombol, Teks)
              SliverPadding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const VodanHeader(
                      icon: Icons.room_service_rounded, 
                      title: 'Ruang Tunggu',
                      subtitle: 'Menunggu Persetujuan Admin...'
                    ),
                    const SizedBox(height: 16),
                    
                    VodanActionButton(
                      text: 'Gunakan Tiket Akses Shift',
                      prefixIcon: Icons.qr_code_scanner_rounded,
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      onPressed: _scanQr,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Rekan Kasir',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),

              otherCashiersAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator(),),
                  ),
                ),
                error: ((error, stackTrace) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Gagal memuat: $error'),),
                  );
                }), 
                data: (otherCashiers) {
                  if (otherCashiers.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Belum ada kasir lain yang menunggu.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 120.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.sizeOf(context).width < 600 ? 3 : 5, 
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 24, width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  otherCashiers[index],
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: otherCashiers.length,
                      ),
                    ),
                  );
                }, 
              )
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.all(24), 
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  ),
                  child: VodanActionCard(
                    title: 'Halo, $currentCashierName', 
                    subtitle: 'Lapak: $currentWorkspaceId', 
                    prefixIcon: Icons.person, 
                    suffixIcon: IconButton(
                      icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
                      onPressed: _editCredentials,
                      tooltip: 'Ganti Nama/ID Lapak',
                    ),
                    color: theme.colorScheme.primaryContainer, 
                    onTap: () {}
                  ),
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}