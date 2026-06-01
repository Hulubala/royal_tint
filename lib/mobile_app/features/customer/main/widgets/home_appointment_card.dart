import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';

class HomeAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const HomeAppointmentCard({super.key, required this.appointment});

  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(appointment.appointmentDate);
    final dateStr = parsedDate != null ? DateFormat('EEEE, MMM dd, yyyy').format(parsedDate) : appointment.appointmentDate;
    final timeStr = appointment.appointmentTime;

    Color statusColor;
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = _gold;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${appointment.vehicleBrand.toUpperCase()} ${appointment.vehicleModel.toUpperCase()}',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date & Time
          Row(
            children: [
              const Icon(BootstrapIcons.calendar_event, color: Colors.white70, size: 14),
              const SizedBox(width: 8),
              Text(
                '$dateStr at $timeStr',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Package selected
          Row(
            children: [
              const Icon(BootstrapIcons.box_seam, color: Colors.white70, size: 14),
              const SizedBox(width: 8),
              Text(
                appointment.packageName,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),

          // Estimated Bill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTIMATED BILL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Includes installation & warranty',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
              Text(
                'RM ${appointment.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
