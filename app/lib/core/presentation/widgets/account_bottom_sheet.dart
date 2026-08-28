import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_bottom_sheet.dart';
import 'package:vodan/core/routes/app_router.dart';
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
      spacing: 16,
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
        Column(
          children: [
            Text(name,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(email,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        VodanActionButton(
          text: 'Daftar Lapakku',
          prefixIcon: Icons.storefront_rounded,
          width: double.infinity,
          onPressed: () => WorkspaceListRoute().go(context),
        ),
        VodanActionButton(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onPrimary,
          text: 'Pengaturan Akun',
          prefixIcon: Icons.manage_accounts_outlined,
          width: double.infinity,
          onPressed: () => AccountRoute().go(context),
        ),
        VodanActionButton(
          backgroundColor: theme.colorScheme.errorContainer,
          foregroundColor: theme.colorScheme.onErrorContainer,
          text: 'Keluar (Logout)',
          prefixIcon: Icons.logout_rounded,
          width: double.infinity,
          onPressed: () async {
            await ref.read(accountControllerProvider.notifier).logout();
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
        ),
      ],
    );
  }
}
