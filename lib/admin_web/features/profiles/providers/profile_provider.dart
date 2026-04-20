// lib/admin_web/features/profiles/providers/profile_provider.dart
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/profiles/models/manager_profile.dart';
import 'package:royal_tint/admin_web/features/profiles/models/branch_settings.dart';
import 'package:royal_tint/admin_web/features/profiles/services/profile_service.dart';


class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;

  ProfileProvider({ProfileService? service})
      : _service = service ?? ProfileService();

  ManagerProfile? manager;
  BranchSettings? branch;

  bool isLoading = false;
  bool savingAccount = false;
  bool savingShop = false;
  bool sendingReset = false;

  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      manager = await _service.fetchManagerProfile();
      branch = await _service.fetchBranchSettings(manager!.branchID);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> saveAccountSettings({
    required String name,
    required String phone,
  }) async {
    savingAccount = true;
    notifyListeners();
    try {
      await _service.updateAccountSettings(name: name, phone: phone);
      // refresh local state
      manager = await _service.fetchManagerProfile();
      return null; // success
    } catch (e) {
      return e.toString();
    } finally {
      savingAccount = false;
      notifyListeners();
    }
  }

  Future<String?> sendResetPassword() async {
    if (manager == null) return 'Manager profile not loaded';
    sendingReset = true;
    notifyListeners();
    try {
      await _service.sendPasswordResetEmail(manager!.email);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      sendingReset = false;
      notifyListeners();
    }
  }

  Future<String?> saveShopSettings({
    required String supportPhone,
    required Map<String, String> operatingHours,
  }) async {
    if (manager == null) return 'Manager profile not loaded';
    savingShop = true;
    notifyListeners();
    try {
      await _service.updateShopSettings(
        branchID: manager!.branchID,
        supportPhone: supportPhone,
        operatingHours: operatingHours,
      );
      branch = await _service.fetchBranchSettings(manager!.branchID);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      savingShop = false;
      notifyListeners();
    }
  }
}