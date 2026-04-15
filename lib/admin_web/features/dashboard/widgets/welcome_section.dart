import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart' as auth;

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key, required this.authProvider});
  final auth.AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    final managerName = authProvider.manager?.name ?? 'Manager';
    final branchName = authProvider.branchName ?? 'Branch';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Welcome Back, $managerName! ',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Text('👋', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(BootstrapIcons.geo_alt_fill, color: Color(0xFFFFD700), size: 14),
              const SizedBox(width: 6),
              Text(
                branchName,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(BootstrapIcons.circle_fill, color: Color(0xFF4CAF50), size: 8),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Here's what's happening with your business today.",
            style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}