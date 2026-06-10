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
    String? expectedRole,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    
    if (expectedRole != null) {
      if (expectedRole == 'customer') {
        final doc = await _db.collection('users').doc(cred.user!.uid).get();
        if (!doc.exists || doc.data()?['role'] != 'customer') {
          await _auth.signOut();
          throw Exception('Unauthorized. Please use the Staff or Manager app.');
        }
      } else if (expectedRole == 'staff') {
        final doc = await _db.collection('staff').where('uid', isEqualTo: cred.user!.uid).limit(1).get();
        if (doc.docs.isEmpty) {
          await _auth.signOut();
          throw Exception('Unauthorized. Please use the correct login app.');
        }
      }
    }
    return cred;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    String role = 'customer';
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        role = querySnapshot.docs.first.data()['role'] ?? 'customer';
      } else {
        // Fallback: Check staff collection
        final staffSnapshot = await _db
            .collection('staff')
            .where('email', isEqualTo: email.trim().toLowerCase())
            .limit(1)
            .get();
        if (staffSnapshot.docs.isNotEmpty) {
          role = 'staff';
        }
      }
    } catch (_) {}

    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
        actionCodeSettings: ActionCodeSettings(
          url: 'https://royal-tint-admin.vercel.app/mobile-success',
          handleCodeInApp: false,
        ),
      );
    } catch (_) {
      // Fallback
      await _auth.sendPasswordResetEmail(email: email.trim());
    }
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
    
    // Ensure the phone number is stored cleanly as digits only
    final rawPhone = phone.trim();
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final finalPhoneToSave = cleanPhone.isNotEmpty ? cleanPhone : rawPhone;

    // users/{uid} minimal identity
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'role': 'customer',
      'name': name.trim(),
      'email': email.trim(),
      'phone': finalPhoneToSave,
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
      'phone': finalPhoneToSave,
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

    // Link any existing appointments that managers created using this phone number
    try {
      if (cleanPhone.isNotEmpty) {
        // Build a list of possible phone number formats the manager might have typed
        final searchPhones = {rawPhone, cleanPhone};
        if (cleanPhone.length >= 10) {
          searchPhones.add('${cleanPhone.substring(0, 3)}-${cleanPhone.substring(3)}');
        }

        final appointmentsSnap = await _db
            .collection('appointments')
            .where('customerPhone', whereIn: searchPhones.toList())
            .get();
        
        if (appointmentsSnap.docs.isNotEmpty) {
          final batch = _db.batch();
          for (var doc in appointmentsSnap.docs) {
            // Update the appointment to map to this new registered user
            batch.update(doc.reference, {'customerID': uid});
          }
          await batch.commit();
        }
      }
    } catch (e) {
      print('Error linking previous appointments: $e');
    }

    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}