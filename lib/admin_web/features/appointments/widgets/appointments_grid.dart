import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_card.dart';

class AppointmentsGrid extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final Function(AppointmentModel) onView;
  final Function(AppointmentModel) onEdit;
  final Function(AppointmentModel) onChangeStatus;
  final Function(AppointmentModel) onDelete;

  const AppointmentsGrid({
    super.key,
    required this.appointments,
    required this.onView,
    required this.onEdit,
    required this.onChangeStatus,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFC107); // Amber
      case 'confirmed':
        return const Color(0xFF00BCD4); // Cyan
      case 'in-progress':
        return const Color(0xFF2196F3); // Blue
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  Color _getCardBorderColor(int index) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFC107),
      const Color(0xFF00BCD4),
      const Color(0xFF9C27B0),
    ];
    return colors[index % colors.length];
  }

  bool _isLightColor(Color color) {
    final double luminance =
        (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    return luminance > 0.5;
  }

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

  String _formatBranch(String branchID) {
    if (branchID.toLowerCase().contains('melaka')) return 'Melaka';
    if (branchID.toLowerCase().contains('seremban')) return 'Seremban 2';
    return branchID;
  }

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(BootstrapIcons.calendar_x,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5), size: 64),
              const SizedBox(height: 16),
              const Text('No appointments found',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Try adjusting your filters',
                  style: TextStyle(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                      fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxCardWidth;

        if (constraints.maxWidth < 600) {
          maxCardWidth = constraints.maxWidth;
        } else if (constraints.maxWidth < 900) {
          maxCardWidth = 500;
        } else if (constraints.maxWidth < 1400) {
          maxCardWidth = 420;
        } else {
          maxCardWidth = 380;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCardWidth,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 350,
          ),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final apt = appointments[index];

            return AppointmentCard(
              appointment: apt,
              index: index,
              borderColor: _getCardBorderColor(index),
              statusColor: _getStatusColor(apt.status),
              formatPhoneNumber: _formatPhoneNumber,
              formatDate: _formatDate,
              formatTime: _formatTime,
              formatBranch: _formatBranch,
              isLightColor: _isLightColor,
              onView: () => onView(apt),
              onEdit: () => onEdit(apt),
              onChangeStatus: () => onChangeStatus(apt),
              onDelete: () => onDelete(apt),
            );
          },
        );
      },
    );
  }
}
