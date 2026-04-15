import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String branchID;
  final String branchName;
  final bool isActive;
  final DateTime dateJoined;
  final DateTime? lastActiveDate;
  final String? profileImage;
  final List<String> expertise;
  final double rating;
  final int totalCompletedTasks;

  StaffModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.branchID,
    required this.branchName,
    this.isActive = true,
    required this.dateJoined,
    this.lastActiveDate,
    this.profileImage,
    this.expertise = const [],
    this.rating = 0.0,
    this.totalCompletedTasks = 0,
  });

  /// Create StaffModel from Firestore document
  factory StaffModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return StaffModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      branchID: data['branchID'] ?? '',
      branchName: data['branchName'] ?? '',
      isActive: data['isActive'] ?? true,
      dateJoined: (data['dateJoined'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      profileImage: data['profileImage'],
      expertise: List<String>.from(data['expertise'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalCompletedTasks: data['totalCompletedTasks'] ?? 0,
    );
  }

  /// Create StaffModel from JSON
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      branchID: json['branchID'] ?? '',
      branchName: json['branchName'] ?? '',
      isActive: json['isActive'] ?? true,
      dateJoined: json['dateJoined'] is Timestamp 
          ? (json['dateJoined'] as Timestamp).toDate()
          : DateTime.parse(json['dateJoined'] ?? DateTime.now().toIso8601String()),
      lastActiveDate: json['lastActiveDate'] != null
          ? (json['lastActiveDate'] is Timestamp
              ? (json['lastActiveDate'] as Timestamp).toDate()
              : DateTime.parse(json['lastActiveDate']))
          : null,
      profileImage: json['profileImage'],
      expertise: List<String>.from(json['expertise'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalCompletedTasks: json['totalCompletedTasks'] ?? 0,
    );
  }

  /// Convert StaffModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'branchID': branchID,
      'branchName': branchName,
      'isActive': isActive,
      'dateJoined': Timestamp.fromDate(dateJoined),
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'profileImage': profileImage,
      'expertise': expertise,
      'rating': rating,
      'totalCompletedTasks': totalCompletedTasks,
    };
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Create a copy with updated fields
  StaffModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? branchID,
    String? branchName,
    bool? isActive,
    DateTime? dateJoined,
    DateTime? lastActiveDate,
    String? profileImage,
    List<String>? expertise,
    double? rating,
    int? totalCompletedTasks,
  }) {
    return StaffModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchID: branchID ?? this.branchID,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      dateJoined: dateJoined ?? this.dateJoined,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      profileImage: profileImage ?? this.profileImage,
      expertise: expertise ?? this.expertise,
      rating: rating ?? this.rating,
      totalCompletedTasks: totalCompletedTasks ?? this.totalCompletedTasks,
    );
  }

  @override
  String toString() {
    return 'StaffModel(id: $id, name: $name, role: $role, branchID: $branchID, isActive: $isActive)';
  }
}