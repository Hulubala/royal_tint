import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class VehicleSeeder {
  static Future<void> seedFromAssets() async {
    final firestore = FirebaseFirestore.instance;

    // one-time guard
    final flagRef = firestore.collection('config').doc('vehicle_seed');
    final flagSnap = await flagRef.get();
    if (flagSnap.exists && (flagSnap.data()?['done'] == true)) {
      throw Exception('Seeding already done (config/vehicle_seed).');
    }

    final csvText = await rootBundle.loadString('assets/seed/vehicles_my.csv');

    final rows = const CsvToListConverter(eol: '\n').convert(csvText);
    if (rows.isEmpty) throw Exception('CSV is empty.');

    final seenBrandKeys = <String>{};
    int insertedBrands = 0;
    int insertedModels = 0;

    WriteBatch batch = firestore.batch();
    int opCount = 0;

    for (int i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.length < 6) continue;

      final brandKey = (r[0] ?? '').toString().trim();
      final brandName = (r[1] ?? '').toString().trim();
      final modelKey = (r[2] ?? '').toString().trim();
      final modelName = (r[3] ?? '').toString().trim();
      final type = (r[4] ?? '').toString().trim(); // Sedan/SUV/MPV
      final minutes = int.tryParse((r[5] ?? '').toString().trim()) ?? 0;

      if (brandKey.isEmpty ||
          brandName.isEmpty ||
          modelKey.isEmpty ||
          modelName.isEmpty ||
          type.isEmpty ||
          minutes <= 0) {
        continue;
      }

      if (seenBrandKeys.add(brandKey)) {
        final brandRef = firestore.collection('vehicle_brands').doc(brandKey);
        batch.set(brandRef, {'name': brandName}, SetOptions(merge: true));
        insertedBrands++;
        opCount++;
      }

      final modelId = '${brandKey}__$modelKey';
      final modelRef = firestore.collection('vehicle_models').doc(modelId);

      batch.set(
        modelRef,
        {
          'brandKey': brandKey,
          'brandName': brandName,
          'name': modelName,
          'searchName': modelName.toLowerCase(),
          'type': type,
          'minutes': minutes,
        },
        SetOptions(merge: true),
      );

      insertedModels++;
      opCount++;

      if (opCount >= 450) {
        await batch.commit();
        batch = firestore.batch();
        opCount = 0;
      }
    }

    if (opCount > 0) await batch.commit();

    await flagRef.set({
      'done': true,
      'seededAt': FieldValue.serverTimestamp(),
      'brands': insertedBrands,
      'models': insertedModels,
    });

    // ignore: avoid_print
    print('✅ Seed done. Brands: $insertedBrands, Models: $insertedModels');
  }
}