import 'dart:async';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/staff_member.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/appointment_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/services/staff_tasks_service.dart';

class StaffTasksProvider extends ChangeNotifier {
  final StaffTasksService _service;

  StaffTasksProvider({StaffTasksService? service})
      : _service = service ?? StaffTasksService();

  bool isLoading = false;
  bool isAssigning = false;
  String? error;

  List<StaffMember> staff = [];
  List<AppointmentItem> appointments = [];

  Stream<List<TaskItem>>? activeTasksStream;

  Future<void> load({
    required String branchID,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      staff = await _service.fetchActiveStaff(branchID);
      appointments = await _service.fetchAssignableAppointments(branchID);
      activeTasksStream = _service.streamActiveTasks(branchID);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> assign({
    required String branchID,
    required StaffMember staffMember,
    required AppointmentItem appointment,
    required String mirrorSection,
    required String darknessCode,
    required String createdByManagerUid,
  }) async {
    isAssigning = true;
    notifyListeners();
    try {
      await _service.assignTask(
        branchID: branchID,
        staff: staffMember,
        appt: appointment,
        mirrorSection: mirrorSection,
        darknessCode: darknessCode,
        createdByManagerUid: createdByManagerUid,
      );

      staff = await _service.fetchActiveStaff(branchID);
      appointments = await _service.fetchAssignableAppointments(branchID);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isAssigning = false;
      notifyListeners();
    }
  }

  Future<Set<String>> getAssignedSectionsForAppointment(String appointmentID) {
    return _service.fetchAssignedMirrorSections(appointmentID);
  }
}