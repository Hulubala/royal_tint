import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart' as auth;
import 'package:royal_tint/admin_web/features/staff_management/models/staff_registration_request.dart';
import 'package:royal_tint/admin_web/features/staff_management/providers/staff_registration_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/models/staff_registration_result.dart';

class StaffRegistrationController {
  Future<StaffRegistrationResult> register(
    BuildContext context, {
    required String staffName,
    required String staffEmail,
    required String staffPhone,
    required String password,
  }) async {
    final reg = context.read<StaffRegistrationProvider>();
    final authProvider = context.read<auth.AuthProvider>();

    return reg.registerStaff(
      request: StaffRegistrationRequest(
        staffName: staffName,
        staffEmail: staffEmail,
        staffPhone: staffPhone,
        password: password.trim(),
      ),
      authProvider: authProvider,
    );
  }
}