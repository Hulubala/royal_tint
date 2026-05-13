import 'package:shared_preferences/shared_preferences.dart';
import 'user_role.dart';

class RoleStorage {
  static const _kRole = 'user_role';

  static Future<void> setRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRole, role.key);
  }

  static Future<UserRole?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return UserRoleX.fromKey(prefs.getString(_kRole));
  }

  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRole);
  }
}