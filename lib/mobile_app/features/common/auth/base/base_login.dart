import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/mobile_app/features/common/auth/controllers/mobile_login_controller.dart';
import 'package:royal_tint/mobile_app/features/common/auth/widgets/forgot_password_dialog.dart';
import 'package:royal_tint/mobile_app/features/common/auth/widgets/support_dialog.dart';

class BaseLoginPage extends StatefulWidget {
  final String title; 
  final bool showSignup;
  final String? signupRoute; 
  final String homeRoute;
  final String? expectedRole;

  const BaseLoginPage({
    super.key,
    required this.title,
    required this.homeRoute,
    this.showSignup = false,
    this.signupRoute,
    this.expectedRole,
  });

  @override
  State<BaseLoginPage> createState() => _BaseLoginPageState();
}

class _BaseLoginPageState extends State<BaseLoginPage> {
  static const gold = Color(0xFFD4AF37);

  final _controller = MobileLoginController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await _controller.login(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        expectedRole: widget.expectedRole,
      );
      if (!mounted) return;
      context.go(widget.homeRoute);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: gold,
        elevation: 0,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold, width: 2),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Royal Tint',
                  style: TextStyle(
                    color: gold,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Text('Email', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration(
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 16),

              const Text('Password', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration(
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (_) => ForgotPasswordDialog(
                              initialEmail: _emailCtrl.text.trim(),
                              onSend: (email) => _controller.sendResetLink(email),
                            ),
                          );
                        },
                  child: const Text('Forgot Password?', style: TextStyle(color: gold)),
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              if (widget.showSignup && widget.signupRoute != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : () => context.go(widget.signupRoute!),
                  child: const Text(
                    'No account? Sign up',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ] else ...[
              const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR', style: TextStyle(color: Colors.white54)),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                ],
              ),

              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Need help accessing your account?',
                  style: TextStyle(color: Colors.white.withOpacity(0.65)),
                ),
              ),

              TextButton(
                onPressed: () {
                  showDialog(context: context, builder: (_) => const SupportDialog());
                },
                child: const Text('Contact Support', style: TextStyle(color: gold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}