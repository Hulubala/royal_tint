import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Fetch the saved user role (customer by default)
  static Future<bool> getUserRoleFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isCustomer') ?? true; // Default to customer role
  }

  // Save the user role
  static Future<void> saveUserRole(bool isCustomer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCustomer', isCustomer);
  }
}