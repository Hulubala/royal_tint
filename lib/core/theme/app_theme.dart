import 'package:flutter/material.dart';

class AppTheme {
  // Royal Tint Brand Colors
  static const Color black = Color(0xFF000000);
  static const Color gold = Color(0xFFFFD700);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grayBg = Color(0xFFF5F5F5);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: gold,
      scaffoldBackgroundColor: grayBg,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: black,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        titleTextStyle: TextStyle(
          color: gold,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // TextButton Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: gold, width: 2),
        ),
        color: white,
      ),
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: gold,
        secondary: black,
        surface: white,
        error: Colors.red,
      ),
    );
  }
}