import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,

    primary: Color(0xFF4C662B),
    secondary: Color(0xFF3A4D1F),
    secondaryContainer: Color(0xFFDCE7C8),
    primaryContainer: Color(0xFFCDEDA3),
    surfaceDim: Color(0xFFDADBD0),
    outline: Color(0xFF75796C),
    surface: Color(0xFFE2E3D8),

    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSecondaryContainer: Color(0xFF404A33),
    onPrimaryContainer: Color(0xFF354E16),
    onSurface: Color(0xFF1A1C16),
  ),
  
);
