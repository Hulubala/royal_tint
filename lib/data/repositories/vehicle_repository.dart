import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepository {
  final FirebaseFirestore _db;
  VehicleRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<VehicleBrand>> watchBrands() => _db
      .collection('vehicle_brands')
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs
          .map((d) => VehicleBrand(brandKey: d.id, name: d['name'] as String))
          .toList());

  Stream<List<VehicleModel>> watchModelsByBrandKey(String brandKey) => _db
      .collection('vehicle_models')
      .where('brandKey', isEqualTo: brandKey)
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs.map((d) {
            final data = d.data();
            return VehicleModel(
              id: d.id,
              brandKey: data['brandKey'] as String,
              brandName: data['brandName'] as String,
              name: data['name'] as String,
              type: data['type'] as String?,
              minutes: (data['minutes'] as num?)?.toInt(),
            );
          }).toList());

  Future<List<VehicleBrand>> getBrands() async {
    final snapshot = await _db.collection('vehicle_brands').get();
    return snapshot.docs.map((d) => VehicleBrand(brandKey: d.id, name: d['name'] as String)).toList();
  }

  Future<List<VehicleModel>> getModelsByBrandKey(String brandKey) async {
    final snapshot = await _db.collection('vehicle_models').where('brandKey', isEqualTo: brandKey).get();
    return snapshot.docs.map((d) {
      final data = d.data();
      return VehicleModel(
        id: d.id,
        brandKey: data['brandKey'] as String,
        brandName: data['brandName'] as String,
        name: data['name'] as String,
        type: data['type'] as String?,
        minutes: (data['minutes'] as num?)?.toInt(),
      );
    }).toList();
  }

  Future<VehicleModel?> getModelById(String modelId) async {
    final doc = await _db.collection('vehicle_models').doc(modelId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return VehicleModel(
      id: doc.id,
      brandKey: data['brandKey'] as String,
      brandName: data['brandName'] as String,
      name: data['name'] as String,
      type: data['type'] as String?,
      minutes: (data['minutes'] as num?)?.toInt(),
    );
  }
}

class VehicleBrand {
  final String brandKey;
  final String name;
  VehicleBrand({required this.brandKey, required this.name});
}

class VehicleModel {
  final String id;
  final String brandKey;
  final String brandName;
  final String name;
  final String? type;
  final int? minutes;
  
  VehicleModel({
    required this.id,
    required this.brandKey,
    required this.brandName,
    required this.name,
    this.type,
    this.minutes,
  });
}