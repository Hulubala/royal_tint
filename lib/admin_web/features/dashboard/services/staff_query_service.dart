import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';

class StaffQueryService {
  StaffQueryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<int> countActiveStaff({required String branchID}) async {
    final snap = await _firestore
        .collection(FirebaseConstants.staffCollection)
        .where(FirebaseConstants.fieldBranchId, isEqualTo: branchID)
        .where('isActive', isEqualTo: true)
        .get();

    return snap.docs.length;
  }
}