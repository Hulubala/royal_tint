import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/controllers/appointment_controller.dart';
import 'package:royal_tint/data/services/notification_service.dart';

class ChangeStatusDialog extends StatefulWidget {
  final AppointmentModel appointment;
  final String branchID;
  final AppointmentProvider appointmentProvider;
  final AppointmentController controller;

  const ChangeStatusDialog({
    super.key,
    required this.appointment,
    required this.branchID,
    required this.appointmentProvider,
    required this.controller,
  });

  @override
  State<ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<ChangeStatusDialog> {
  void _confirmStatusChange(String newStatus, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFC107), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFA000)]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                ),
                child: const Row(
                  children: [
                    Icon(BootstrapIcons.exclamation_triangle, color: Colors.black, size: 24),
                    SizedBox(width: 12),
                    Text('CONFIRM STATUS CHANGE',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Are you sure you want to change the appointment status?',
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                      textAlign: TextAlign.center,
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
                              const Text('CURRENT STATUS:',
                                  style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(widget.appointment.status.toUpperCase(),
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('NEW STATUS:',
                                  style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(newStatus.toUpperCase(),
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('CONFIRM CHANGE',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
      ),
    );

    if (confirmed == true) {
      try {
        bool isValidStatusTransition(String from, String to) {
          final f = from.toLowerCase().trim();
          final t = to.toLowerCase().trim();
          if (t == 'pending') return false;
          if (f == 'completed' || f == 'cancelled') return false;
          if (f == 'pending') return t == 'confirmed' || t == 'cancelled';
          if (f == 'confirmed') return t == 'completed' || t == 'cancelled';
          if (f == 'in-progress') return t == 'completed' || t == 'cancelled';
          return false;
        }

        if (!isValidStatusTransition(widget.appointment.status, newStatus)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid status change: ${widget.appointment.status.toUpperCase()} → ${newStatus.toUpperCase()}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await widget.controller.changeStatus(
          provider: widget.appointmentProvider,
          branchID: widget.branchID,
          appointmentID: widget.appointment.appointmentID,
          newStatus: newStatus,
        );

        if (!mounted) return;

        Navigator.pop(context); // Close the status dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );

        // Clear manager notification if appointment is confirmed/changed
        await NotificationService().markNotificationsAsReadForAppointment(widget.appointment.appointmentID);

        // Auto-notify customer about status change
        if (widget.appointment.customerID.isNotEmpty &&
            !widget.appointment.customerID.startsWith('GUEST_')) {
          NotificationService().notifyCustomerStatusChange(
            customerID: widget.appointment.customerID,
            newStatus: newStatus,
            appointmentDate: widget.appointment.appointmentDate,
            appointmentTime: widget.appointment.appointmentTime,
            appointmentID: widget.appointment.appointmentID,
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildStatusChangeOption(String label, String newStatus, IconData icon, Color color) {
    return InkWell(
      onTap: () => _confirmStatusChange(newStatus, label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = widget.appointment.status.toLowerCase();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Change Status',
                    style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (currentStatus == 'pending') ...[
                    _buildStatusChangeOption('MARK CONFIRMED', 'confirmed', BootstrapIcons.check_circle, const Color(0xFF4CAF50)),
                    _buildStatusChangeOption('CANCEL', 'cancelled', BootstrapIcons.x_circle, const Color(0xFFF44336)),
                  ] else if (currentStatus == 'confirmed') ...[
                    _buildStatusChangeOption('MARK COMPLETED', 'completed', BootstrapIcons.check_all, const Color(0xFF9E9E9E)),
                    _buildStatusChangeOption('CANCEL', 'cancelled', BootstrapIcons.x_circle, const Color(0xFFF44336)),
                  ] else if (currentStatus == 'in-progress') ...[
                    _buildStatusChangeOption('MARK COMPLETED', 'completed', BootstrapIcons.check_all, const Color(0xFF9E9E9E)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
