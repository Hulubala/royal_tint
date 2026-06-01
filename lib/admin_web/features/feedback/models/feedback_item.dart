import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackItem {
  final String id;
  final String customerID;
  final String customerName;
  final String customerEmail;
  final String comment;
  final DateTime? createdAt;
  final String? appointmentID;
  final String? branchID;
  final String category;
  final String customerPhone;
  final String? carPlate;

  FeedbackItem({
    required this.id,
    required this.customerID,
    required this.customerName,
    required this.customerEmail,
    required this.comment,
    this.createdAt,
    this.appointmentID,
    this.branchID,
    this.category = 'Services', // default for backward compatibility
    this.customerPhone = 'N/A', // default for backward compatibility
    this.carPlate,
  });

  factory FeedbackItem.fromMap(String id, Map<String, dynamic> map) {
    DateTime? createdTime;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        createdTime = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        createdTime = DateTime.tryParse(map['createdAt']);
      }
    }

    return FeedbackItem(
      id: id,
      customerID: map['customerID']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? 'Anonymous',
      customerEmail: map['customerEmail']?.toString() ?? 'N/A',
      comment: map['comment']?.toString() ?? '',
      createdAt: createdTime,
      appointmentID: map['appointmentID']?.toString(),
      branchID: map['branchID']?.toString(),
      category: map['category']?.toString() ?? 'Services',
      customerPhone: map['customerPhone']?.toString() ?? 'N/A',
      carPlate: map['carPlate']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerID': customerID,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'comment': comment,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'appointmentID': appointmentID,
      'branchID': branchID,
      'category': category,
      'customerPhone': customerPhone,
      'carPlate': carPlate,
    };
  }
}
