import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/domain/models/notification_model.dart';

/// Service for managing in-app notifications via Firestore
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'notifications';

  /// Create a new notification
  Future<void> createNotification({
    required String recipientID,
    required String recipientType,
    required String title,
    required String message,
    required String type,
    String? appointmentID,
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'recipientID': recipientID,
        'recipientType': recipientType,
        'title': title,
        'message': message,
        'type': type,
        'appointmentID': appointmentID,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail — notifications are non-critical
    }
  }

  /// Get real-time notification stream for a recipient
  Stream<List<NotificationModel>> getNotificationsStream(String recipientID, [String? branchID]) {
    final recipients = branchID != null 
        ? [recipientID, 'branch_$branchID', 'all_branches'] 
        : [recipientID];
    
    return _firestore
        .collection(_collection)
        .where('recipientID', whereIn: recipients)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((n) => !n.isRead) // Hide read notifications
              .toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs.take(50).toList();
        });
  }

  /// Get unread count stream
  Stream<int> getUnreadCountStream(String recipientID, [String? branchID]) {
    final recipients = branchID != null 
        ? [recipientID, 'branch_$branchID', 'all_branches'] 
        : [recipientID];

    return _firestore
        .collection(_collection)
        .where('recipientID', whereIn: recipients)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .where((n) => !n.isRead)
            .length);
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationID) async {
    try {
      await _firestore.collection(_collection).doc(notificationID).update({
        'isRead': true,
      });
    } catch (_) {}
  }

  /// Mark all notifications as read for a recipient
  Future<void> markAllAsRead(String recipientID, [String? branchID]) async {
    try {
      final recipients = branchID != null 
          ? [recipientID, 'branch_$branchID', 'all_branches'] 
          : [recipientID];

      final snapshot = await _firestore
          .collection(_collection)
          .where('recipientID', whereIn: recipients)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  /// Mark all notifications related to a specific appointment as read
  Future<void> markNotificationsAsReadForAppointment(String appointmentID) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('appointmentID', isEqualTo: appointmentID)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  // ========== CONVENIENCE METHODS ==========

  /// Notify all managers of a branch about a new appointment
  Future<void> notifyManagersNewAppointment({
    required String branchID,
    required String customerName,
    required String appointmentDate,
    required String appointmentTime,
    String? appointmentID,
  }) async {
    try {
      await createNotification(
        recipientID: 'branch_$branchID', // Broadcast to the whole branch
        recipientType: 'manager',
        title: 'New Appointment Booked',
        message: '$customerName booked an appointment on $appointmentDate at $appointmentTime.',
        type: 'appointment_created',
        appointmentID: appointmentID,
      );
    } catch (_) {}
  }

  /// Notify all managers of a branch about a cancelled appointment
  Future<void> notifyManagersAppointmentCancelled({
    required String branchID,
    required String customerName,
    required String appointmentDate,
    required String appointmentTime,
    String? appointmentID,
  }) async {
    try {
      await createNotification(
        recipientID: 'branch_$branchID', 
        recipientType: 'manager',
        title: 'Appointment Cancelled ❌',
        message: '$customerName has cancelled their appointment on $appointmentDate at $appointmentTime.',
        type: 'appointment_cancelled',
        appointmentID: appointmentID,
      );
    } catch (_) {}
  }

  /// Notify customer about appointment status change
  Future<void> notifyCustomerStatusChange({
    required String customerID,
    required String newStatus,
    required String appointmentDate,
    required String appointmentTime,
    String? appointmentID,
  }) async {
    String title;
    String message;

    switch (newStatus.toLowerCase()) {
      case 'confirmed':
        title = 'Appointment Confirmed ✅';
        message = 'Your appointment on $appointmentDate at $appointmentTime has been confirmed by the manager.';
        break;
      case 'cancelled':
        title = 'Appointment Cancelled ❌';
        message = 'Your appointment on $appointmentDate at $appointmentTime has been cancelled, please choose another time.';
        break;
      case 'completed':
        title = 'Service Completed 🎉';
        message = 'Your tinting service on $appointmentDate has been completed. Thank you for choosing Royal Tint!';
        break;
      default:
        title = 'Appointment Update';
        message = 'Your appointment on $appointmentDate at $appointmentTime status changed to ${newStatus.toUpperCase()}.';
    }

    await createNotification(
      recipientID: customerID,
      recipientType: 'customer',
      title: title,
      message: message,
      type: 'status_changed',
      appointmentID: appointmentID,
    );
  }
}
