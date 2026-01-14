import 'package:cloud_firestore/cloud_firestore.dart';

/// Staff Model
/// Represents a staff member in the system
class StaffModel {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role; // e.g., 'Technician', 'Installer', 'Assistant'
  final String branchID;
  final String branchName;
  final bool isActive;
  final DateTime joinedDate;
  final DateTime? lastActiveDate;
  final String? profileImageUrl;
  final List<String> skills;
  final double rating;
  final int completedJobs;

  StaffModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.branchID,
    required this.branchName,
    this.isActive = true,
    required this.joinedDate,
    this.lastActiveDate,
    this.profileImageUrl,
    this.skills = const [],
    this.rating = 0.0,
    this.completedJobs = 0,
  });

  /// Create StaffModel from Firestore document
  factory StaffModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return StaffModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? '',
      branchID: data['branchID'] ?? '',
      branchName: data['branchName'] ?? '',
      isActive: data['isActive'] ?? true,
      joinedDate: (data['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      profileImageUrl: data['profileImageUrl'],
      skills: List<String>.from(data['skills'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      completedJobs: data['completedJobs'] ?? 0,
    );
  }

  /// Create StaffModel from JSON
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      branchID: json['branchID'] ?? '',
      branchName: json['branchName'] ?? '',
      isActive: json['isActive'] ?? true,
      joinedDate: json['joinedDate'] is Timestamp 
          ? (json['joinedDate'] as Timestamp).toDate()
          : DateTime.parse(json['joinedDate'] ?? DateTime.now().toIso8601String()),
      lastActiveDate: json['lastActiveDate'] != null
          ? (json['lastActiveDate'] is Timestamp
              ? (json['lastActiveDate'] as Timestamp).toDate()
              : DateTime.parse(json['lastActiveDate']))
          : null,
      profileImageUrl: json['profileImageUrl'],
      skills: List<String>.from(json['skills'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      completedJobs: json['completedJobs'] ?? 0,
    );
  }

  /// Convert StaffModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'branchID': branchID,
      'branchName': branchName,
      'isActive': isActive,
      'joinedDate': Timestamp.fromDate(joinedDate),
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'profileImageUrl': profileImageUrl,
      'skills': skills,
      'rating': rating,
      'completedJobs': completedJobs,
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
    String? phoneNumber,
    String? role,
    String? branchID,
    String? branchName,
    bool? isActive,
    DateTime? joinedDate,
    DateTime? lastActiveDate,
    String? profileImageUrl,
    List<String>? skills,
    double? rating,
    int? completedJobs,
  }) {
    return StaffModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      branchID: branchID ?? this.branchID,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
    );
  }

  @override
  String toString() {
    return 'StaffModel(id: $id, name: $name, role: $role, branchID: $branchID, isActive: $isActive)';
  }
}