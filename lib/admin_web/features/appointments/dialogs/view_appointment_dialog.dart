import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';

class ViewAppointmentDialog extends StatelessWidget {
  final AppointmentModel appointment;
  final Function(AppointmentModel) onEdit;
  final Function(AppointmentModel) onChangeStatus;
  final VoidCallback onRefresh;

  const ViewAppointmentDialog({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onChangeStatus,
    required this.onRefresh,
  });

  String _formatPhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length >= 10) {
      return '${phone.substring(0, 3)}-${phone.substring(3)}';
    } else if (phone.length >= 3) {
      return '${phone.substring(0, 3)}-${phone.substring(3)}';
    }
    return phone;
  }

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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC700)]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.2), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTintRows(Map<String, String> tintSelections, String packageName) {
    final preferredOrder = [
      TintSections.frontWindScreen,
      TintSections.frontSideWindows,
      TintSections.rearPassenger,
      TintSections.rearWindscreen,
    ];

    final sortedEntries = preferredOrder.map((key) {
      if (tintSelections.containsKey(key)) {
        final label = TintSections.labelByKey[key] ?? key;
        final darknessCode = mapVLTtoCode(tintSelections[key]!, packageName, sectionKey: key);
        return _buildViewRow('$label:', darknessCode);
      }
      return const SizedBox.shrink();
    }).toList();

    return sortedEntries;
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = appointment.status.toLowerCase() == 'completed';
    final isInProgress = appointment.status.toLowerCase() == 'in-progress';
    final isCancelled = appointment.status.toLowerCase() == 'cancelled';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.eye, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  const Text('APPOINTMENT DETAILS',
                      style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('CUSTOMER INFORMATION', BootstrapIcons.person_circle),
                    const SizedBox(height: 16),
                    _buildViewRow('NAME:', appointment.customerName),
                    const SizedBox(height: 12),
                    _buildViewRow('PHONE:', _formatPhoneNumber(appointment.customerPhone ?? 'N/A')),

                    const SizedBox(height: 24),

                    _buildSectionHeader('VEHICLE INFORMATION', BootstrapIcons.car_front_fill),
                    const SizedBox(height: 16),
                    _buildViewRow('CAR MODEL:', '${appointment.vehicleBrand} ${appointment.vehicleModel}'),
                    const SizedBox(height: 12),
                    _buildViewRow('CAR PLATE:', appointment.vehiclePlate),

                    const SizedBox(height: 24),

                    _buildSectionHeader('APPOINTMENT DETAILS', BootstrapIcons.calendar_check),
                    const SizedBox(height: 16),
                    _buildViewRow('DATE:', _formatDate(appointment.appointmentDate)),
                    const SizedBox(height: 12),
                    _buildViewRow('TIME:', _formatTime(appointment.appointmentTime)),
                    const SizedBox(height: 12),
                    _buildViewRow('PACKAGE:', appointment.packageName),
                    const SizedBox(height: 12),
                    _buildViewRow('PRICE:', 'RM ${appointment.totalPrice.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _buildViewRow('STATUS:', isInProgress ? 'IN-PROGRESS' : appointment.status.toUpperCase()),
                    if (isCompleted) ...[
                      const SizedBox(height: 12),
                      _buildViewRow(
                        'FINISH SERVICE TIME:',
                        DateFormat('MMM dd, yyyy hh:mm a').format(appointment.updatedAt),
                      ),
                      if (appointment.warranty != null && appointment.warranty!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildViewRow('WARRANTY (YEARS):', appointment.warranty!.replaceAll(RegExp(r'\s*years?', caseSensitive: false), '').trim()),
                      ],
                    ],

                    const SizedBox(height: 24),
                    _buildSectionHeader('DARKNESS TINTED', BootstrapIcons.droplet_half),
                    const SizedBox(height: 16),
                    ..._buildTintRows(appointment.tintSelections, appointment.packageName),

                    if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildViewRow('NOTES:', appointment.notes!),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(13), bottomRight: Radius.circular(13)),
                border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCompleted && !isCancelled)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onChangeStatus(appointment);
                            },
                            icon: const Icon(BootstrapIcons.check_circle),
                            label: const Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF198754),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      if (!isCompleted && !isInProgress && !isCancelled)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit(appointment);
                          },
                          icon: const Icon(BootstrapIcons.pencil),
                          label: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
