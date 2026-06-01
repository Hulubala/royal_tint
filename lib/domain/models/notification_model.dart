import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationID;
  final String recipientID;
  final String recipientType; // 'manager', 'customer', 'staff'
  final String title;
  final String message;
  final String type; // 'appointment_created', 'status_changed', 'appointment_confirmed', 'appointment_cancelled', 'appointment_completed'
  final String? appointmentID;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationID,
    required this.recipientID,
    required this.recipientType,
    required this.title,
    required this.message,
    required this.type,
    this.appointmentID,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime createdAt = DateTime.now();
    try {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt']);
      }
    } catch (_) {}

    return NotificationModel(
      notificationID: doc.id,
      recipientID: data['recipientID'] ?? '',
      recipientType: data['recipientType'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      appointmentID: data['appointmentID'],
      isRead: data['isRead'] ?? false,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientID': recipientID,
      'recipientType': recipientType,
      'title': title,
      'message': message,
      'type': type,
      'appointmentID': appointmentID,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    String? notificationID,
    String? recipientID,
    String? recipientType,
    String? title,
    String? message,
    String? type,
    String? appointmentID,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationID: notificationID ?? this.notificationID,
      recipientID: recipientID ?? this.recipientID,
      recipientType: recipientType ?? this.recipientType,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      appointmentID: appointmentID ?? this.appointmentID,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Human-readable time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
