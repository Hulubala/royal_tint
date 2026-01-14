// 🔥 UNIVERSAL APPOINTMENT MODEL
// This version works with BOTH nested vehicleInfo AND flat fields!
// Replace your entire appointment_model.dart with this

import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentID;
  final String customerID;
  final String customerName;
  final String? customerPhone;
  final String branchID;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleType;
  final String vehiclePlate;
  final String packageID;
  final String packageName;
  final String appointmentDate;
  final String appointmentTime;
  final String appointmentType;
  final int estimatedDuration;
  final String status;
  final String? assignedStaffID;
  final String? notes;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.appointmentID,
    required this.customerID,
    required this.customerName,
    this.customerPhone,
    required this.branchID,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.packageID,
    required this.packageName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentType,
    required this.estimatedDuration,
    required this.status,
    this.assignedStaffID,
    this.notes,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  // ✅ Getter for 'id' (alias for appointmentID)
  String get id => appointmentID;

  // ✅ Getter for 'vehicleDisplay' (formatted vehicle info)
  String get vehicleDisplay => '$vehiclePlate • $vehicleBrand $vehicleModel';

  // 🔥 UNIVERSAL fromFirestore - Works with BOTH structures!
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    print('🔍 Parsing appointment: ${doc.id}');
    print('📋 Raw data keys: ${data.keys.toList()}');
    
    // Check if vehicleInfo exists (nested structure)
    final vehicleInfo = data['vehicleInfo'] as Map<String, dynamic>?;
    
    String vehicleBrand = '';
    String vehicleModel = '';
    String vehicleType = '';
    String vehiclePlate = '';
    
    if (vehicleInfo != null) {
      // ✅ NESTED STRUCTURE: Extract from vehicleInfo object
      print('✅ Using NESTED vehicleInfo structure');
      vehicleBrand = vehicleInfo['brand'] ?? '';
      vehicleModel = vehicleInfo['model'] ?? '';
      vehicleType = vehicleInfo['type'] ?? '';
      vehiclePlate = vehicleInfo['plateNumber'] ?? vehicleInfo['plate'] ?? '';
    } else {
      // ✅ FLAT STRUCTURE: Read directly from root
      print('✅ Using FLAT field structure');
      vehicleBrand = data['vehicleBrand'] ?? '';
      vehicleModel = data['vehicleModel'] ?? '';
      vehicleType = data['vehicleType'] ?? '';
      vehiclePlate = data['vehiclePlate'] ?? data['plateNumber'] ?? '';
    }
    
    print('🚗 Vehicle parsed: $vehicleBrand $vehicleModel ($vehicleType) - $vehiclePlate');
    
    // Parse dates safely
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    
    try {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt']);
      }
    } catch (e) {
      print('⚠️ Error parsing createdAt: $e');
    }
    
    try {
      if (data['updatedAt'] is Timestamp) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      } else if (data['updatedAt'] is String) {
        updatedAt = DateTime.parse(data['updatedAt']);
      }
    } catch (e) {
      print('⚠️ Error parsing updatedAt: $e');
    }
    
    final model = AppointmentModel(
      appointmentID: doc.id,
      customerID: data['customerID'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'],
      branchID: data['branchID'] ?? '',
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
      packageID: data['packageID'] ?? '',
      packageName: data['packageName'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      appointmentType: data['appointmentType'] ?? 'scheduled',
      estimatedDuration: data['estimatedDuration'] ?? 0,
      status: data['status'] ?? 'pending',
      assignedStaffID: data['assignedStaffID'],
      notes: data['notes'],
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    
    print('✅ Appointment parsed successfully: ${model.customerName}');
    return model;
  }

  // Convert to Firestore (NESTED structure - recommended)
  Map<String, dynamic> toFirestore() {
    return {
      'customerID': customerID,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'branchID': branchID,
      'vehicleInfo': {
        'brand': vehicleBrand,
        'model': vehicleModel,
        'type': vehicleType,
        'plateNumber': vehiclePlate,
      },
      'packageID': packageID,
      'packageName': packageName,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'appointmentType': appointmentType,
      'estimatedDuration': estimatedDuration,
      'status': status,
      'assignedStaffID': assignedStaffID,
      'notes': notes,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updates
  AppointmentModel copyWith({
    String? appointmentID,
    String? customerID,
    String? customerName,
    String? customerPhone,
    String? branchID,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleType,
    String? vehiclePlate,
    String? packageID,
    String? packageName,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    int? estimatedDuration,
    String? status,
    String? assignedStaffID,
    String? notes,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      appointmentID: appointmentID ?? this.appointmentID,
      customerID: customerID ?? this.customerID,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      branchID: branchID ?? this.branchID,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      packageID: packageID ?? this.packageID,
      packageName: packageName ?? this.packageName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      appointmentType: appointmentType ?? this.appointmentType,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      assignedStaffID: assignedStaffID ?? this.assignedStaffID,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}