import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';
import 'package:royal_tint/data/models/task_model.dart';

/// Repository for task CRUD operations in Firestore.
class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Create ──────────────────────────────────────────────────────────────

  /// Creates a new task document and increments the assigned staff member's
  /// [currentTaskCount] atomically.
  Future<String> createTask(TaskModel task) async {
    final taskRef =
        _firestore.collection(FirebaseConstants.tasksCollection).doc();

    final batch = _firestore.batch();

    // Write the task document (include the generated ID in the document itself)
    batch.set(taskRef, {
      ...task.toFirestore(),
      'taskID': taskRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Increment the staff member's currentTaskCount
    final staffRef = _firestore
        .collection(FirebaseConstants.staffCollection)
        .doc(task.assignedStaffID);
    batch.update(staffRef, {
      'currentTaskCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('✅ TaskRepository: task created (${taskRef.id})');
    return taskRef.id;
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  /// Returns all tasks for a branch, ordered by creation date (newest first).
  Future<List<TaskModel>> getTasksByBranch(String branchID) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .where('branchID', isEqualTo: branchID)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(TaskModel.fromFirestore).toList();
  }

  /// Returns all tasks linked to a specific appointment.
  Future<List<TaskModel>> getTasksByAppointment(String appointmentID) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .where('appointmentID', isEqualTo: appointmentID)
        .get();
    return snapshot.docs.map(TaskModel.fromFirestore).toList();
  }

  // ── Cleanup on appointment deletion ──────────────────────────────────────

  /// Cancels all active (PENDING / IN_PROGRESS) tasks that belong to
  /// [appointmentID] and decrements each assigned staff member's
  /// [currentTaskCount] accordingly.
  ///
  /// Call this **before** or **after** deleting the appointment document.
  Future<void> cancelTasksForAppointment(String appointmentID) async {
    final tasks = await getTasksByAppointment(appointmentID);

    // Only active tasks affect the task count
    final activeTasks = tasks
        .where((t) =>
            t.status == TaskStatus.pending ||
            t.status == TaskStatus.inProgress)
        .toList();

    if (activeTasks.isEmpty) return;

    final batch = _firestore.batch();

    for (final task in activeTasks) {
      // Mark the task as CANCELLED
      final taskRef = _firestore
          .collection(FirebaseConstants.tasksCollection)
          .doc(task.taskID);
      batch.update(taskRef, {
        'status': TaskStatus.cancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Decrement the staff member's currentTaskCount.
      // Firestore does not natively floor at 0, but currentTaskCount should
      // never be negative in correct usage (we only decrement for tasks that
      // were previously counted when created).
      final staffRef = _firestore
          .collection(FirebaseConstants.staffCollection)
          .doc(task.assignedStaffID);
      batch.update(staffRef, {
        'currentTaskCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    debugPrint(
        '✅ TaskRepository: cancelled ${activeTasks.length} task(s) for appointment $appointmentID');
  }
}
