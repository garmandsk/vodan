import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';

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
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green,),
                ),
                const SizedBox(height: 24,),
                Text(
                  'Lapak Berhasil Dibuat!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 32,),
      
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID Lapak Kamu', style: Theme.of(context).textTheme.bodyMedium,),
                            const SizedBox(height: 4,),
                            Text(
                              workspaceId, 
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary
                              ),
                            )
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
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
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16,),
      
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.table_chart_rounded, color: Colors.green, size: 40,),
                    title: const Text('Template Spreadsheets', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Salin template Google Sheets untuk laporan lapakmu.'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: _openGoogleSheets,
                  ),
                ),
                const SizedBox(height: 32,),
      
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      WorkspaceRoute(workspaceId: workspaceId).go(context);
                    }, 
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: Text(
                      'Masuk ke Lapak',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}