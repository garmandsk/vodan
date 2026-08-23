import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_badge.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/voice_bottom_sheet.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/account/data/repositories/account_repository.dart';
import 'package:vodan/core/presentation/widgets/account_bottom_sheet.dart';
import 'package:vodan/features/workspace/presentation/controllers/tts_service_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/voice_transaction_controller.dart';

class VodanMainScaffold extends ConsumerStatefulWidget {
  const VodanMainScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<VodanMainScaffold> createState() => _VodanMainScaffoldState();
}

class _VodanMainScaffoldState extends ConsumerState<VodanMainScaffold> {
  bool _isBottomSheetOpen = false;
  bool _isSpaceDown = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _stopAndProcess(String? workspaceId) {
    if (workspaceId == null) return;
    final currentState = ref.read(voiceTransactionControllerProvider);
    if (currentState == VoiceState.listening) {
      ref.read(voiceTransactionControllerProvider.notifier).stopAndProcess(workspaceId);
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (FocusManager.instance.primaryFocus?.context?.widget is EditableText) {
        return false; 
      }

      if (event is KeyRepeatEvent) {
        return true;
      }

      final workspaceId = ref.read(currentWorkspaceIdProvider);

      if (event is KeyDownEvent) {
        if (!_isSpaceDown && !_isBottomSheetOpen) {
          _isSpaceDown = true; 
          _startVoiceSession(workspaceId);
        }
        return true; 
      } 
      else if (event is KeyUpEvent) {
        if (_isSpaceDown) {
          _isSpaceDown = false;
          _stopAndProcess(workspaceId);
        }
        return true; 
      }
    }
    return false;
  }

