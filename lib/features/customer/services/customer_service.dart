import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firestore_service.dart';

class CustomerService {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  /// Register a new customer account
  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Create Firebase Auth account using service
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      String customerID = 'cust_${uid.substring(0, 8)}';

      // 2. Send email verification using service
      await _authService.sendEmailVerification();

      // 3. Create user document using firestore service
      await _firestoreService.createDocument(
        collection: 'users',
        docId: uid,
        data: {
          'uid': uid,
          'email': email,
          'role': 'customer',
          'name': fullName,
          'phone': phone,
          'branchID': null,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // 4. Create customer document using firestore service
      await _firestoreService.createDocument(
        collection: 'customers',
        docId: customerID,
        data: {
          'customerID': customerID,
          'uid': uid,
          'name': fullName,
          'email': email,
          'phone': phone,
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
        },
      );

      return {
        'success': true,
        'message': 'Registration successful! Please verify your email.',
        'uid': uid,
        'customerID': customerID,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  /// Get customer data by UID
  Future<Map<String, dynamic>?> getCustomerByUID(String uid) async {
    try {
      // Using firestore service to query
      final query = await _firestoreService.queryDocuments(
        collection: 'customers',
        filters: [QueryFilter(field: 'uid', value: uid)],
        limit: 1,
      );

      if (query.docs.isNotEmpty) {
        return query.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting customer: $e');
      return null;
    }
  }

  /// Add vehicle to customer
  Future<bool> addVehicle({
    required String customerID,
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String color,
  }) async {
    try {
      String vehicleID = 'veh_${DateTime.now().millisecondsSinceEpoch}';

      // Using firestore service to update
      await _firestoreService.updateDocument(
        collection: 'customers',
        docId: customerID,
        data: {
          'vehicles': FieldValue.arrayUnion([
            {
              'vehicleID': vehicleID,
              'plateNumber': plateNumber.toUpperCase(),
              'brand': brand,
              'model': model,
              'year': year,
              'color': color,
              'addedDate': FieldValue.serverTimestamp(),
            }
          ]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      print('Error adding vehicle: $e');
      return false;
    }
  }

  /// Update customer profile
  Future<bool> updateCustomerProfile({
    required String customerID,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      // Using firestore service to update
      await _firestoreService.updateDocument(
        collection: 'customers',
        docId: customerID,
        data: updates,
      );
      
      return true;
    } catch (e) {
      print('Error updating customer: $e');
      return false;
    }
  }

  /// Get authentication error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Registration error: $code';
    }
  }
}