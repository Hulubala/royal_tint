import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  final String id;
  final String uid;
  final String staffID;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String branchID;
  final String branchName;
  final bool isActive;
  final DateTime dateJoined;
  final DateTime? lastActiveDate;
  final int completedTasks;
  final int currentTaskCount;

  StaffModel({
    required this.id,
    required this.uid,
    required this.staffID,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.branchID,
    required this.branchName,
    this.isActive = true,
    required this.dateJoined,
    this.lastActiveDate,
    this.completedTasks = 0,
    this.currentTaskCount = 0,
  });

  factory StaffModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
    
    return StaffModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      staffID: data['staffID'] ?? '', 
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      branchID: data['branchID'] ?? '',
      branchName: data['branchName'] ?? '',
      isActive: data['isActive'] ?? true,
      dateJoined: (data['dateJoined'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      completedTasks: data['completedTasks'] ?? data['totalCompletedTasks'] ?? 0,
      currentTaskCount: data['currentTaskCount'] ?? 0,
    );
  }

  /// Create StaffModel from JSON
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      staffID: json['staffID'] ?? '',
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
      completedTasks: json['completedTasks'] ?? json['totalCompletedTasks'] ?? 0,
      currentTaskCount: json['currentTaskCount'] ?? 0,
    );
  }

  /// Convert StaffModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'staffID': staffID,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'branchID': branchID,
      'branchName': branchName,
      'isActive': isActive,
      'dateJoined': Timestamp.fromDate(dateJoined),
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'completedTasks': completedTasks,
      'currentTaskCount': currentTaskCount,
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
    String? staffID,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? branchID,
    String? branchName,
    bool? isActive,
    DateTime? dateJoined,
    DateTime? lastActiveDate,
    int? completedTasks,
    int? currentTaskCount,
  }) {
    return StaffModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      staffID: staffID ?? this.staffID,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchID: branchID ?? this.branchID,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      dateJoined: dateJoined ?? this.dateJoined,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedTasks: completedTasks ?? this.completedTasks,
      currentTaskCount: currentTaskCount ?? this.currentTaskCount,
    );
  }

  @override
  String toString() {
    return 'StaffModel(id: $id, staffID: $staffID, name: $name, role: $role, branchID: $branchID, isActive: $isActive)';
  }
}