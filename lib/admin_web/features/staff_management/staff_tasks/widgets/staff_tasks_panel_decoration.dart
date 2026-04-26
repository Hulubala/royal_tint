  import 'package:flutter/material.dart';

BoxDecoration staffTasksPanelDecoration() {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0F0F0F),
        Color(0xFF1A1A1A),
        Color(0xFF0B0B0B),
      ],
    ),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFFFD700), width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.20),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ],
  );
}