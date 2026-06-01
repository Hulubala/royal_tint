import 'package:cloud_firestore/cloud_firestore.dart';

class StaffTaskModel {
  final String id;
  final String appointmentID;
  final String branchID;

  final String carBrand;
  final String carModel;
  final String plateNumber;

  final String packageName;
  final String packageType; // 'sv', 'gl', or 'ptn'
  final String customerName;

  // The field in Firestore is 'assignedStaffID' (written by TaskModel.toFirestore())
  final String assignedStaffID;
  final String assignedStaffName;

  final String mirrorSection; // e.g. "Front Windshield, Left Side"
  final String darkness;      // e.g. "SV35, SV35"

  final String status;
  final DateTime createdAt;
  final bool isFinalized;

  StaffTaskModel({
    required this.id,
    required this.appointmentID,
    required this.branchID,
    required this.carBrand,
    required this.carModel,
    required this.plateNumber,
    required this.packageName,
    required this.packageType,
    required this.customerName,
    required this.assignedStaffID,
    required this.assignedStaffName,
    required this.mirrorSection,
    required this.darkness,
    required this.status,
    required this.createdAt,
    this.isFinalized = false,
  });

  bool get isPending    => status.toUpperCase() == 'PENDING';
  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';
  bool get isCompleted  => status.toUpperCase() == 'COMPLETED';

  factory StaffTaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StaffTaskModel(
      id:                doc.id,
      appointmentID:     (data['appointmentID']    ?? '') as String,
      branchID:          (data['branchID']          ?? '') as String,
      carBrand:          (data['carBrand']          ?? '') as String,
      carModel:          (data['carModel']          ?? '') as String,
      plateNumber:       (data['plateNumber']       ?? '') as String,
      packageName:       (data['packageName']       ?? '') as String,
      packageType:       (data['packageType']       ?? 'sv') as String,
      customerName:      (data['customerName']      ?? '') as String,
      // Firestore field is 'assignedStaffID', not 'staffID'
      assignedStaffID:   (data['assignedStaffID']   ?? '') as String,
      assignedStaffName: (data['assignedStaffName'] ?? '') as String,
      mirrorSection:     (data['mirrorSection']     ?? '') as String,
      darkness:          (data['darkness']          ?? '') as String,
      status:            (data['status']            ?? 'PENDING') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFinalized:       (data['isFinalized']       ?? false) as bool,
    );
  }
}
