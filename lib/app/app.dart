import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/onboarding/onboarding_page.dart';
import '../pages/onboarding/profile_setup_page.dart';
import '../pages/profile/profile_page.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';
import 'routes.dart';

class PesoTrackApp extends ConsumerWidget {
  const PesoTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PesoTrack',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const _AppGate(),
      routes: {
        AppRoutes.shell: (_) => const AppShell(),
        AppRoutes.onboarding: (_) => const OnboardingPage(),
        AppRoutes.profileSetup: (_) => const ProfileSetupPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
      },
    );
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!profileState.hasProfile) {
      return const OnboardingPage();
    }

    return const AppShell();
  }
}
