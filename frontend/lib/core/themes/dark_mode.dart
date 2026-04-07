import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.dark(
    // Brand chính
    primary: Color(0xFF7B8FFF),
    onPrimary: Color(0xFF0D0F2B),

    // Brand phụ
    secondary: Color(0xFF9C8FFF),
    onSecondary: Color(0xFF0D0F2B),

    // Container
    primaryContainer: Color(0xFF1E2460),
    onPrimaryContainer: Color(0xFFB8C4FF),
    secondaryContainer: Color(0xFF2A1F6B),
    onSecondaryContainer: Color(0xFFCCC4FF),

    // Surface
    surface: Color(0xFF1A1B2E),
    onSurface: Color(0xFFE8E9FF),
    surfaceBright: Color(0xFF252640),
    surfaceDim: Color(0xFF12131F),

    // Misc
    tertiary: Color(0xFF252640),
    inversePrimary: Color(0xFFB8C4FF),
    outline: Color(0xFF3D3F5C),
    onSurfaceVariant: Color(0xFFAAABCC),
    tertiaryContainer: Color(0xFF00B4A0),
  ),
  scaffoldBackgroundColor: Color(0xFF12131F),
  cardColor: Color(0xFF1A1B2E),
  dividerColor: Color(0xFF2A2B40),
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Color(0xFF1A1B2E),
    foregroundColor: Color(0xFFE8E9FF),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFE8E9FF),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 4,
    shadowColor: Color(0x407B8FFF),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Color(0xFF1A1B2E),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF252640),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF3D3F5C)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF3D3F5C)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF7B8FFF), width: 2),
    ),
    hintStyle: TextStyle(color: Color(0xFF5C5F7A)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF7B8FFF),
      foregroundColor: Color(0xFF0D0F2B),
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
