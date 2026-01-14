import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:royal_tint/data/repositories/auth_repository.dart';
import 'package:royal_tint/data/models/user_model.dart';
import 'package:royal_tint/data/models/manager_model.dart';

/// Authentication Provider
/// Manages user authentication state and user/manager data
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  // Authentication state
  User? _firebaseUser;
  UserModel? _user;
  ManagerModel? _manager;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  ManagerModel? get manager => _manager;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed getters
  bool get isAuthenticated => _firebaseUser != null && _user != null;
  bool get isManager => _user?.isManager ?? false;
  String? get uid => _firebaseUser?.uid;
  String? get email => _user?.email;
  String? get name => _user?.name;
  String? get branchID => _user?.branchID;
  String? get branchName => _manager?.branchName;

  /// Initialize auth provider and listen to auth state changes
  AuthProvider() {
    _initializeAuthListener();
  }

  /// Listen to Firebase Auth state changes
  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      
      if (user != null) {
        // User signed in, load user and manager data
        await _loadUserData(user.uid);
      } else {
        // User signed out, clear data
        _clearUserData();
      }
      
      notifyListeners();
    });
  }

  /// Load user and manager data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load user document
      _user = await _authRepository.getUserData(uid);
      
      // If user is a manager, load manager data
      if (_user?.isManager ?? false) {
        _manager = await _authRepository.getManagerData(uid);
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear user data on sign out
  void _clearUserData() {
    _user = null;
    _manager = null;
    _errorMessage = null;
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      Map<String, dynamic> result = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = result['user'];
      _user = result['userData'];
      _manager = result['managerData'];

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.signOut();
      
      // Clear local data
      _firebaseUser = null;
      _clearUserData();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to sign out: $e';
      notifyListeners();
      debugPrint('Error signing out: $e');
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reload current user data
  Future<void> reloadUserData() async {
    if (_firebaseUser != null) {
      await _loadUserData(_firebaseUser!.uid);
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String getUserFriendlyError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (error.contains('email-already-in-use')) {
      return 'Email already registered';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    } else {
      return 'An error occurred. Please try again';
    }
  }
}