import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/core/constants/app_colors.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Get AuthProvider
      final authProvider = context.read<AuthProvider>();
      
      // Call sign in method
      bool success = await authProvider.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      setState(() => _isLoading = false);
      
      if (success) {
        // Login successful - navigate to dashboard
        if (mounted) {
          context.go('/manager/dashboard');
        }
      } else {
        // Show error message
        if (mounted) {
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
                      authProvider.getUserFriendlyError(
                        authProvider.errorMessage ?? 'Login failed'
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1A1A1A),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated gold accent circles
            _buildBackgroundAccents(),
            
            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 48),
                          _buildLoginCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BACKGROUND ACCENTS
  // ============================================
  
  Widget _buildBackgroundAccents() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // HEADER SECTION
  // ============================================
  
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Title
        const Text(
          'Royal Tint',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: AppColors.gold,
                blurRadius: 20,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        const Text(
          'Manager Portal',
          style: TextStyle(
            color: AppColors.grey300,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  // ============================================
  // LOGIN CARD
  // ============================================
  
  Widget _buildLoginCard() {
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
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 2,
        ),
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
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome text
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
            
            // Email field
            _buildEmailField(),
            
            const SizedBox(height: 20),
            
            // Password field
            _buildPasswordField(),
            
            const SizedBox(height: 16),
            
            // Remember me & Forgot password
            _buildRememberMeRow(),
            
            const SizedBox(height: 32),
            
            // Login button
            _buildLoginButton(),
            
            const SizedBox(height: 24),
            
            // Divider
            _buildDivider(),
            
            const SizedBox(height: 24),
            
            // Help text
            _buildHelpText(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // EMAIL FIELD
  // ============================================
  
  Widget _buildEmailField() {
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
          controller: _emailController,
          hintText: 'Enter your email',
          prefixIcon: BootstrapIcons.envelope_fill,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ============================================
  // PASSWORD FIELD
  // ============================================
  
  Widget _buildPasswordField() {
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
          controller: _passwordController,
          hintText: 'Enter your password',
          prefixIcon: BootstrapIcons.lock_fill,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? BootstrapIcons.eye_fill
                  : BootstrapIcons.eye_slash_fill,
              color: AppColors.grey600,
              size: 18,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ============================================
  // REMEMBER ME ROW
  // ============================================
  
  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me checkbox
        _HoverableWidget(
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
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
        
        // Forgot password
        const _HoverableWidget(
          child: Text(
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
      ],
    );
  }

  // ============================================
  // LOGIN BUTTON
  // ============================================
  
  Widget _buildLoginButton() {
    return _HoverableButton(
      onPressed: _isLoading ? null : _handleLogin,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isLoading
                ? [AppColors.grey600, AppColors.grey600]
                : [AppColors.gold, const Color(0xFFFFD700)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isLoading
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
          child: _isLoading
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
      ),
    );
  }

  // ============================================
  // DIVIDER
  // ============================================
  
  Widget _buildDivider() {
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

  // ============================================
  // HELP TEXT
  // ============================================
  
  Widget _buildHelpText() {
    return const Column(
      children: [
        Text(
          'Need help accessing your account?',
          style: TextStyle(
            color: AppColors.grey300,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        _HoverableWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                BootstrapIcons.headset,
                color: AppColors.gold,
                size: 16,
              ),
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
      ],
    );
  }
}

// ============================================
// CUSTOM TEXT FIELD WIDGET
// ============================================

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

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused
                ? AppColors.gold
                : AppColors.grey600.withOpacity(0.3),
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
    );
  }
}

// ============================================
// HOVERABLE BUTTON WIDGET
// ============================================

class _HoverableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _HoverableButton({
    required this.child,
    this.onPressed,
  });

  @override
  State<_HoverableButton> createState() => _HoverableButtonState();
}

class _HoverableButtonState extends State<_HoverableButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================
// HOVERABLE WIDGET (FOR LINKS AND CHECKBOXES)
// ============================================

class _HoverableWidget extends StatefulWidget {
  final Widget child;

  const _HoverableWidget({
    required this.child,
  });

  @override
  State<_HoverableWidget> createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<_HoverableWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isHovered ? 0.8 : 1.0,
        child: widget.child,
      ),
    );
  }
}