import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/providers/session.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/features/account/presentation/controllers/account_controller.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/waiting_room_controller.dart';

class WorkspaceCreatedScreen extends ConsumerStatefulWidget {
  const WorkspaceCreatedScreen({
    super.key,
    required this.workspaceId
  });

  final String workspaceId;

  @override
  ConsumerState<WorkspaceCreatedScreen> createState() => _WorkspaceCreatedScreenState();
}

class _WorkspaceCreatedScreenState extends ConsumerState<WorkspaceCreatedScreen> {
  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.workspaceId));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID Lapak berhasil disalin! 📋'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      )
    );
  }

  Future<void> _openGoogleSheets() async {
    final Uri url = Uri.parse('https://docs.google.com/spreadsheets/d/1GZLnX5r6eAtcUiblTxxBSUeChDF0s96LRNWU2gDMaB4/copy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Gagal membuka link $url');
    }
  }

  // void _enterWorkspace () {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: VodanScaffold(
        title: 'Pembuatan Lapak Berhasil',
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              VodanHeader(
                icon: Icons.check_circle_rounded,
                iconColor: Colors.green, 
                title: 'Lapak Berhasil Dibuat!'
              ),
              
              VodanActionCard(
                title: 'ID Lapak Kamu', 
                subtitle: widget.workspaceId, 
                prefixIcon: Icons.storefront_rounded,
                suffixIcon: IconButton(
                  icon: Icon(Icons.copy_rounded),
                  onPressed: () => _copy(context),
                ), 
                color: Theme.of(context).colorScheme.primary, 
                onTap: () => _copy(context)
              ),
              
              VodanActionCard(
                title: 'Template Spreadsheets', 
                subtitle: 'Salin template Google Sheets untuk laporan lapakmu.', 
                prefixIcon: Icons.table_chart_rounded, 
                color: Colors.green, 
                onTap: _openGoogleSheets
              ),
              const SizedBox(height: 16,),
              
              VodanActionButton(
                text: 'Masuk ke Lapak', 
                onPressed: () async {
                  try {
                    final name =
                    ref.read(getAccountProvider)?.userMetadata?['name'] ??
                        'Anonim';
                    // print('name: $name');

                    ref.read(currentWorkspaceProvider.notifier).setWorkspaceSession(workspaceId: widget.workspaceId);

                    await ref.read(waitingRoomControllerProvider.notifier).joinAsOwner(widget.workspaceId, name);

                    if (context.mounted) {
                      PosRoute().go(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal masuk: $e'), backgroundColor: Theme.of(context).colorScheme.error,)
                      );
                    }
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}