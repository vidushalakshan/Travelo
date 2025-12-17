import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _errorCode;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError({String message = '', String? code}) {
    _errorMessage = message;
    _errorCode = code;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(message: '', code: null);

    try {
      _currentUser = await _authService.signIn(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is AuthFailure) {
        _setError(message: e.message, code: e.code);
      } else {
        _setError(message: e.toString(), code: null);
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    _setLoading(true);
    _setError(message: '', code: null);

    try {
      _currentUser = await _authService.register(email, password, displayName);
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is AuthFailure) {
        _setError(message: e.message, code: e.code);
      } else {
        _setError(message: e.toString(), code: null);
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(message: '', code: null);

    try {
      await _authService.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is AuthFailure) {
        _setError(message: e.message, code: e.code);
      } else {
        _setError(message: e.toString(), code: null);
      }
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }
}