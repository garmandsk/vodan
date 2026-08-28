import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_badge.dart';
import 'package:vodan/features/account/data/repositories/account_repository.dart';
import 'package:vodan/core/presentation/widgets/account_bottom_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(accountRepositoryProvider).currentUser;
    final name = user?.userMetadata?['name'] ?? user?.email?.split('@')[0] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Akun'),
        automaticallyImplyLeading: false,
        actions: [
          if (name != 'Anonim')
            VodanBadge(
              text: name,
              radius: 18,
              onTap: () => AccountBottomSheet.show(context),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $name! 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mau pantau lapak mana hari ini?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}