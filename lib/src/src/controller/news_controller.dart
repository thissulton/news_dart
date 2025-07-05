import 'dart:convert';
import 'package:berita_garut/src/src/models/news_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  final String baseApiUrl = 'https://rest-api-berita.vercel.app/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<NewsResponse> fetchNews(String apiUrl) async {
    if (apiUrl.isEmpty) {
      return NewsResponse(
        success: false,
        message: "URL kosong",
        data: NewsData(
          articles: [],
          pagination: Pagination(page: 0, limit: 0, total: 0, hasMore: false),
        ),
      );
    }

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return NewsResponse.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('Failed to load news (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception(
        'Failed to load news: Network error or parsing error occurred.',
      );
    }
  }

  Future<NewsArticle> fetchArticleById(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    try {
      final response = await http
          .get(Uri.parse('$baseApiUrl/news/$articleId'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return NewsArticle.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal memuat artikel');
        }
      } else {
        throw Exception(
          'Gagal memuat artikel (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memuat artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<List<NewsArticle>> fetchRelatedArticles(
    String category, {
    int limit = 2,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$baseApiUrl/news?category=$category&limit=$limit'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data']['articles'] != null) {
          return List<NewsArticle>.from(
            jsonData['data']['articles'].map((x) => NewsArticle.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> checkBookmarkStatus(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseApiUrl/news/$articleId/bookmark'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        // Perubahan di sini: mengambil status bookmark dari data.isSaved
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data']['isSaved'] ?? false;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> addBookmark(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseApiUrl/news/$articleId/bookmark'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception('Gagal menyimpan artikel');
      }
    } catch (e) {
      throw Exception(
        'Gagal menyimpan artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<bool> removeBookmark(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseApiUrl/news/$articleId/bookmark'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception('Gagal menghapus artikel dari simpanan');
      }
    } catch (e) {
      throw Exception(
        'Gagal menghapus artikel dari simpanan: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<List<NewsArticle>> fetchBookmarkedArticles() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseApiUrl/news/bookmarks/list'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data']['articles'] != null) {
          return List<NewsArticle>.from(
            jsonData['data']['articles'].map((x) => NewsArticle.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Gagal memuat artikel tersimpan (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memuat artikel tersimpan: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<NewsResponse> fetchMyArticles() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseApiUrl/news/user/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return NewsResponse.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          'Gagal memuat artikel Anda (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memuat artikel Anda: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<bool> createArticle(Map<String, dynamic> articleData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseApiUrl/news'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(articleData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('Error response: $errorBody');
        throw Exception(
          'Gagal membuat artikel (Status: ${response.statusCode}, Body: $errorBody)',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal membuat artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<bool> updateArticle(
    String articleId,
    Map<String, dynamic> articleData,
  ) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .put(
            Uri.parse('$baseApiUrl/news/$articleId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(articleData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception(
          'Gagal memperbarui artikel (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memperbarui artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<bool> deleteArticle(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseApiUrl/news/$articleId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception(
          'Gagal menghapus artikel (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal menghapus artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }
}
