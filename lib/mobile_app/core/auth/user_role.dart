enum UserRole { customer, staff }

extension UserRoleX on UserRole {
  String get key => this == UserRole.customer ? 'customer' : 'staff';
  static UserRole? fromKey(String? v) {
    if (v == 'customer') return UserRole.customer;
    if (v == 'staff') return UserRole.staff;
    return null;
  }
}