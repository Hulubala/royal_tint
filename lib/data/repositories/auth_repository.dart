import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/domain/models/user/user_model.dart';
import 'package:royal_tint/domain/models/user/manager_model.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Sign in with Firebase Auth
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('Sign in failed');
    }

    // Get user data from Firestore
    final userData = await getUserData(user.uid);
    if (userData == null) {
      await _firebaseAuth.signOut();
      throw Exception('User data not found in Firestore for uid=${user.uid}');
    }

    // Ensure user has manager role
    if (!userData.isManager) {
      await _firebaseAuth.signOut();
      throw Exception('not-a-manager');
    }

    // Get manager data
    final managerData = await getManagerData(user.uid);
    if (managerData == null) {
      await _firebaseAuth.signOut();
      throw Exception('not-a-manager');
    }

    return {
      'user': user,
      'userData': userData,
      'managerData': managerData,
    };
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Get manager data from Firestore
  Future<ManagerModel?> getManagerData(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConstants.managersCollection)
          .where(FirebaseConstants.fieldUid, isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ManagerModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get manager data: $e');
    }
  }

  Future<bool> managerEmailExists(String email) async {
    try {
      final e = email.trim().toLowerCase();

      final doc = await _firestore
          .collection('manager_email_lookup')
          .doc(e)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check manager email: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send password reset email + redirect back to your login page after reset
  Future<void> sendPasswordResetEmail({
    required String email,
    required String continueUrl,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
        actionCodeSettings: ActionCodeSettings(
          url: continueUrl,
          handleCodeInApp: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Keep Firebase's error code info
      throw Exception('${e.code}: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.updatePassword(newPassword);
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Check if user is signed in
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }
}