import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';
import 'package:royal_tint/domain/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createTask(TaskModel task) async {
    final taskRef =
        _firestore.collection(FirebaseConstants.tasksCollection).doc();
    final batch = _firestore.batch();

    batch.set(taskRef, {
      ...task.toFirestore(),
      'taskID': taskRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

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

  Future<List<TaskModel>> getTasksByBranch(String branchID) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .where('branchID', isEqualTo: branchID)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(TaskModel.fromFirestore).toList();
  }
  
  Future<List<TaskModel>> getTasksByAppointment(String appointmentID) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .where('appointmentID', isEqualTo: appointmentID)
        .get();
    return snapshot.docs.map(TaskModel.fromFirestore).toList();
  }

  Future<void> cancelTasksForAppointment(String appointmentID) async {
    final tasks = await getTasksByAppointment(appointmentID);

    final activeTasks = tasks
        .where((t) =>
            t.status == TaskStatus.pending ||
            t.status == TaskStatus.inProgress)
        .toList();
    if (activeTasks.isEmpty) return;
    final batch = _firestore.batch();
    for (final task in activeTasks) {

      final taskRef = _firestore
          .collection(FirebaseConstants.tasksCollection)
          .doc(task.taskID);
      batch.update(taskRef, {
        'status': TaskStatus.cancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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