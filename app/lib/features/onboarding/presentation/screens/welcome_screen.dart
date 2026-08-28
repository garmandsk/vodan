import 'package:flutter/material.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return VodanScaffold(
      title: 'Selamat Datang',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Spacer(),
            VodanHeader(
              icon: Icons.storefront_rounded, 
              iconColor: Theme.of(context).colorScheme.primary, 
              title: 'VoDan',
              titleStyle: Theme.of(context).textTheme.displayLarge, 
              subtitle: 'Sistem Kasir Pintar dengan AI.\nKelola lapakmu dengan suara.'
            ),
            Spacer(),
            
            VodanActionButton(
              text: 'Buat Lapak', 
              onPressed: () => CreateWorkspaceRoute().go(context)
            ),
            
            VodanActionButton(
              text: 'Masuk Lapak', 
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              elevation: 5,
              onPressed: () => EnterWorkspaceRoute().go(context),
            ),
            const SizedBox(height: 32,)
          ],
        ),
      )
    );
  }
}