  Future<void> _startVoiceSession(String? workspaceId) async {
    if (workspaceId == null || _isBottomSheetOpen) return;

    final voiceState = ref.read(voiceTransactionControllerProvider);
    final isSpeaking = ref.read(ttsServiceControllerProvider).isSpeaking;
    final isIdle = voiceState == VoiceState.idle || 
                   voiceState == VoiceState.successTransaction || 
                   voiceState == VoiceState.successChat || 
                   voiceState == VoiceState.error;

    if (!isIdle || isSpeaking) return;

    setState(() => _isBottomSheetOpen = true);

    try {
      await ref.read(voiceTransactionControllerProvider.notifier).startRecording();

      final controller = _scaffoldKey.currentState?.showBottomSheet(
        (context) => VoiceBottomSheet(workspaceId: workspaceId),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );

      if (controller != null) {
        await controller.closed;
      }
    } finally {
      if (mounted) {
        setState(() => _isBottomSheetOpen = false);
      } else {
        _isBottomSheetOpen = false;
      }
    }

    if (mounted) {
      final currentState = ref.read(voiceTransactionControllerProvider);
      if (currentState == VoiceState.successTransaction) {
        final isStockAdjusted = ref.read(voiceTransactionControllerProvider.notifier).isLastStockAdjusted;

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            if (isStockAdjusted) {
              VodanDialog.show(
                context: context,
                title: 'Stok Disesuaikan',
                message: 'Beberapa pesanan suara disesuaikan otomatis karena melebihi sisa stok yang ada di sistem.',
                buttonText: 'Lanjut ke Pembayaran',
                buttonColor: Theme.of(context).colorScheme.primary,
                icon: Icons.info_outline_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  const TransactionRoute().push(context);
                },
              );
            } else {
              const TransactionRoute().push(context);
            }
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop || context.isTablet;
    final theme = Theme.of(context);

    final destinations = [
      const _NavigationDestination(icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale_rounded, label: 'Kasir'),
      const _NavigationDestination(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded, label: 'Riwayat'),
      const _NavigationDestination(icon: Icons.people_alt_outlined, selectedIcon: Icons.people_alt_rounded, label: 'Akses'),
      const _NavigationDestination(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Pengaturan'),
    ];

    String currentTitle = 'Kasir';
    if (widget.navigationShell.currentIndex == 1) currentTitle = 'Riwayat Transaksi';
    if (widget.navigationShell.currentIndex == 2) currentTitle = 'Daftar Akses';
    if (widget.navigationShell.currentIndex == 3) currentTitle = 'Pengaturan Lapak';

    final user = ref.watch(accountRepositoryProvider).currentUser;
    final name = user?.userMetadata?['name'] ?? user?.email?.split('@')[0] ?? 'Anonim';
    final workspaceId = ref.watch(currentWorkspaceIdProvider);

    final voiceState = ref.watch(voiceTransactionControllerProvider);
    final isSpeaking = ref.watch(ttsServiceControllerProvider).isSpeaking;
    final isIdle = voiceState == VoiceState.idle || 
                   voiceState == VoiceState.successTransaction || 
                   voiceState == VoiceState.successChat || 
                   voiceState == VoiceState.error;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(currentTitle),
              automaticallyImplyLeading: false,
              actions: [
                if (name != 'Anonim')
                  VodanBadge(
                    text: name,
                    radius: 18,
                    onTap: () => AccountBottomSheet.show(context),
                  ),
                const SizedBox(width: 16),
              ],
            ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  extended: MediaQuery.sizeOf(context).width >= 900,
                  backgroundColor: theme.colorScheme.surface,
                  indicatorColor: theme.colorScheme.primaryContainer,
                  selectedLabelTextStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  destinations: destinations.map((dest) {
                    return NavigationRailDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: Icon(dest.selectedIcon),
                      label: Text(dest.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.navigationShell),
              ],
            )
          : widget.navigationShell,
    
      floatingActionButtonLocation: isDesktop 
          ? FloatingActionButtonLocation.endFloat 
          : const FixedCenterDockedFabLocation(),
          
      floatingActionButton: Builder(
        builder: (fabContext) {
          return Container(
            padding: const EdgeInsets.all(8.0), 
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, 
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Listener(
              onPointerDown: (isIdle && !isSpeaking) ? (_) async {
                if (workspaceId == null) return;
    
                await ref.read(voiceTransactionControllerProvider.notifier).startRecording();
    
                if (!_isBottomSheetOpen) {
                  _isBottomSheetOpen = true;
                  final controller = Scaffold.of(fabContext).showBottomSheet(
                    (context) => VoiceBottomSheet(workspaceId: workspaceId),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  );
    
                  // 3. Tunggu sampai ditutup
                  await controller.closed;
                  _isBottomSheetOpen = false;
    
                  // 4. Setelah ditutup, cek jika transaksi sukses dan butuh dialog
                  if (context.mounted) {
                    final currentState = ref.read(voiceTransactionControllerProvider);
                    if (currentState == VoiceState.successTransaction) {
                      final isStockAdjusted = ref.read(voiceTransactionControllerProvider.notifier).isLastStockAdjusted;
    
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (context.mounted) {
                          if (isStockAdjusted) {
                            VodanDialog.show(
                              context: context,
                              title: 'Stok Disesuaikan',
                              message: 'Beberapa pesanan suara disesuaikan otomatis karena melebihi sisa stok yang ada di sistem.',
                              buttonText: 'Lanjut ke Pembayaran',
                              buttonColor: theme.colorScheme.primary,
                              icon: Icons.info_outline_rounded,
                              iconColor: theme.colorScheme.primary,
                              onPressed: () {
                                const TransactionRoute().push(context);
                              },
                            );
                          } else {
                            const TransactionRoute().push(context);
                          }
                        }
                      });
                    }
                  }
                }
              } : null,
              
              onPointerUp: (_) => _stopAndProcess(workspaceId),
              onPointerCancel: (_) => _stopAndProcess(workspaceId),
              
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 30),
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _buildFlatBottomBar(context, theme, destinations),
    );
  }

  Widget _buildFlatBottomBar(BuildContext context, ThemeData theme, List<_NavigationDestination> destinations) {
    return Container(
      height: 65, 
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildNavItem(context, 0, destinations[0], theme),
              _buildNavItem(context, 1, destinations[1], theme),
            ],
          ),
          Row(
            children: [
              _buildNavItem(context, 2, destinations[2], theme),
              _buildNavItem(context, 3, destinations[3], theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, _NavigationDestination dest, ThemeData theme) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    final itemWidth = MediaQuery.sizeOf(context).width / 5.2; 

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _goBranch(index),
        child: SizedBox(
          width: itemWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Icon(
                isSelected ? dest.selectedIcon : dest.icon, 
                color: color, 
                size: 24
              ),
              const SizedBox(height: 2),
              Text(
                dest.label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// ==========================================
// KELAS TAMBAHAN (Letakkan Paling Bawah File)
// ==========================================
class FixedCenterDockedFabLocation extends FloatingActionButtonLocation {
  const FixedCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Tepat di tengah horizontal
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
    
    // Kunci posisi Y di atas BottomNavigationBar, abaikan keberadaan Bottom Sheet
    final double fabY = scaffoldGeometry.contentBottom - (scaffoldGeometry.floatingActionButtonSize.height / 2.0);
    
    return Offset(fabX, fabY);
  }
} 