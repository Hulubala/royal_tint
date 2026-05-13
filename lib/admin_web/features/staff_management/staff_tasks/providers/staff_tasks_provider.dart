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

  Stream<List<StaffMember>>? staffStream;
  Stream<List<TaskItem>>? activeTasksStream;

  Future<void> load({
    required String branchID,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      staffStream = _service.streamActiveStaff(branchID);
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

      staffStream = _service.streamActiveStaff(branchID);
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

  Future<void> completeTask(String taskID, String staffID, String appointmentID) async {
    if (taskID.trim().isEmpty || staffID.trim().isEmpty) {
      debugPrint("Aborting: TaskID or StaffID is empty");
      return;
    }
    
    try {
      await _service.completeTask(taskID, staffID, appointmentID);
      notifyListeners();
    } catch (e) {
      debugPrint("Error completing task: $e");
    }
  }

  Future<void> finalizeAppointment(String appointmentID, String branchID) async {
    try {
      await _service.finalizeAppointment(appointmentID);
      // Refresh appointments list
      appointments = await _service.fetchAssignableAppointments(branchID);
      notifyListeners();
    } catch (e) {
      debugPrint("Error finalizing appointment: $e");
    }
  }

  Future<void> deleteTask(String taskID, String staffID, String appointmentID) async {
    try {
      await _service.deleteTask(taskID, staffID, appointmentID);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting task: $e");
    }
  }
}