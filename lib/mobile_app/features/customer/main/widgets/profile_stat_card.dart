import 'package:flutter/material.dart';

class ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileStatCard({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: gold, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: gold.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
