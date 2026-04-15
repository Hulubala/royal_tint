import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerModel {
  final String managerID;
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String branchID;
  final String branchName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ManagerModel({
    required this.managerID,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.branchID,
    required this.branchName,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ManagerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ManagerModel(
      managerID: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      branchID: data['branchID'] ?? '',
      branchName: data['branchName'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'branchID': branchID,
      'branchName': branchName,
      'isActive': isActive,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}