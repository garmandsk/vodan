import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';

class WorkspaceCreatedScreen extends StatelessWidget {
  const WorkspaceCreatedScreen({
    super.key,
    required this.workspaceId
  });

  final String workspaceId;

  Future<void> _openGoogleSheets() async {
    final Uri url = Uri.parse('https://docs.google.com/spreadsheets/d/1GZLnX5r6eAtcUiblTxxBSUeChDF0s96LRNWU2gDMaB4/copy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Gagal membuka link $url');
    }
  }

  // void _enterWorkspace () {
  //   WorkspaceRoute(workspaceId: workspaceId).go(context);
  // }

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
                subtitle: workspaceId, 
                prefixIcon: Icons.storefront_rounded,
                suffixIcon: Icons.copy_rounded, 
                color: Theme.of(context).colorScheme.primary, 
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: workspaceId));
        
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ID Lapak berhasil disalin! 📋'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    )
                  );
                },
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
                onPressed: () => WorkspaceRoute(workspaceId: workspaceId).go(context)
              ),
            ],
          ),
        ),
      ),
    );
  }
}