import 'package:flutter/material.dart';

import '../pages/add_weight/add_weight_page.dart';
import '../pages/history/history_page.dart';
import '../pages/home/home_page.dart';
import '../pages/imc/imc_page.dart';
import '../pages/ocr/ocr_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';
import 'routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _titles = <String>['Inicio', 'Registro', 'OCR', 'Historico', 'IMC'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onOpenRegister: () => setState(() => _currentIndex = 1),
        onOpenOcr: () => setState(() => _currentIndex = 2),
        onOpenHistory: () => setState(() => _currentIndex = 3),
      ),
      const AddWeightPage(),
      const OcrPage(),
      const HistoryPage(),
      const ImcPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0 ? const _BrandTitle() : Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(child: IndexedStack(index: _currentIndex, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded), label: 'Registro'),
          NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner_rounded), label: 'OCR'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Historico'),
          NavigationDestination(icon: Icon(Icons.monitor_weight_outlined), selectedIcon: Icon(Icons.monitor_weight_rounded), label: 'IMC'),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppGradients.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.show_chart_rounded,
            color: AppColors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PesoTrack',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'soft wellness edition',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
