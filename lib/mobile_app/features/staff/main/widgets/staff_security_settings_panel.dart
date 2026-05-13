import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class StaffSecuritySettingsPanel extends StatefulWidget {
  final String email;
  final Future<String?> Function(String email) onSendReset;

  const StaffSecuritySettingsPanel({
    super.key,
    required this.email,
    required this.onSendReset,
  });

  @override
  State<StaffSecuritySettingsPanel> createState() => _StaffSecuritySettingsPanelState();
}

class _StaffSecuritySettingsPanelState extends State<StaffSecuritySettingsPanel> {
  bool _isSending = false;

  void _handleSendReset() async {
    setState(() => _isSending = true);
    final error = await widget.onSendReset(widget.email);
    
    if (mounted) {
      setState(() => _isSending = false);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent to your email'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.shield_lock, color: gold, size: 20),
              SizedBox(width: 8),
              Text('Security Settings', style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Reset your password by sending a secure link to your registered email address.',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSending ? null : _handleSendReset,
              icon: _isSending 
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: gold))
                  : const Icon(BootstrapIcons.envelope_paper),
              label: Text(_isSending ? 'Sending...' : 'Send Reset Link to Email'),
              style: OutlinedButton.styleFrom(
                foregroundColor: gold,
                side: BorderSide(color: gold.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
