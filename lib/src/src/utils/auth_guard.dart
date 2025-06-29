import 'package:berita_garut/src/src/configs/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard {
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  static Future<void> checkAuth(BuildContext context) async {
    final isAuth = await isAuthenticated();
    if (!isAuth) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
}
