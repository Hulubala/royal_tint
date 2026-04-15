import 'package:flutter/foundation.dart';

class ManagerShellProvider extends ChangeNotifier {
  int _unreadNotifications = 0;

  int get unreadNotifications => _unreadNotifications;

  void setUnreadNotifications(int value) {
    _unreadNotifications = value;
    notifyListeners();
  }

  void clear() {
    _unreadNotifications = 0;
    notifyListeners();
  }
}