import 'package:flutter/material.dart';

class ManagerFooter extends StatelessWidget {
  const ManagerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Color(0xFF1a1a1a)],
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFFFFD700), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '© ${DateTime.now().year} Royal Tint Digital Platform. All rights reserved.',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}