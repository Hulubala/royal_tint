import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/widgets/staff_registration_info_row.dart';

class StaffRegistrationSuccessDialog extends StatelessWidget {
  final String staffEmail;
  final String staffID;
  final String password;
  final bool requiresReauth;
  final VoidCallback onOk;

  const StaffRegistrationSuccessDialog({
    super.key,
    required this.staffEmail,
    required this.staffID,
    required this.password,
    required this.requiresReauth,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              BootstrapIcons.check_circle_fill,
              color: Color(0xFFFFD700),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Staff Registered!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff account has been created successfully!',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          StaffRegistrationInfoRow(label: 'Staff ID', value: staffID),
          StaffRegistrationInfoRow(label: 'Email', value: staffEmail),
          StaffRegistrationInfoRow(label: 'Password', value: password),
          const SizedBox(height: 16),
          _successBox(),
          if (requiresReauth) ...[
            const SizedBox(height: 16),
            _reauthBox(),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: onOk, child: const Text('OK')),
      ],
    );
  }

  Widget _successBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(BootstrapIcons.check_circle_fill, color: Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Staff can log in using the email and password you set.',
              style: TextStyle(fontSize: 13, color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reauthBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(BootstrapIcons.exclamation_triangle_fill, color: Colors.orange[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You will need to log back in to continue.',
              style: TextStyle(fontSize: 13, color: Colors.orange[700], fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}