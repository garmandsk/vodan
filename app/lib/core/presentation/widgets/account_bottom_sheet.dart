import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/features/account/data/repositories/account_repository.dart';
import 'package:vodan/features/account/presentation/controllers/account_controller.dart'; 

class AccountBottomSheet extends ConsumerWidget {
  const AccountBottomSheet({super.key});

  static void show(BuildContext context) {
    VodanBottomSheet.show(
      context: context,
      child: const AccountBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(accountRepositoryProvider).currentUser;
    final email = user?.email ?? 'Tidak ada email';
    final name = user?.userMetadata?['name'] ?? email.split('@')[0];
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),

        Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 32),

        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.manage_accounts_outlined),
          label: const Text('Pengaturan Akun'),
        ),
        const SizedBox(height: 12),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
          ),
          onPressed: () async {
            if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
            await Future.delayed(const Duration(milliseconds: 300));
            ref.read(accountControllerProvider.notifier).logout();
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Keluar (Logout)'),
        ),
      ],
    );
  }
}