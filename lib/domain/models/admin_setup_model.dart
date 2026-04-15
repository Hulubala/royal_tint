// admin_setup.dart - Run this ONCE to setup managers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerSetup {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Run this once to create manager accounts
  Future<void> setupManagers() async {
    await _createManager(
      email: 'steven.melaka@royaltint.com',
      password: 'RoyalTint123!', // Change after first login
      name: 'Steven Ting',
      phone: '+60123456789',
      branchID: 'melaka',
      branchName: 'Royal Tint Melaka',
    );

    await _createManager(
      email: 'alex.seremban2@royaltint.com',
      password: 'RoyalTint123!',
      name: 'Alex Tan',
      phone: '+60123456788',
      branchID: 'seremban2',
      branchName: 'Royal Tint Seremban 2',
    );
  }

  Future<void> _createManager({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String branchID,
    required String branchName,
  }) async {
    try {
      // 1. Create Firebase Auth account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      String managerID = 'manager_${branchID}_001';

      // 2. Create user document
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
      });

      // 3. Create manager document
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
      });

      print('✅ Manager created: $email');
    } catch (e) {
      print('❌ Error creating manager: $e');
    }
  }
}