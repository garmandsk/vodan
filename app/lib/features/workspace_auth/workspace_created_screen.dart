import 'package:flutter/material.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';

class WorkspaceCreatedScreen extends StatelessWidget {
  const WorkspaceCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VodanScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green,),
              ),
              const SizedBox(height: 32,),
              Text(
                'Lapak Berhasil Dibuat!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24,),

              Card(
                color: Colors.white,
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
                          Text('VDN-8842-XYZ', style: Theme.of(context).textTheme.titleLarge,)
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          // TODO: logika clipboard disalin
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ID Lapak disalin!'))
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
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Image.network('https://docs.flutter.dev/assets/images/dash/dash-fainting.gif', width: 40,),
                  title: const Text('Template Database', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Salin template Google Sheets untuk laporan lapakmu.'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    // TODO: logika buka url gsheets template
                  },
                ),
              ),

              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  WorkspaceRoute().go(context);
                }, 
                child: const Text('Masuk ke Lapak'),
              )
            ],
          ),
        ),
      ),
    );
  }
}