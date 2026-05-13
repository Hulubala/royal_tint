import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

void main() async {
  final serviceAccountPath = 'assets/service-account-key.json';

  if (!File(serviceAccountPath).existsSync()) {
    print('❌ Error: service-account-key.json not found.');
    return;
  }

  // FIX 1: Use initializeApp instead of .credential
  // The first argument is a name for the app (e.g., 'royal-tint')
  final admin = FirebaseAdminApp.initializeApp(
    'royal-tint-digital-platform', 
    Credential.fromServiceAccount(File(serviceAccountPath)),
  );

  final firestore = Firestore(admin);
  
  try {
    print('🚀 Starting migration...');
    
    final staffCollection = firestore.collection('staff');
    final snapshot = await staffCollection.get();
    
    int updatedCount = 0;

    for (var doc in snapshot.docs) {
      print('Updating: ${doc.id}');
      
      // FIX 2: Remove the () from FieldValue.delete
      await staffCollection.doc(doc.id).update({
        'expertise': FieldValue.delete,
        'rating': FieldValue.delete,
        'totalRatings': FieldValue.delete,
        'profileImage': FieldValue.delete,
      });
      
      updatedCount++;
    }

    print('\n✅ Success: Updated $updatedCount staff records.');
  } catch (e) {
    print('❌ Migration failed: $e');
  } finally {
    await admin.close();
    exit(0);
  }
}