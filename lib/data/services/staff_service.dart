import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/domain/models/user/staff_model.dart';
import 'package:royal_tint/domain/models/task_model.dart';

class StaffService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all staff members
  Future<List<StaffModel>> getAllStaff() async {
    try {
      final snapshot = await _firestore.collection('staff')
          .get();
          
      return snapshot.docs
          .map((doc) => StaffModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching staff: $e');
      return [];
    }
  }

  /// Get staff members by branch
  Future<List<StaffModel>> getStaffByBranch(String branchId) async {
    try {
      final snapshot = await _firestore.collection('staff')
          .where('branchID', isEqualTo: branchId)
          .get();
          
      return snapshot.docs
          .map((doc) => StaffModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching staff by branch: $e');
      return [];
    }
  }

  /// Mark staff absent or present for a specific date
  Future<void> setStaffAbsence(String staffId, String dateString, bool isAbsent) async {
    try {
      if (isAbsent) {
        await _firestore.collection('staff').doc(staffId).update({
          'absentDates': FieldValue.arrayUnion([dateString])
        });
      } else {
        await _firestore.collection('staff').doc(staffId).update({
          'absentDates': FieldValue.arrayRemove([dateString])
        });
      }
    } catch (e) {
      print('❌ Error updating staff absence: $e');
      rethrow;
    }
  }

  /// Delete a staff member entirely
  Future<void> deleteStaff(String staffId) async {
    try {
      // Fetch the staff doc first to get their Auth uid so we can delete from 'users' too
      final doc = await _firestore.collection('staff').doc(staffId).get();
      if (doc.exists) {
        final uid = doc.data()?['uid'] ?? '';
        if (uid.isNotEmpty) {
          // Delete from 'users'
          await _firestore.collection('users').doc(uid).delete().catchError((e) {
            print('⚠️ Non-fatal error deleting from users collection: $e');
          });
        }
      }
      // Delete from 'staff'
      await _firestore.collection('staff').doc(staffId).delete();
    } catch (e) {
      print('❌ Error deleting staff: $e');
      rethrow;
    }
  }

  /// Get tasks assigned to a specific staff on a specific date
  Future<List<TaskModel>> getTasksForStaffOnDate(String staffId, DateTime date) async {
    try {
      // Create start and end of the day to query
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore.collection('tasks')
          .where('assignedStaffID', isEqualTo: staffId)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error fetching staff tasks: $e');
      return [];
    }
  }

  /// Get appointments assigned to a specific staff on a specific date
  Future<List<Map<String, dynamic>>> getAppointmentsForStaffOnDate(String staffId, String dateString) async {
    try {
      final snapshot = await _firestore.collection('appointments')
          .where('assignedStaffID', isEqualTo: staffId)
          .where('appointmentDate', isEqualTo: dateString)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['appointmentID'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error fetching staff appointments: $e');
      return [];
    }
  }

  /// Get a single staff member by ID
  Future<StaffModel?> getStaffById(String staffId) async {
    try {
      final doc = await _firestore.collection('staff').doc(staffId).get();
      if (doc.exists) {
        return StaffModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching staff details: $e');
      return null;
    }
  }
}
