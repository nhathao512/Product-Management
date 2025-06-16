import 'package:flutter/material.dart';
import '../../data/models/auth_models.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _error = '';
  User? _currentUser;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String get error => _error;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isAuthenticated = await _authService.isLoggedIn();
      if (_isAuthenticated) {
        _currentUser = await _authService.getUser();
      }
    } catch (e) {
      _error = 'Lỗi kiểm tra trạng thái: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String userName, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final request = LoginRequest(userName: userName, password: password);
      final response = await _authService.login(request);

      if (response.success && response.data != null) {
        _isAuthenticated = true;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi mạng: ${e.toString()}';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String userName, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final request = RegisterRequest(
        userName: userName,
        email: email,
        password: password,
      );
      final response = await _authService.register(request);

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _authService.saveUser(_currentUser!);
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi mạng: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _currentUser = null;
    _error = '';
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
