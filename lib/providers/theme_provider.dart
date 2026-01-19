// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  warm,
  dark,
  ocean,
  forest,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _currentTheme = AppThemeMode.warm;
  bool _isDarkMode = false;

  AppThemeMode get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? 0;
    _currentTheme = AppThemeMode.values[themeIndex];
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', theme.index);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData getThemeData() {
    if (_isDarkMode) {
      return _getDarkTheme();
    }

    switch (_currentTheme) {
      case AppThemeMode.warm:
        return _getWarmTheme();
      case AppThemeMode.ocean:
        return _getOceanTheme();
      case AppThemeMode.forest:
        return _getForestTheme();
      case AppThemeMode.dark:
        return _getDarkTheme();
    }
  }

  ThemeData _getWarmTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFF5E1),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF8A65),
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFF9EE),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  ThemeData _getOceanTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFE0F7FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0097A7),
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFB2EBF2),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  ThemeData _getForestTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFE8F5E9),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFC8E6C9),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF8A65),
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}