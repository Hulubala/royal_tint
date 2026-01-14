import 'package:royal_tint/setup/branch_setup.dart';
import 'package:royal_tint/setup/manager_setup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Main setup orchestrator for Royal Tint Firebase initialization
class InitialSetup {
  final BranchSetup _branchSetup = BranchSetup();
  final ManagerSetup _managerSetup = ManagerSetup();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if setup has already been completed
  Future<bool> isSetupComplete() async {
    try {
      // Check if setup document exists
      DocumentSnapshot setupDoc = await _firestore
          .collection('system')
          .doc('setup_status')
          .get();

      if (setupDoc.exists) {
        Map<String, dynamic> data = setupDoc.data() as Map<String, dynamic>;
        return data['isComplete'] ?? false;
      }

      return false;
    } catch (e) {
      print('Error checking setup status: $e');
      return false;
    }
  }

  /// Mark setup as complete
  Future<void> markSetupComplete() async {
    try {
      await _firestore.collection('system').doc('setup_status').set({
        'isComplete': true,
        'setupDate': FieldValue.serverTimestamp(),
        'version': '1.0.0',
      });
      print('✅ Setup marked as complete');
    } catch (e) {
      print('❌ Error marking setup complete: $e');
      rethrow;
    }
  }

  /// Run the complete setup process
  /// This will:
  /// 1. Create branches
  /// 2. Create manager accounts
  /// 3. Create initial tint packages (optional)
  /// 4. Mark setup as complete
  Future<Map<String, dynamic>> runCompleteSetup({
    Function(String)? onProgress,
  }) async {
    List<String> logs = [];
    bool success = false;

    try {
      // Check if already setup
      onProgress?.call('Checking setup status...');
      logs.add('🔍 Checking if setup has already been completed...');

      bool alreadySetup = await isSetupComplete();
      if (alreadySetup) {
        onProgress?.call('⚠️  Setup already completed');
        logs.add('⚠️  Setup has already been completed previously');
        logs.add('   If you want to re-run setup, delete the setup_status document');
        logs.add('   from Firebase Console: Firestore > system > setup_status');
        return {
          'success': false,
          'logs': logs,
          'message': 'Setup already completed',
        };
      }

      logs.add('✅ No previous setup found, proceeding...');
      logs.add('');

      // STEP 1: Setup Branches
      onProgress?.call('Creating branches...');
      logs.add('📍 STEP 1: Creating Branches');
      logs.add('─' * 50);
      
      await _branchSetup.setupDefaultBranches();
      
      logs.add('✅ Royal Tint Melaka');
      logs.add('✅ Royal Tint Seremban 2');
      logs.add('');

      // STEP 2: Setup Managers
      onProgress?.call('Creating manager accounts...');
      logs.add('👤 STEP 2: Creating Manager Accounts');
      logs.add('─' * 50);
      
      await _managerSetup.setupDefaultManagers();
      
      logs.add('✅ Steven Ting (steven.melaka@royaltint.com)');
      logs.add('✅ Alex Tan (alex.seremban2@royaltint.com)');
      logs.add('');

      // STEP 3: Setup Tint Packages (Optional)
      onProgress?.call('Creating tint packages...');
      logs.add('📦 STEP 3: Creating Default Tint Packages');
      logs.add('─' * 50);
      
      await _setupDefaultPackages();
      
      logs.add('✅ Package A (Dyed Film)');
      logs.add('✅ Package B (HD Dyed Carbon Film & Dyed Film)');
      logs.add('✅ Package C (HD Dyed Carbon Film)');
      logs.add('✅ Package D (HD Nano Ceramic Film & HD Dyed Carbon Film)');
      logs.add('✅ Package E (HD Nano Ceramic Film)');
      logs.add('');

      // STEP 4: Mark Setup Complete
      onProgress?.call('Finalizing setup...');
      logs.add('✅ STEP 4: Finalizing Setup');
      logs.add('─' * 50);
      
      await markSetupComplete();
      
      logs.add('✅ Setup marked as complete');
      logs.add('');

      // SUCCESS - Set success to true
      success = true;
      onProgress?.call('✅ Setup Complete!');
      logs.add('🎉 SETUP COMPLETE!');
      logs.add('═' * 50);
      logs.add('');
      logs.add('You can now:');
      logs.add('1. Login to the manager portal');
      logs.add('2. Use the following credentials:');
      logs.add('');
      logs.add('   Melaka Branch:');
      logs.add('   📧 Email: steven.melaka@royaltint.com');
      logs.add('   🔑 Password: RoyalTint123!');
      logs.add('');
      logs.add('   Seremban 2 Branch:');
      logs.add('   📧 Email: alex.seremban2@royaltint.com');
      logs.add('   🔑 Password: RoyalTint123!');
      logs.add('');
      logs.add('⚠️  IMPORTANT: Change passwords after first login!');

      return {
        'success': success,
        'logs': logs,
        'message': 'Setup completed successfully!',
      };

    } catch (e) {
      onProgress?.call('❌ Setup failed');
      logs.add('');
      logs.add('❌ ERROR OCCURRED');
      logs.add('═' * 50);
      logs.add('Error: $e');
      logs.add('');
      logs.add('Please check:');
      logs.add('1. Firebase is properly configured');
      logs.add('2. Firestore database is created');
      logs.add('3. Firebase Authentication is enabled');

      return {
        'success': success,
        'logs': logs,
        'message': 'Setup failed: $e',
      };
    }
  }

