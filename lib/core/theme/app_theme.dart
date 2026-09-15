import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const ink = Color(0xFF152038);
  static const primary = Color(0xFF4F6BFF);
  static const mint = Color(0xFF18B88B);
  static const canvas = Color(0xFFF6F7FB);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
      );
}
