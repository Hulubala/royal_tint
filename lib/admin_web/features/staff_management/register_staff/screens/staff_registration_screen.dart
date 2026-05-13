import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/controllers/staff_registration_controller.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/dialogs/staff_registration_success_dialog.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/providers/staff_registration_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/widgets/staff_registration_form_panel.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/widgets/staff_registration_header_panel.dart';

class StaffRegistrationScreen extends StatefulWidget {
  const StaffRegistrationScreen({super.key});

  @override
  State<StaffRegistrationScreen> createState() => _StaffRegistrationScreenState();
}

class _StaffRegistrationScreenState extends State<StaffRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = StaffRegistrationController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerStaff() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _controller.register(
      context,
      staffName: _nameController.text,
      staffEmail: _emailController.text,
      staffPhone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StaffRegistrationSuccessDialog(
          staffEmail: result.staffEmail ?? _emailController.text.trim(),
          staffID: result.staffID ?? '',
          password: _passwordController.text.trim(),
          requiresReauth: result.requiresManagerReauth,
          onOk: () {
            Navigator.of(context).pop();
            _clearForm();
          },
          onReauth: () {
            if (mounted) context.go('/manager/login');
          },
        ),
      );
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<StaffRegistrationProvider>().isLoading;

    return Container(
      color: const Color(0xFFF5F5F5), // outside stays white like your request
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const StaffRegistrationHeaderPanel(),
                const SizedBox(height: 22),
                StaffRegistrationFormPanel(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  isLoading: isLoading,
                  onSubmit: _registerStaff,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}