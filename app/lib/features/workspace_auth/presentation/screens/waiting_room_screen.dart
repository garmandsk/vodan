import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/cashier_bottom_sheet.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_qr_scanner.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
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
  bool _autoJoinTriggered = false;

  @override
  void initState() {
    super.initState();

    currentWorkspaceId = widget.workspaceId;
    currentCashierName = widget.cashierName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSharedLinkJoin();
    });
  }

  Future<void> _handleSharedLinkJoin() async {
    if (_autoJoinTriggered) return;

    final existingSessionId = ref.read(currentCashierProvider)?.sessionId;
    if (existingSessionId != null) return;

    final safeName = currentCashierName.trim();
    if (safeName.isEmpty) return;

    _autoJoinTriggered = true;

    try {
      await ref
          .read(waitingRoomControllerProvider.notifier)
          .join(currentWorkspaceId, safeName);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal masuk dari tautan undangan: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      if (mounted) {
        EnterWorkspaceRoute().go(context);
      }
    }
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
        await ref
            .read(waitingRoomControllerProvider.notifier)
            .editData(newCashierName, newWorkspaceId);

        // 2. Tampilkan notifikasi sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Data berhasil diperbarui!'),
              backgroundColor: Colors.green));

          setState(() {
            currentWorkspaceId = newWorkspaceId;
            currentCashierName = newCashierName;
          });

          WorkspaceWaitingRoomRoute(
                  workspaceId: newWorkspaceId, cashierName: newCashierName)
              .replace(context);
        }
      },
    );
  }

  Future<void> _handleTicketEntry(String passCode) async {
    final trimmedCode = passCode.trim();
    if (trimmedCode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode tiket tidak boleh kosong.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final isValid = await ref
          .read(waitingRoomControllerProvider.notifier)
          .scanTicket(trimmedCode, currentWorkspaceId);

      if (!mounted) return;

      if (isValid) {
        ref
            .read(currentWorkspaceProvider.notifier)
            .setWorkspaceSession(workspaceId: currentWorkspaceId);
        const PosRoute().go(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Tiket tidak valid atau sudah kedaluwarsa!'),
            backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal memvalidasi tiket: $e'),
            backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  Future<void> _scanTicketQr() async {
    final scannedResult = await Navigator.push<String>(context,
        MaterialPageRoute(builder: (context) => const VodanQrScannerScreen()));

    if (scannedResult != null && scannedResult.isNotEmpty) {
      await _handleTicketEntry(scannedResult);
    }
  }

  void _showTicketInputBottomSheet() {
    final passCodeController = TextEditingController();
    bool isLoading = false;

    VodanBottomSheet.show(
      context: context,
      isDismissible: true,
      child: StatefulBuilder(
        builder: (context, setStateModal) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VodanHeader(
                title: 'Masuk dengan Tiket Lapak',
                subtitle: 'Masukkan kode tiket atau pindai QR dari owner.',
              ),
              const SizedBox(height: 16),
              VodanTextFormField(
                controller: passCodeController,
                labelText: 'Kode Tiket',
                hintText: 'DGC.....',
                prefixIcon: Icons.key_rounded,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: VodanActionButton(
                  text: isLoading ? 'Memeriksa tiket...' : 'Masuk dengan Kode',
                  prefixIcon: Icons.login_rounded,
                  onPressed: isLoading
                      ? null
                      : () async {
                          final enteredCode = passCodeController.text;
                          if (enteredCode.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kode tiket tidak boleh kosong.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setStateModal(() => isLoading = true);
                          final navigationContext = context;
                          try {
                            await _handleTicketEntry(enteredCode);
                            if (navigationContext.mounted) {
                              Navigator.pop(navigationContext);
                            }
                          } finally {
                            if (mounted && navigationContext.mounted) {
                              setStateModal(() => isLoading = false);
                            }
                          }
                        },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: VodanActionButton(
                  text: 'Pindai QR',
                  prefixIcon: Icons.qr_code_scanner_rounded,
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  onPressed: () {
                    Navigator.pop(context);
                    _scanTicketQr();
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(myStatusStreamProvider, (previous, next) {
      next.whenData((statusData) {
        final status = statusData['status'] ?? '';

        if (status == QueueStatus.approved.name) {
          ref
              .read(currentWorkspaceProvider.notifier)
              .setWorkspaceSession(workspaceId: currentWorkspaceId);

          const PosRoute().go(context);
        } else if (status == QueueStatus.rejected.name) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Anda ditolak untuk memasuki lapak.'),
              backgroundColor: Theme.of(context).colorScheme.error));

          EnterWorkspaceRoute().go(context);
        }
      });
    });

    final otherCashiersAsync =
        ref.watch(otherCashiersStreamProvider(workspaceId: widget.workspaceId));

    return VodanScaffold(
        body: Stack(children: [
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
                    subtitle: 'Menunggu Persetujuan Admin...'),
                const SizedBox(height: 16),
                VodanActionButton(
                  text: 'Gunakan Tiket Lapak',
                  prefixIcon: Icons.qr_code_scanner_rounded,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  onPressed: _showTicketInputBottomSheet,
                ),
                const SizedBox(height: 24),
                Text(
                  'Rekan Kasir',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),

          otherCashiersAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: ((error, stackTrace) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Text('Gagal memuat: $error'),
                ),
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
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24.0, bottom: 120.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.sizeOf(context).width < 600 ? 3 : 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              otherCashiers[index],
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]),
              child: VodanActionCard(
                  title: 'Halo, $currentCashierName',
                  subtitle: 'Lapak: $currentWorkspaceId',
                  prefixIcon: Icons.person,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.edit_rounded,
                        color: theme.colorScheme.primary),
                    onPressed: _editCredentials,
                    tooltip: 'Ganti Nama/ID Lapak',
                  ),
                  color: theme.colorScheme.primaryContainer,
                  onTap: () {}),
            ),
          ],
        ),
      ),
    ]));
  }
}
