/// Firebase Collection and Field Constants
/// 
/// This file contains all Firebase Firestore collection names and common field names
/// to maintain consistency across the app and avoid typos.

class FirebaseConstants {
  // Private constructor to prevent instantiation
  FirebaseConstants._();

  // ============================================
  // COLLECTION NAMES
  // ============================================
  
  /// Users collection - stores all user accounts
  static const String usersCollection = 'users';
  
  /// Customers collection - stores customer profiles
  static const String customersCollection = 'customers';
  
  /// Managers collection - stores manager accounts
  static const String managersCollection = 'managers';
  
  /// Staff collection - stores staff accounts
  static const String staffCollection = 'staff';
  
  /// Branches collection - stores branch information
  static const String branchesCollection = 'branches';
  
  /// Appointments collection - stores all appointments
  static const String appointmentsCollection = 'appointments';
  
  /// Tasks collection - stores staff tasks
  static const String tasksCollection = 'tasks';
  
  /// Packages collection - stores available tint packages
  static const String packagesCollection = 'packages';
  
  /// Feedback collection - stores customer feedback
  static const String feedbackCollection = 'feedback';
  
  /// Sales Reports collection - stores sales data
  static const String salesReportsCollection = 'sales_reports';
  
  /// Vehicles collection - stores customer vehicles
  static const String vehiclesCollection = 'vehicles';
  
  /// System collection - stores system configuration
  static const String systemCollection = 'system';
  
  /// Notifications collection - stores user notifications
  static const String notificationsCollection = 'notifications';

  // ============================================
  // COMMON FIELD NAMES
  // ============================================
  
  /// Common field: Document ID
  static const String fieldId = 'id';
  
  /// Common field: Branch ID
  static const String fieldBranchId = 'branchID';
  
  /// Common field: User ID
  static const String fieldUserId = 'userID';
  
  /// Common field: Customer ID
  static const String fieldCustomerId = 'customerID';
  
  /// Common field: Manager ID
  static const String fieldManagerId = 'managerID';
  
  /// Common field: Staff ID
  static const String fieldStaffId = 'staffID';
  
  /// Common field: Created At timestamp
  static const String fieldCreatedAt = 'createdAt';
  
  /// Common field: Updated At timestamp
  static const String fieldUpdatedAt = 'updatedAt';
  
  /// Common field: Status
  static const String fieldStatus = 'status';
  
  /// Common field: Email
  static const String fieldEmail = 'email';
  
  /// Common field: Phone
  static const String fieldPhone = 'phone';
  
  /// Common field: Name
  static const String fieldName = 'name';
  
  /// Common field: Role
  static const String fieldRole = 'role';
  
  /// Common field: UID (Firebase Auth User ID)
  static const String fieldUid = 'uid';

  // ============================================
  // APPOINTMENT STATUS VALUES
  // ============================================
  
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  // ============================================
  // USER ROLES
  // ============================================
  
  static const String roleCustomer = 'customer';
  static const String roleManager = 'manager';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';

  // ============================================
  // TASK STATUS VALUES
  // ============================================
  
  static const String taskStatusAssigned = 'assigned';
  static const String taskStatusInProgress = 'in_progress';
  static const String taskStatusCompleted = 'completed';
  
  // ============================================
  // VEHICLE TYPES
  // ============================================
  
  static const String vehicleTypeSedan = 'sedan';
  static const String vehicleTypeSuv = 'suv';
  static const String vehicleTypeMpv = 'mpv';

  // ============================================
  // STORAGE PATHS
  // ============================================
  
  /// Storage path for user profile images
  static const String storageProfileImages = 'profile_images';
  
  /// Storage path for vehicle images
  static const String storageVehicleImages = 'vehicle_images';
  
  /// Storage path for package images
  static const String storagePackageImages = 'package_images';
  
  /// Storage path for documents
  static const String storageDocuments = 'documents';
}