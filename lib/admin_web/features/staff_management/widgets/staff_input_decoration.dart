import 'package:flutter/material.dart';

class StaffInputStyles {
  static const Color gold = Color(0xFFFFD700);
  static const Color inputBg = Color(0xFF0F0F0F);
  static const Color borderDark = Color(0xFF2A2A2A);

  static InputDecoration decoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,

      labelStyle: const TextStyle(color: gold),
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),

      prefixIcon: Icon(prefixIcon, color: gold),

      helperText: helperText,
      helperStyle: TextStyle(color: Colors.grey[400], fontSize: 12),

      filled: true,
      fillColor: inputBg,

      counterText: '',

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Use this for TextFormField.style
  static const TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  // Use this for cursorColor
  static const Color cursorColor = gold;
}