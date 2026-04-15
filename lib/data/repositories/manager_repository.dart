import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for setting up manager accounts
class ManagerRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a manager account
  Future<String> createManager({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String branchID,
    required String branchName,
    Map<String, dynamic>? additionalData,
  }) async {
      UserCredential userCredential;

      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw Exception('Email already exists');
        }
        rethrow;
      }

      final uid = userCredential.user!.uid;
      final managerID = 'manager_${branchID}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'manager',
        'name': name,
        'phone': phone,
        'branchID': branchID,
        'branchName': branchName,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        if (additionalData != null) ...additionalData,
      });

      await _firestore.collection('managers').doc(managerID).set({
        'managerID': managerID,
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'branchID': branchID,
        'branchName': branchName,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        if (additionalData != null) ...additionalData,
      });

      return managerID;
  }


  /// Setup default manager accounts for Royal Tint
  Future<void> setupDefaultManagers() async {
    // Manager 1: Steven Ting - Melaka Branch
    const melakaEmail = 'derrickting2003+melaka@gmail.com';
    if (!await managerExists(melakaEmail)) {
      await createManager(
        email: 'derrickting2003+steven.melaka@gmail.com',
        password: 'RoyalTint123!',
        name: 'Steven Ting',
        phone: '+60123456789',
        branchID: 'melaka',
        branchName: 'Royal Tint Melaka',
        additionalData: {
          'position': 'Branch Manager',
          'department': 'Operations',
        },
      );
    }

    // Manager 2: Alex Tan - Seremban 2 Branch
    const serembanEmail = 'derrickting2003+seremban2@gmail.com';
    if (!await managerExists(serembanEmail)) {
      await createManager(
        email: 'derrickting2003+alex.seremban2@gmail.com',
        password: 'RoyalTint123!',
        name: 'Alex Tan',
        phone: '+60123456788',
        branchID: 'seremban2',
        branchName: 'Royal Tint Seremban 2',
        additionalData: {
          'position': 'Branch Manager',
          'department': 'Operations',
        },
      );
    }
  }
  
  Future<bool> managerExists(String email) async {
    final snapshot = await _firestore
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get all managers
  Future<List<Map<String, dynamic>>> getAllManagers() async {
    final snapshot = await _firestore
      .collection('managers')
      .orderBy('branchName')
      .get();

    return snapshot.docs
      .map((doc) => doc.data())
      .toList();
  }

  /// Get managers by branch
  Future<List<Map<String, dynamic>>> getManagersByBranch(String branchID) async {
    final snapshot = await _firestore
      .collection('managers')
      .where('branchID', isEqualTo: branchID)
      .orderBy('name')
      .get();

    return snapshot.docs
      .map((doc) => doc.data())
      .toList();
  }

  /// Update manager status
  Future<void> updateManagerStatus(String managerID, bool isActive) async {
      await _firestore.collection('managers').doc(managerID).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
  }

  /// Delete a manager account
  Future<void> deleteManager(String managerID) async {
    final managerDoc = await _firestore
      .collection('managers')
      .doc(managerID)
      .get();

    if (!managerDoc.exists) {
      throw Exception('Manager not found');
    }

    final managerData = managerDoc.data() as Map<String, dynamic>;
    final uid = managerData['uid'] as String;

      // Delete manager document
      await _firestore.collection('managers').doc(managerID).delete();

      // Delete user document
      await _firestore.collection('users').doc(uid).delete();
  }

  /// Reset manager password
  Future<void> resetManagerPassword(String email) async {
      await _auth.sendPasswordResetEmail(email: email);
  }
}