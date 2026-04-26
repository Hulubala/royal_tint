import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentID;
  final String customerID;
  final String customerName;
  final String? customerPhone;
  final String branchID;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleType;
  final String vehiclePlate;
  final String packageID;
  final String packageName;
  final Map<String, String> tintSelections;
  final String appointmentDate;
  final String appointmentTime;
  final String appointmentType;
  final int estimatedDuration;
  final String status;
  final String? assignedStaffID;
  final String? notes;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.appointmentID,
    required this.customerID,
    required this.customerName,
    this.customerPhone,
    required this.branchID,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.packageID,
    required this.packageName,
    required this.tintSelections,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentType,
    required this.estimatedDuration,
    required this.status,
    this.assignedStaffID,
    this.notes,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  String get id => appointmentID;

  String get vehicleDisplay => '$vehiclePlate • $vehicleBrand $vehicleModel';

  DateTime get appointmentDateTime {
    DateTime date;

    try {
      date = DateTime.parse(appointmentDate);
    } catch (_) {
      final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$')
          .firstMatch(appointmentDate.trim());
      if (m == null) {
        date = DateTime(1970, 1, 1);
      } else {
        final dd = int.parse(m.group(1)!);
        final mm = int.parse(m.group(2)!);
        final yyyy = int.parse(m.group(3)!);
        date = DateTime(yyyy, mm, dd);
      }
    }

    final t = appointmentTime.trim().toUpperCase();

    final hm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
    if (hm != null) {
      final h = int.parse(hm.group(1)!);
      final min = int.parse(hm.group(2)!);
      return DateTime(date.year, date.month, date.day, h, min);
    }

    final ampm = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(t);
    if (ampm != null) {
      var h = int.parse(ampm.group(1)!);
      final min = int.parse(ampm.group(2)!);
      final ap = ampm.group(3)!;

      if (ap == 'PM' && h != 12) h += 12;
      if (ap == 'AM' && h == 12) h = 0;

      return DateTime(date.year, date.month, date.day, h, min);
    }
    
    return DateTime(date.year, date.month, date.day);
  }

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final tintRaw = (data['tintSelections'] as Map?)?.cast<String, dynamic>() ?? {};
    final tintSelections = <String, String>{};

    for (final e in tintRaw.entries) {
      tintSelections[e.key] = e.value?.toString() ?? '';
    }
    
    print('🔍 Parsing appointment: ${doc.id}');
    print('📋 Raw data keys: ${data.keys.toList()}');
    
    final vehicleInfo = data['vehicleInfo'] as Map<String, dynamic>?;
    
    String vehicleBrand = '';
    String vehicleModel = '';
    String vehicleType = '';
    String vehiclePlate = '';
    
    if (vehicleInfo != null) {
      print('✅ Using NESTED vehicleInfo structure');
      vehicleBrand = vehicleInfo['brand'] ?? '';
      vehicleModel = vehicleInfo['model'] ?? '';
      vehicleType = vehicleInfo['type'] ?? '';
      vehiclePlate = vehicleInfo['plateNumber'] ?? vehicleInfo['plate'] ?? '';
    } else {
      print('✅ Using FLAT field structure');
      vehicleBrand = data['vehicleBrand'] ?? '';
      vehicleModel = data['vehicleModel'] ?? '';
      vehicleType = data['vehicleType'] ?? '';
      vehiclePlate = data['vehiclePlate'] ?? data['plateNumber'] ?? '';
    }
    
    print('🚗 Vehicle parsed: $vehicleBrand $vehicleModel ($vehicleType) - $vehiclePlate');
    
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    
    try {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt']);
      }
    } catch (e) {
      print('⚠️ Error parsing createdAt: $e');
    }
    
    try {
      if (data['updatedAt'] is Timestamp) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      } else if (data['updatedAt'] is String) {
        updatedAt = DateTime.parse(data['updatedAt']);
      }
    } catch (e) {
      print('⚠️ Error parsing updatedAt: $e');
    }
    
    final model = AppointmentModel(
      appointmentID: doc.id,
      customerID: data['customerID'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'],
      branchID: data['branchID'] ?? '',
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
      packageID: data['packageID'] ?? '',
      packageName: data['packageName'] ?? '',
      tintSelections: tintSelections,
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      appointmentType: data['appointmentType'] ?? 'scheduled',
      estimatedDuration: data['estimatedDuration'] ?? 0,
      status: data['status'] ?? 'pending',
      assignedStaffID: data['assignedStaffID'],
      notes: data['notes'],
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    
    print('✅ Appointment parsed successfully: ${model.customerName}');
    return model;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerID': customerID,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'branchID': branchID,
      'vehicleInfo': {
        'brand': vehicleBrand,
        'model': vehicleModel,
        'type': vehicleType,
        'plateNumber': vehiclePlate,
      },
      'packageID': packageID,
      'packageName': packageName,
      'tintSelections': tintSelections,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'appointmentType': appointmentType,
      'estimatedDuration': estimatedDuration,
      'status': status,
      'assignedStaffID': assignedStaffID,
      'notes': notes,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppointmentModel copyWith({
    String? appointmentID,
    String? customerID,
    String? customerName,
    String? customerPhone,
    String? branchID,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleType,
    String? vehiclePlate,
    String? packageID,
    String? packageName,
    Map<String, String>? tintSelections,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    int? estimatedDuration,
    String? status,
    String? assignedStaffID,
    String? notes,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      appointmentID: appointmentID ?? this.appointmentID,
      customerID: customerID ?? this.customerID,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      branchID: branchID ?? this.branchID,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      packageID: packageID ?? this.packageID,
      packageName: packageName ?? this.packageName,
      tintSelections: tintSelections ?? this.tintSelections,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      appointmentType: appointmentType ?? this.appointmentType,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      assignedStaffID: assignedStaffID ?? this.assignedStaffID,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}