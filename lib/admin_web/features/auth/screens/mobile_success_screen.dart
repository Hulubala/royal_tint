import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class MobileSuccessScreen extends StatelessWidget {
  const MobileSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: gold.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(BootstrapIcons.check_circle_fill, color: Colors.green, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Password Reset Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your password has been successfully reset. You may now close this browser tab and return to the Royal Tint Mobile App to log in.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Icon(BootstrapIcons.phone, color: gold, size: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
