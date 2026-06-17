import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import 'package:royal_tint/core/design_system/app_colors.dart';
import 'package:royal_tint/core/utils/validators.dart'; 
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';

class LoginController extends ChangeNotifier {
  final AuthProvider authProvider;

  LoginController({
    required this.authProvider,
    required TickerProvider vsync,
  }) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  // Form
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // UI state
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool rememberMe = false;

  // Animations
  late final AnimationController _animationController;
  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<bool> submit() async {
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return false;

    isLoading = true;
    notifyListeners();

    final success = await authProvider.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isLoading = false;
    notifyListeners();

    return success;
  }

  void showLoginError(BuildContext context) {
    final message = authProvider.getUserFriendlyError(
      authProvider.errorMessage ?? 'Login failed',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              BootstrapIcons.exclamation_circle_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}