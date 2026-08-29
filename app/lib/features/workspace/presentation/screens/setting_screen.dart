import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vodan/core/presentation/widgets/pin_barrier.dart';
import 'package:vodan/core/presentation/widgets/vodan_dropdown.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/presentation/widgets/vodan_tff_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/utils/ai_form_row.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/workspace/data/models/payment_config_model.dart';
import 'package:vodan/features/workspace/data/models/ticket_model.dart';
import 'package:vodan/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:vodan/features/workspace/data/repositories/workspace_repository.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';
import 'package:vodan/features/workspace_auth/data/models/create_workspace_request_model.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  final TextEditingController _pinController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _copy(BuildContext context, String workspaceId) async {
    await Clipboard.setData(ClipboardData(text: workspaceId));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('ID Lapak berhasil disalin! 📋'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }

  Future<void> _submitPin() async {
    setState(() => _isLoading = true);

    final workspaceId = ref.read(currentWorkspaceProvider)?.id;
    if (workspaceId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final errorMessage = await ref
        .read(currentCashierProvider.notifier)
        .verifyPin(workspaceId, _pinController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);
    _pinController.clear();

    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
    }
  }

  Future<void> _shareWorkspace(BuildContext context, String workspaceId) async {
    final joinLink = Uri.parse('https://vodan.vercel.app')
        .resolve(
          WorkspaceWaitingRoomRoute(
            workspaceId: workspaceId,
            cashierName: 'Kasir-Join',
          ).location,
        )
        .toString();

    final String message =
        'Halo! 👋 Mari bergabung ke lapak saya di VoDan.\n\nKlik tautan berikut untuk masuk otomatis:\n$joinLink\n\nAtau masukkan ID Lapak manual:\n$workspaceId';

    final isMobileShareAllowed = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (isMobileShareAllowed) {
      final result = await SharePlus.instance.share(
        ShareParams(text: message, subject: 'Undangan Akses Lapak Vodan'),
      );

      if (result.status == ShareResultStatus.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tautan lapak berhasil dibagikan! 🚀'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    await Clipboard.setData(ClipboardData(text: message));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan lapak berhasil disalin ke clipboard. 📋'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Bottomsheet Tampilkan info lapak
  void _showInfoBottomSheet(String workspaceId) {
    final initialName =
        ref.read(currentWorkspaceProvider)?.name ?? 'Lapak Anonim';
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
                subtitleStyle:
                    TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                          SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red),
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
                suffixIcon: const Icon(Icons.copy_rounded,
                    size: 20, color: Colors.grey),
                padding: 12,
                iconSize: 22.0,
                titleSize: 12.0,
                onTap: () => _copy(context, workspaceId),
              ),
              const SizedBox(height: 24),
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
                  subtitleStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                                      content:
                                          Text('PIN lapak berhasil diubah! 🔐'),
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

  void _showTicketBottomSheet(String workspaceId) {
    String? passCode;
    bool isLoading = false;
    bool isEditMode = false;
    Duration selectedDuration = const Duration(hours: 24);

    VodanBottomSheet.show(
      context: context,
      child: StatefulBuilder(
        builder: (context, setStateModal) {
          final durationOptions = <Map<String, dynamic>>[
            {'label': '30 Menit', 'duration': const Duration(minutes: 30)},
            {'label': '1 Jam', 'duration': const Duration(hours: 1)},
            {'label': '6 Jam', 'duration': const Duration(hours: 6)},
            {'label': '24 Jam', 'duration': const Duration(hours: 24)},
            {'label': '7 Hari', 'duration': const Duration(days: 7)},
          ];

          String getDurationOptionLabel(Duration duration) {
            final match = durationOptions.firstWhere(
              (option) => (option['duration'] as Duration) == duration,
              orElse: () => durationOptions.first,
            );
            return match['label'] as String;
          }

          String formatDuration(Duration duration) {
            if (duration.inDays > 0) return '${duration.inDays} hari';
            if (duration.inHours > 0) return '${duration.inHours} jam';
            if (duration.inMinutes > 0) return '${duration.inMinutes} menit';
            return 'sesaat';
          }

          Future<void> generateTicket() async {
            setStateModal(() => isLoading = true);
            try {
              final createdCode = await ref
                  .read(workspaceControllerProvider.notifier)
                  .generateShiftPass(workspaceId, ttl: selectedDuration);

              if (!context.mounted) return;

              if (createdCode == null || createdCode.startsWith('Gagal')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(createdCode ?? 'Gagal membuat tiket.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setStateModal(() {
                passCode = createdCode;
                isEditMode = false;
              });
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal membuat tiket: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              if (context.mounted) {
                setStateModal(() => isLoading = false);
              }
            }
          }

          Future<void> copyCode() async {
            if (passCode == null || passCode!.isEmpty) return;

            await Clipboard.setData(ClipboardData(text: passCode!));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kode tiket berhasil disalin!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }

          Future<void> shareTicket() async {
            if (passCode == null || passCode!.isEmpty) return;

            final shareText =
                'Tiket Lapak\nKode akses: $passCode\nBerlaku ${formatDuration(selectedDuration)}\n\nBuka aplikasi VoDan lalu pilih tombol "Gunakan Tiket (QR) Lapak" untuk memindai kode ini.';

            final isMobileShareAllowed = !kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS);

            if (isMobileShareAllowed) {
              final qrPainter = QrPainter(
                data: passCode!,
                version: QrVersions.auto,
                gapless: false,
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
              );

              final recorder = ui.PictureRecorder();
              final canvas = Canvas(
                recorder,
                Rect.fromLTWH(0, 0, 1024, 1024),
              );

              canvas.drawRect(
                const Rect.fromLTWH(0, 0, 1024, 1024),
                Paint()..color = Colors.white,
              );
              qrPainter.paint(canvas, const Size(1024, 1024));

              final picture = recorder.endRecording();
              final qrImage = await picture.toImage(1024, 1024);
              final qrBytes = await qrImage.toByteData(
                format: ui.ImageByteFormat.png,
              );

              if (qrBytes == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal membuat gambar QR untuk dibagikan.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              final qrFile = XFile.fromData(
                qrBytes.buffer.asUint8List(),
                name: 'tiket_emas_$passCode.png',
                mimeType: 'image/png',
              );

              final result = await SharePlus.instance.share(
                ShareParams(
                  text: shareText,
                  subject: 'Tiket Lapak',
                  files: [qrFile],
                ),
              );

              if (result.status == ShareResultStatus.success &&
                  context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tiket berhasil dibagikan!'),
                    backgroundColor: Colors.green,
                  ),
                );
                return;
              }
            }

            await Clipboard.setData(ClipboardData(text: shareText));

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Info tiket berhasil disalin ke clipboard. 📋'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }

          return FutureBuilder<TicketModel?>(
            future: ref
                .read(workspaceControllerProvider.notifier)
                .getShiftPass(workspaceId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Gagal memuat tiket aktif: ${snapshot.error}'),
                );
              }

              final ticket = snapshot.data;
              if (ticket != null && passCode == null) {
                passCode = ticket.passCode;
                final remaining = ticket.expiresAt.difference(DateTime.now());
                if (!remaining.isNegative) {
                  selectedDuration = remaining;
                }
              }

              final DateTime? effectiveExpiry = ticket?.expiresAt;

              final bool isTicketCurrentlyValid = passCode != null &&
                  (ticket == null ||
                      !ticket.expiresAt.isBefore(DateTime.now()));

              String buildRemainingText() {
                if (effectiveExpiry == null) {
                  return 'Berlaku ${formatDuration(selectedDuration)}';
                }

                final remaining = effectiveExpiry.difference(DateTime.now());
                if (remaining.isNegative) {
                  return 'Sudah kadaluarsa';
                }

                if (remaining.inDays > 0) {
                  return '${remaining.inDays} hari ${remaining.inHours % 24} jam tersisa';
                }
                if (remaining.inHours > 0) {
                  return '${remaining.inHours} jam ${remaining.inMinutes % 60} menit tersisa';
                }
                if (remaining.inMinutes > 0) {
                  return '${remaining.inMinutes} menit tersisa';
                }
                return 'Kurang dari 1 menit tersisa';
              }

              final String ticketStatusText = isTicketCurrentlyValid
                  ? 'Tiket masih berlaku • ${buildRemainingText()}'
                  : 'Tiket kadaluarsa';
              final Color ticketStatusColor = isTicketCurrentlyValid
                  ? Colors.green.shade100
                  : Colors.red.shade100;
              final Color ticketStatusTextColor = isTicketCurrentlyValid
                  ? Colors.green.shade800
                  : Colors.red.shade800;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VodanHeader(
                    crossAlign: CrossAxisAlignment.start,
                    title: 'Tiket Lapak',
                    subtitle:
                        'Buat kode akses yang bisa dipakai kasir tanpa menunggu persetujuan owner.',
                    subtitleStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (passCode != null || ticket != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ticketStatusColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ticketStatusTextColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isTicketCurrentlyValid
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            color: ticketStatusTextColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ticketStatusText,
                              style: TextStyle(
                                color: ticketStatusTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (passCode == null || isEditMode) ...[
                    const Text(
                      'Kasir dapat menggunakan tiket ini untuk langsung masuk ke lapak bila owner sedang sibuk.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: VodanDropdown(
                        initialValue: getDurationOptionLabel(selectedDuration),
                        labelText: 'Durasi tiket',
                        icon: Icons.timer_rounded,
                        items: durationOptions
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option['label'] as String,
                                child: Text(option['label'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          final selectedOption = durationOptions.firstWhere(
                            (option) => option['label'] == value,
                          );

                          setStateModal(() {
                            selectedDuration =
                                selectedOption['duration'] as Duration;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: VodanActionButton(
                        text: isLoading ? 'Membuat tiket...' : 'Buat',
                        onPressed: isLoading ? null : generateTicket,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: VodanActionButton(
                        text: 'Batal',
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        onPressed: () {
                          setStateModal(() {
                            isEditMode = false;
                          });
                        },
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode Tiket',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            passCode!,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: QrImageView(
                                data: passCode!,
                                version: QrVersions.auto,
                                size: 180,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Berlaku sampai ${ticket?.expiresAt.toLocal().toString().substring(0, 16) ?? formatDuration(selectedDuration)}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 150,
                          child: VodanActionButton(
                            text: 'Salin Kode',
                            prefixIcon: Icons.copy_rounded,
                            onPressed: copyCode,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: VodanActionButton(
                            text: 'Bagikan',
                            prefixIcon: Icons.share_rounded,
                            onPressed: shareTicket,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: VodanActionButton(
                            text: 'Buat Lagi',
                            prefixIcon: Icons.refresh_rounded,
                            onPressed: () {
                              setStateModal(() {
                                isEditMode = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              );
            },
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
                    maxHeight: MediaQuery.sizeOf(context).height * 0.7,
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
                          subtitle:
                              'Kelola integrasi AI API Keys untuk lapak ini.',
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
                              text:
                                  isLoading ? 'Menyimpan...' : 'Simpan AI Keys',
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

  void _showPaymentConfigBottomSheet(String workspaceId, bool isDesktop) {
    final paymentConfigFuture =
        ref.read(workspacePaymentConfigProvider(workspaceId).future);
    final bankNameControllers = <TextEditingController>[];
    final accountNumberControllers = <TextEditingController>[];
    final accountNameControllers = <TextEditingController>[];
    
    bool isLoading = false;
    String? qrisImageUrl;
    bool initialized = false;

    void addAccount([TransferAccountModel? account]) {
      bankNameControllers.add(TextEditingController(text: account?.bankName));
      accountNumberControllers
          .add(TextEditingController(text: account?.accountNumber));
      accountNameControllers
          .add(TextEditingController(text: account?.accountName));
    }

    void disposeControllers() {
      for (final controller in [
        ...bankNameControllers,
        ...accountNumberControllers,
        ...accountNameControllers,
      ]) {
        controller.dispose();
      }
    }

    VodanBottomSheet.show(
      context: context,
      child: StatefulBuilder(
        builder: (context, setStateModal) {
          return FutureBuilder<PaymentConfigModel>(
            future: paymentConfigFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return const Text('Gagal memuat konfigurasi pembayaran');
              }

              final data = snapshot.data!;
              if (!initialized) {
                qrisImageUrl = data.qrisImageUrl;
                for (final account in data.transferAccounts) {
                  addAccount(account);
                }
                if (bankNameControllers.isEmpty) addAccount();
                initialized = true;
              }

              Future<void> pickQrisImage() async {
                final image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (image == null) return;
                setStateModal(() => isLoading = true);
                try {
                  final url = await ref
                      .read(workspaceRepositoryProvider)
                      .uploadQrisImage(workspaceId, await image.readAsBytes());
                  if (context.mounted) {
                    setStateModal(() => qrisImageUrl = url);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal upload QRIS: $e')));
                  }
                } finally {
                  if (context.mounted) {
                    setStateModal(() => isLoading = false);
                  }
                }
              }

              Future<void> saveAccounts() async {
                final accounts = <TransferAccountModel>[];
                for (var index = 0;
                    index < bankNameControllers.length;
                    index++) {
                  final bank = bankNameControllers[index].text.trim();
                  final number = accountNumberControllers[index].text.trim();
                  final owner = accountNameControllers[index].text.trim();
                  if (bank.isEmpty && number.isEmpty && owner.isEmpty) continue;
                  if (bank.isEmpty || number.isEmpty || owner.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Lengkapi semua data rekening transfer')));
                    return;
                  }
                  accounts.add(TransferAccountModel(
                      bankName: bank,
                      accountNumber: number,
                      accountName: owner));
                }
                setStateModal(() => isLoading = true);
                try {
                  await ref
                      .read(workspaceRepositoryProvider)
                      .updateTransferAccounts(workspaceId, accounts);
                  if (context.mounted) {
                    setStateModal(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Konfigurasi pembayaran berhasil disimpan'),
                        backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (context.mounted) {
                    setStateModal(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Gagal menyimpan rekening: $e')));
                  }
                }
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VodanHeader(
                        crossAlign: CrossAxisAlignment.start,
                        title: 'Konfigurasi Pembayaran',
                        subtitle: 'Atur QRIS dan rekening transfer lapak.',
                        subtitleStyle: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const Text('QRIS',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (qrisImageUrl != null)
                        Center(
                            child: Image.network(qrisImageUrl!,
                                width: 220, height: 220, fit: BoxFit.contain))
                      else
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text('Belum ada gambar QRIS'))),
                      SizedBox(
                          width: double.infinity,
                          child: VodanActionButton(
                              text: isLoading
                                  ? 'Mengunggah...'
                                  : 'Pilih Gambar QRIS',
                              prefixIcon: Icons.upload_file_rounded,
                              onPressed: isLoading ? null : pickQrisImage)),
                      const SizedBox(height: 24),
                      const Text('Rekening Transfer',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List.generate(
                          bankNameControllers.length,
                          (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(spacing: 8, children: [
                                  Row(children: [
                                    Expanded(
                                        child: VodanTextFormField(
                                            controller:
                                                bankNameControllers[index],
                                            labelText: 'E-Wallet / Bank')),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: VodanTextFormField(
                                            controller:
                                                accountNumberControllers[index],
                                            labelText: 'Nomor HP / Rekening',
                                            keyboardType:
                                                TextInputType.number)),
                                    IconButton(
                                        onPressed: bankNameControllers.length ==
                                                1
                                            ? null
                                            : () => setStateModal(() {
                                                  bankNameControllers[index]
                                                      .dispose();
                                                  accountNumberControllers[
                                                          index]
                                                      .dispose();
                                                  accountNameControllers[index]
                                                      .dispose();
                                                  bankNameControllers
                                                      .removeAt(index);
                                                  accountNumberControllers
                                                      .removeAt(index);
                                                  accountNameControllers
                                                      .removeAt(index);
                                                }),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red)),
                                  ]),
                                  VodanTextFormField(
                                      controller: accountNameControllers[index],
                                      labelText: 'Atas Nama'),
                                ]),
                              )),
                      VodanActionButton(
                          text: 'Tambah Rekening',
                          prefixIcon: Icons.add,
                          onPressed: isLoading
                              ? null
                              : () => setStateModal(addAccount)),
                      const SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: VodanActionButton(
                              text: isLoading
                                  ? 'Menyimpan...'
                                  : 'Simpan Konfigurasi',
                              onPressed: isLoading ? null : saveAccounts)),
                      SizedBox(height: isDesktop ? 0 : 24),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ).whenComplete(disposeControllers);
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
                  }),
              const SizedBox(
                width: 16,
              ),
              VodanActionButton(
                  text: 'Hapus',
                  prefixIcon: Icons.delete_forever_rounded,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    final errorMessage = await ref
                        .read(workspaceControllerProvider.notifier)
                        .deleteWorkspace(workspaceId);

                    if (!mounted || !dialogContext.mounted) return;

                    Navigator.pop(dialogContext);

                    if (errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Lapak berhasil dihapus'),
                        duration: const Duration(seconds: 2),
                      ));
                      EnterWorkspaceRoute().go(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(errorMessage),
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  })
            ]);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CashierSessionModel?>(currentCashierProvider, ((previous, next) {
      if (previous?.isPinVerified == true && next?.isPinVerified == false) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              '⏳ Sesi habis karena tidak ada aktivitas. Layar dikunci otomatis.'),
          backgroundColor: Colors.orange,
        ));
      }
    }));

    final theme = Theme.of(context);
    final isDesktop = context.isDesktop || context.isTablet;

    final currentUserState = ref.watch(currentCashierProvider);
    final saleBroadcastState =
        ref.watch(currentWorkspaceProvider)!.isSaleBroadcastOn;
    final workspaceId =
        ref.watch(currentWorkspaceProvider)?.id ?? 'ID_TIDAK_DITEMUKAN';
    final workspaceName =
        ref.watch(currentWorkspaceProvider)?.name ?? 'Lapak Anonim';

    if (!currentUserState!.isPinVerified) {
      return PinBarrier(
        tffController: _pinController,
        tffEnabled: _isLoading,
        tffOnFieldSubmitted: (_) => _submitPin(),
        buttonText: _isLoading ? 'Memeriksa...' : 'Buka Kunci',
        buttonOnPressed: _isLoading ? null : _submitPin,
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header
          Builder(builder: (cardContext) {
            return VodanActionCard(
              title: workspaceName,
              subtitle: 'ID: ${workspaceId.substring(0, 8)}...',
              prefixIcon: Icons.storefront_rounded,
              suffixIcon: IconButton(
                  icon: const Icon(Icons.share_rounded, size: 32),
                  color: theme.colorScheme.primary,
                  onPressed: () => _shareWorkspace(cardContext, workspaceId)),
              color: theme.colorScheme.primary,
              onTap: () => _showInfoBottomSheet(workspaceId),
            );
          }),
          const SizedBox(
            height: 8,
          ),

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
          const SizedBox(height: 8),
          VodanActionCard(
            title: 'Tiket Lapak',
            subtitle:
                'Buat kode akses agar kasir bisa masuk tanpa persetujuan owner.',
            prefixIcon: Icons.airplane_ticket_rounded,
            color: theme.colorScheme.secondary,
            onTap: () => _showTicketBottomSheet(workspaceId),
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
                  final errorMessage = await ref
                      .read(workspaceControllerProvider.notifier)
                      .toggleSaleBroadcast(workspaceId, saleBroadcastState);

                  if (errorMessage != null && context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(errorMessage)));
                  }
                }),
            onTap: () {
              ref
                  .read(workspaceControllerProvider.notifier)
                  .toggleSaleBroadcast(workspaceId, !saleBroadcastState);
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
          const SizedBox(height: 8),
          VodanActionCard(
            title: 'Metode Pembayaran',
            subtitle: 'Atur QRIS dan rekening transfer lapak.',
            prefixIcon: Icons.payments_rounded,
            color: Colors.indigo,
            onTap: () => _showPaymentConfigBottomSheet(workspaceId, isDesktop),
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
            ? EdgeInsetsGeometry.only(left: 16, right: 96, top: 16, bottom: 16)
            : EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
        child: FloatingActionButton.small(
          onPressed: () =>
              ref.read(currentCashierProvider.notifier).activateLock(),
          backgroundColor: theme.colorScheme.errorContainer,
          child: Icon(Icons.lock_outline_rounded,
              color: theme.colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700),
      ),
    );
  }
}
