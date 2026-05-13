import 'package:flutter/material.dart';
import 'package:royal_tint/mobile_app/features/common/auth/base/base_login.dart';

class StaffLoginScreen extends StatelessWidget {
  const StaffLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseLoginPage(
      title: 'Staff Login',
      homeRoute: '/staff/home',
      showSignup: false,
    );
  }
}