import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:royal_tint/core/design_system/app_colors.dart';
import 'package:royal_tint/admin_web/features/auth/controllers/login_controller.dart';
import 'package:royal_tint/admin_web/features/auth/widgets/login_card.dart';
import 'package:royal_tint/admin_web/features/auth/widgets/login_header.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<LoginController>();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [Color(0xFF1A1A1A), Colors.black],
        ),
      ),
      child: Stack(
        children: [
          _backgroundAccents(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: FadeTransition(
                opacity: c.fadeAnimation,
                child: SlideTransition(
                  position: c.slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        LoginHeader(),
                        SizedBox(height: 48),
                        LoginCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundAccents() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.gold.withOpacity(0.1), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.gold.withOpacity(0.08), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}