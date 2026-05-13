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
}