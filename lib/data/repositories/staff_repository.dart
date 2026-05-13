import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:royal_tint/domain/models/user/staff_model.dart';

class StaffRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  StaffRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<StaffModel> getCurrentStaff() async {
    final uid = _auth.currentUser!.uid;

    final q = await _db
        .collection('staff')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (q.docs.isEmpty) {
      throw Exception('Staff profile not found for uid=$uid in staff collection');
    }

    return StaffModel.fromFirestore(q.docs.first);
  }

  Stream<StaffModel?> watchCurrentStaff() async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      yield null;
      return;
    }

    yield* _db
        .collection('staff')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : StaffModel.fromFirestore(snap.docs.first));
  }
  Future<String?> updateProfile(String staffID, String name, String phone) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return 'Not authenticated';

      await _db.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _db.collection('staff').doc(staffID).update({
        'name': name,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
