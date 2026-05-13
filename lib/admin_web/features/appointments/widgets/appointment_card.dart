import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import 'package:royal_tint/domain/models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.index,
    required this.borderColor,
    required this.statusColor,
    required this.formatPhoneNumber,
    required this.formatDate,
    required this.formatTime,
    required this.formatBranch,
    required this.isLightColor,
    required this.onView,
    required this.onEdit,
    required this.onChangeStatus,
    required this.onDelete,
  });

  final AppointmentModel appointment;
  final int index;

  /// Injected UI helpers from the screen (so card stays dumb)
  final Color borderColor;
  final Color statusColor;
  final String Function(String raw) formatPhoneNumber;
  final String Function(String appointmentDate) formatDate;
  final String Function(String appointmentTime) formatTime;
  final String Function(String branchId) formatBranch;
  final bool Function(Color c) isLightColor;

  /// Injected actions
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onChangeStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final appointmentType = appointment.appointmentType.toLowerCase();

    // Safely get customer phone
    String customerPhone = 'N/A';
    try {
      customerPhone = formatPhoneNumber(appointment.customerPhone ?? 'N/A');
    } catch (_) {
      customerPhone = 'N/A';
    }

    final vehicleDisplay = '${appointment.vehicleBrand} ${appointment.vehicleModel}';

    final String s = appointment.status.toUpperCase();
    final isInProgress = s == 'IN_PROGRESS' || s == 'IN-PROGRESS';
    final isCompleted = s == 'COMPLETED';
    final isCancelled = s == 'CANCELLED';

    final typeColor =
        appointmentType == 'walk-in' ? const Color(0xFF9C27B0) : const Color(0xFF00BCD4);

    final typeTextColor = isLightColor(typeColor) ? Colors.black : Colors.white;
    final statusTextColor = isLightColor(statusColor) ? Colors.black : Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.customerName,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointmentType == 'walk-in' ? 'WALK-IN' : 'SCHEDULED',
                        style: TextStyle(
                          color: typeTextColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          BootstrapIcons.telephone_fill,
                          color: Color(0xFFFFD700),
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          customerPhone,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isInProgress ? 'IN-PROGRESS' : appointment.status.toUpperCase(),
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  _compactDetailRow(BootstrapIcons.calendar3, 'DATE', formatDate(appointment.appointmentDate)),
                  const SizedBox(height: 12),
                  _compactDetailRow(BootstrapIcons.clock, 'TIME', formatTime(appointment.appointmentTime)),
                  const SizedBox(height: 12),
                  _compactDetailRow(
                    BootstrapIcons.car_front_fill,
                    'VEHICLE',
                    '${appointment.vehiclePlate} • $vehicleDisplay',
                  ),
                  const SizedBox(height: 12),
                  _compactDetailRow(BootstrapIcons.geo_alt_fill, 'BRANCH', formatBranch(appointment.branchID)),
                  const SizedBox(height: 12),
                  _compactDetailRow(BootstrapIcons.box_seam, 'PACKAGE', appointment.packageName),
                  const SizedBox(height: 12),
                  _compactDetailRow(
                    BootstrapIcons.cash_stack,
                    'PRICE',
                    'RM ${appointment.totalPrice.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onView,
                    icon: const Icon(BootstrapIcons.eye, size: 12),
                    label: const Text(
                      'VIEW',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                if (!isInProgress && !isCompleted && !isCancelled) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(BootstrapIcons.pencil, size: 12),
                      label: const Text(
                        'EDIT',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onChangeStatus,
                      icon: const Icon(BootstrapIcons.arrow_repeat, size: 12),
                      label: const Text(
                        'STATUS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(BootstrapIcons.trash, size: 14, color: Colors.white),
                    padding: const EdgeInsets.all(9),
                    constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFFFFD700).withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}