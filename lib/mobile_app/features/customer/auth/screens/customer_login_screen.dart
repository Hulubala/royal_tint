import 'package:flutter/material.dart';
import 'package:royal_tint/mobile_app/features/common/auth/base/base_login.dart';

class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseLoginPage(
      title: 'Customer Login',
      homeRoute: '/customer/home',
      showSignup: true,
      signupRoute: '/customer/register',
      expectedRole: 'customer',
    );
  }
}