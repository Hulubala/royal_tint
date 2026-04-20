import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/widgets/staff_input_decoration.dart';
import 'package:royal_tint/core/utils/validators.dart';
import 'staff_registration_panel_decoration.dart';

class StaffRegistrationFormPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  final bool isLoading;
  final VoidCallback onSubmit;

  const StaffRegistrationFormPanel({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: staffPanelDecoration(),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Personal Information'),
            const SizedBox(height: 16),
            _nameField(),
            const SizedBox(height: 16),
            _emailField(),
            const SizedBox(height: 16),
            _phoneField(),
            const SizedBox(height: 28),

            _sectionTitle('Password'),
            const SizedBox(height: 8),
            Text(
              'Set a password for the staff account (min 6 characters)',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            _passwordField(),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(BootstrapIcons.person_plus_fill),
                          SizedBox(width: 12),
                          Text(
                            'Register Staff',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFD700),
      ),
    );
  }

  Widget _nameField() {
    return TextFormField(
      controller: nameController,
      keyboardType: TextInputType.name,
      enableIMEPersonalizedLearning: false,
      style: StaffInputStyles.textStyle,
      cursorColor: StaffInputStyles.cursorColor,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-'.@/]")),
        LengthLimitingTextInputFormatter(30),
      ],
      validator: Validators.validateName,
      decoration: StaffInputStyles.decoration(
        labelText: 'Full Name',
        hintText: 'John Doe',
        prefixIcon: BootstrapIcons.person_fill,
        helperText: 'Max 30 characters',
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      enableIMEPersonalizedLearning: false,
      style: StaffInputStyles.textStyle,
      cursorColor: StaffInputStyles.cursorColor,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@._+\-]")),
        LengthLimitingTextInputFormatter(50),
      ],
      validator: Validators.validateEmail,
      decoration: StaffInputStyles.decoration(
        labelText: 'Email Address',
        hintText: 'john@example.com',
        prefixIcon: BootstrapIcons.envelope_fill,
        helperText: 'Max 50 characters',
      ),
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      enableIMEPersonalizedLearning: false,
      style: StaffInputStyles.textStyle,
      cursorColor: StaffInputStyles.cursorColor,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
        LengthLimitingTextInputFormatter(15),
      ],
      validator: Validators.validatePhone,
      decoration: StaffInputStyles.decoration(
        labelText: 'Phone Number',
        hintText: '012-345 6789 or +6012-345 6789',
        prefixIcon: BootstrapIcons.telephone_fill,
        helperText: 'Format: 01x-xxxx xxxx',
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      enableIMEPersonalizedLearning: false,
      style: StaffInputStyles.textStyle,
      cursorColor: StaffInputStyles.cursorColor,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      validator: Validators.validatePassword,
      decoration: StaffInputStyles.decoration(
        labelText: 'Password',
        hintText: 'Enter password (min 6 characters)',
        prefixIcon: BootstrapIcons.key_fill,
        helperText: 'Required',
      ),
    );
  }
}