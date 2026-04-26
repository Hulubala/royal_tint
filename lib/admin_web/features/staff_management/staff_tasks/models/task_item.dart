import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  final String id;

  final String branchID;

  final String staffID;
  final String staffName;

  final String appointmentID;

  /// Backward-compatible: you can keep using this, but new UI will prefer customerName/plate/package.
  final String appointmentTitle;

  /// Backward-compatible: old field (e.g. "Audi A3"), new UI will prefer carBrand/carModel if present.
  final String carInfo;

  final String mirrorSection;
  final String status;

  final Timestamp? createdAt;

  // ✅ NEW fields for dashboard-like UI
  final String? customerName;
  final String? plateNumber;
  final String? packageName;
  final String? carBrand;
  final String? carModel;
  final String? darkness; // e.g. "70%" or "VLT 70"

  TaskItem({
    required this.id,
    required this.branchID,
    required this.staffID,
    required this.staffName,
    required this.appointmentID,
    required this.appointmentTitle,
    required this.carInfo,
    required this.mirrorSection,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.plateNumber,
    required this.packageName,
    required this.carBrand,
    required this.carModel,
    required this.darkness,
  });

  factory TaskItem.fromMap(String id, Map<String, dynamic> map) {
    return TaskItem(
      id: id,
      branchID: (map['branchID'] ?? '') as String,
      staffID: (map['staffID'] ?? '') as String,
      staffName: (map['staffName'] ?? '') as String,
      appointmentID: (map['appointmentID'] ?? '') as String,
      appointmentTitle: (map['appointmentTitle'] ?? '') as String,
      carInfo: (map['carInfo'] ?? '') as String,
      mirrorSection: (map['mirrorSection'] ?? '') as String,
      status: (map['status'] ?? 'pending') as String,
      createdAt: map['createdAt'] as Timestamp?,

      customerName: (map['customerName'] as String?)?.trim(),
      plateNumber: (map['plateNumber'] as String?)?.trim(),
      packageName: (map['packageName'] as String?)?.trim(),
      carBrand: (map['carBrand'] as String?)?.trim(),
      carModel: (map['carModel'] as String?)?.trim(),
      darkness: (map['darkness'] as String?)?.trim(),
    );
  }
}