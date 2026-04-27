import 'package:flutter/material.dart';

import '../pages/add_weight/add_weight_page.dart';
import '../pages/history/history_page.dart';
import '../pages/home/home_page.dart';
import '../pages/imc/imc_page.dart';
import '../pages/ocr/ocr_page.dart';
import 'routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _titles = <String>['Inicio', 'Registro', 'OCR', 'Historico', 'IMC'];

  final _pages = const [
    HomePage(),
    AddWeightPage(),
    OcrPage(),
    HistoryPage(),
    ImcPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(child: IndexedStack(index: _currentIndex, children: _pages)),
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
