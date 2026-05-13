import 'package:flutter/material.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({super.key});

  static const gold = Color(0xFFD4AF37);

  static const supportEmail = 'support@royaltint.com';
  static const supportPhone = '0162059690';
  static const supportHours = '9am–7pm (Mon–Sat)';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111111),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Contact Support',
        textAlign: TextAlign.center,
        style: TextStyle(color: gold, fontWeight: FontWeight.w700),
      ),
      content: const Text(
        'Email: $supportEmail\n'
        'Phone: $supportPhone\n'
        'Hours: $supportHours',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}