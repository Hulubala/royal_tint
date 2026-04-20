// lib/admin_web/features/profiles/models/manager_profile.dart
class ManagerProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String branchID;
  final String branchName;

  ManagerProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.branchID,
    required this.branchName,
  });

  factory ManagerProfile.fromMap(Map<String, dynamic> map) {
    return ManagerProfile(
      uid: (map['uid'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      branchID: (map['branchID'] ?? '') as String,
      branchName: (map['branchName'] ?? '') as String,
    );
  }
}