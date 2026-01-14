import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';
import 'package:royal_tint/data/models/appointment_model.dart';
import 'package:royal_tint/data/models/staff_model.dart';

class ManagerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Branch-specific data
  String? _branchID;
  List<AppointmentModel> _appointments = [];
  List<StaffModel> _staff = [];
  
  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  
  // Dashboard stats
  int _todayAppointments = 0;
  final int _pendingTasks = 0;
  double _monthlyRevenue = 0.0;
  int _activeStaff = 0;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppointmentModel> get appointments => _appointments;
  List<StaffModel> get staff => _staff;
  int get todayAppointments => _todayAppointments;
  int get pendingTasks => _pendingTasks;
  double get monthlyRevenue => _monthlyRevenue;
  int get activeStaff => _activeStaff;
  
  // Initialize with branch ID
  Future<void> init(String branchID) async {
    _branchID = branchID;
    await _loadDashboardData();
  }
  
  // Fetch appointments for a specific branch
  Future<void> fetchAppointments(String branchID) async {
    try {
      debugPrint('🟢 ManagerProvider: Starting fetchAppointments for branch: $branchID');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _branchID = branchID;
      
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConstants.appointmentsCollection)
          .where(FirebaseConstants.fieldBranchId, isEqualTo: branchID)
          .orderBy('appointmentDate', descending: true)
          .get();
      
      debugPrint('🟢 ManagerProvider: Firebase returned ${snapshot.docs.length} documents');
      
      _appointments = snapshot.docs.map((doc) {
        debugPrint('  📄 Processing document: ${doc.id}');
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('    - customerName: ${data['customerName']}');
        debugPrint('    - customerPhone: ${data['customerPhone']}');
        debugPrint('    - appointmentDate: ${data['appointmentDate']}');
        debugPrint('    - status: ${data['status']}');
        debugPrint('    - appointmentType: ${data['appointmentType']}');
        
        return AppointmentModel.fromFirestore(doc);
      }).toList();
      
      debugPrint('🟢 ManagerProvider: Mapped to ${_appointments.length} appointments');
      
      // Debug print each appointment
      for (var apt in _appointments) {
        debugPrint('  ✅ Appointment: ${apt.customerName} | ${apt.appointmentDate} | ${apt.status}');
      }
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint('🟢 ManagerProvider: fetchAppointments complete');
    } catch (e) {
      debugPrint('🔴 ManagerProvider ERROR: $e');
      _isLoading = false;
      _errorMessage = 'Failed to fetch appointments: $e';
      notifyListeners();
    }
  }
  
  // Fetch staff for a specific branch
  Future<void> fetchStaff(String branchID) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConstants.staffCollection)
          .where(FirebaseConstants.fieldBranchId, isEqualTo: branchID)
          .get();
      
      _staff = snapshot.docs
          .map((doc) => StaffModel.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch staff: $e';
      notifyListeners();
      debugPrint('Error fetching staff: $e');
    }
  }
  
  // Load dashboard data
  Future<void> _loadDashboardData() async {
    if (_branchID == null) return;
    
    try {
      // Get today's appointments for this branch
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      
      QuerySnapshot appointmentsSnap = await _firestore
          .collection(FirebaseConstants.appointmentsCollection)
          .where(FirebaseConstants.fieldBranchId, isEqualTo: _branchID)
          .where('appointmentDate', isGreaterThanOrEqualTo: startOfDay)
          .where('appointmentDate', isLessThan: endOfDay)
          .get();
      
      _todayAppointments = appointmentsSnap.docs.length;
      
      // Get active staff count
      QuerySnapshot staffSnap = await _firestore
          .collection(FirebaseConstants.staffCollection)
          .where(FirebaseConstants.fieldBranchId, isEqualTo: _branchID)
          .where('isActive', isEqualTo: true)
          .get();
      
      _activeStaff = staffSnap.docs.length;
      
      // Calculate monthly revenue
      DateTime startOfMonth = DateTime(today.year, today.month, 1);
      
      QuerySnapshot revenueSnap = await _firestore
          .collection(FirebaseConstants.appointmentsCollection)
          .where(FirebaseConstants.fieldBranchId, isEqualTo: _branchID)
          .where(FirebaseConstants.fieldStatus, isEqualTo: FirebaseConstants.statusCompleted)
          .where('appointmentDate', isGreaterThanOrEqualTo: startOfMonth)
          .get();
      
      _monthlyRevenue = revenueSnap.docs.fold(0.0, (sum, doc) {
        return sum + (doc['totalPrice'] ?? 0.0);
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }
  
  // Refresh data
  Future<void> refresh() async {
    await _loadDashboardData();
    if (_branchID != null) {
      await fetchAppointments(_branchID!);
    }
  }
  
  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Update appointment status - FIXED to use appointmentID
  Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      debugPrint('🟢 ManagerProvider: Updating appointment $appointmentId to $newStatus');
      
      _isLoading = true;
      notifyListeners();
      
      await _firestore
          .collection(FirebaseConstants.appointmentsCollection)
          .doc(appointmentId)
          .update({
        FirebaseConstants.fieldStatus: newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update local list - FIXED to use appointmentID
      int index = _appointments.indexWhere((apt) => apt.appointmentID == appointmentId);
      if (index != -1) {
        // Update the appointment in the list
        final updatedApt = _appointments[index];
        // Note: You'll need to add a copyWith method to AppointmentModel
        // For now, just refetch the appointments
        if (_branchID != null) {
          await fetchAppointments(_branchID!);
        }
      }
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint('🟢 ManagerProvider: Status updated successfully');
      return true;
    } catch (e) {
      debugPrint('🔴 ManagerProvider ERROR updating status: $e');
      _isLoading = false;
      _errorMessage = 'Failed to update appointment: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Delete appointment - FIXED to use appointmentID
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      debugPrint('🟢 ManagerProvider: Deleting appointment $appointmentId');
      
      _isLoading = true;
      notifyListeners();
      
      await _firestore
          .collection(FirebaseConstants.appointmentsCollection)
          .doc(appointmentId)
          .delete();
      
      // Remove from local list - FIXED to use appointmentID
      _appointments.removeWhere((apt) => apt.appointmentID == appointmentId);
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint('🟢 ManagerProvider: Appointment deleted successfully');
      return true;
    } catch (e) {
      debugPrint('🔴 ManagerProvider ERROR deleting: $e');
      _isLoading = false;
      _errorMessage = 'Failed to delete appointment: $e';
      notifyListeners();
      return false;
    }
  }
}