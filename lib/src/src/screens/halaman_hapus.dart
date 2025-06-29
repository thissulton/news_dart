import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model dan Service
class Article {
  final String id;
  final String title;
  final String content;
  final String image;
  final String authorId;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
    required this.authorId,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      authorId: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ArticleResponse {
  final bool success;
  final String message;
  final List<Article> data;

  ArticleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ArticleResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Article> articles = list.map((i) => Article.fromJson(i)).toList();
    
    return ArticleResponse(
      success: json['success'],
      message: json['message'],
      data: articles,
    );
  }
}

class ArticleService {
  static const String _baseUrl = 'https://rest-api-berita.vercel.app/api/v1';

  Future<ArticleResponse> getMyArticles(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/articles/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ArticleResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load articles: ${response.body}');
    }
  }

  Future<void> deleteArticle(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/articles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete article: ${response.body}');
    }
  }
}

// Halaman Artikel
class DeleteArticleScreen extends StatefulWidget {
  final String token;

  const DeleteArticleScreen({Key? key, required this.token}) : super(key: key);

  @override
  _DeleteArticleScreenState createState() => _DeleteArticleScreenState();
}

class _DeleteArticleScreenState extends State<DeleteArticleScreen> {
  late Future<List<Article>> _articlesFuture;
  final ArticleService _articleService = ArticleService();

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    setState(() {
      _articlesFuture = _articleService
          .getMyArticles(widget.token)
          .then((response) => response.data);
    });
  }

  Future<void> _deleteArticle(String articleId) async {
    try {
      await _articleService.deleteArticle(articleId, widget.token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus')),
        );
        _loadArticles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus artikel: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hapus Artikel'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Article>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat artikel',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadArticles,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.article, size: 50, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada artikel',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Anda belum membuat artikel apapun'),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final article = snapshot.data![index];
                return Dismissible(
                  key: Key(article.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteDialog(article.id);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: article.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.article, size: 40),
                    title: Text(
                      article.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          article.content.length > 50
                              ? '${article.content.substring(0, 50)}...'
                              : article.content,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dibuat: ${article.createdAt.day}/${article.createdAt.month}/${article.createdAt.year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(article.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(String articleId) async {
    bool confirmDelete = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              confirmDelete = true;
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmDelete) {
      await _deleteArticle(articleId);
    }
    return confirmDelete;
  }
}

// Cara menggunakan:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => DeleteArticleScreen(token: 'your_auth_token'),
//   ),
// );