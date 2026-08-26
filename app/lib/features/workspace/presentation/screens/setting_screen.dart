import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:vodan/core/presentation/widgets/pin_barrier.dart';
import 'package:vodan/core/presentation/widgets/vodan_dropdown.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/presentation/widgets/vodan_tff_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/providers/admin_session.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/utils/ai_form_row.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:vodan/features/workspace_auth/data/models/create_workspace_request_model.dart';

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

  // Bottomsheet Tampilkan info lapak
  void _showInfoBottomSheet(String workspaceId) {
    final String joinLink = 'https://vodan.app/join?id=$workspaceId';

    final initialName = ref.read(currentWorkspaceProvider)?.name ?? 'Lapak Anonim';
    final nameController = TextEditingController(text: initialName);
    bool isEditing = false;
    bool isLoading = false;

    VodanBottomSheet.show(
      context: context,
      isDismissible: true,
      child: StatefulBuilder(
        builder: (context, setStateModal) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              VodanHeader(
                crossAlign: CrossAxisAlignment.start,
                title: 'Informasi Lapak',
                titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                subtitle: 'Ubah nama atau Scan & Bagikan QR dibawah',
                subtitleStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              // --- Nama Lapak ---
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
              const SizedBox(height: 16),
              
              // --- ID Lapak ---
              VodanActionCard(
                title: 'Ketuk untuk menyalin ID Lapak',
                subtitle: '${workspaceId.substring(0, 8)}...',
                prefixIcon: Icons.commit_rounded,
                color: Theme.of(context).colorScheme.secondary,
                suffixIcon: const Icon(Icons.copy_rounded, size: 20, color: Colors.grey),
                padding: 12,
                iconSize: 22.0,
                titleSize: 12.0,
                onTap: () => _copy(context, workspaceId),
              ),
              const SizedBox(height: 24),

              // --- QR Code Lapak ---
              const Text(
                'QR Code Akses Lapak', 
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: QrImageView(
                    data: joinLink,
                    version: QrVersions.auto,
                    size: 160,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Jangka aman bawah untuk SafeArea
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
                VodanHeader(
                  crossAlign: CrossAxisAlignment.start,
                  title: 'Ganti PIN Lapak',
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  subtitle: 'Masukkan PIN baru untuk keamanan admin lapak ini.',
                  subtitleStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

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

  void _showApiKeysBottomSheet(String workspaceId, bool isDesktop) {
    final aiKeysFuture = ref
        .read(workspaceControllerProvider.notifier)
        .getWorkspaceAiKeys(workspaceId);

    final formKey = GlobalKey<FormState>();
    final rows = <AiKeyFormRow>[];

    bool isEditing = false;
    bool isLoading = false;
    bool initialized = false;

    VodanBottomSheet.show(
      context: context,
      isDismissible: true,
      child: StatefulBuilder(
        builder: (context, setStateModal) {
          return FutureBuilder<List<AiKeys>?>(
            future: aiKeysFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal memuat API keys'),
                );
              }

              if (!initialized) {
                final keys = snapshot.data ?? [];

                rows.addAll(
                  keys.map(
                    (key) => AiKeyFormRow(
                      provider: key.provider,
                      key: key.key,
                    ),
                  ),
                );

                if (rows.isEmpty) {
                  rows.add(AiKeyFormRow());
                }

                initialized = true;
              }

              Future<void> saveAiKeys() async {
                if (!(formKey.currentState?.validate() ?? false)) return;

                setStateModal(() => isLoading = true);

                final newAiKeys = rows
                    .map(
                      (row) => AiKeys(
                        provider: row.provider,
                        key: row.keyController.text.trim(),
                      ),
                    )
                    .toList();

                final errorMessage = await ref
                    .read(workspaceControllerProvider.notifier)
                    .editWorkspaceAiKeys(workspaceId, newAiKeys);

                if (!context.mounted) return;

                setStateModal(() => isLoading = false);

                if (errorMessage == null) {
                  setStateModal(() => isEditing = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI keys berhasil diubah!'),
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

              return Form(
                key: formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height *  0.7,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VodanHeader(
                          crossAlign: CrossAxisAlignment.start,
                          title: 'AI API Keys',
                          titleStyle: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          subtitle: 'Kelola integrasi AI API Keys untuk lapak ini.',
                          subtitleStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                    
                        if (!isEditing) ...[
                          if (rows.isEmpty)
                            const Center(child: Text('Tidak ada API keys'))
                          else
                            ...rows.map(
                              (row) => VodanActionCard(
                                title: row.provider,
                                subtitle: row.keyController.text,
                                prefixIcon: Icons.vpn_key_rounded,
                                color: Colors.purple.shade100,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: VodanActionButton(
                                text: 'Ubah AI Keys',
                                onPressed: () {
                                  setStateModal(() => isEditing = true);
                                },
                              ),
                            ),
                        ] else ...[
                          ...rows.asMap().entries.map((entry) {
                            final index = entry.key;
                            final row = entry.value;
                    
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: VodanDropdown(
                                          initialValue: row.provider,
                                          labelText: 'Provider',
                                          icon: Icons.assistant,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'Gemini',
                                              child: Text('Gemini'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'OpenAI',
                                              child: Text('OpenAI'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Claude',
                                              child: Text('Claude'),
                                            ),
                                          ],
                                          onChanged: isLoading
                                              ? null
                                              : (value) {
                                                  if (value == null) return;
                                                        
                                                  setStateModal(() {
                                                    row.provider = value;
                                                  });
                                                },
                                        ),
                                      ),
                                                        
                                      const SizedBox(width: 12),
                                                        
                                      Expanded(
                                        flex: 2,
                                        child: VodanTextFormField(
                                          controller: row.keyController,
                                          labelText: 'API Key',
                                          prefixIcon: Icons.key_rounded,
                                          obscureText: row.isObscure,
                                          enabled: !isLoading,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              row.isObscure
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                            onPressed: () {
                                              setStateModal(() {
                                                row.isObscure = !row.isObscure;
                                              });
                                            },
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'API Key wajib diisi';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                                        
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: isLoading || rows.length <= 1
                                            ? null
                                            : () {
                                                setStateModal(() {
                                                  row.dispose();
                                                  rows.removeAt(index);
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    
                          VodanActionButton(
                            text: 'Tambah Key',
                            prefixIcon: Icons.add,
                            onPressed: isLoading
                                ? null
                                : () {
                                    setStateModal(() {
                                      rows.add(AiKeyFormRow());
                                    });
                                  },
                          ),
                    
                          const SizedBox(height: 24),
                    
                          SizedBox(
                            width: double.infinity,
                            child: VodanActionButton(
                              text: isLoading ? 'Menyimpan...' : 'Simpan AI Keys',
                              onPressed: isLoading ? null : saveAiKeys,
                            ),
                          ),
                        ],
                    
                        SizedBox(height: isDesktop ? 0 : 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteWorkspaceDialog(String workspaceId) {
    VodanDialog.show(
      context: context, 
      title: 'Hapus Lapak ?',
      message: 'Aksi yang dilakukan tidak dapat dikembalikan',
      customActions: (dialogContext) => [
        VodanActionButton(
          text: 'Batal', 
          prefixIcon: Icons.cancel_rounded,
          onPressed: () {
            Navigator.pop(dialogContext);
          }
        ),

        const SizedBox(width: 16,),

        VodanActionButton(
          text: 'Hapus', 
          prefixIcon: Icons.delete_forever_rounded,
          backgroundColor: Theme.of(context).colorScheme.error,
          onPressed: () async {
            final errorMessage = await ref.read(workspaceControllerProvider.notifier).deleteWorkspace(workspaceId);

            if (context.mounted) {
              Navigator.pop(dialogContext);

              if (errorMessage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lapak berhasil dihapus'),
                    duration: const Duration(seconds: 2),
                  )
                );
                EnterWorkspaceRoute().go(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    duration: const Duration(seconds: 2),
                  )
                );
              }
            }
          }
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = context.isDesktop || context.isTablet;

    final barrierState = ref.watch(adminSessionProvider);
    final saleBroadcastState = ref.watch(currentWorkspaceProvider)!.isSaleBroadcastOn;
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
                onTap: () => _showInfoBottomSheet(workspaceId),
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
            subtitle: 'Notifikasi kasir lain saat ada transaksi baru.',
            prefixIcon: Icons.campaign_rounded,
            color: Colors.blue,
            suffixIcon: Switch(
              value: saleBroadcastState,
              activeThumbColor: Colors.blue,
              onChanged: (bool _) async {
                final errorMessage = await ref.read(workspaceControllerProvider.notifier).toggleSaleBroadcast(workspaceId, saleBroadcastState);

                if (errorMessage != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage))
                  );
                }
              }
            ),
            onTap: () {
              ref.read(workspaceControllerProvider.notifier).toggleSaleBroadcast(workspaceId, !saleBroadcastState);
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
            title: 'AI API Keys',
            subtitle: 'Kelola integrasi AI API Keys Anda',
            prefixIcon: Icons.smart_toy_rounded,
            color: Colors.purple,
            onTap: () => _showApiKeysBottomSheet(workspaceId, isDesktop),
          ),
          const SizedBox(height: 48),

          // SECTION 4: ZONA BERBAHAYA
          _buildSectionTitle('Zona Destruktif'),
          VodanActionCard(
            title: 'Hapus Lapak',
            subtitle: 'Tindakan ini tidak dapat dikembalikan.',
            prefixIcon: Icons.delete_forever_rounded,
            color: Colors.red,
            onTap: () => _showDeleteWorkspaceDialog(workspaceId),
          ),
          const SizedBox(height: 32),
        ],
      ),
      floatingActionButton: Padding(
        padding: isDesktop
              ? EdgeInsetsGeometry.only(
                  left: 16, right: 96, top: 16, bottom: 16)
              : EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
        child: FloatingActionButton.small(
          onPressed: () => ref.read(adminSessionProvider.notifier).lockScreen(),
          backgroundColor: theme.colorScheme.errorContainer,
          child: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onErrorContainer),
        ),
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