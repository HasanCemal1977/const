import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: 0.4,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: 0.3,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: 0.2,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    letterSpacing: 0.15,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    letterSpacing: 0.1,
  );

  // Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Input text
  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    letterSpacing: 0.15,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.1,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textDisabled,
    letterSpacing: 0.1,
  );

  // Card title and content
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: 0.15,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.1,
  );

  // Specific to app features
  static const TextStyle costLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.1,
  );

  static const TextStyle costValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: 0.15,
  );

  static const TextStyle totalCost = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 0.15,
  );

  // Hierarchy level indicators
  static TextStyle levelIndicator(int level) {
    Color color;
    switch (level) {
      case 1:
        color = AppColors.level1;
        break;
      case 2:
        color = AppColors.level2;
        break;
      case 3:
        color = AppColors.level3;
        break;
      case 4:
        color = AppColors.level4;
        break;
      case 5:
        color = AppColors.level5;
        break;
      case 6:
        color = AppColors.level6;
        break;
      case 7:
        color = AppColors.level7;
        break;
      default:
        color = AppColors.text;
    }

    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.1,
    );
  }
}
