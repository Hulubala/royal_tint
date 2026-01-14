// lib/features/manager/screens/staff_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/features/staff/services/staff_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart' as auth;

class StaffRegistrationScreen extends StatefulWidget {
  const StaffRegistrationScreen({super.key});

  @override
  State<StaffRegistrationScreen> createState() => _StaffRegistrationScreenState();
}

class _StaffRegistrationScreenState extends State<StaffRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _staffService = StaffService();
  final _auth = FirebaseAuth.instance;
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // State
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Generate temporary password
  String _generateTemporaryPassword() {
    return 'Staff${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}!';
  }

  // Validate Malaysia phone number format
  String? _validateMalaysiaPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    
    // Remove all spaces and dashes for validation
    final cleanNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it's all digits
    if (!RegExp(r'^[0-9+]+$').hasMatch(cleanNumber)) {
      return 'Phone number can only contain numbers';
    }
    
    // Malaysia mobile format: 01x-xxxx xxxx (10-11 digits)
    // Or international: +601x-xxxx xxxx
    if (cleanNumber.startsWith('+60')) {
      // International format: +60 + 10-11 digits
      if (cleanNumber.length < 12 || cleanNumber.length > 13) {
        return 'Invalid format. Use: +6012-345 6789';
      }
    } else if (cleanNumber.startsWith('01')) {
      // Local format: 01x + 7-8 digits = 10-11 digits total
      if (cleanNumber.length < 10 || cleanNumber.length > 11) {
        return 'Invalid format. Use: 012-345 6789';
      }
    } else {
      return 'Must start with 01 or +60';
    }
    
    return null;
  }

  Future<void> _registerStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showSnackBar('You must be logged in as a manager', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Generate temporary password
      final tempPassword = _passwordController.text.isEmpty 
          ? _generateTemporaryPassword() 
          : _passwordController.text;
      
      // Get branch ID from AuthProvider
      final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);
      final branchID = authProvider.branchID ?? 'melaka';

      // Clean phone number (remove spaces and dashes)
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[\s-]'), '');

      // Register staff (without expertise)
      final result = await _staffService.registerStaffByManager(
        managerUID: currentUser.uid,
        managerBranchID: branchID,
        staffName: _nameController.text.trim(),
        staffEmail: _emailController.text.trim().toLowerCase(),
        staffPhone: cleanPhone,
        temporaryPassword: tempPassword,
        expertise: [], // Empty list - no expertise needed
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _showSuccessDialog(
          staffEmail: result['staffEmail'],
          staffID: result['staffID'],
          tempPassword: tempPassword,
          requiresReauth: result['requiresManagerReauth'] ?? false,
        );
      } else {
        _showSnackBar(result['message'] ?? 'Failed to register staff', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showSuccessDialog({
    required String staffEmail,
    required String staffID,
    required String tempPassword,
    required bool requiresReauth,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                BootstrapIcons.check_circle_fill,
                color: Color(0xFFFFD700),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Staff Registered!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff account has been created successfully!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Staff ID', staffID),
            _buildInfoRow('Email', staffEmail),
            _buildInfoRow('Temp Password', tempPassword),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    BootstrapIcons.info_circle_fill,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A password reset email has been sent to $staffEmail',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (requiresReauth) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      BootstrapIcons.exclamation_triangle_fill,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will need to log back in to continue.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
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
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),
                  
                  // Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information
                        _buildSectionTitle('Personal Information'),
                        const SizedBox(height: 16),
                        
                        // NAME FIELD WITH RESTRICTIONS
                        _buildNameField(),
                        
                        const SizedBox(height: 16),
                        
                        // EMAIL FIELD WITH RESTRICTIONS
                        _buildEmailField(),
                        
                        const SizedBox(height: 16),
                        
                        // PHONE NUMBER WITH MALAYSIA FORMAT
                        _buildPhoneField(),
                        
                        const SizedBox(height: 32),
                        
                        // Password (Optional)
                        _buildSectionTitle('Temporary Password (Optional)'),
                        const SizedBox(height: 8),
                        Text(
                          'Leave empty to auto-generate a secure password',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerStaff,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black, Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: const Icon(
            BootstrapIcons.person_plus_fill,
            color: Color(0xFFFFD700),
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Register New Staff',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Create a new staff account for your branch',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // NAME FIELD WITH RESTRICTIONS - FIX UNDERLINE BUG
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      enableIMEPersonalizedLearning: false, // FIX: Prevents underline bug
      inputFormatters: [
        // Only letters, spaces, hyphens, apostrophes, and dots
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-'.@/]")),
        LengthLimitingTextInputFormatter(30), // Max 30 characters
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter staff name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'John Doe',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          BootstrapIcons.person_fill,
          color: Color(0xFFFFD700),
        ),
        helperText: 'Max 30 characters',
        helperStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        counterText: '', // Hide character counter
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // EMAIL FIELD WITH RESTRICTIONS - FIX UNDERLINE BUG
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enableIMEPersonalizedLearning: false, // FIX: Prevents underline bug
      inputFormatters: [
        // Standard email characters only
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        LengthLimitingTextInputFormatter(50), // Max 50 characters
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
          return 'Please enter a valid email';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'john@example.com',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          BootstrapIcons.envelope_fill,
          color: Color(0xFFFFD700),
        ),
        helperText: 'Max 50 characters',
        helperStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        counterText: '', // Hide character counter
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // PHONE NUMBER FIELD WITH MALAYSIA FORMAT - FIX UNDERLINE BUG
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      enableIMEPersonalizedLearning: false, // FIX: Prevents underline bug
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')), // Only numbers, +, space, dash
        LengthLimitingTextInputFormatter(15), // Max 15 characters
      ],
      validator: _validateMalaysiaPhone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '012-345 6789 or +6012-345 6789',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          BootstrapIcons.telephone_fill,
          color: Color(0xFFFFD700),
        ),
        helperText: 'Format: 01x-xxxx xxxx',
        helperStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        counterText: '', // Hide character counter
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // PASSWORD FIELD - FIX UNDERLINE BUG
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      enableIMEPersonalizedLearning: false, // FIX: Prevents underline bug
      inputFormatters: [
        LengthLimitingTextInputFormatter(50), // Max 50 characters
      ],
      decoration: InputDecoration(
        labelText: 'Temporary Password',
        hintText: 'Leave empty to auto-generate',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          BootstrapIcons.key_fill,
          color: Color(0xFFFFD700),
        ),
        helperText: 'Optional - Auto-generated if empty',
        helperStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        counterText: '', // Hide character counter
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}