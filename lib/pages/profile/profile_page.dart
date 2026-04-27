import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/soft_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Altura: ${profile.heightCm.toStringAsFixed(0)} cm'),
                Text('Meta: ${profile.goalWeight.toStringAsFixed(1)} kg'),
                Text('Idade: ${profile.age} anos'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            child: const Text('Alternar tema'),
          ),
        ],
      ),
    );
  }
}
