import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  double _getStrength() {
    if (password.isEmpty) return 0.0;
    
    double strength = 0.0;
    
    // Length check
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    
    // Complexity checks
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[!@#\$&*~_.]').hasMatch(password)) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }

  Color _getColor(double strength) {
    if (strength == 0.0) return Colors.transparent;
    if (strength <= 0.35) return Colors.red;
    if (strength <= 0.75) return Colors.orange;
    return Colors.green;
  }

  String _getLabel(double strength) {
    if (strength == 0.0) return '';
    if (strength <= 0.35) return 'Weak';
    if (strength <= 0.75) return 'Medium';
    return 'Strong';
  }

  Widget _buildRuleItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isMet ? Colors.green : Colors.grey[500],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey[500],
              fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength();
    final color = _getColor(strength);
    final label = _getLabel(strength);
    
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$&*~_.]').hasMatch(password);

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: color,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRuleItem('At least 8 characters long', password.length >= 8),
        _buildRuleItem('Contains uppercase and lowercase letters', hasUppercase && hasLowercase),
        _buildRuleItem('Contains at least one digit', hasDigit),
        _buildRuleItem('Contains at least one special symbol', hasSpecial),
      ],
    );
  }
}
