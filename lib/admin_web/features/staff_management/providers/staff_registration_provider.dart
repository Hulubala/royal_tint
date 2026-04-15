import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart' as auth;
import 'package:royal_tint/admin_web/features/staff_management/models/staff_registration_request.dart';
import 'package:royal_tint/admin_web/features/staff_management/models/staff_registration_result.dart';
import 'package:royal_tint/admin_web/features/staff_management/services/staff_service.dart';

class StaffRegistrationProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final StaffService _service;

  StaffRegistrationProvider({
    FirebaseAuth? auth,
    StaffService? service,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _service = service ?? StaffService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String generatePassword() {
    return 'Staff${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}!';
  }

  Future<StaffRegistrationResult> registerStaff({
    required StaffRegistrationRequest request,
    required auth.AuthProvider authProvider,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const StaffRegistrationResult(
        success: false,
        message: 'You must be logged in as a manager',
      );
    }

    final branchID = authProvider.branchID ?? 'melaka';
    final cleanPhone = request.staffPhone.replaceAll(RegExp(r'[\s-]'), '');

    final password = request.password.trim();
    if (password.isEmpty) {
      return const StaffRegistrationResult(
        success: false,
        message: 'Password is required',
      );
    }
    if (password.length < 6) {
      return const StaffRegistrationResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    _setLoading(true);
    try {
      final result = await _service.registerStaffByManager(
        managerUID: currentUser.uid,
        managerBranchID: branchID,
        staffName: request.staffName.trim(),
        staffEmail: request.staffEmail.trim().toLowerCase(),
        staffPhone: cleanPhone,
        Password: password,
        expertise: const [],
      );

      final ok = result['success'] == true;

      return StaffRegistrationResult(
        success: ok,
        message: (result['message'] ?? '').toString(),
        staffID: result['staffID']?.toString(),
        staffEmail: result['staffEmail']?.toString(),
        requiresManagerReauth: result['requiresManagerReauth'] == true,
      );
    } finally {
      _setLoading(false);
    }
  }
}