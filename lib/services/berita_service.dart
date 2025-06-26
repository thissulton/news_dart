import 'dart:convert';
import 'package:http/http.dart' as http; 
import '../models/berita_model.dart';

class BeritaService {
  final String baseUrl = 'https://berita-garut.vercel.app/api/v1/news';

  Future<List<BeritaModel>> fetchBerita() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data['data']['articles'];
      return articles.map((json) => BeritaModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat berita');
    }
  }

  Future<void> tambahBerita(BeritaModel berita) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(berita.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Gagal menambah berita');
    }
  }

  Future<void> updateBerita(BeritaModel berita) async {
    final url = '$baseUrl/${berita.id}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(berita.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal mengupdate berita');
    }
  }

  Future<void> hapusBerita(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus berita');
    }
  }
}
