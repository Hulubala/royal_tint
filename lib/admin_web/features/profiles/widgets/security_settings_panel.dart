import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'profile_panel_decoration.dart';

class SecuritySettingsPanel extends StatelessWidget {
  final String email;
  final bool isSending;
  final Future<void> Function() onSendReset;

  const SecuritySettingsPanel({
    super.key,
    required this.email,
    required this.isSending,
    required this.onSendReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: profilePanelDecoration(),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(BootstrapIcons.shield_lock_fill,
                  color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 10),
              const Text(
                'Security Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reset your password via email link',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _infoRow('Email', email.isEmpty ? '-' : email),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.info_circle_fill,
                    color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We will send a password reset link to your email. This is the safest option and does not require re-login inside the app.',
                    style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: (isSending || email.isEmpty) ? null : onSendReset,
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(BootstrapIcons.envelope_arrow_up_fill),
                label: const Text(
                  'Send Reset Link',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[300],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}