class StaffRegistrationResult {
  final bool success;
  final String message;
  final String? staffID;
  final String? staffEmail;
  final bool requiresManagerReauth;

  const StaffRegistrationResult({
    required this.success,
    required this.message,
    this.staffID,
    this.staffEmail,
    this.requiresManagerReauth = false,
  });
}