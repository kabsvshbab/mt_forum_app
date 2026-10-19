import 'package:flutter/material.dart';

class LiquidTheme {
  // iOS 26 Liquid Glass 配色
  static const Color accentBlue = Color(0xFF0A84FF);
  static const Color accentPurple = Color(0xFFBF5AF2);
  static const Color accentPink = Color(0xFFFF375F);
  static const Color darkBg = Color(0xFF0A0A1A);
  static const Color darkBgSecondary = Color(0xFF141433);
  static const Color glassWhite = Color(0x38FFFFFF);
  static const Color glassBorder = Color(0x59FFFFFF);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: accentBlue,
        secondary: accentPurple,
        surface: darkBgSecondary,
        background: darkBg,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        titleMedium: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white, height: 1.55),
        bodyMedium: TextStyle(color: Colors.white70, height: 1.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData light() => dark();
}
