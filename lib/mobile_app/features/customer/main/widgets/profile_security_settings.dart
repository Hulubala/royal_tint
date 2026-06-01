import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class ProfileSecuritySettings extends StatelessWidget {
  final bool isSendingReset;
  final VoidCallback onSendReset;

  const ProfileSecuritySettings({
    super.key,
    required this.isSendingReset,
    required this.onSendReset,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.shield_lock_fill, color: gold, size: 18),
              SizedBox(width: 10),
              Text(
                'Security Settings',
                style: TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Forgot your password? Reset your password by sending a secure link to your registered email address.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isSendingReset ? null : onSendReset,
              icon: isSendingReset
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: gold))
                  : const Icon(BootstrapIcons.envelope_paper, size: 16),
              label: Text(isSendingReset ? 'Sending...' : 'Send Reset Link to Email'),
              style: OutlinedButton.styleFrom(
                foregroundColor: gold,
                side: BorderSide(color: gold.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
