import 'package:berita_garut/src/src/controller/news_controller.dart';
import 'package:berita_garut/src/src/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditArticlePage extends StatefulWidget {
  final String articleId;

  const EditArticlePage({super.key, required this.articleId});

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final NewsService _newsService = NewsService();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  NewsArticle? _article;

  final _titleController = TextEditingController();
  String _selectedCategory = 'Technology'; // Default value
  final _readTimeController = TextEditingController();
  String _imageUrl = '';
  bool _isTrending = false;
  List<String> _tags = [];
  String _newTag = '';
  final _contentController = TextEditingController();

  // Pastikan daftar kategori konsisten dengan API
  final List<String> _categories = [
    'Technology',
    'Health',
    'Business',
    'Sports',
    'Entertainment',
    'Science',
    'Politics',
    'Education',
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _readTimeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getString('auth_token') != null;

    if (!isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => _isLoggedIn = isLoggedIn);
    await _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      final article = await _newsService.fetchArticleById(widget.articleId);

      if (mounted) {
        setState(() {
          _article = article;
          _titleController.text = article.title;

          // Periksa apakah kategori artikel ada dalam daftar kategori
          if (_categories.contains(article.category)) {
            _selectedCategory = article.category;
          }

          _readTimeController.text = article.readTime;
          _imageUrl = article.imageUrl;
          _isTrending = article.isTrending;
          _tags = List<String>.from(article.tags);
          _contentController.text = article.content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return const Scaffold(
        body: Center(child: Text('Redirecting to login...')),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Artikel')),
        body: const Center(child: Text('Artikel tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Artikel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Artikel',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Judul artikel tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              // Perbaikan DropdownButtonFormField
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedCategory = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(
                  labelText: 'Waktu Baca (contoh: 5 menit)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Waktu baca tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              if (_imageUrl.isNotEmpty) ...[
                const Text('Gambar Saat Ini:'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SwitchListTile(
                title: const Text('Artikel Trending'),
                value: _isTrending,
                onChanged: (bool value) => setState(() => _isTrending = value),
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tags', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => setState(() => _tags.remove(tag)),
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Tambahkan tag',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _newTag = value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_newTag.isNotEmpty) {
                            setState(() {
                              _tags.add(_newTag);
                              _newTag = '';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Konten Artikel',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) => value == null || value.isEmpty
                    ? 'Konten artikel tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final articleData = {
          "title": _titleController.text,
          "category": _selectedCategory,
          "readTime": _readTimeController.text,
          "imageUrl": _imageUrl,
          "isTrending": _isTrending,
          "tags": _tags,
          "content": _contentController.text,
        };

        final success = await _newsService.updateArticle(
          widget.articleId,
          articleData,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Artikel berhasil diperbarui')),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal memperbarui artikel')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }
}
