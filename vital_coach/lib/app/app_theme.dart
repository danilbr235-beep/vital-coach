import 'package:flutter/material.dart';

/// Calm, premium neutrals — extend with tokens from DESIGN_SYSTEM when ported.
class AppTheme {
  static const Color _ink = Color(0xFF1C2433);
  static const Color _surface = Color(0xFFF4F6FA);
  static const Color _accent = Color(0xFF2E6B6E);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accent,
        brightness: Brightness.light,
        surface: _surface,
      ),
      scaffoldBackgroundColor: _surface,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _surface,
        foregroundColor: _ink,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _ink,
        displayColor: _ink,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: base.colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
