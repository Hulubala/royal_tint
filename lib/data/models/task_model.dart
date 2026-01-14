import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskID;
  final String branchID;
  final String title;
  final String description;
  final String assignedStaffID;
  final String assignedStaffName;
  final String? assignedByManagerID;
  final String? assignedByManagerName;
  final String appointmentID;
  final String customerName;
  final String vehicleModel;
  final String packageName;
  final String status; // PENDING, IN_PROGRESS, COMPLETED, CANCELLED
  final String priority; // LOW, MEDIUM, HIGH, URGENT
  final DateTime dueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final List<String>? attachments;
  final Map<String, dynamic>? taskDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.taskID,
    required this.branchID,
    required this.title,
    required this.description,
    required this.assignedStaffID,
    required this.assignedStaffName,
    this.assignedByManagerID,
    this.assignedByManagerName,
    required this.appointmentID,
    required this.customerName,
    required this.vehicleModel,
    required this.packageName,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.attachments,
    this.taskDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter for id (alias for taskID)
  String get id => taskID;

  // Check if task is overdue
  bool get isOverdue {
    if (status == 'COMPLETED' || status == 'CANCELLED') return false;
    return DateTime.now().isAfter(dueDate);
  }

  // Check if task is pending
  bool get isPending => status == 'PENDING';

  // Check if task is in progress
  bool get isInProgress => status == 'IN_PROGRESS';

  // Check if task is completed
  bool get isCompleted => status == 'COMPLETED';

  // Check if task is cancelled
  bool get isCancelled => status == 'CANCELLED';

  // Get priority color
  String get priorityColor {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return '#F44336'; // Red
      case 'HIGH':
        return '#FF9800'; // Orange
      case 'MEDIUM':
        return '#FFC107'; // Yellow
      case 'LOW':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status color
  String get statusColor {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return '#4CAF50'; // Green
      case 'IN_PROGRESS':
        return '#2196F3'; // Blue
      case 'PENDING':
        return '#FFC107'; // Yellow
      case 'CANCELLED':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get time until due
  String get timeUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      final overdue = now.difference(dueDate);
      if (overdue.inDays > 0) return '${overdue.inDays} days overdue';
      if (overdue.inHours > 0) return '${overdue.inHours} hours overdue';
      return '${overdue.inMinutes} minutes overdue';
    }
    
    if (difference.inDays > 0) return '${difference.inDays} days left';
    if (difference.inHours > 0) return '${difference.inHours} hours left';
    return '${difference.inMinutes} minutes left';
  }

  // From Firestore
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TaskModel(
      taskID: doc.id,
      branchID: data['branchID'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedStaffID: data['assignedStaffID'] ?? '',
      assignedStaffName: data['assignedStaffName'] ?? '',
      assignedByManagerID: data['assignedByManagerID'],
      assignedByManagerName: data['assignedByManagerName'],
      appointmentID: data['appointmentID'] ?? '',
      customerName: data['customerName'] ?? '',
      vehicleModel: data['vehicleModel'] ?? '',
      packageName: data['packageName'] ?? '',
      status: data['status'] ?? 'PENDING',
      priority: data['priority'] ?? 'MEDIUM',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      attachments: data['attachments'] != null 
          ? List<String>.from(data['attachments']) 
          : null,
      taskDetails: data['taskDetails'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // From Map
  factory TaskModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TaskModel(
      taskID: documentId,
      branchID: data['branchID'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedStaffID: data['assignedStaffID'] ?? '',
      assignedStaffName: data['assignedStaffName'] ?? '',
      assignedByManagerID: data['assignedByManagerID'],
      assignedByManagerName: data['assignedByManagerName'],
      appointmentID: data['appointmentID'] ?? '',
      customerName: data['customerName'] ?? '',
      vehicleModel: data['vehicleModel'] ?? '',
      packageName: data['packageName'] ?? '',
      status: data['status'] ?? 'PENDING',
      priority: data['priority'] ?? 'MEDIUM',
      dueDate: data['dueDate'] is Timestamp 
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.parse(data['dueDate'] ?? DateTime.now().toIso8601String()),
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] is Timestamp
              ? (data['startedAt'] as Timestamp).toDate()
              : DateTime.parse(data['startedAt']))
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] is Timestamp
              ? (data['completedAt'] as Timestamp).toDate()
              : DateTime.parse(data['completedAt']))
          : null,
      notes: data['notes'],
      attachments: data['attachments'] != null 
          ? List<String>.from(data['attachments']) 
          : null,
      taskDetails: data['taskDetails'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'branchID': branchID,
      'title': title,
      'description': description,
      'assignedStaffID': assignedStaffID,
      'assignedStaffName': assignedStaffName,
      'assignedByManagerID': assignedByManagerID,
      'assignedByManagerName': assignedByManagerName,
      'appointmentID': appointmentID,
      'customerName': customerName,
      'vehicleModel': vehicleModel,
      'packageName': packageName,
      'status': status,
      'priority': priority,
      'dueDate': Timestamp.fromDate(dueDate),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
      'attachments': attachments,
      'taskDetails': taskDetails,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'taskID': taskID,
      'branchID': branchID,
      'title': title,
      'description': description,
      'assignedStaffID': assignedStaffID,
      'assignedStaffName': assignedStaffName,
      'assignedByManagerID': assignedByManagerID,
      'assignedByManagerName': assignedByManagerName,
      'appointmentID': appointmentID,
      'customerName': customerName,
      'vehicleModel': vehicleModel,
      'packageName': packageName,
      'status': status,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'attachments': attachments,
      'taskDetails': taskDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  TaskModel copyWith({
    String? taskID,
    String? branchID,
    String? title,
    String? description,
    String? assignedStaffID,
    String? assignedStaffName,
    String? assignedByManagerID,
    String? assignedByManagerName,
    String? appointmentID,
    String? customerName,
    String? vehicleModel,
    String? packageName,
    String? status,
    String? priority,
    DateTime? dueDate,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? taskDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      taskID: taskID ?? this.taskID,
      branchID: branchID ?? this.branchID,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedStaffID: assignedStaffID ?? this.assignedStaffID,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      assignedByManagerID: assignedByManagerID ?? this.assignedByManagerID,
      assignedByManagerName: assignedByManagerName ?? this.assignedByManagerName,
      appointmentID: appointmentID ?? this.appointmentID,
      customerName: customerName ?? this.customerName,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      packageName: packageName ?? this.packageName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      taskDetails: taskDetails ?? this.taskDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $taskID, title: $title, status: $status, assignedTo: $assignedStaffName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.taskID == taskID;
  }

  @override
  int get hashCode => taskID.hashCode;
}

// Task Status Constants
class TaskStatus {
  static const String pending = 'PENDING';
  static const String inProgress = 'IN_PROGRESS';
  static const String completed = 'COMPLETED';
  static const String cancelled = 'CANCELLED';
  
  static List<String> get all => [pending, inProgress, completed, cancelled];
}

// Task Priority Constants
class TaskPriority {
  static const String low = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high = 'HIGH';
  static const String urgent = 'URGENT';
  
  static List<String> get all => [low, medium, high, urgent];
}