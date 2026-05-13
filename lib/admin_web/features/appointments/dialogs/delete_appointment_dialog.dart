import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/controllers/appointment_controller.dart';

class DeleteAppointmentDialog extends StatefulWidget {
  final AppointmentModel appointment;
  final String branchID;
  final AppointmentProvider appointmentProvider;
  final AppointmentController controller;

  const DeleteAppointmentDialog({
    super.key,
    required this.appointment,
    required this.branchID,
    required this.appointmentProvider,
    required this.controller,
  });

  @override
  State<DeleteAppointmentDialog> createState() => _DeleteAppointmentDialogState();
}

class _DeleteAppointmentDialogState extends State<DeleteAppointmentDialog> {
  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(d);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  Future<void> _handleDelete() async {
    try {
      await widget.controller.delete(
        provider: widget.appointmentProvider,
        branchID: widget.branchID,
        appointmentID: widget.appointment.appointmentID,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment deleted successfully'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF44336), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFF44336), Color(0xFFD32F2F)]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
              ),
              child: const Row(
                children: [
                  Icon(BootstrapIcons.trash, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text('DELETE APPOINTMENT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Are you sure you want to delete this appointment?',
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF44336), width: 2),
                    ),
                    child: const Row(
                      children: [
                        Icon(BootstrapIcons.exclamation_triangle, color: Color(0xFFF44336), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This action cannot be undone.',
                            style: TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('CUSTOMER:',
                                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(widget.appointment.customerName,
                                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('DATE:',
                                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${_formatDate(widget.appointment.appointmentDate)} at ${_formatTime(widget.appointment.appointmentTime)}',
                                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleDelete,
                          icon: const Icon(BootstrapIcons.trash),
                          label: const Text('DELETE APPOINTMENT',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF44336),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
