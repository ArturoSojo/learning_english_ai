import 'package:flutter/material.dart';



class AppTheme {
  
  static final light = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6A1B9A), // Purple 800
      secondary: Color(0xFFBA68C8), // Purple 300
      surface: Colors.white,
      surfaceVariant: Color(0xFFF3E5F5), // Light purple 50
      onSecondary: Colors.white,
      error: Color(0xFFD32F2F), // Red 700
    ),
    useMaterial3: true,
  );

  static final dark = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFBA68C8), // Purple 300
      secondary: Color(0xFF9C27B0), // Purple 500
      surface: Color(0xFF121212),
      surfaceVariant: Color(0xFF1E1E1E),
      onSecondary: Colors.black,
      error: Color(0xFFEF5350), // Red 400
    ),
    useMaterial3: true,
  );
}