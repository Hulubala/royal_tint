import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/mobile_app/core/auth/role_storage.dart';
import 'package:royal_tint/mobile_app/core/auth/user_role.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> pick(UserRole role) async {
      await RoleStorage.setRole(role);
      if (!context.mounted) return;
      context.go(role == UserRole.customer ? '/customer/login' : '/staff/login');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Royal Tint",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => pick(UserRole.customer),
                    child: const Text("Customer"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => pick(UserRole.staff),
                    child: const Text("Staff"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}