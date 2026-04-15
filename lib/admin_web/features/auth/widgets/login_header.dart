import 'package:flutter/material.dart';
import 'package:royal_tint/core/design_system/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Royal Tint',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            shadows: [Shadow(color: AppColors.gold, blurRadius: 20)],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manager Portal',
          style: TextStyle(
            color: AppColors.grey300,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}