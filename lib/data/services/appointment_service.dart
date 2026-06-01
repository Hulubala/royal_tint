import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/data/repositories/task_repository.dart';

/// Service for managing appointments in Firebase
class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new appointment with slot validation
  Future<String?> createAppointment({
    String? customerID,
    required String customerName,
    required String customerPhone,
    required String branchID,
    required String vehicleBrand,
    required String vehicleModel,
    required String vehicleType,
    required String vehiclePlate,
    required String packageID,
    required String packageName,
    required Map<String, String> tintSelections,
    required String appointmentDate,
    required String appointmentTime,
    required String appointmentType, // 'scheduled' or 'walk-in'
    String? warranty,
    String? notes,
    required double totalPrice,
    required int estimatedDuration, // in minutes
  }) async {
    try {
      // ⭐ STEP 1: Validate slot availability BEFORE creating
      final existingAppointments = await getAppointmentsByDate(
        branchID: branchID,
        date: appointmentDate,
      );

      // Check if slot can accept this appointment
      if (!canAcceptAppointment(
          existingAppointments, appointmentTime, estimatedDuration)) {
        throw Exception(
            'TIME_SLOT_FULL: This time slot is fully booked (max 2 cars)');
      }

      // ⭐ STEP 2: Create appointment (validation already done above)
      // Create vehicle info map
      final vehicleInfo = {
        'brand': vehicleBrand,
        'model': vehicleModel,
        'type': vehicleType,
        'plateNumber': vehiclePlate,
      };

      // Create appointment data
      final appointmentData = {
        'customerID': customerID ?? 'GUEST_${DateTime.now().millisecondsSinceEpoch}',
        'customerName': customerName,
        'customerPhone': customerPhone,
        'branchID': branchID,
        'vehicleInfo': vehicleInfo,
        'packageID': packageID,
        'packageName': packageName,
        'tintSelections': tintSelections,
        'appointmentDate': appointmentDate,
        'appointmentTime': appointmentTime,
        'appointmentType': appointmentType,
        'estimatedDuration': estimatedDuration,
        'status': 'pending',
        'assignedStaffID': null,
        'warranty': warranty,
        'notes': notes,
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      final docRef =
          await _firestore.collection('appointments').add(appointmentData);

      return docRef.id;
    } catch (e) {
      if (e.toString().contains('TIME_SLOT_FULL')) {
        rethrow; // Pass the specific error up
      }
      throw Exception('❌ Error creating appointment: $e');
    }
  }

  /// Update appointment details (for Edit dialog)
  Future<void> updateAppointment({
    required String appointmentID,
    required String customerName,
    required String customerPhone,
    required String vehiclePlate,
    required String appointmentDate,
    required String appointmentTime,
    required String packageID,
    required String packageName,
    Map<String, String>? tintSelections, 
    String? notes,
    String? branchID,
  }) async {
    try {
      final updateData = {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'vehicleInfo.plateNumber': vehiclePlate, // Update nested field
        'appointmentDate': appointmentDate,
        'appointmentTime': appointmentTime,
        'packageID': packageID,
        'packageName': packageName,
        'notes': notes,
        if (tintSelections != null) 'tintSelections': tintSelections,
        if (branchID != null) 'branchID': branchID,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('appointments').doc(appointmentID).update(updateData);
    } catch (e) {
      throw Exception('❌ Failed to update appointment: $e');
    }
  }

  /// Update appointment status only (for status changes)
  Future<void> updateAppointmentStatus({
    required String appointmentID,
    required String newStatus,
    bool isBranchSwap = false,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (isBranchSwap) {
        updateData['isBranchSwap'] = true;
      }
      await _firestore.collection('appointments').doc(appointmentID).update(updateData);
    } catch (e) {
      throw Exception('❌ Failed to update appointment status: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentID) async {
    try {
      await TaskRepository().cancelTasksForAppointment(appointmentID);

      await _firestore.collection('appointments').doc(appointmentID).delete();
    } catch (e) {
      throw Exception('❌ Error deleting appointment: $e');
    }
  }


  /// Get next upcoming appointment for a specific customer
  Future<AppointmentModel?> getNextUpcomingAppointmentForCustomer(String customerID) async {
    try {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('customerID', isEqualTo: customerID)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      if (appointments.isEmpty) return null;

      final upcoming = appointments.where((a) {
        try {
          final aptDate = DateTime.parse(a.appointmentDate);
          final aptTimeParts = a.appointmentTime.split(':');
          final aptDateTime = DateTime(
            aptDate.year,
            aptDate.month,
            aptDate.day,
            int.parse(aptTimeParts[0]),
            int.parse(aptTimeParts[1]),
          );
          return aptDateTime.isAfter(now);
        } catch (_) {
          return a.appointmentDate.compareTo(todayStr) >= 0;
        }
      }).toList();

      if (upcoming.isEmpty) return null;

      upcoming.sort((a, b) {
        final dateCompare = a.appointmentDate.compareTo(b.appointmentDate);
        if (dateCompare != 0) return dateCompare;
        return a.appointmentTime.compareTo(b.appointmentTime);
      });

      return upcoming.first;
    } catch (e) {
      print('Error fetching next upcoming appointment: $e');
      return null;
    }
  }

  /// Get all appointments for a customer (sorted descending by date and time)
  Future<List<AppointmentModel>> getAppointmentsForCustomer(String customerID) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('customerID', isEqualTo: customerID)
          .get();

      final list = querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      list.sort((a, b) {
        final dateCompare = b.appointmentDate.compareTo(a.appointmentDate);
        if (dateCompare != 0) return dateCompare;
        return b.appointmentTime.compareTo(a.appointmentTime);
      });

      return list;
    } catch (e) {
      print('❌ Error fetching appointments for customer: $e');
      return [];
    }
  }

  /// Get all appointments for a customer as a real-time stream
  Stream<List<AppointmentModel>> getCustomerAppointmentsStream(String customerID) {
    return _firestore
        .collection('appointments')
        .where('customerID', isEqualTo: customerID)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) {
        final dateCompare = b.appointmentDate.compareTo(a.appointmentDate);
        if (dateCompare != 0) return dateCompare;
        return b.appointmentTime.compareTo(a.appointmentTime);
      });
      return list;
    });
  }

  Future<List<AppointmentModel>> getLatestAppointments({
    required String branchID,
    int limit = 10,
    List<String>? statuses,
  }) async {
    try {
      Query query = _firestore
          .collection('appointments')
          .where('branchID', isEqualTo: branchID);

      // Optional: filter by status list
      if (statuses != null && statuses.isNotEmpty) {
        query = query.where('status', whereIn: statuses);
      }

      final querySnapshot = await query
          .orderBy('appointmentDate', descending: true)
          .orderBy('appointmentTime', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('❌ Error fetching latest appointments: $e');
    }
  }

  /// Get all appointments for a branch (Stream for real-time updates)
  Stream<List<AppointmentModel>> getAppointmentsStream(String branchID) {
    return _firestore
        .collection('appointments')
        .where('branchID', isEqualTo: branchID)
        .orderBy('appointmentDate', descending: false)
        .orderBy('appointmentTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  /// Get appointments for a specific date
  ///
  /// ⭐ FILTERS: Only includes pending and confirmed appointments (excludes cancelled/completed)
  Future<List<AppointmentModel>> getAppointmentsByDate({
    required String branchID,
    required String date,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('branchID', isEqualTo: branchID)
          .where('appointmentDate', isEqualTo: date)
          .where('status', whereIn: [
            'pending',
            'confirmed'
          ]) // ⭐ FILTER: Exclude cancelled/completed
          .orderBy('appointmentTime', descending: false)
          .get();

      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      print(
          '[AVAILABILITY] Fetched ${appointments.length} active appointments for $date');
      for (final apt in appointments) {
        print(
            '[AVAILABILITY]   - ${apt.appointmentTime} (${apt.vehicleDisplay}, status: ${apt.status}, duration: ${apt.estimatedDuration}min)');
      }

      return appointments;
    } catch (e) {
      throw Exception('❌ Error fetching appointments by date: $e');
    }
  }

  /// Check if a time slot is available (legacy method - kept for compatibility)
  Future<bool> isTimeSlotAvailable({
    required String branchID,
    required String date,
    required String time,
    String? excludeAppointmentID,
  }) async {
    try {
      var query = _firestore
          .collection('appointments')
          .where('branchID', isEqualTo: branchID)
          .where('appointmentDate', isEqualTo: date)
          .where('appointmentTime', isEqualTo: time)
          .where('status', whereIn: [
        'pending',
        'confirmed'
      ]); // Only check active appointments

      final querySnapshot = await query.get();

      // If excluding an appointment (for updates), filter it out
      if (excludeAppointmentID != null) {
        return querySnapshot.docs
            .where((doc) => doc.id != excludeAppointmentID)
            .isEmpty;
      }

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('❌ Error checking time slot availability: $e');
    }
  }

  // ========== HELPER METHODS ==========

  /// ⭐ Check if a time slot can accept a new appointment (max 2 cars)
  bool canAcceptAppointment(
    List<AppointmentModel> dayAppointments,
    String timeSlot,
    int durationMinutes,
  ) {
    final slotTime = _parseTimeSlot(timeSlot);
    final endTime = slotTime + durationMinutes;

    // Count overlapping appointments
    final overlappingAppointments = <AppointmentModel>[];

    for (final apt in dayAppointments) {
      final aptStartTime = _parseTimeSlot(apt.appointmentTime);
      final aptDuration = apt.estimatedDuration > 0 ? apt.estimatedDuration : 90; // Default 90 minutes
      final aptEndTime = aptStartTime + aptDuration;

      // Check if appointments overlap
      final isOverlapping = (aptStartTime < endTime && aptEndTime > slotTime);

      if (isOverlapping) {
        overlappingAppointments.add(apt);
      }
    }

    final overlappingCount = overlappingAppointments.length;
    final canAccept = overlappingCount < 2;

    // Maximum 2 cars can be serviced at any given moment
    return canAccept;
  }

  /// ⭐ Parse time slot to minutes since midnight (e.g., "14:30" -> 870)
  int _parseTimeSlot(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  /// ⭐ Convert minutes since midnight back to HH:MM format
  String _convertToTimeString(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
