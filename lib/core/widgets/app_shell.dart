import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.index, required this.child, required this.onScan});
  final int index;
  final Widget child;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: child),
    floatingActionButton: FloatingActionButton.large(onPressed: onScan, child: const Icon(Icons.document_scanner_outlined)),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Documents'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );
}
