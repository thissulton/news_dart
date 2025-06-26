import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'https://rest-api-berita.vercel.app/api/v1';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Login: kirim email dan password ke API, simpan token jika berhasil
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['token']);
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  /// Register user ke API
  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  /// Logout: hapus token
  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  /// Cek apakah user adalah admin dari payload JWT
  Future<bool> isAdmin() async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return payload['email'] == 'admin@berita.com';
    } catch (_) {
      return false;
    }
  }

  /// Ambil email dari token (optional)
  Future<String?> getEmail() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final parts = token.split('.');
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return payload['email'];
    } catch (_) {
      return null;
    }
  }

  /// Ambil token mentah
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }
}
