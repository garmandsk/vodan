import 'package:flutter/material.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return VodanScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.storefront_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.primary
              ),
              const SizedBox(height: 24),
              Text(
                'VoDan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge
              ),
              const SizedBox(height: 12,),
              Text(
                'Sistem Kasir Pintar dengan AI.\nKelola lapakmu dengan suara.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  CreateWorkspaceRoute().go(context);
                }, 
                child: const Text('Buat Lapak')
              ),
              const SizedBox(height: 16,),

              OutlinedButton(
                onPressed: () {
                  EnterWorkspaceRoute().go(context);
                }, 
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Masuk Lapak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
              ),
              const SizedBox(height: 32,)
            ],
          ),
        ),
      )
    );
  }
}