import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  final String branchID;
  final String branchName;
  final String branchAddress;
  final String branchPhone;
  final String branchEmail;
  final String city;
  final String state;
  final String postcode;
  final Map<String, dynamic> operatingHours;
  final List<String> services;
  final bool isActive;
  final String? managerID;
  final String? managerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchModel({
    required this.branchID,
    required this.branchName,
    required this.branchAddress,
    required this.branchPhone,
    required this.branchEmail,
    required this.city,
    required this.state,
    required this.postcode,
    required this.operatingHours,
    required this.services,
    required this.isActive,
    this.managerID,
    this.managerName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter for id (alias for branchID)
  String get id => branchID;

  // Get formatted address
  String get fullAddress {
    return '$branchAddress, $postcode $city, $state';
  }

  // Get operating hours for a specific day
  String getOperatingHours(String day) {
    if (operatingHours.containsKey(day)) {
      final hours = operatingHours[day];
      if (hours is Map) {
        final open = hours['open'] ?? '';
        final close = hours['close'] ?? '';
        final isClosed = hours['closed'] ?? false;
        
        if (isClosed) return 'Closed';
        if (open.isNotEmpty && close.isNotEmpty) {
          return '$open - $close';
        }
      }
    }
    return 'Not Available';
  }

  // Check if branch is open on a specific day
  bool isOpenOn(String day) {
    if (operatingHours.containsKey(day)) {
      final hours = operatingHours[day];
      if (hours is Map) {
        return !(hours['closed'] ?? false);
      }
    }
    return false;
  }

  // From Firestore
  factory BranchModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return BranchModel(
      branchID: doc.id,
      branchName: data['branchName'] ?? '',
      branchAddress: data['branchAddress'] ?? '',
      branchPhone: data['branchPhone'] ?? '',
      branchEmail: data['branchEmail'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postcode: data['postcode'] ?? '',
      operatingHours: data['operatingHours'] ?? {},
      services: List<String>.from(data['services'] ?? []),
      isActive: data['isActive'] ?? true,
      managerID: data['managerID'],
      managerName: data['managerName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // From Map
  factory BranchModel.fromMap(Map<String, dynamic> data, String documentId) {
    return BranchModel(
      branchID: documentId,
      branchName: data['branchName'] ?? '',
      branchAddress: data['branchAddress'] ?? '',
      branchPhone: data['branchPhone'] ?? '',
      branchEmail: data['branchEmail'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postcode: data['postcode'] ?? '',
      operatingHours: data['operatingHours'] ?? {},
      services: List<String>.from(data['services'] ?? []),
      isActive: data['isActive'] ?? true,
      managerID: data['managerID'],
      managerName: data['managerName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'branchName': branchName,
      'branchAddress': branchAddress,
      'branchPhone': branchPhone,
      'branchEmail': branchEmail,
      'city': city,
      'state': state,
      'postcode': postcode,
      'operatingHours': operatingHours,
      'services': services,
      'isActive': isActive,
      'managerID': managerID,
      'managerName': managerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'branchID': branchID,
      'branchName': branchName,
      'branchAddress': branchAddress,
      'branchPhone': branchPhone,
      'branchEmail': branchEmail,
      'city': city,
      'state': state,
      'postcode': postcode,
      'operatingHours': operatingHours,
      'services': services,
      'isActive': isActive,
      'managerID': managerID,
      'managerName': managerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  BranchModel copyWith({
    String? branchID,
    String? branchName,
    String? branchAddress,
    String? branchPhone,
    String? branchEmail,
    String? city,
    String? state,
    String? postcode,
    Map<String, dynamic>? operatingHours,
    List<String>? services,
    bool? isActive,
    String? managerID,
    String? managerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchModel(
      branchID: branchID ?? this.branchID,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      branchPhone: branchPhone ?? this.branchPhone,
      branchEmail: branchEmail ?? this.branchEmail,
      city: city ?? this.city,
      state: state ?? this.state,
      postcode: postcode ?? this.postcode,
      operatingHours: operatingHours ?? this.operatingHours,
      services: services ?? this.services,
      isActive: isActive ?? this.isActive,
      managerID: managerID ?? this.managerID,
      managerName: managerName ?? this.managerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BranchModel(id: $branchID, name: $branchName, city: $city, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchModel && other.branchID == branchID;
  }

  @override
  int get hashCode => branchID.hashCode;
}

// Example operating hours structure:
// {
//   "monday": {"open": "09:00 AM", "close": "06:00 PM", "closed": false},
//   "tuesday": {"open": "09:00 AM", "close": "06:00 PM", "closed": false},
//   "wednesday": {"open": "09:00 AM", "close": "06:00 PM", "closed": false},
//   "thursday": {"open": "09:00 AM", "close": "06:00 PM", "closed": false},
//   "friday": {"open": "09:00 AM", "close": "06:00 PM", "closed": false},
//   "saturday": {"open": "09:00 AM", "close": "02:00 PM", "closed": false},
//   "sunday": {"open": "", "close": "", "closed": true}
// }