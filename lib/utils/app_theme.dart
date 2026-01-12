import 'package:flutter/material.dart';

class AppTheme {
  // 1. 定义新的暖色调颜色常量
  static const Color backgroundWarm = Color(0xFFFFF5E1); 
  static const Color accentWarmOrange = Color(0xFFFF8A65); 
  static const Color textBrown = Color(0xFF5D4037); 
  static const Color textLightBrown = Color(0xFF8D6E63); 
  static const Color paperColor = Color(0xFFFFF9EE);

  // 2. 【别名修复】：为了让旧代码不报错，我们把旧名字指向新颜色
  static const Color accentGreen = accentWarmOrange; 
  static const Color accentPurple = accentWarmOrange; 
  static const Color backgroundDark = backgroundWarm;
  static const Color cardBackground = paperColor;

  static ThemeData get warmTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundWarm,
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textBrown),
        bodyMedium: TextStyle(color: textBrown),
        titleMedium: TextStyle(color: textBrown),
        titleLarge: TextStyle(color: textBrown, fontWeight: FontWeight.bold),
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: accentWarmOrange,
        brightness: Brightness.light,
        primary: accentWarmOrange,
        surface: paperColor,
      ),

      cardTheme: CardThemeData(
        color: paperColor,
        elevation: 2,
        shadowColor: textBrown.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: textBrown.withOpacity(0.05)),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textBrown),
        titleTextStyle: TextStyle(color: textBrown, fontSize: 20, fontWeight: FontWeight.bold),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentWarmOrange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}