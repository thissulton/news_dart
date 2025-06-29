import 'package:berita_garut/src/src/controller/news_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({super.key});

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final NewsService _newsService = NewsService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  // Form fields
  String _title = '';
  String _category = 'Technology';
  String _readTime = '5 menit';
  String _imageUrl = '';
  bool _isTrending = false;
  List<String> _tags = [];
  String _newTag = '';
  String _content = '';
  File? _imageFile;

  // Categories list
  final List<String> _categories = [
    'Technology',
    'Health',
    'Business',
    'Sports',
    'Entertainment',
    'Science',
    'Politics',
    'Education'
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('auth_token') != null;
      _isLoading = false;
    });
    
    if (!_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return const Scaffold(
        body: Center(child: Text('Redirecting to login...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Artikel Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Artikel
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Judul Artikel',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul artikel tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                value: _category,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Waktu Baca
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Waktu Baca (contoh: 5 menit)',
                  border: OutlineInputBorder(),
                ),
                initialValue: _readTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu baca tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _readTime = value!,
              ),
              const SizedBox(height: 16),

              // Trending
              SwitchListTile(
                title: const Text('Artikel Trending'),
                value: _isTrending,
                onChanged: (bool value) {
                  setState(() {
                    _isTrending = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      );
                    }).toList(),
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

              // Konten Artikel
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Konten Artikel',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konten artikel tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _content = value!,
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Simpan Artikel',
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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });

      try {
        final articleData = {
          "title": _title,
          "category": _category,
          "readTime": _readTime,
          "imageUrl": 'https://media.gettyimages.com/id/1130349147/photo/france-animal-zoo-tourism.jpg?b=1&s=594x594&w=0&k=20&c=T446IFenDDKxELjLHrKqVIIEBsFaG00KUlmihw6V9Tk=',
          "isTrending": _isTrending,
          "tags": _tags,
          "content": _content,
        };

        final success = await _newsService.createArticle(articleData);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil dibuat')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuat artikel')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}