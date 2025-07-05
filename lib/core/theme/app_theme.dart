import 'package:flutter/material.dart';

class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueAccent,
      secondary: Colors.white,
      surface: Color(0xFF0F103F),
      surfaceVariant: Color(0xFF0F103F),
      background: Color(0xFF030014),
      onSecondary: Colors.black,
      error: Color(0xFFEF5350),
      brightness: Brightness.dark,
    ),
  );
}
