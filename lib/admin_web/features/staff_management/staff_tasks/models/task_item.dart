import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  final String id;
  final String branchID;
  final String staffID;
  final String staffName;
  final String appointmentID;
  final String appointmentTitle;
  final String carInfo;
  final List<String> mirrorSections;
  final String status;
  final DateTime? createdAt;
  final String? customerName;
  final String? plateNumber;
  final String? packageName;
  final String? carBrand;
  final String? carModel;
  final String? darkness; 
  final bool isFinalized;
  final String? appointmentDate;
  final String? appointmentTime;
  final int? estimatedDuration;

  TaskItem({
    required this.id,
    required this.branchID,
    required this.staffID,
    required this.staffName,
    required this.appointmentID,
    required this.appointmentTitle,
    required this.carInfo,
    required this.mirrorSections,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.plateNumber,
    required this.packageName,
    required this.carBrand,
    required this.carModel,
    required this.darkness,
    this.isFinalized = false,
    this.appointmentDate,
    this.appointmentTime,
    this.estimatedDuration,
  });

  factory TaskItem.fromMap(String id, Map<String, dynamic> map) {
    final rawSection = map['mirrorSection'];
    List<String> sections = [];
    if (rawSection is List) {
      sections = List<String>.from(rawSection);
    } else if (rawSection is String && rawSection.isNotEmpty) {
      sections = rawSection.split(',').map((e) => e.trim()).toList();
    }
    
    return TaskItem(
      id: id,
      branchID: (map['branchID'] ?? '') as String,
      staffID: (map['assignedStaffID'] ?? '') as String,
      staffName: (map['assignedStaffName'] ?? '') as String,
      appointmentID: (map['appointmentID'] ?? '') as String,
      appointmentTitle: (map['appointmentTitle'] ?? '') as String,
      carInfo: (map['carInfo'] ?? '') as String,
      mirrorSections: sections,
      status: (map['status'] ?? 'pending') as String,
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as Timestamp).toDate() 
        : null,
      customerName: (map['customerName'] as String?)?.trim(),
      plateNumber: (map['plateNumber'] as String?)?.trim(),
      packageName: (map['packageName'] as String?)?.trim(),
      carBrand: (map['carBrand'] as String?)?.trim(),
      carModel: (map['carModel'] as String?)?.trim(),
      darkness: (map['darkness'] as String?)?.trim(),
      isFinalized: (map['isFinalized'] ?? false) as bool,
      appointmentDate: map['appointmentDate'] as String?,
      appointmentTime: map['appointmentTime'] as String?,
      estimatedDuration: map['estimatedDuration'] as int?,
    );
  }
}
