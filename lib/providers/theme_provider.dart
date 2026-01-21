// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  warm,
  dark,
  ocean,
  forest,
  custom, // 新增自定义主题
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _currentTheme = AppThemeMode.warm;
  bool _isDarkMode = false;
  Color _customColor = const Color(0xFFFF8A65); // 自定义颜色

  AppThemeMode get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  Color get customColor => _customColor;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? 0;
    _currentTheme = AppThemeMode.values[themeIndex];
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    
    // 加载自定义颜色
    final customColorValue = prefs.getInt('customColor');
    if (customColorValue != null) {
      _customColor = Color(customColorValue);
    }
    
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', theme.index);
    notifyListeners();
  }

  // 新增: 设置自定义颜色
  Future<void> setCustomColor(Color color) async {
    _customColor = color;
    _currentTheme = AppThemeMode.custom;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customColor', color.value);
    await prefs.setInt('theme', AppThemeMode.custom.index);
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
      case AppThemeMode.custom:
        return _getCustomTheme();
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
        shadowColor: const Color(0xFF5D4037).withOpacity(0.1),
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
        shadowColor: Colors.cyan.withOpacity(0.1),
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
        shadowColor: Colors.green.withOpacity(0.1),
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
        elevation: 1, // 【优化】减少深色模式阴影
        shadowColor: Colors.black.withOpacity(0.3), // 【优化】降低阴影透明度
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // 【新增】优化深色模式文字颜色
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
        titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
      ),
    );
  }

  // 新增: 自定义主题
  ThemeData _getCustomTheme() {
    final lightness = HSLColor.fromColor(_customColor).lightness;
    final backgroundColor = HSLColor.fromColor(_customColor)
        .withLightness(0.95)
        .toColor();
    final cardColor = HSLColor.fromColor(_customColor)
        .withLightness(0.98)
        .toColor();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _customColor,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: _customColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}