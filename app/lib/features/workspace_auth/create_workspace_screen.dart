import 'package:flutter/material.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';

class CreateWorkspaceScreen extends StatelessWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VodanScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Masukkan Pin Lapak', style: Theme.of(context).textTheme.headlineMedium,),
            const SizedBox(height: 8,),
            Text(
              'Amankan lapakmu dengan 6 digit PIN khusus.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: index < 3 ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                  shape: BoxShape.circle
                ),
              )),
            ),
            const Spacer(),

            ElevatedButton(
              onPressed: () {
                WorkspaceCreatedRoute().go(context);
              }, 
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56)
              ),
              child: const Text('Konfirmasi PIN')
            ),
            const SizedBox(height: 32,)
          ],
        ),
      ),
    );
  }
}