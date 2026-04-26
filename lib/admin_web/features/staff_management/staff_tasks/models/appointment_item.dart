class AppointmentItem {
  final String id; 
  final String customerName;
  final String customerPhone;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String plateNumber;
  final String brand;
  final String model;
  final String packageName;
  final String packageType;
  final Map<String, String> tintSelections;
  final String? assignedStaffID;

  AppointmentItem({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.packageName,
    required this.packageType,
    required this.tintSelections,
    required this.assignedStaffID,
  });

  bool get isAssigned => (assignedStaffID != null && assignedStaffID!.trim().isNotEmpty);

  String get title => '$customerName • $plateNumber';
  String get carInfo => '$brand $model';
  String get compactLabel => '$plateNumber • $packageName • $appointmentDate $appointmentTime';

  factory AppointmentItem.fromMap(String id, Map<String, dynamic> map) {
    final vehicle = (map['vehicleInfo'] as Map?)?.cast<String, dynamic>() ?? {};
    final tintRaw = (map['tintSelections'] as Map?)?.cast<String, dynamic>() ?? {};
    final tintSelections = <String, String>{};
    
    for (final e in tintRaw.entries) {
      tintSelections[e.key] = e.value?.toString() ?? '';
    }
    return AppointmentItem(
      id: id,
      customerName: (map['customerName'] ?? '') as String,
      customerPhone: (map['customerPhone'] ?? '') as String,
      appointmentDate: (map['appointmentDate'] ?? '') as String,
      appointmentTime: (map['appointmentTime'] ?? '') as String,
      status: (map['status'] ?? '') as String,
      plateNumber: (vehicle['plateNumber'] ?? '') as String,
      brand: (vehicle['brand'] ?? '') as String,
      model: (vehicle['model'] ?? '') as String,
      packageName: (map['packageName'] ?? '') as String,
      packageType: (map['packageType'] ?? 'sv'),
      tintSelections: tintSelections,
      assignedStaffID: map['assignedStaffID'] as String?,
    );
  }
}