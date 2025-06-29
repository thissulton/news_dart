import 'package:berita_garut/src/src/controller/auth_controller.dart';
import 'package:berita_garut/src/src/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get token => _token;

  Future<void> initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      _token = token;
      _isAuthenticated = true;

      final userId = prefs.getString('user_id');
      final userEmail = prefs.getString('user_email');
      final userName = prefs.getString('user_name');
      final userTitle = prefs.getString('user_title');
      final userAvatar = prefs.getString('user_avatar');

      if (userId != null && userEmail != null && userName != null) {
        _currentUser = User(
          id: userId,
          email: userEmail,
          name: userName,
          title: userTitle ?? '',
          avatar: userAvatar ?? '',
        );
      }

      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      await _saveAuthData(response.data);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_title');
    await prefs.remove('user_avatar');

    _isAuthenticated = false;
    _currentUser = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveAuthData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', userData.token);
    _token = userData.token;

    await prefs.setString('user_id', userData.user.id);
    await prefs.setString('user_email', userData.user.email);
    await prefs.setString('user_name', userData.user.name);
    await prefs.setString('user_title', userData.user.title);
    await prefs.setString('user_avatar', userData.user.avatar);

    _currentUser = userData.user;
  }
}
