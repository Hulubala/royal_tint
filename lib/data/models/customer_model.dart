// lib/data/models/customer_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerID;
  final String uid;
  final String name;
  final String email;
  final String phone;
  final List<Vehicle> vehicles;
  final int totalAppointments;
  final double totalSpent;
  final DateTime memberSince;
  final DateTime? lastVisit;
  final String preferredBranch;
  final String notes;
  final bool isActive;

  CustomerModel({
    required this.customerID,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicles,
    required this.totalAppointments,
    required this.totalSpent,
    required this.memberSince,
    this.lastVisit,
    required this.preferredBranch,
    required this.notes,
    required this.isActive,
  });

  // Convert Firestore document to CustomerModel
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      customerID: data['customerID'] ?? '',
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      vehicles: (data['vehicles'] as List<dynamic>?)
              ?.map((v) => Vehicle.fromMap(v))
              .toList() ??
          [],
      totalAppointments: data['totalAppointments'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      memberSince: (data['memberSince'] as Timestamp).toDate(),
      lastVisit: data['lastVisit'] != null
          ? (data['lastVisit'] as Timestamp).toDate()
          : null,
      preferredBranch: data['preferredBranch'] ?? '',
      notes: data['notes'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert CustomerModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'customerID': customerID,
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicles': vehicles.map((v) => v.toMap()).toList(),
      'totalAppointments': totalAppointments,
      'totalSpent': totalSpent,
      'memberSince': Timestamp.fromDate(memberSince),
      'lastVisit': lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
      'preferredBranch': preferredBranch,
      'notes': notes,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class Vehicle {
  final String vehicleID;
  final String plateNumber;
  final String brand;
  final String model;
  final int year;
  final String color;
  final DateTime addedDate;

  Vehicle({
    required this.vehicleID,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.addedDate,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      vehicleID: map['vehicleID'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      color: map['color'] ?? '',
      addedDate: (map['addedDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleID': vehicleID,
      'plateNumber': plateNumber,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'addedDate': Timestamp.fromDate(addedDate),
    };
  }
}