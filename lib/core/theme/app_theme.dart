import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primarySeed,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        
        
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primarySeed,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        
        
      ),
    );
  }

  // Aliases de compatibilidad
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
}
