import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.light(
    // Brand chính: xanh dương-tím hiện đại
    primary: Color(0xFF4F6AF5),
    onPrimary: Color(0xFFFFFFFF),

    // Brand phụ
    secondary: Color(0xFF6C63FF),
    onSecondary: Color(0xFFFFFFFF),

    // Container
    primaryContainer: Color(0xFFE8ECFF),
    onPrimaryContainer: Color(0xFF1A237E),
    secondaryContainer: Color(0xFFEDE7FF),
    onSecondaryContainer: Color(0xFF311B92),

    // Surface
    surface: Color(0xFFF8F9FF),
    onSurface: Color(0xFF1A1B2E),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFE8E9F0),

    // Misc
    tertiary: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFF1A237E),
    outline: Color(0xFFBDBECC),
    onSurfaceVariant: Color(0xFF5C5F7A),
    tertiaryContainer: Color(0xFF00C9A7),
  ),
  scaffoldBackgroundColor: Color(0xFFF0F2FF),
  cardColor: Color(0xFFFFFFFF),
  dividerColor: Color(0xFFE8E9F0),
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Color(0xFF4F6AF5),
    foregroundColor: Color(0xFFFFFFFF),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shadowColor: Color(0x1A4F6AF5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Color(0xFFFFFFFF),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFFFFFFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFBDBECC)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFBDBECC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF4F6AF5), width: 2),
    ),
    hintStyle: TextStyle(color: Color(0xFFBDBECC)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF4F6AF5),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  listTileTheme: ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
