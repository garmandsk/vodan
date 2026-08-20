import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Lapakku', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          // 🌟 AVATAR PROFIL DI POJOK KANAN ATAS
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              // Panggil Bottom Sheet saat ditekan
              onTap: () => AccountBottomSheet.show(context), 
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Text(
                  name[0].toUpperCase(), 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
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