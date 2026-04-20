class StaffRegistrationRequest {
  final String staffName;
  final String staffEmail;
  final String staffPhone;
  final String password;

  const StaffRegistrationRequest({
    required this.staffName,
    required this.staffEmail,
    required this.staffPhone,
    required this.password,
  });
}