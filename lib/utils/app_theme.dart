import 'package:flutter/material.dart';

class AppTheme {
  // 1. 定义核心颜色 (static const 确保全局可用且性能高)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color accentGreen = Color(0xFF00FFAB);
  static const Color accentPurple = Color(0xFFBB86FC);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // 2. 定义主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      
      // 颜色方案
      colorScheme: const ColorScheme.dark(
        primary: accentGreen,
        secondary: accentPurple,
        surface: cardBackground,
      ),

      // 【核心修复点】：这里必须用 CardThemeData 而不是 CardTheme
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 顶部标题栏
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: accentGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 底部导航栏
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
        selectedItemColor: accentGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}