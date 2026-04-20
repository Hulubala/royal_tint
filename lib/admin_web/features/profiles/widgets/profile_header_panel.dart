import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'profile_panel_decoration.dart';

class ProfileHeaderPanel extends StatelessWidget {
  final String managerName;
  final String branchName;

  const ProfileHeaderPanel({
    super.key,
    required this.managerName,
    required this.branchName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: profilePanelDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: const Icon(
              BootstrapIcons.person_circle,
              color: Color(0xFFFFD700),
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (managerName.isEmpty && branchName.isEmpty)
                      ? 'Manage account, security and shop settings'
                      : '$managerName • $branchName',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}