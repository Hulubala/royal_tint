import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:royal_tint/data/repositories/auth_repository.dart';
import 'package:royal_tint/domain/models/user/user_model.dart';
import 'package:royal_tint/domain/models/user/manager_model.dart';

enum PasswordResetResult { sent, emailNotFound, authUserNotFound, invalidEmail, tooManyRequests, networkError, failed }

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

      final result = await _authRepository.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      _firebaseUser = result['user'] as User?;
      _user = result['userData'] as UserModel?;
      _manager = result['managerData'] as ManagerModel?;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.code;
      notifyListeners();

      if (kDebugMode) {
          print('LOGIN ERROR: code=${e.code}, message=${e.message}');
      }
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      if (kDebugMode) {
        print('LOGIN ERROR (non-firebase): $e');
      }
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

  String passwordResetResultMessage(PasswordResetResult result) {
    switch (result) {
      case PasswordResetResult.sent:
        return 'Reset email sent. Please check your inbox.';
      case PasswordResetResult.emailNotFound:
        return 'Email not found. Please check your email address.';
      case PasswordResetResult.invalidEmail:
        return 'Invalid email address.';
      case PasswordResetResult.tooManyRequests:
        return 'Too many attempts. Please try again later.';
      case PasswordResetResult.networkError:
        return 'Network error. Please check your connection.';
      case PasswordResetResult.failed:
      default:
        // If errorMessage is a Firebase code like "invalid-email",
        // convert to user-friendly text:
        return getUserFriendlyError(_errorMessage ?? 'unknown');
    }
  }

  void _logReset(PasswordResetResult result) {
    if (kDebugMode) {
      print('RESET (friendly): ${passwordResetResultMessage(result)}');
      if (_errorMessage != null) {
        print('RESET (debug): errorMessage=$_errorMessage');
      }
    }
  }

 /// Request password reset with 3 outcomes:
  Future<PasswordResetResult> requestPasswordReset({
    required String email,
    required String continueUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Normalize
      final normalizedEmail = email.trim().toLowerCase();

      // 1) Check manager email exists in Firestore (guarantee emailNotFound)
      final exists = await _authRepository.managerEmailExists(normalizedEmail);
      if (!exists) {
        final result = PasswordResetResult.emailNotFound;
        _isLoading = false;
        notifyListeners();
        _logReset(result);
        return result;
      }

      // 2) Send reset email with continue URL (return to login after reset)
      await _authRepository.sendPasswordResetEmail(
        email: normalizedEmail,
        continueUrl: continueUrl,
      );
        
      final result = PasswordResetResult.sent;
      _isLoading = false;
      notifyListeners();
      _logReset(result);
      return result;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('RESET ERROR: code=${e.code}, message=${e.message}');
      }
      _errorMessage = e.code;
      _isLoading = false;
      notifyListeners();

      late final PasswordResetResult result;
    switch (e.code) {
        case 'invalid-email':
          result = PasswordResetResult.invalidEmail;
          break;
        case 'network-request-failed':
          result = PasswordResetResult.networkError;
          break;
        case 'too-many-requests':
          result = PasswordResetResult.tooManyRequests;
          break;
        case 'invalid-continue-uri':
        case 'unauthorized-continue-uri':
          result = PasswordResetResult.failed;
          break;
        default:
          result = PasswordResetResult.failed;
      }

      _logReset(result);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('RESET ERROR (non-firebase): $e');
      }

      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      final result = PasswordResetResult.failed;
      _logReset(result);
      return result;
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
    switch (error) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-email':
        return 'Invalid email address';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}