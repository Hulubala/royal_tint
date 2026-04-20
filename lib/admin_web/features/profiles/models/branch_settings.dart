// lib/admin_web/features/profiles/models/branch_settings.dart
class BranchSettings {
  final String branchID;
  final String branchName;
  final String address;
  final String phone;
  final Map<String, String> operatingHours; // monday..sunday

  BranchSettings({
    required this.branchID,
    required this.branchName,
    required this.address,
    required this.phone,
    required this.operatingHours,
  });

  factory BranchSettings.fromMap(String id, Map<String, dynamic> map) {
    final oh = (map['operatingHours'] as Map?)?.cast<String, dynamic>() ?? {};
    return BranchSettings(
      branchID: (map['branchID'] ?? id) as String,
      branchName: (map['branchName'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      operatingHours: oh.map((k, v) => MapEntry(k, (v ?? '').toString())),
    );
  }
}