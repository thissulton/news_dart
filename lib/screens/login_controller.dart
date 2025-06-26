import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginController {
  static const String baseUrl = 'https://rest-api-berita.vercel.app';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Login menggunakan email & password
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        await storage.write(key: 'token', value: token);
        return true;
      } else {
        print('Login gagal: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  // Registrasi user baru
  Future<bool> registerWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Registrasi gagal: ${response.body}');
      }
    } catch (e) {
      print('Register error: $e');
    }
    return false;
  }

  // Logout: hapus token dari local
  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  // Ambil token dari penyimpanan lokal
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // Cek apakah user adalah admin berdasarkan email di token JWT
  Future<bool> isAdminUser() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      return payload['email'] == 'admin@berita.com'; // Sesuaikan email admin
    } catch (e) {
      print('Token decode error: $e');
      return false;
    }
  }
}
