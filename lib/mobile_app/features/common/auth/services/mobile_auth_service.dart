import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MobileAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  MobileAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    // users/{uid} minimal identity
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'role': 'customer',
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // customers/{uid} customer profile
    await _db.collection('customers').doc(uid).set({
      'customerID': uid,
      'uid': uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'vehicles': [],
      'totalAppointments': 0,
      'totalSpent': 0.0,
      'memberSince': FieldValue.serverTimestamp(),
      'lastVisit': null,
      'preferredBranch': '',
      'notes': '',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}