import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/data/models/user_model.dart';
import 'package:royal_tint/data/models/manager_model.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('Sign in failed');
      }

      // Get user data from Firestore
      UserModel? userData = await getUserData(user.uid);
      if (userData == null) {
        throw Exception('User data not found');
      }

      // Get manager data if user is a manager
      ManagerModel? managerData;
      if (userData.isManager) {
        managerData = await getManagerData(user.uid);
      }

      return {
        'user': user,
        'userData': userData,
        'managerData': managerData,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
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

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
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