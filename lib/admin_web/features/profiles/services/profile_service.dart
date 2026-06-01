import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:royal_tint/admin_web/features/profiles/models/manager_profile.dart';
import 'package:royal_tint/admin_web/features/profiles/models/branch_settings.dart';

class ProfileService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  String get currentUid => _auth.currentUser!.uid;

  Future<ManagerProfile> fetchManagerProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('Auth currentUser: ${user?.uid} / ${user?.email}');

    final uid = currentUid;

    final q = await _db
        .collection('managers')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (q.docs.isEmpty) {
      throw Exception('Manager profile not found for uid=$uid');
    }

    return ManagerProfile.fromMap(q.docs.first.data());
  }

  Future<BranchSettings> fetchBranchSettings(String branchID) async {
    try {
      final snap = await _db.collection('branches').doc(branchID).get();
      debugPrint('Firestore read branches/$branchID OK. exists=${snap.exists}');
      final data = snap.data();
      if (data == null) throw Exception('Branch not found: $branchID');
      return BranchSettings.fromMap(branchID, data);
    } on FirebaseException catch (e) {
      debugPrint('Firestore read branches/$branchID FAILED: ${e.code} ${e.message}');
      rethrow;
    }
  }

  Future<void> updateAccountSettings({
    required String name,
    required String phone,
  }) async {
    final uid = currentUid;
    final q = await _db.collection('managers').where('uid', isEqualTo: uid).limit(1).get();
    if (q.docs.isEmpty) throw Exception('Manager profile not found');
    
    await q.docs.first.reference.update({
      'name': name.trim(),
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateShopSettings({
    required String branchID,
    required String supportPhone,
    required Map<String, String> operatingHours,
  }) async {
    await _db.collection('branches').doc(branchID).update({
      'phone': supportPhone.trim(),
      'operatingHours': operatingHours,
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
        actionCodeSettings: ActionCodeSettings(
          url: 'http://localhost:60512/#/reset-password?role=manager',
          handleCodeInApp: false,
        ),
      );
    } catch (_) {
      await _auth.sendPasswordResetEmail(email: email.trim());
    }
  }
}