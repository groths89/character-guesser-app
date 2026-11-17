import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get carnivalTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.carnivalSky,
        primary: AppColors.carnivalSkyDeep,
        secondary: AppColors.carnivalGold,
        surface: Colors.white,
      ),
      fontFamily: 'Rubik',
      cardTheme: CardThemeData(
        elevation: 8,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: AppColors.carnivalGold, width: 4),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.carnivalGold,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 6,
        ),
      ),
    );
  }
}
