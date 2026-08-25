import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:vodan/core/presentation/widgets/pin_barrier.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/presentation/widgets/vodan_tff_card.dart';
import 'package:vodan/core/providers/admin_session.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/workspace/presentation/controllers/setting_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/workspace_controller.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _copy(BuildContext context, String workspaceId) async {
    await Clipboard.setData(ClipboardData(text: workspaceId));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID Lapak berhasil disalin! 📋'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      )
    );
  }

  Future<void> _submitPin() async {
    final workspaceId = ref.read(currentWorkspaceProvider)?.id;
    if (workspaceId == null) return;

    final errorMessage = await ref.read(adminSessionProvider.notifier).verifyPin(workspaceId, _pinController.text);
    
    _pinController.clear();
    
    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
    }
  }

  Future<void> _shareWorkspace(BuildContext context, String workspaceId) async {
    final String joinLink = 'https://vodan.app/join?id=$workspaceId';
    
    final String message = '''
      Halo! 👋 Mari bergabung ke lapak saya di VoDan.

      Klik tautan berikut untuk masuk otomatis:
      $joinLink

      Atau masukkan ID Lapak manual:
      *$workspaceId*
    ''';

    final box = context.findRenderObject() as RenderBox?;
    Rect? sharePosition;
    if (box != null) {
      sharePosition = box.localToGlobal(Offset.zero) & box.size;
    }

    final result = await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Undangan Akses Lapak Vodan'
      )
    );

    if (result.status == ShareResultStatus.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan lapak berhasil dibagikan! 🚀'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Dialog Tampilkan info lapak
  void _showInfoDialog(String workspaceId) {
    final String joinLink = 'https://vodan.app/join?id=$workspaceId';

    final initialName = ref.watch(currentWorkspaceProvider)?.name ?? 'Lapak Anonim';
    String displayName = initialName;
    final nameController = TextEditingController(text: initialName);
    bool isEditing = false;
    bool isLoading = false;

    VodanDialog.show(
      context: context,
      title: 'Informasi Lapak',
      icon: Icons.storefront_rounded, 
      customContent: StatefulBuilder(
        builder: (context, setStateModal) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              // Nama lapak
              VodanTffCard(
                title: 'Nama Lapak',
                controller: nameController,
                isEditing: isEditing,
                isLoading: isLoading,
                icon: Icons.storefront_rounded,
                onPressed: () async {
                  if (isEditing) {
                    setStateModal(() => isLoading = true);
                    
                    final errorMessage = await ref
                        .read(workspaceControllerProvider.notifier)
                        .editWorkspaceName(workspaceId, nameController.text);

                    if (context.mounted) {
                      setStateModal(() => isLoading = false);
                      if (errorMessage == null) {
                        setStateModal(() => isEditing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama lapak berhasil diubah! 🔐'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                        );
                      }
                    }
                  } else {
                    setStateModal(() => isEditing = true);
                  }
                },
              ),
              
              VodanActionCard(
                title: 'Ketuk untuk menyalin ID Lapak',
                subtitle: '${workspaceId.substring(0, 8)}...',
                prefixIcon: Icons.fingerprint_rounded,
                color: Theme.of(context).colorScheme.secondary,
                suffixIcon: const Icon(Icons.copy_rounded, size: 20, color: Colors.grey),
                padding: 12,
                iconSize: 22.0,
                titleSize: 10.0,
                onTap: () => _copy(context, workspaceId), // Langsung salin saat kartu diklik!
              ),
              const SizedBox(height: 16),

              // QR CODE
              Text('QR Code Lapak'),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: QrImageView(
                    data: joinLink,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePinBottomSheet(String workspaceId, bool isDesktop) {
    final formKey = GlobalKey<FormState>();
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    bool isLoading = false;

    VodanBottomSheet.show(
      context: context,
      isDismissible: true,
      child: StatefulBuilder(
        builder: (context, setStateModal) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                Text(
                  'Ganti PIN Lapak',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan PIN baru untuk keamanan admin lapak ini.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Input PIN Baru
                VodanTextFormField(
                  controller: pinController,
                  hintText: 'PIN Baru',
                  prefixIcon: Icons.password_rounded,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6)
                  ],
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'PIN harus berjumlah 6 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Konfirmasi PIN Baru
                VodanTextFormField(
                  controller: confirmPinController,
                  hintText: 'Konfirmasi PIN Baru',
                  prefixIcon: Icons.lock_reset_rounded,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6)
                  ],
                  validator: (value) {
                    if (value != pinController.text) {
                      return 'PIN tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: VodanActionButton(
                    text: isLoading ? 'Menyimpan...' : 'Simpan PIN Baru',
                    height: 48,
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              setStateModal(() => isLoading = true);

                              // Panggil WorkspaceController yang sudah kita buat
                              final errorMessage = await ref
                                  .read(workspaceControllerProvider.notifier)
                                  .editPin(workspaceId, pinController.text);

                              if (context.mounted) {
                                Navigator.pop(context);
                                pinController.dispose();
                                confirmPinController.dispose();

                                if (errorMessage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('PIN lapak berhasil diubah! 🔐'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                  ),
                ),
                SizedBox(height: isDesktop ? 0 : 30),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = context.isDesktop || context.isTablet;

    final barrierState = ref.watch(adminSessionProvider);
    final state = ref.watch(settingControllerProvider);
    final workspaceId = ref.watch(currentWorkspaceProvider)?.id ?? 'ID_TIDAK_DITEMUKAN';
    final workspaceName = ref.watch(currentWorkspaceProvider)?.name ?? 'Lapak Anonim';

    if (!barrierState.isPinVerified) {
      return PinBarrier(
        tffController: _pinController,
        tffEnabled: !barrierState.isLoading,
        tffOnFieldSubmitted: (_) => _submitPin(),
        buttonText: barrierState.isLoading ? 'Memeriksa...' : 'Buka Kunci', 
        buttonOnPressed: barrierState.isLoading ? null : _submitPin,
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header
          Builder(
            builder: (cardContext) {
              // TODO: ganti nama lapak
              return VodanActionCard(
                title: workspaceName, 
                subtitle: 'ID: ${workspaceId.substring(0, 8)}...', 
                prefixIcon: Icons.storefront_rounded,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.share_rounded, size: 32),
                  color: theme.colorScheme.primary,
                  onPressed: () => _shareWorkspace(cardContext, workspaceId)
                ), 
                color: theme.colorScheme.primary, 
                onTap: () => _showInfoDialog(workspaceId),
              );
            }
          ),
          const SizedBox(height: 24,),

          // SECTION 1: KEAMANAN & AKSES
          _buildSectionTitle('Keamanan & Akses'),
          VodanActionCard(
            title: 'Ganti PIN Lapak',
            subtitle: 'Perbarui PIN keamanan admin.',
            prefixIcon: Icons.password_rounded,
            color: theme.colorScheme.secondary,
            onTap: () => _showChangePinBottomSheet(workspaceId, isDesktop),
          ),
          const SizedBox(height: 8),
          VodanActionCard(
            title: 'Manajemen Daftar Akses',
            subtitle: 'Terima, tolak, atau cabut akses kasir.',
            prefixIcon: Icons.manage_accounts_rounded,
            color: theme.colorScheme.secondary,
            onTap: () => AccessRoute().go(context),
          ),
          const SizedBox(height: 24),

          // SECTION 2: PREFERENSI PENJUALAN
          _buildSectionTitle('Preferensi Penjualan'),
          VodanActionCard(
            title: 'Siaran Penjualan',
            subtitle: 'Notifikasi kasir lain saat ada struk baru.',
            prefixIcon: Icons.campaign_rounded,
            color: Colors.blue,
            suffixIcon: Switch(
              value: state.isBroadcastEnabled,
              onChanged: (val) => ref.read(settingControllerProvider.notifier).toggleBroadcast(val),
              activeThumbColor: Colors.blue,
            ),
            onTap: () {
              ref.read(settingControllerProvider.notifier).toggleBroadcast(!state.isBroadcastEnabled);
            },
          ),
          const SizedBox(height: 8),
          VodanActionCard(
            title: 'Informasi Struk (Akan Datang)',
            subtitle: 'Atur nama, alamat, dan catatan lapak.',
            prefixIcon: Icons.receipt_long_rounded,
            color: Colors.teal,
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // SECTION 3: KECERDASAN BUATAN
          _buildSectionTitle('Kecerdasan Buatan (AI)'),
          VodanActionCard(
            title: 'Kredensial & API Keys',
            subtitle: 'Kelola integrasi Gemini AI.',
            prefixIcon: Icons.smart_toy_rounded,
            color: Colors.purple,
            onTap: () {},
          ),
          const SizedBox(height: 48),

          // SECTION 4: ZONA BERBAHAYA
          _buildSectionTitle('Zona Destruktif'),
          VodanActionCard(
            title: 'Hapus Lapak',
            subtitle: 'Tindakan ini tidak dapat dikembalikan.',
            prefixIcon: Icons.delete_forever_rounded,
            color: Colors.red,
            onTap: () {
              VodanDialog.show(
                context: context, 
                title: 'Hapus Lapak ?'
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => ref.read(adminSessionProvider.notifier).lockScreen(),
        backgroundColor: theme.colorScheme.errorContainer,
        child: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onErrorContainer),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      ),
    );
  }
}