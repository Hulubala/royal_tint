import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/data/repositories/task_repository.dart';
import 'package:royal_tint/domain/models/task_model.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/staff_member.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/appointment_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';

class StaffTasksService {
  final FirebaseFirestore _db;
  final TaskRepository _taskRepository; 

  StaffTasksService({FirebaseFirestore? db, TaskRepository? taskRepository}) 
    : _db = db ?? FirebaseFirestore.instance,
     _taskRepository = taskRepository ?? TaskRepository();

  Stream<List<StaffMember>> streamActiveStaff(String branchID) {
    return _db
        .collection('staff')
        .where('branchID', isEqualTo: branchID)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((d) => StaffMember.fromMap(d.id, d.data())).toList();
      
      list.sort((a, b) {
        final av = (b.isAvailable ? 1 : 0) - (a.isAvailable ? 1 : 0);
        if (av != 0) return av;
        return a.currentTaskCount.compareTo(b.currentTaskCount);
      });
      return list;
    });
  }

  Future<void> decreaseStaffTaskCount(String staffID) async {
    await FirebaseFirestore.instance
        .collection('staff')
        .doc(staffID)
        .update({
      'currentTaskCount': FieldValue.increment(-1), 
    });
  }

  Future<List<AppointmentItem>> fetchAssignableAppointments(String branchID) async {
    final snap = await _db
        .collection('appointments')
        .where('branchID', isEqualTo: branchID)
        .orderBy('appointmentDate')
        .get();

    final list = snap.docs
        .map((d) => AppointmentItem.fromMap(d.id, d.data()))
        .toList();

    final filtered = list.where((a) {
      final s = a.status.toUpperCase();
      // Allow assignment for CONFIRMED or already IN_PROGRESS appointments 
      return s == 'CONFIRMED' || s == 'IN_PROGRESS' || s == 'IN-PROGRESS';
    }).toList();

    filtered.sort((a, b) =>
        ('${b.appointmentDate} ${b.appointmentTime}')
            .compareTo('${a.appointmentDate} ${a.appointmentTime}'));

    return filtered;
  }

  Future<Set<String>> fetchAssignedMirrorSections(String appointmentID) async {
    final q = await _db
        .collection('tasks')
        .where('appointmentID', isEqualTo: appointmentID)
        .get();

    final set = <String>{};

    for (final d in q.docs) {
      final data = d.data();
      final String sectionsRaw = (data['mirrorSection'] ?? '').toString().trim();
      final status = (data['status'] ?? '').toString().trim().toLowerCase();

      // Only count sections from tasks that are NOT cancelled
      if (sectionsRaw.isNotEmpty && status != 'cancelled') {
        final List<String> sections = sectionsRaw.split(',').map((s) => s.trim()).toList();
        for (var s in sections) {
          if (s.isNotEmpty) set.add(s);
        }
      }
    }

    return set;
  }

  Stream<List<TaskItem>> streamActiveTasks(String branchID) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    
    return _db
        .collection('tasks')
        .where('branchID', isEqualTo: branchID)
        .snapshots()
        .map((snap) {
      
      final allTasks = snap.docs.map((d) => TaskItem.fromMap(d.id, d.data())).toList();

      final filtered = allTasks.where((t) {
        final s = t.status.toUpperCase();
        final DateTime taskDate = t.createdAt ?? DateTime.now();

        bool isFromToday = taskDate.isAfter(todayStart) && taskDate.isBefore(tomorrowStart);
        bool isActive = (s == 'PENDING' || s == 'IN_PROGRESS' || s == 'IN-PROGRESS');

        return isFromToday || isActive;
      }).toList();

      filtered.sort((a, b) {
        if (a.status != 'COMPLETED' && b.status == 'COMPLETED') return -1;
        if (a.status == 'COMPLETED' && b.status != 'COMPLETED') return 1;
       
        final at = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bt = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bt.compareTo(at);
        });

      return filtered;
    });
  }

  Future<void> assignTask({
    required String branchID,
    required StaffMember staff,
    required AppointmentItem appt,
    required String mirrorSection,
    required String darknessCode,
    required String createdByManagerUid,
  }) async {

    final now = DateTime.now();

    final task = TaskModel(
      taskID: '',
      branchID: branchID,
      title: '${appt.customerName} - $mirrorSection',
      description: 'Tint ${appt.brand} ${appt.model}',
      assignedStaffID: staff.id,
      assignedStaffName: staff.name,
      appointmentID: appt.id,
      customerName: appt.customerName,
      vehicleModel: '${appt.brand} ${appt.model}',
      packageName: appt.packageName,
      plateNumber: appt.plateNumber,
      carBrand: appt.brand,
      carModel: appt.model,
      mirrorSection: mirrorSection,
      darkness: darknessCode,
      packageType: appt.packageType,
      status: TaskStatus.pending,
      priority: TaskPriority.medium,
      dueDate: now.add(const Duration(hours: 2)),
      createdAt: now,
      updatedAt: now,
    );

    await _taskRepository.createTask(task);

    await _db.collection('appointments').doc(appt.id).update({
      'assignedStaffID': staff.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeTask(String taskID, String staffID, String appointmentID) async {
    final batch = _db.batch();

    // Mark task completed with timestamp
    final taskRef = _db.collection('tasks').doc(taskID);
    batch.update(taskRef, {
      'status': 'COMPLETED',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Decrement staff workload
    final staffRef = _db.collection('staff').doc(staffID);
    batch.update(staffRef, {
      'currentTaskCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // NOTE: Appointment status is NOT updated here. 
    // It will be updated by the manager via finalizeAppointment() 
    // after all tasks for this appointment are done.

    await batch.commit();
  }

  Future<void> finalizeAppointment(String appointmentID) async {
    final batch = _db.batch();

    // 1. Update appointment
    batch.update(_db.collection('appointments').doc(appointmentID), {
      'status': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Mark all tasks for this appointment as isFinalized = true and status = COMPLETED
    final tasksSnap = await _db.collection('tasks').where('appointmentID', isEqualTo: appointmentID).get();
    for (var doc in tasksSnap.docs) {
      batch.update(doc.reference, {
        'status': 'COMPLETED',
        'isFinalized': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> deleteTask(String taskID, String staffID, String appointmentID) async {
    final batch = _db.batch();

    // Remove the task document
    final taskRef = _db.collection('tasks').doc(taskID);
    batch.delete(taskRef);

    // Decrement staff workload
    final staffRef = _db.collection('staff').doc(staffID);
    batch.update(staffRef, {
      'currentTaskCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Check if there are other tasks for this appointment
    final otherTasks = await _db
        .collection('tasks')
        .where('appointmentID', isEqualTo: appointmentID)
        .get();
    
    // Only revert appointment to CONFIRMED if NO other tasks exist
    // If other tasks exist, it remains in its current state (assigned/in-progress)
    if (otherTasks.docs.length <= 1) { 
      // <= 1 because the current task is still in the collection until batch commit, 
      // but 'delete' is queued. Actually, better check if any REMAINING tasks.
      // Wait, since we are in a Future, we can check the count.
      final remainingTasks = otherTasks.docs.where((d) => d.id != taskID).toList();
      
      if (remainingTasks.isEmpty) {
        final apptRef = _db.collection('appointments').doc(appointmentID);
        batch.update(apptRef, {
          'status': 'confirmed',
          'assignedStaffID': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }
}
