import 'package:flutter/foundation.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/domain/models/user/staff_model.dart';

class ManagerProvider extends ChangeNotifier {
  // Branch-specific data
  String? _branchID;
  List<AppointmentModel> _appointments = [];
  List<StaffModel> _staff = [];
  List<dynamic> _tasks = [];

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Dashboard stats
  int _todayAppointments = 0;
  int _pendingTasks = 0; // keep for future tasks module
  double _monthlyRevenue = 0.0;
  int _activeStaff = 0;

  // Getters
  String? get branchID => _branchID;
  List<AppointmentModel> get appointments => _appointments;
  List<StaffModel> get staff => _staff;
  List<dynamic> get tasks => _tasks;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get todayAppointments => _todayAppointments;
  int get pendingTasks => _pendingTasks;
  double get monthlyRevenue => _monthlyRevenue;
  int get activeStaff => _activeStaff;

  // ===== setters used by Controller =====

  void setBranch(String branchID) {
    _branchID = branchID;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setAppointments(List<AppointmentModel> value) {
    _appointments = value;
    notifyListeners();
  }

  void setTasks(List<dynamic> value) {
    _tasks = value;
    notifyListeners();
  }

  void setStaff(List<StaffModel> value) {
    _staff = value;
    notifyListeners();
  }

  void setStats({
    int? todayAppointments,
    int? pendingTasks,
    double? monthlyRevenue,
    int? activeStaff,
  }) {
    if (todayAppointments != null) _todayAppointments = todayAppointments;
    if (pendingTasks != null) _pendingTasks = pendingTasks;
    if (monthlyRevenue != null) _monthlyRevenue = monthlyRevenue;
    if (activeStaff != null) _activeStaff = activeStaff;
    notifyListeners();
  }

  void removeAppointmentById(String appointmentId) {
    _appointments.removeWhere((apt) => apt.appointmentID == appointmentId);
    notifyListeners();
  }
}