import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/models/staff_task_model.dart';
import 'staff_repository.dart';

class StaffTaskRepository {
  final FirebaseFirestore _db;
  final StaffRepository _staffRepo;

  StaffTaskRepository({FirebaseFirestore? db, StaffRepository? staffRepo})
      : _db = db ?? FirebaseFirestore.instance,
        _staffRepo = staffRepo ?? StaffRepository();

  // ── Watch a single task by its document ID (used by the details screen) ──────
  Stream<StaffTaskModel?> watchTaskById(String taskId) {
    return _db
        .collection('tasks')
        .doc(taskId)
        .snapshots()
        .map((doc) => doc.exists ? StaffTaskModel.fromFirestore(doc) : null);
  }

  // ── Stream PENDING + IN_PROGRESS tasks for this staff (task list screen) ──────
  Stream<List<StaffTaskModel>> watchUpcomingTasksForCurrentStaff() async* {
    final staff = await _staffRepo.getCurrentStaff();

    yield* _db
        .collection('tasks')
        .where('assignedStaffID', isEqualTo: staff.id)
        .where('status', whereIn: ['PENDING', 'IN_PROGRESS'])
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(StaffTaskModel.fromFirestore).toList());
  }

  // ── Stream today's tasks for the home screen — client-side date filter ────────
  // Uses a single-field query (assignedStaffID) to avoid requiring a composite
  // Firestore index, then filters by date client-side.
  Stream<List<StaffTaskModel>> watchTodayTasksForCurrentStaff() async* {
    final staff = await _staffRepo.getCurrentStaff();

    final now         = DateTime.now();
    final todayStart  = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    yield* _db
        .collection('tasks')
        .where('assignedStaffID', isEqualTo: staff.id)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map(StaffTaskModel.fromFirestore)
              .where((t) {
                return t.createdAt.isAfter(todayStart) &&
                    t.createdAt.isBefore(tomorrowStart);
              })
              .toList();
        });
  }

  // ── Start task: PENDING → IN_PROGRESS, mirrors appointment ──────────────────
  Future<void> startTask(String taskId, String appointmentId) async {
    final batch = _db.batch();

    batch.update(_db.collection('tasks').doc(taskId), {
      'status':    'IN_PROGRESS',
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (appointmentId.isNotEmpty) {
      batch.update(_db.collection('appointments').doc(appointmentId), {
        'status':    'IN_PROGRESS',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ── Complete task: IN_PROGRESS → COMPLETED, mirrors appointment, decrements count
  Future<void> completeTask(
      String taskId, String appointmentId, String staffId) async {
    final batch = _db.batch();

    batch.update(_db.collection('tasks').doc(taskId), {
      'status':      'COMPLETED',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt':   FieldValue.serverTimestamp(),
    });

    if (staffId.isNotEmpty) {
      batch.update(_db.collection('staff').doc(staffId), {
        'currentTaskCount': FieldValue.increment(-1),
        'updatedAt':        FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}