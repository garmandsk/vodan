import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_dialog.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/features/account/presentation/controllers/account_controller.dart';

class CashierBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final String submitButtonText;
  final String? initialWorkspaceId;
  final String? initialCashierName;
  
  final Future<void> Function(String workspaceId, String cashierName) onSubmit;

  const CashierBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.submitButtonText,
    required this.onSubmit,
    this.initialWorkspaceId,
    this.initialCashierName,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String submitButtonText,
    required Future<void> Function(String workspaceId, String cashierName) onSubmit,
    String? initialWorkspaceId,
    String? initialCashierName,
  }) {
    return VodanBottomSheet.show( // Memanggil Cangkang Utama
      context: context,
      child: CashierBottomSheet(
        title: title,
        subtitle: subtitle,
        submitButtonText: submitButtonText,
        onSubmit: onSubmit,
        initialWorkspaceId: initialWorkspaceId,
        initialCashierName: initialCashierName,
      ),
    );
  }

  @override
  ConsumerState<CashierBottomSheet> createState() => _CashierBottomSheetState();
}

class _CashierBottomSheetState extends ConsumerState<CashierBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _workspaceIdController;
  late TextEditingController _nameController;

  bool _isLoadingDeviceName = true;
  bool _isSubmitting = false; 

  Future<void> _fetchName() async {
    final userLoggedInName = ref.read(getAccountProvider)?.userMetadata?['name'];
    final cashierName = userLoggedInName ?? await _fetchDeviceName();
    
    if (mounted) {
      setState(() {
        _nameController.text = 'Kasir-$cashierName';
        _isLoadingDeviceName = false;
      });
    }
  }

  Future<String> _fetchDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Unknown Device';
    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceName = webInfo.browserName.name;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        final iOsInfo = await deviceInfo.iosInfo;
        deviceName = iOsInfo.model;
      } else if (Platform.isMacOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        deviceName = macOsInfo.model;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceName = windowsInfo.computerName;
      }

      return deviceName;
    } catch (e) {
      debugPrint('Gagal mengambil device ID: $e');
      return deviceName;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final workspaceId = _workspaceIdController.text.trim();
      final cashierName = _nameController.text.trim();

      try {
        setState(() => _isSubmitting = true); 
        await widget.onSubmit(workspaceId, cashierName);

        if (mounted){
          Navigator.of(context).pop(); 
        }
      } catch (e) {
        if (mounted) {
          VodanDialog.show(
            context: context, 
            title: 'Gagal Masuk Lapak', 
            message: 'Tidak dapat menemukan Lapak dengan ID tersebut atau terjadi kesalahan jaringan.\n\nDetail: $e'
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false); 
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _workspaceIdController = TextEditingController(text: widget.initialWorkspaceId);
    _nameController = TextEditingController(text: widget.initialCashierName);

    if (widget.initialCashierName != null && widget.initialCashierName!.isNotEmpty) {
      _isLoadingDeviceName = false;
    } else {
      _fetchName();
    }
  }

  @override
  void dispose() {
    _workspaceIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          VodanHeader(
            icon: Icons.point_of_sale_rounded,
            title: widget.title, 
            subtitle: widget.subtitle,
          ),

          VodanTextFormField(
            controller: _workspaceIdController,
            labelText: 'ID Lapak',
            hintText: '123-abc-456-def-789',
            prefixIcon: Icons.store_rounded,
            prefixIconColor: Theme.of(context).colorScheme.secondary,
            validator: (value) {
              if (value == null || value.isEmpty) return 'ID Lapak wajib diisi';
              return null;
            }
          ),

          VodanTextFormField(
            controller: _nameController,
            enabled: !_isLoadingDeviceName,
            labelText: 'Nama Kasir',
            hintText: 'Kasir-Udin',
            prefixIcon: Icons.badge_rounded,
            prefixIconColor: Theme.of(context).colorScheme.tertiary,
            suffixIcon: _isLoadingDeviceName
                ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                : null,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
              return null;
            }
          ),

          VodanActionButton(
            text: widget.submitButtonText, 
            isLoading: _isLoadingDeviceName || _isSubmitting, 
            onPressed: _submit
          ),
        ],
      ),
    );
  }
}