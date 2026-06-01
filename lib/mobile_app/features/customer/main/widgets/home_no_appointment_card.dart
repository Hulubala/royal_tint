import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/mobile_app/features/customer/main/screens/customer_main_screen.dart';

class HomeNoAppointmentCard extends StatelessWidget {
  const HomeNoAppointmentCard({super.key});

  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(BootstrapIcons.calendar_x, color: _gold.withValues(alpha: 0.5), size: 36),
          const SizedBox(height: 12),
          const Text(
            'No Appointment Found',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Book a professional tinting service today.',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => CustomerMainScreen.changeTab(context, 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Book a New Appointment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
