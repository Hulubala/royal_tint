import 'package:cloud_firestore/cloud_firestore.dart';

/// Tint Package Model
/// Matches the package structure created in Firebase setup
class TintPackageModel {
  final String packageID;
  final String packageName;
  final String description;
  final double originalPrice;
  final String filmType;
  final String heatRejection; // IRR - Infrared Rejection
  final String uvRejection;   // UVR - UV Rejection
  final List<String> darknessOptions; // VLT options
  final String thickness;
  final String warranty;
  final Map<String, int> duration; // Duration by vehicle type (minutes)
  final bool isActive;
  final List<String> freeItems;
  final Map<String, double> pricing; // Price by vehicle type
  final List<String> features;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TintPackageModel({
    required this.packageID,
    required this.packageName,
    required this.description,
    required this.originalPrice,
    required this.filmType,
    required this.heatRejection,
    required this.uvRejection,
    required this.darknessOptions,
    required this.thickness,
    required this.warranty,
    required this.duration,
    this.isActive = true,
    required this.freeItems,
    required this.pricing,
    required this.features,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from Firestore document
  factory TintPackageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TintPackageModel(
      packageID: data['packageID'] ?? doc.id,
      packageName: data['packageName'] ?? '',
      description: data['description'] ?? '',
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      filmType: data['filmType'] ?? '',
      heatRejection: data['heatRejection'] ?? '',
      uvRejection: data['uvRejection'] ?? '',
      darknessOptions: List<String>.from(data['darknessOptions'] ?? []),
      thickness: data['thickness'] ?? '',
      warranty: data['warranty'] ?? '',
      duration: Map<String, int>.from(data['duration'] ?? {}),
      isActive: data['isActive'] ?? true,
      freeItems: List<String>.from(data['freeItems'] ?? []),
      pricing: Map<String, double>.from(
        (data['pricing'] ?? {}).map((key, value) => 
          MapEntry(key.toString(), (value as num).toDouble())
        )
      ),
      features: List<String>.from(data['features'] ?? []),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'packageID': packageID,
      'packageName': packageName,
      'description': description,
      'originalPrice': originalPrice,
      'filmType': filmType,
      'heatRejection': heatRejection,
      'uvRejection': uvRejection,
      'darknessOptions': darknessOptions,
      'thickness': thickness,
      'warranty': warranty,
      'duration': duration,
      'isActive': isActive,
      'freeItems': freeItems,
      'pricing': pricing,
      'features': features,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get price for specific vehicle type
  double getPriceForVehicle(String vehicleType) {
    return pricing[vehicleType.toLowerCase()] ?? 0.0;
  }

  /// Get duration for specific vehicle type (in minutes)
  int getDurationForVehicle(String vehicleType) {
    return duration[vehicleType.toLowerCase()] ?? 60;
  }

  /// Get duration for specific vehicle type (as Duration object)
  Duration getDurationObjectForVehicle(String vehicleType) {
    int minutes = getDurationForVehicle(vehicleType);
    return Duration(minutes: minutes);
  }

  /// Calculate discount amount
  double get discountAmount => originalPrice - getLowestPrice();

  /// Calculate discount percentage
  double get discountPercentage {
    if (originalPrice == 0) return 0;
    return ((originalPrice - getLowestPrice()) / originalPrice) * 100;
  }

  /// Get lowest price (sedan price)
  double getLowestPrice() {
    return pricing['sedan'] ?? 0.0;
  }

  /// Get highest price (mpv price)
  double getHighestPrice() {
    return pricing['mpv'] ?? 0.0;
  }

  /// Get formatted price range
  String getPriceRange() {
    double lowest = getLowestPrice();
    double highest = getHighestPrice();
    if (lowest == highest) {
      return 'RM ${lowest.toStringAsFixed(0)}';
    }
    return 'RM ${lowest.toStringAsFixed(0)} - RM ${highest.toStringAsFixed(0)}';
  }

  /// Get formatted original price
  String get formattedOriginalPrice => 'RM ${originalPrice.toStringAsFixed(0)}';

  /// Get formatted duration range
  String getDurationRange() {
    int sedanDuration = duration['sedan'] ?? 60;
    int mpvDuration = duration['mpv'] ?? 120;
    
    if (sedanDuration == mpvDuration) {
      return '$sedanDuration minutes';
    }
    
    return '$sedanDuration-$mpvDuration minutes';
  }

  /// Get all darkness options as formatted string
  String get darknessOptionsText {
    if (darknessOptions.isEmpty) return 'N/A';
    return darknessOptions.join(', ');
  }

  /// Get free items as formatted string
  String get freeItemsText {
    if (freeItems.isEmpty) return 'None';
    return freeItems.join(', ');
  }

  /// Create a copy with updated fields
  TintPackageModel copyWith({
    String? packageID,
    String? packageName,
    String? description,
    double? originalPrice,
    String? filmType,
    String? heatRejection,
    String? uvRejection,
    List<String>? darknessOptions,
    String? thickness,
    String? warranty,
    Map<String, int>? duration,
    bool? isActive,
    List<String>? freeItems,
    Map<String, double>? pricing,
    List<String>? features,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TintPackageModel(
      packageID: packageID ?? this.packageID,
      packageName: packageName ?? this.packageName,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      filmType: filmType ?? this.filmType,
      heatRejection: heatRejection ?? this.heatRejection,
      uvRejection: uvRejection ?? this.uvRejection,
      darknessOptions: darknessOptions ?? this.darknessOptions,
      thickness: thickness ?? this.thickness,
      warranty: warranty ?? this.warranty,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      freeItems: freeItems ?? this.freeItems,
      pricing: pricing ?? this.pricing,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// For debugging
  @override
  String toString() {
    return 'TintPackageModel(packageID: $packageID, packageName: $packageName, priceRange: ${getPriceRange()})';
  }
}