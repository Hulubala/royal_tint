class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final password = (value ?? '');

    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[a-z]').hasMatch(password) || !RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain uppercase and lowercase letters';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$&*~_.]').hasMatch(password)) {
      return 'Password must contain at least one special character (e.g., !@#)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Please enter your phone number';

    // Keep digits and optional leading +
    final phone = raw.replaceAll(RegExp(r'[^\d+]'), '');

    // Convert leading 0 to +60 format for consistent checking
    final normalized = phone.startsWith('0')
        ? '+60${phone.substring(1)}'
        : (phone.startsWith('60') ? '+$phone' : phone);

    // +60 + 9 to 10 digits (Malaysia mobile numbers after +60 are usually 9-10 digits, e.g. 12xxxxxxxx or 11xxxxxxxxx)
    final phoneRegex = RegExp(r'^\+60(1\d{8,9})$');

    if (!phoneRegex.hasMatch(normalized)) {
      return 'Please enter a valid Malaysian phone number';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }
}