  /// Setup default tint packages based on Royal Tint Monthly Promotion
  Future<void> _setupDefaultPackages() async {
    try {
      // Package A - Dyed Film
      await _firestore.collection('packages').doc('package_a').set({
        'packageID': 'package_a',
        'packageName': 'Package A',
        'description': 'Full Car Tinted with Dyed Film',
        'originalPrice': 499.00,
        'filmType': 'Dyed Film',
        'heatRejection': 'IRR 35% - 65%',
        'uvRejection': 'UVR 90% - 99%',
        'darknessOptions': ['VLT 50%', 'VLT 35%', 'VLT 20%', 'VLT 05%'],
        'thickness': '2-ply Film',
        'warranty': '2 Years',
        'duration': {
          'sedan': 60,    // minutes
          'suv': 90,      // minutes
          'mpv': 120,     // minutes
        },
        'isActive': true,
        'freeItems': [
          '8" Sun Block',
          'RM50 Voucher',
        ],
        'pricing': {
          'sedan': 148.00,
          'suv': 198.00,
          'mpv': 298.00,
        },
        'features': [
          'Full Car Tinted',
          'Dyed Film',
          'IRR 35% - 65% Heat Rejection',
          'UVR 90% - 99% UV Protection',
          'Multiple Darkness Options',
          '2 Years Warranty',
          'FREE 8" Sun Block',
          'FREE RM50 Voucher',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Package B - HD Dyed Carbon Film & Dyed Film
      await _firestore.collection('packages').doc('package_b').set({
        'packageID': 'package_b',
        'packageName': 'Package B',
        'description': 'Full Car Tinted with HD Dyed Carbon Film & Dyed Film',
        'originalPrice': 999.00,
        'filmType': 'HD Dyed Carbon Film & Dyed Film',
        'heatRejection': 'IRR 50% - 90%',
        'uvRejection': 'UVR 99%',
        'darknessOptions': ['VLT 70%', 'VLT 50%', 'VLT 30%', 'VLT 20%', 'VLT 05%'],
        'thickness': '2-ply Film',
        'warranty': '3 Years',
        'duration': {
          'sedan': 60,    // minutes
          'suv': 90,      // minutes
          'mpv': 120,     // minutes
        },
        'isActive': true,
        'freeItems': [
          '8" Sun Block',
          'RM100 Voucher',
        ],
        'pricing': {
          'sedan': 248.00,
          'suv': 298.00,
          'mpv': 398.00,
        },
        'features': [
          'Full Car Tinted',
          'HD Dyed Carbon Film & Dyed Film',
          'IRR 50% - 90% Heat Rejection',
          'UVR 99% UV Protection',
          'Multiple Darkness Options',
          '3 Years Warranty',
          'FREE 8" Sun Block',
          'FREE RM100 Voucher',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Package C - HD Dyed Carbon Film
      await _firestore.collection('packages').doc('package_c').set({
        'packageID': 'package_c',
        'packageName': 'Package C',
        'description': 'Full Car Tinted with HD Dyed Carbon Film',
        'originalPrice': 1199.00,
        'filmType': 'HD Dyed Carbon Film',
        'heatRejection': 'IRR 90%',
        'uvRejection': 'UVR 99%',
        'darknessOptions': ['VLT 70%', 'VLT 50%', 'VLT 30%', 'VLT 20%', 'VLT 05%'],
        'thickness': '2-ply Film',
        'warranty': '5 Years',
        'duration': {
          'sedan': 60,    // minutes
          'suv': 90,      // minutes
          'mpv': 120,     // minutes
        },
        'isActive': true,
        'freeItems': [
          '8" Sun Block',
          'RM150 Voucher',
        ],
        'pricing': {
          'sedan': 348.00,
          'suv': 448.00,
          'mpv': 498.00,
        },
        'features': [
          'Full Car Tinted',
          'HD Dyed Carbon Film',
          'IRR 90% Heat Rejection',
          'UVR 99% UV Protection',
          'Multiple Darkness Options',
          '5 Years Warranty',
          'FREE 8" Sun Block',
          'FREE RM150 Voucher',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Package D - HD Nano Ceramic Film & HD Dyed Carbon Film
      await _firestore.collection('packages').doc('package_d').set({
        'packageID': 'package_d',
        'packageName': 'Package D',
        'description': 'Full Car Tinted with HD Nano Ceramic Film & HD Dyed Carbon Film',
        'originalPrice': 1499.00,
        'filmType': 'HD Nano Ceramic Film & HD Dyed Carbon Film',
        'heatRejection': 'IRR 90% - 95%',
        'uvRejection': 'UVR 99%',
        'darknessOptions': ['VLT 70%', 'VLT 50%', 'VLT 35%', 'VLT 20%', 'VLT 05%'],
        'thickness': '2-ply Film',
        'warranty': '5 Years',
        'duration': {
          'sedan': 60,    // minutes
          'suv': 90,      // minutes
          'mpv': 120,     // minutes
        },
        'isActive': true,
        'freeItems': [
          '8" Sun Block',
          'RM200 Voucher',
        ],
        'pricing': {
          'sedan': 488.00,
          'suv': 588.00,
          'mpv': 688.00,
        },
        'features': [
          'Full Car Tinted',
          'HD Nano Ceramic Film & HD Dyed Carbon Film',
          'IRR 90% - 95% Heat Rejection',
          'UVR 99% UV Protection',
          'Multiple Darkness Options',
          '5 Years Warranty',
          'FREE 8" Sun Block',
          'FREE RM200 Voucher',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Package E - HD Nano Ceramic Film 
      await _firestore.collection('packages').doc('package_e').set({
        'packageID': 'package_e',
        'packageName': 'Package E',
        'description': 'Full Car Tinted with HD Nano Ceramic Film',
        'originalPrice': 1799.00,
        'filmType': 'HD Nano Ceramic Film',
        'heatRejection': 'IRR 95%',
        'uvRejection': 'UVR 99%',
        'darknessOptions': ['VLT 70%', 'VLT 50%', 'VLT 35%', 'VLT 20%', 'VLT 05%'],
        'thickness': '2-ply Film',
        'warranty': '7 Years',
        'duration': {
          'sedan': 60,    // minutes
          'suv': 90,      // minutes
          'mpv': 120,     // minutes
        },
        'isActive': true,
        'freeItems': [
          '8" Sun Block',
          'RM250 Voucher',
        ],
        'pricing': {
          'sedan': 688.00,
          'suv': 788.00,
          'mpv': 988.00,
        },
        'features': [
          'Full Car Tinted',
          'HD Nano Ceramic Film',
          'IRR 95% Heat Rejection',
          'UVR 99% UV Protection',
          'Multiple Darkness Options',
          '7 Years Warranty',
          'FREE 8" Sun Block',
          'FREE RM250 Voucher',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Default packages created successfully');
    } catch (e) {
      print('❌ Error creating packages: $e');
      rethrow;
    }
  }

  /// Reset setup (WARNING: This will allow setup to run again)
  Future<void> resetSetup() async {
    try {
      await _firestore.collection('system').doc('setup_status').delete();
      print('✅ Setup status reset');
    } catch (e) {
      print('❌ Error resetting setup: $e');
      rethrow;
    }
  }

  /// Get setup information
  Future<Map<String, dynamic>> getSetupInfo() async {
    try {
      bool isComplete = await isSetupComplete();
      
      List<Map<String, dynamic>> branches = await _branchSetup.getAllBranches();
      List<Map<String, dynamic>> managers = await _managerSetup.getAllManagers();

      return {
        'isSetupComplete': isComplete,
        'branchCount': branches.length,
        'managerCount': managers.length,
        'branches': branches,
        'managers': managers,
      };
    } catch (e) {
      print('Error getting setup info: $e');
      return {
        'isSetupComplete': false,
        'branchCount': 0,
        'managerCount': 0,
        'error': e.toString(),
      };
    }
  }
}