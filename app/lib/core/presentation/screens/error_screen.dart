import 'package:flutter/material.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';


class ErrorScreen extends StatelessWidget {
  final Exception error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return VodanScaffold(
      title: 'Halaman Tidak Ditemukan',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 80, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 24),
              Text(
                'Oops! Ada yang salah.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Menampilkan pesan error asli dari router
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  const WelcomeRoute().go(context);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Kembali ke Awal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}