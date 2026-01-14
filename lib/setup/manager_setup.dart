import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for setting up manager accounts
class ManagerSetup {
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
    try {
      // Check if email already exists
      List<String> methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        print('⚠️  Email already exists: $email');
        throw Exception('Email already exists');
      }

      // 1. Create Firebase Auth account
      print('  → Creating Firebase Auth account for: $email');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      String managerID = 'manager_${branchID}_${DateTime.now().millisecondsSinceEpoch}';

      // 2. Create user document
      print('  → Creating user document...');
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'manager',
        'name': name,
        'phone': phone,
        'branchID': branchID,
        'emailVerified': true, // Pre-verified for managers
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });

      // 3. Create manager document
      print('  → Creating manager document...');
      await _firestore.collection('managers').doc(managerID).set({
        'managerID': managerID,
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'branchID': branchID,
        'branchName': branchName,
        'isActive': true,
        'dateJoined': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });

      // Sign out after creating (so we don't stay logged in as this manager)
      await _auth.signOut();

      print('✅ Manager created successfully: $email');
      return managerID;
    } catch (e) {
      print('❌ Error creating manager: $e');
      rethrow;
    }
  }

  /// Setup default manager accounts for Royal Tint
  Future<void> setupDefaultManagers() async {
    try {
      // Manager 1: Steven Ting - Melaka Branch
      await createManager(
        email: 'steven.melaka@royaltint.com',
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

      // Manager 2: Alex Tan - Seremban 2 Branch
      await createManager(
        email: 'alex.seremban2@royaltint.com',
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

      print('✅ All managers created successfully');
    } catch (e) {
      print('❌ Error setting up managers: $e');
      rethrow;
    }
  }

  /// Check if a manager exists by email
  Future<bool> managerExists(String email) async {
    try {
      List<String> methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking manager existence: $e');
      return false;
    }
  }

  /// Get all managers
  Future<List<Map<String, dynamic>>> getAllManagers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('managers')
          .orderBy('branchName')
          .get();

      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error getting managers: $e');
      return [];
    }
  }

  /// Get managers by branch
  Future<List<Map<String, dynamic>>> getManagersByBranch(String branchID) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('managers')
          .where('branchID', isEqualTo: branchID)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error getting managers by branch: $e');
      return [];
    }
  }

  /// Update manager status
  Future<void> updateManagerStatus(String managerID, bool isActive) async {
    try {
      await _firestore.collection('managers').doc(managerID).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Manager status updated: $managerID → $isActive');
    } catch (e) {
      print('❌ Error updating manager status: $e');
      rethrow;
    }
  }

  /// Delete a manager account
  Future<void> deleteManager(String managerID) async {
    try {
      // Get manager document
      DocumentSnapshot managerDoc = await _firestore
          .collection('managers')
          .doc(managerID)
          .get();

      if (!managerDoc.exists) {
        throw Exception('Manager not found');
      }

      Map<String, dynamic> managerData = managerDoc.data() as Map<String, dynamic>;
      String uid = managerData['uid'];

      // Delete manager document
      await _firestore.collection('managers').doc(managerID).delete();

      // Delete user document
      await _firestore.collection('users').doc(uid).delete();

      // Note: Firebase Auth user cannot be deleted from client SDK
      // This requires Admin SDK or Firebase Console manual deletion

      print('✅ Manager deleted: $managerID');
      print('⚠️  Note: Firebase Auth account must be deleted manually from Firebase Console');
    } catch (e) {
      print('❌ Error deleting manager: $e');
      rethrow;
    }
  }

  /// Reset manager password
  Future<void> resetManagerPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      rethrow;
    }
  }
}