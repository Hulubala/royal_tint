import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/data/models/tint_package_model.dart';

/// Service for managing tint packages
class PackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all active packages
  Future<List<TintPackageModel>> getAllPackages() async {
    try {
      final querySnapshot = await _firestore
          .collection('packages')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TintPackageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching packages: $e');
      return [];
    }
  }

  /// Get package by ID
  Future<TintPackageModel?> getPackageById(String packageId) async {
    try {
      final doc = await _firestore.collection('packages').doc(packageId).get();
      
      if (doc.exists) {
        return TintPackageModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching package: $e');
      return null;
    }
  }

  /// Get package by name
  Future<TintPackageModel?> getPackageByName(String packageName) async {
    try {
      final querySnapshot = await _firestore
          .collection('packages')
          .where('packageName', isEqualTo: packageName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return TintPackageModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching package by name: $e');
      return null;
    }
  }

  /// Get package names for dropdown
  Future<List<String>> getPackageNames() async {
    try {
      final packages = await getAllPackages();
      return packages.map((p) => p.packageName).toList();
    } catch (e) {
      print('❌ Error fetching package names: $e');
      return ['Package A', 'Package B', 'Package C', 'Package D', 'Package E']; // Fallback
    }
  }

  /// Calculate price for vehicle type
  double calculatePrice(TintPackageModel package, String vehicleType) {
    return package.getPriceForVehicle(vehicleType);
  }

  /// Get duration for vehicle type
  int getDuration(TintPackageModel package, String vehicleType) {
    return package.getDurationForVehicle(vehicleType);
  }
}