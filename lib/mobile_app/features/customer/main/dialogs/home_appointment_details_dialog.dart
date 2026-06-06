import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/data/services/notification_service.dart';
import 'package:royal_tint/data/services/package_service.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/screens/customer_booking_screen.dart';

class HomeAppointmentDetailsDialog extends StatelessWidget {
  final AppointmentModel appointment;

  const HomeAppointmentDetailsDialog({super.key, required this.appointment});

  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(appointment.appointmentDate);
    final dateStr = parsedDate != null ? DateFormat('EEEE, MMM dd, yyyy').format(parsedDate) : appointment.appointmentDate;
    final timeStr = appointment.appointmentTime;
    final packageService = PackageService();

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

    return Dialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: _gold, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'APPOINTMENT DETAILS',
                style: TextStyle(
                  color: _gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),

              // Status & Branch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildModalInfoCol('BRANCH', appointment.branchID.toUpperCase()),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor, width: 1.2),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date & Time & Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildModalInfoCol('DATE', dateStr),
                  _buildModalInfoCol('TIME', timeStr),
                ],
              ),
              const SizedBox(height: 16),
              _buildModalInfoCol('ESTIMATED DURATION', '${appointment.estimatedDuration} Minutes'),
              const SizedBox(height: 20),

              const Divider(color: _gold, height: 1, thickness: 0.5),
              const SizedBox(height: 16),

              // Customer Details
              const Text(
                'CUSTOMER DETAILS',
                style: TextStyle(
                  color: _gold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gold, width: 1),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Name', appointment.customerName),
                    const SizedBox(height: 6),
                    _buildDetailRow('Phone', appointment.customerPhone ?? ''),
                    const SizedBox(height: 6),
                    _buildDetailRow('Vehicle', '${appointment.vehicleBrand} ${appointment.vehicleModel}'),
                    const SizedBox(height: 6),
                    _buildDetailRow('Plate', appointment.vehiclePlate.toUpperCase()),
                    const SizedBox(height: 6),
                    _buildDetailRow('Type', appointment.vehicleType.toUpperCase()),
                    const SizedBox(height: 6),
                    if (appointment.warranty != null && appointment.warranty!.isNotEmpty) ...[
                      _buildDetailRow('Warranty (Years)', appointment.warranty!.replaceAll(RegExp(r'\s*years?', caseSensitive: false), '').trim()),
                      const SizedBox(height: 6),
                    ],
                    _buildDetailRow('Booked On', DateFormat('MMM dd, yyyy').format(appointment.createdAt)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Divider(color: _gold, height: 1, thickness: 0.5),
              const SizedBox(height: 16),

              // Tint Package & Selections
              const Text(
                'PACKAGE SELECTION',
                style: TextStyle(
                  color: _gold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appointment.packageName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              
              if (appointment.tintSelections.isNotEmpty) ...[
                const Text(
                  'TINT SELECTIONS',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold, width: 1),
                  ),
                  child: Column(
                    children: TintSections.all
                        .where((key) => appointment.tintSelections.containsKey(key))
                        .map((key) {
                      final label = TintSections.labelByKey[key] ?? key;
                      final value = appointment.tintSelections[key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailRow(label, mapSVtoVLT(value)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Free Items
              FutureBuilder<TintPackageModel?>(
                future: packageService.getPackageById(appointment.packageID),
                builder: (context, pkgSnap) {
                  if (!pkgSnap.hasData || pkgSnap.data!.freeItems.isEmpty) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FREE ITEMS',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pkgSnap.data!.freeItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(BootstrapIcons.star_fill, color: _gold, size: 10),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 12))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),

              const Divider(color: _gold, height: 1, thickness: 0.5),
              const SizedBox(height: 16),

              // Estimated Bill Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMATED BILL',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons at bottom
              Column(
                children: [
                  if (appointment.status.toLowerCase() != 'completed' && appointment.status.toLowerCase() != 'cancelled') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerBookingScreen(editAppointment: appointment),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'EDIT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: _surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.red, width: 2),
                              ),
                              title: const Text('Cancel Appointment', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              content: const Text('Are you sure you want to cancel this appointment?', style: TextStyle(color: Colors.white)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('BACK', style: TextStyle(color: Colors.grey))),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('CANCEL APPOINTMENT', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            if (context.mounted) Navigator.pop(context); // Close details modal
                            try {
                              await AppointmentService().updateAppointmentStatus(
                                appointmentID: appointment.appointmentID,
                                newStatus: 'cancelled',
                              );
                              await NotificationService().notifyManagersAppointmentCancelled(
                                branchID: appointment.branchID,
                                customerName: appointment.customerName,
                                appointmentDate: appointment.appointmentDate,
                                appointmentTime: appointment.appointmentTime,
                                appointmentID: appointment.appointmentID,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled'), backgroundColor: Colors.red));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: Colors.red));
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CANCEL APPOINTMENT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (appointment.status.toLowerCase() == 'cancelled') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: _surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.red, width: 2),
                              ),
                              title: const Text('Delete Appointment', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              content: const Text('Are you sure you want to permanently delete this appointment? This cannot be undone.', style: TextStyle(color: Colors.white)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('DELETE', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            if (context.mounted) Navigator.pop(context); // Close details modal
                            try {
                              await AppointmentService().deleteAppointment(appointment.appointmentID);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment deleted'), backgroundColor: Colors.red));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _gold,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
