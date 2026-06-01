import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:royal_tint/domain/models/user/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CustomerRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<CustomerModel> getCurrentCustomer() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _db.collection('customers').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Customer profile not found in customers/$uid');
    }
    return CustomerModel.fromFirestore(doc);
  }

  Stream<CustomerModel> streamCurrentCustomer() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('customers').doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Customer profile not found in customers/$uid');
      }
      return CustomerModel.fromFirestore(doc);
    });
  }

  Future<void> updateProfile(String uid, String name, String phone) async {
    await _db.collection('customers').doc(uid).update({
      'name': name,
      'phone': phone,
    });
  }

  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    final snapshot = await _db
        .collection('customers')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return CustomerModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}