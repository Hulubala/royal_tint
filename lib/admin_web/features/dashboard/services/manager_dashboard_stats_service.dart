import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';
import 'package:royal_tint/admin_web/features/dashboard/utils/date_utils.dart';

class ManagerDashboardStatsService {
  ManagerDashboardStatsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<int> getTodayAppointmentsCount({
    required String branchID,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final todayYmd = ymd(t);

    final snap = await _firestore
        .collection(FirebaseConstants.appointmentsCollection)
        .where(FirebaseConstants.fieldBranchId, isEqualTo: branchID)
        .where('appointmentDate', isEqualTo: todayYmd)
        .get();

    return snap.docs.length;
  }

  Future<double> getMonthlyRevenue({
    required String branchID,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final todayYmd = ymd(t);
    final startOfMonthYmd = ymd(DateTime(t.year, t.month, 1));

    final snap = await _firestore
        .collection(FirebaseConstants.appointmentsCollection)
        .where(FirebaseConstants.fieldBranchId, isEqualTo: branchID)
        .where(FirebaseConstants.fieldStatus, isEqualTo: FirebaseConstants.statusCompleted)
        .where('appointmentDate', isGreaterThanOrEqualTo: startOfMonthYmd)
        .where('appointmentDate', isLessThanOrEqualTo: todayYmd)
        .get();

    return snap.docs.fold<double>(0.0, (sum, doc) {
      final v = doc.data()['totalPrice'];
      if (v is num) return sum + v.toDouble();
      return sum;
    });
  }

  Future<int> getActiveStaffCount({
    required String branchID,
  }) async {
    final snap = await _firestore
        .collection(FirebaseConstants.staffCollection)
        .where(FirebaseConstants.fieldBranchId, isEqualTo: branchID)
        .where('isActive', isEqualTo: true)
        .get();

    return snap.docs.length;
  }
}