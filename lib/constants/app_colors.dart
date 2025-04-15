import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E88E5); // Blue
  static const Color secondary = Color(0xFF43A047); // Green
  static const Color accent = Color(0xFFFFB300); // Amber

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color text = Color(0xFF333333);
  static const Color textLight = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Level Colors (for hierarchy visualization)
  static const Color level1 = Color(0xFF1E88E5); // Project - Blue
  static const Color level2 = Color(0xFF43A047); // Buildings - Green
  static const Color level3 = Color(0xFF8E24AA); // Disciplines - Purple
  static const Color level4 = Color(0xFFEF6C00); // Groups - Orange
  static const Color level5 = Color(0xFF1976D2); // Items - Dark Blue
  static const Color level6 = Color(0xFF00897B); // Sub Items - Teal
  static const Color level7 = Color(0xFFE53935); // Analysis - Red

  // Helper method to create MaterialColor from a single Color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = <int, Color>{};

    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    swatch[500] = color;
    return MaterialColor(color.value, swatch);
  }
}
