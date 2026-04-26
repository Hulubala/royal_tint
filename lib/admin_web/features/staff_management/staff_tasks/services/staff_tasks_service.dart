import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/staff_member.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/appointment_item.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/models/task_item.dart';

class StaffTasksService {
  final FirebaseFirestore _db;

  StaffTasksService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<List<StaffMember>> fetchActiveStaff(String branchID) async {
    final q = await _db
        .collection('staff')
        .where('branchID', isEqualTo: branchID)
        .where('isActive', isEqualTo: true)
        .get();

    final list = q.docs.map((d) => StaffMember.fromMap(d.id, d.data())).toList();

    // optional: sort available first then by task count
    list.sort((a, b) {
      final av = (b.isAvailable ? 1 : 0) - (a.isAvailable ? 1 : 0);
      if (av != 0) return av;
      return a.currentTaskCount.compareTo(b.currentTaskCount);
    });

    return list;
  }

  Future<List<AppointmentItem>> fetchAssignableAppointments(String branchID) async {
    final q = await _db
        .collection('appointments')
        .where('branchID', isEqualTo: branchID)
        .get();

    final list = q.docs
        .map((d) => AppointmentItem.fromMap(d.id, d.data()))
        .toList();

    final filtered = list.where((a) {
      final s = a.status.toLowerCase();
      final okStatus =
          s == 'pending' || s == 'confirmed' || s == 'in-progress';

      return okStatus;
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
      final section = (data['mirrorSection'] ?? '').toString().trim();
      final status = (data['status'] ?? '').toString().trim().toLowerCase();

      if (section.isNotEmpty && status != 'approved') {
        set.add(section);
      }
    }

    return set;
  }

  Stream<List<TaskItem>> streamActiveTasks(String branchID) {
    return _db
        .collection('tasks')
        .where('branchID', isEqualTo: branchID)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskItem.fromMap(d.id, d.data())).toList())
        .map((tasks) {
          // filter statuses in Dart
          final filtered = tasks.where((t) {
            final s = t.status.toLowerCase();
            return s == 'pending' || s == 'confirmed' || s == 'in-progress';
          }).toList();

          // sort newest first in Dart (createdAt may be null)
          filtered.sort((a, b) {
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
    final taskRef = _db.collection('tasks').doc();
    final apptRef = _db.collection('appointments').doc(appt.id);
    final staffRef = _db.collection('staff').doc(staff.id);

    final batch = _db.batch();

    final existing = await _db
        .collection('tasks')
        .where('appointmentID', isEqualTo: appt.id)
        .where('mirrorSection', isEqualTo: mirrorSection)
        .get();

    final sectionKey = _sectionKeyFromLabel(mirrorSection);
    final darkness = sectionKey.isEmpty ? '' : mapVLTtoCode(appt.tintSelections[sectionKey] ?? '', appt.packageType);

    batch.set(taskRef, {
      'branchID': branchID,
      'staffID': staff.id,
      'staffName': staff.name,
      'appointmentID': appt.id,
      'customerName': appt.customerName,
      'plateNumber': appt.plateNumber,
      'packageName': appt.packageName,
      'carBrand': appt.brand,
      'carModel': appt.model,
      'mirrorSection': mirrorSection,
      'darkness': darkness,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdByManagerUid,
    });

    // store assigned staff id in appointment
    batch.update(apptRef, {
      'assignedStaffID': staff.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // increment staff task count
    batch.update(staffRef, {
      'currentTaskCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  String _sectionKeyFromLabel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'front windshield':
        return 'frontWindshield';
      case 'rear windshield':
        return 'rearWindshield';
      case 'left side':
        return 'leftSide';
      case 'right side':
        return 'rightSide';
      default:
        return '';
    }
  }
}