class StaffMember {
  final String id;
  final String name;
  final bool isAvailable;
  final int currentTaskCount;

  StaffMember({
    required this.id,
    required this.name,
    required this.isAvailable,
    required this.currentTaskCount,
  });

  factory StaffMember.fromMap(String id, Map<String, dynamic> map) {
    return StaffMember(
      id: id,
      name: (map['name'] ?? '') as String,
      isAvailable: (map['isAvailable'] ?? false) as bool,
      currentTaskCount: (map['currentTaskCount'] ?? 0) as int,
    );
  }
}