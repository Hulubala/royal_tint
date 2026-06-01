import 'package:royal_tint/mobile_app/features/common/auth/services/mobile_auth_service.dart';

class MobileLoginController {
  final MobileAuthService _service;

  MobileLoginController({MobileAuthService? service})
      : _service = service ?? MobileAuthService();

  Future<void> login({
    required String email,
    required String password,
    String? expectedRole,
  }) async {
    await _service.signIn(email: email, password: password, expectedRole: expectedRole);
  }

  Future<void> sendResetLink(String email) async {
    await _service.sendPasswordResetEmail(email);
  }
}