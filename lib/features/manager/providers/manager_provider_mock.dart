import 'package:flutter/material.dart';

class ManagerProvider with ChangeNotifier {
  // Mock data - no Firebase needed
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mock appointments data
  List<Map<String, dynamic>> get appointments => [
    {
      'name': 'Ahmad Ibrahim',
      'car': 'Perodua Myvi',
      'plateNumber': 'WXY 1234',
      'time': '10:00 AM',
      'status': 'CONFIRMED',
    },
    {
      'name': 'Sarah Lim',
      'car': 'Honda Civic',
      'plateNumber': 'ABC 5678',
      'time': '2:00 PM',
      'status': 'PENDING',
    },
    {
      'name': 'Kumar Raj',
      'car': 'Toyota Vios',
      'plateNumber': 'DEF 9012',
      'time': '4:30 PM',
      'status': 'CONFIRMED',
    },
  ];

  // Mock stats
  int get todayAppointments => 8;
  int get pendingTasks => 5;
  String get monthlyRevenue => 'RM 45,680';
  int get activeStaff => 6;

  // Mock methods
  Future<void> fetchAppointments(String branchID) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAppointmentStatus(String appointmentID, String status) async {
    // Mock update
    await Future.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }
}