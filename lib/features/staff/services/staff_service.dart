// lib/features/staff/services/staff_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';

class StaffService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Manager creates staff account
  Future<Map<String, dynamic>> registerStaffByManager({
    required String managerUID,
    required String managerBranchID,
    required String staffName,
    required String staffEmail,
    required String staffPhone,
    required String temporaryPassword,
    required List<String> expertise,
  }) async {
    try {
      // 1. Get current user (manager) to restore later
      User? currentManager = _auth.currentUser;
      String? managerEmail = currentManager?.email;
      
      // 2. Create Firebase Auth account for staff
      UserCredential staffCredential = await _auth.createUserWithEmailAndPassword(
        email: staffEmail,
        password: temporaryPassword,
      );

      String staffUID = staffCredential.user!.uid;
      String staffID = 'staff_${staffUID.substring(0, 8)}';

      // 3. Create user document
      await _firestore.collection(FirebaseConstants.usersCollection).doc(staffUID).set({
        'uid': staffUID,
        'email': staffEmail,
        'role': FirebaseConstants.roleStaff,
        'name': staffName,
        'phone': staffPhone,
        'branchID': managerBranchID,
        'emailVerified': false,
        'mustChangePassword': true, // Flag to force password change
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Create staff document
      await _firestore.collection(FirebaseConstants.staffCollection).doc(staffID).set({
        'staffID': staffID,
        'uid': staffUID,
        'name': staffName,
        'email': staffEmail,
        'phone': staffPhone,
        'branchID': managerBranchID,
        'branchName': await _getBranchName(managerBranchID),
        'role': 'Technician',
        'expertise': expertise,
        'employeeNumber': await _generateEmployeeNumber(managerBranchID),
        'dateJoined': FieldValue.serverTimestamp(),
        'isActive': true,
        'isAvailable': true,
        'currentTaskCount': 0,
        'totalCompletedTasks': 0,
        'rating': 0.0,
        'totalRatings': 0,
        'profileImage': '',
        'notes': 'Account created by manager. Please change password on first login.',
        'createdBy': managerUID,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 5. Sign out the newly created staff account
      await _auth.signOut();
      
      // 6. Send password reset email (NOW it will work because we're signed out)
      // ✅ FIXED: Use _auth.sendPasswordResetEmail(), not user.sendPasswordResetEmail()
      await _auth.sendPasswordResetEmail(email: staffEmail);

      // 7. Re-authenticate the manager
      // Note: In a web app, the manager will need to log back in
      // This is a limitation of Firebase Auth when creating users this way

      return {
        'success': true,
        'message': 'Staff account created successfully! Password reset email sent to $staffEmail',
        'staffID': staffID,
        'staffEmail': staffEmail,
        'requiresManagerReauth': true, // Flag that manager needs to log back in
        'managerEmail': managerEmail,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create staff account: ${e.toString()}',
      };
    }
  }

  Future<String> _getBranchName(String branchID) async {
    final doc = await _firestore.collection(FirebaseConstants.branchesCollection).doc(branchID).get();
    return doc.data()?['branchName'] ?? 'Unknown Branch';
  }

  Future<String> _generateEmployeeNumber(String branchID) async {
    // Count existing staff in this branch
    final staffQuery = await _firestore
        .collection(FirebaseConstants.staffCollection)
        .where(FirebaseConstants.fieldBranchId, isEqualTo: branchID)
        .get();
    
    int count = staffQuery.docs.length + 1;
    String branchCode = branchID == 'melaka' ? 'MLK' : 'SRB';
    return 'EMP${branchCode}${count.toString().padLeft(3, '0')}';
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Error: $code';
    }
  }

  // ============================================
  // HELPER: Get staff details
  // ============================================
  Future<Map<String, dynamic>?> getStaffByUID(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.staffCollection)
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error getting staff: $e');
      return null;
    }
  }

  // ============================================
  // HELPER: Update staff availability
  // ============================================
  Future<bool> updateStaffAvailability(String staffID, bool isAvailable) async {
    try {
      await _firestore
          .collection(FirebaseConstants.staffCollection)
          .doc(staffID)
          .update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating staff availability: $e');
      return false;
    }
  }
}