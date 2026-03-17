import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryWine,
          primary: AppColors.primaryWine,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryWine,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      );
}
