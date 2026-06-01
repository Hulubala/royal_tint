import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/core/widgets/password_strength_indicator.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String oobCode;

  const ResetPasswordScreen({super.key, required this.oobCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  String? _userRole;

  // FIXED: Declared at the class state level so it's a true constant everywhere
  static const gold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _fetchUserRoleQuietly();
  }

  Future<void> _fetchUserRoleQuietly() async {
    try {
      final email = await FirebaseAuth.instance.verifyPasswordResetCode(widget.oobCode);
      final normalizedEmail = email.trim().toLowerCase();
      
      // 1. Check if the URL already has a role parameter or if it is inside continueUrl
      String? detectedRole = Uri.base.queryParameters['role'];
      
      if (detectedRole == null) {
        final continueUrl = Uri.base.queryParameters['continueUrl'];
        if (continueUrl != null) {
          try {
            final decodedUri = Uri.parse(Uri.decodeFull(continueUrl));
            detectedRole = decodedUri.queryParameters['role'];
            if (detectedRole == null && continueUrl.contains('manager/login')) {
              detectedRole = 'manager';
            }
          } catch (_) {}
        }
      }

      if (detectedRole != null && (detectedRole == 'staff' || detectedRole == 'customer' || detectedRole == 'manager')) {
        setState(() {
          _userRole = detectedRole;
        });
        return;
      }

      // 2. Check the public 'manager_email_lookup' collection (100% reliable for managers!)
      try {
        final managerDoc = await FirebaseFirestore.instance
            .collection('manager_email_lookup')
            .doc(normalizedEmail)
            .get();
        if (managerDoc.exists) {
          setState(() {
            _userRole = 'manager';
          });
          return;
        }
      } catch (e) {
        print('Quietly ignored error checking manager_email_lookup: $e');
      }

      // 3. Try to check 'staff' collection by email (usually publicly readable for booking selections)
      try {
        final staffSnapshot = await FirebaseFirestore.instance
            .collection('staff')
            .where('email', isEqualTo: normalizedEmail)
            .limit(1)
            .get();
        if (staffSnapshot.docs.isNotEmpty) {
          setState(() {
            _userRole = 'staff';
          });
          return;
        }
      } catch (e) {
        print('Quietly ignored error checking staff collection: $e');
      }

      // 4. Try anonymous login and check 'users' collection
      UserCredential? anonCred;
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          anonCred = await FirebaseAuth.instance.signInAnonymously();
        }
        
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: normalizedEmail)
            .limit(1)
            .get();
            
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _userRole = snapshot.docs.first.data()['role'];
          });
          return;
        }
      } catch (e) {
        print('Quietly ignored error checking users collection: $e');
      } finally {
        if (anonCred != null) {
          try {
            await FirebaseAuth.instance.signOut();
          } catch (_) {}
        }
      }

      // 5. Ultimate Fallback: Default to customer (since if they aren't manager/staff, they are customers)
      setState(() {
        _userRole = 'customer';
      });

    } catch (e) {
      print('Quietly ignored error verifying reset code: $e');
      // If verifyPasswordResetCode itself fails (e.g. code expired after submit), do not override existing _userRole
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Confirm new password
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: _passwordController.text,
      );

      setState(() {
        _isSuccess = true;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'Failed to reset password. The link may have expired.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: _isSuccess ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  // FIXED: Removed Color argument parameters
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.shield_lock_fill, color: gold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Create a strong new password for your account.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          AnimatedBuilder(
            animation: _passwordController,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordField('New Password', _passwordController),
                  PasswordStrengthIndicator(password: _passwordController.text),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField('Confirm Password', _confirmPasswordController),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                    )
                  : const Text(
                      'SAVE NEW PASSWORD',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(BootstrapIcons.key_fill, color: Colors.grey[400], size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[400],
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: gold),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    final activeRole = _userRole;
    String roleText = '';
    Widget actionButton;

    if (activeRole == 'staff') {
      roleText = 'Your password has been successfully reset! Please open the Royal Tint Staff Mobile App on your device to log in.';
      actionButton = const Column(
        children: [
          Icon(BootstrapIcons.phone, color: gold, size: 48),
          SizedBox(height: 16),
          Text(
            'You may now close this browser tab.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      );
    } else if (activeRole == 'customer') {
      roleText = 'Your password has been successfully reset! Please open the Royal Tint Customer Mobile App on your device to log in.';
      actionButton = const Column(
        children: [
          Icon(BootstrapIcons.phone, color: gold, size: 48),
          SizedBox(height: 16),
          Text(
            'You may now close this browser tab.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      );
    } else if (activeRole == 'manager') {
      roleText = 'Your password has been successfully reset! You can now return to the manager login screen.';
      actionButton = SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () {
            context.go('/manager/login');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            side: const BorderSide(color: gold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('GO TO MANAGER LOGIN'),
        ),
      );
    } else {
      // Default Generic Fallback if role couldn't be loaded/detected
      roleText = 'Your password has been successfully reset! You can now close this tab and return to your application to log in.';
      actionButton = const Column(
        children: [
          Icon(BootstrapIcons.phone, color: gold, size: 48),
          SizedBox(height: 16),
          Text(
            'You may now close this browser tab.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(BootstrapIcons.check_circle_fill, color: Colors.green, size: 64),
        const SizedBox(height: 24),
        const Text(
          'Password Reset Successful!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          roleText,
          style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        actionButton,
      ],
    );
  }
} 