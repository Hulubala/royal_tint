import 'package:flutter/foundation.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';

class AppointmentController {
  AppointmentController({AppointmentService? appointmentService})
      : _appointmentService = appointmentService ?? AppointmentService();

  final AppointmentService _appointmentService;

  Future<void> load(AppointmentProvider provider, {required String branchID}) async {
    try {
      provider.setLoading(true);
      provider.setError(null);

      final apts = await _appointmentService.getLatestAppointments(
        branchID: branchID,
        limit: 200,
      );

      provider.setAppointments(apts);
      provider.setLoading(false);
    } catch (e) {
      provider.setLoading(false);
      provider.setError('Failed to load appointments: $e');
      debugPrint('🔴 AppointmentController.load ERROR: $e');
    }
  }

  Future<void> changeStatus({
    required AppointmentProvider provider,
    required String branchID,
    required String appointmentID,
    required String newStatus,
  }) async {
    await _appointmentService.updateAppointmentStatus(
      appointmentID: appointmentID,
      newStatus: newStatus,
    );
    await load(provider, branchID: branchID);
  }

  Future<void> delete({
    required AppointmentProvider provider,
    required String branchID,
    required String appointmentID,
  }) async {
    await _appointmentService.deleteAppointment(appointmentID);
    await load(provider, branchID: branchID);
  }
}