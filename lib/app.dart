import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/documents/presentation/home_screen.dart';

class DocuScanApp extends StatelessWidget {
  const DocuScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocuScan',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
