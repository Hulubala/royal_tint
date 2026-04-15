import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:royal_tint/core/design_system/app_colors.dart';
import 'package:royal_tint/core/widgets/hoverable_button.dart';
import 'package:royal_tint/core/widgets/hoverable_widget.dart';
import 'package:royal_tint/admin_web/features/auth/controllers/login_controller.dart';
import 'package:royal_tint/admin_web/features/auth/widgets/forgot_password_dialog.dart';
import 'package:royal_tint/admin_web/features/auth/widgets/support_dialog.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<LoginController>();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.7),
            const Color(0xFF1A1A1A).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to continue',
              style: TextStyle(
                color: AppColors.grey300,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            _EmailField(),
            const SizedBox(height: 20),
            _PasswordField(),

            const SizedBox(height: 16),
            _RememberMeRow(),

            const SizedBox(height: 32),
            HoverableButton(
              onPressed: c.isLoading
                  ? null
                  : () async {
                      final ok = await context.read<LoginController>().submit();
                      if (!context.mounted) return;

                      if (ok) {
                        context.go('/manager/dashboard');
                      } else {
                        context.read<LoginController>().showLoginError(context);
                      }
                    },
              child: _LoginButtonChild(isLoading: c.isLoading),
            ),

            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 24),
            _helpText(context),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.grey600.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.grey600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.grey600.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _helpText(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Need help accessing your account?',
          style: TextStyle(
            color: AppColors.grey300,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        HoverableWidget(
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const SupportDialog(),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(BootstrapIcons.headset, color: AppColors.gold, size: 16),
                SizedBox(width: 8),
                Text(
                  'Contact Support',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<LoginController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Email Address',
            style: TextStyle(
              color: AppColors.grey300,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        _CustomTextField(
          controller: c.emailController,
          hintText: 'Enter your email',
          prefixIcon: BootstrapIcons.envelope_fill,
          keyboardType: TextInputType.emailAddress,
          validator: c.validateEmail,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<LoginController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Password',
            style: TextStyle(
              color: AppColors.grey300,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        _CustomTextField(
          controller: c.passwordController,
          hintText: 'Enter your password',
          prefixIcon: BootstrapIcons.lock_fill,
          obscureText: !c.isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              c.isPasswordVisible
                  ? BootstrapIcons.eye_fill
                  : BootstrapIcons.eye_slash_fill,
              color: AppColors.grey600,
              size: 18,
            ),
            onPressed: () => context.read<LoginController>().togglePasswordVisibility(),
          ),
          validator: c.validatePassword,
        ),
      ],
    );
  }
}

class _RememberMeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<LoginController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        HoverableWidget(
          cursor: SystemMouseCursors.basic,
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: c.rememberMe,
                  onChanged: (value) =>
                      context.read<LoginController>().setRememberMe(value ?? false),
                  activeColor: AppColors.gold,
                  checkColor: Colors.black,
                  side: const BorderSide(color: AppColors.grey600, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Remember me',
                style: TextStyle(
                  color: AppColors.grey300,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        HoverableWidget(
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const ForgotPasswordDialog(),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.gold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginButtonChild extends StatelessWidget {
  final bool isLoading;

  const _LoginButtonChild({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLoading
              ? [AppColors.grey600, AppColors.grey600]
              : [AppColors.gold, const Color(0xFFFFD700)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isLoading
            ? []
            : [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    BootstrapIcons.arrow_right_circle_fill,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}

// Kept local to LoginCard for now (feature-specific style).
// If you want, we can replace this with your core/widgets/custom_text_field.dart later.
class _CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  bool _isFocused = false;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused
        ? AppColors.gold
        : AppColors.grey600.withOpacity(0.3);

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: ClipRRect(
        borderRadius: _radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: _radius,
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: AppColors.grey600,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _isFocused ? AppColors.gold : AppColors.grey600,
                size: 20,
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              errorStyle: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}