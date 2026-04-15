import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'staff_registration_panel_decoration.dart';

class StaffRegistrationHeaderPanel extends StatelessWidget {
  const StaffRegistrationHeaderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: staffPanelDecoration(),
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
              BootstrapIcons.person_plus_fill,
              color: Color(0xFFFFD700),
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register New Staff',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create a new staff account for your branch',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}