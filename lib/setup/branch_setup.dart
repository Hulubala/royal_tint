import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for setting up branches in Firestore
class BranchSetup {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a branch in Firestore
  Future<void> createBranch({
    required String branchID,
    required String branchName,
    required String address,
    required String city,
    required String state,
    required String postcode,
    required String phone,
    required String email,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection('branches').doc(branchID).set({
        'branchID': branchID,
        'branchName': branchName,
        'address': address,
        'city': city,
        'state': state,
        'postcode': postcode,
        'phone': phone,
        'email': email,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
      
      print('✅ Branch created: $branchName');
    } catch (e) {
      print('❌ Error creating branch: $e');
      rethrow;
    }
  }

  /// Setup default Royal Tint branches
  Future<void> setupDefaultBranches() async {
    try {
      // Branch 1: Melaka
      await createBranch(
        branchID: 'melaka',
        branchName: 'Royal Tint Melaka',
        address: 'No. 649, Jalan Melaka Raya 8, Taman Melaka Raya, 75000 Melaka',
        city: 'Melaka',
        state: 'Melaka',
        postcode: '75000',
        phone: '+60123456789',
        email: 'melaka@royaltint.com',
        additionalData: {
          'operatingHours': {
            'monday': '9:00 AM - 7:00 PM',
            'tuesday': '9:00 AM - 7:00 PM',
            'wednesday': '9:00 AM - 7:00 PM',
            'thursday': '9:00 AM - 7:00 PM',
            'friday': '9:00 AM - 7:00 PM',
            'saturday': '9:00 AM - 7:00 PM',
            'sunday': 'Closed',
          },
        },
      );

      // Branch 2: Seremban 2
      await createBranch(
        branchID: 'seremban2',
        branchName: 'Royal Tint Seremban 2',
        address: '42-G, Jalan S2 B6, Seremban 2, 70300 Seremban, Negeri Sembilan',
        city: 'Seremban',
        state: 'Negeri Sembilan',
        postcode: '70300',
        phone: '+60123456788',
        email: 'seremban2@royaltint.com',
        additionalData: {
          'operatingHours': {
            'monday': '9:00 AM - 7:00 PM',
            'tuesday': '9:00 AM - 7:00 PM',
            'wednesday': '9:00 AM - 7:00 PM',
            'thursday': '9:00 AM - 7:00 PM',
            'friday': '9:00 AM - 7:00 PM',
            'saturday': '9:00 AM - 7:00 PM',
            'sunday': 'Closed',
          },
        },
      );

      print('✅ All branches created successfully');
    } catch (e) {
      print('❌ Error setting up branches: $e');
      rethrow;
    }
  }

  /// Check if a branch exists
  Future<bool> branchExists(String branchID) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('branches')
          .doc(branchID)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking branch existence: $e');
      return false;
    }
  }

  /// Get all branches
  Future<List<Map<String, dynamic>>> getAllBranches() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('branches')
          .orderBy('branchName')
          .get();

      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error getting branches: $e');
      return [];
    }
  }

  /// Delete a branch
  Future<void> deleteBranch(String branchID) async {
    try {
      await _firestore.collection('branches').doc(branchID).delete();
      print('✅ Branch deleted: $branchID');
    } catch (e) {
      print('❌ Error deleting branch: $e');
      rethrow;
    }
  }

  /// Update branch status
  Future<void> updateBranchStatus(String branchID, bool isActive) async {
    try {
      await _firestore.collection('branches').doc(branchID).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Branch status updated: $branchID → $isActive');
    } catch (e) {
      print('❌ Error updating branch status: $e');
      rethrow;
    }
  }
}