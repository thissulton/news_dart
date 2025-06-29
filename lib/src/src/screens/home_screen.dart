import 'package:berita_garut/src/src/controller/news_controller.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:berita_garut/src/src/models/news_model.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();
  late Future<NewsResponse> _futureNews;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<NewsArticle> _articles = [];

  @override
  void initState() {
    super.initState();
    _futureNews = _fetchNews();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<NewsResponse> _fetchNews({int page = 1}) async {
    final response = await _newsService.fetchNews(
      'https://rest-api-berita.vercel.app/api/v1/news?page=$page&limit=10',
    );
    return response;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    try {
      final newData = await _fetchNews(page: _currentPage);
      setState(() {
        _articles.addAll(newData.data.articles);
        _hasMoreData = newData.data.pagination.hasMore;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _articles = [];
      _futureNews = _fetchNews();
    });
  }

  // Fungsi untuk menampilkan dialog form create artikel
  void _showCreateArticleDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String category = 'Technology';
    String content = '';
    String imageUrl = '';
    bool isTrending = false;
    List<String> tags = [];
    String newTag = '';

    final categories = [
      'Technology',
      'Health',
      'Business',
      'Sports',
      'Entertainment',
      'Science',
      'Politics',
      'Education'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Buat Artikel Baru'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Judul Artikel'),
                        validator: (value) =>
                            value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                        onSaved: (value) => title = value!,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: category,
                        items: categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) => category = value!,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'URL Gambar'),
                        onSaved: (value) => imageUrl = value!,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Artikel Trending'),
                        value: isTrending,
                        onChanged: (value) => setState(() => isTrending = value!),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tags:'),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(labelText: 'Tambahkan tag'),
                                  onChanged: (value) => newTag = value,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (newTag.isNotEmpty) {
                                    setState(() {
                                      tags.add(newTag);
                                      newTag = '';
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
                        decoration: const InputDecoration(labelText: 'Konten Artikel'),
                        maxLines: 5,
                        validator: (value) =>
                            value!.isEmpty ? 'Konten tidak boleh kosong' : null,
                        onSaved: (value) => content = value!,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      
                      try {
                        final articleData = {
                          "title": title,
                          "category": category,
                          "readTime": "5 menit", // Default value
                          "imageUrl": imageUrl,
                          "isTrending": isTrending,
                          "tags": tags,
                          "content": content,
                        };

                        final success = await _newsService.createArticle(articleData);

                        if (success) {
                          Navigator.pop(context);
                          _refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Artikel berhasil dibuat')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal membuat artikel')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Terkini'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateArticleDialog,
            tooltip: 'Buat Artikel Baru',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<NewsResponse>(
          future: _futureNews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.data.articles.isEmpty) {
              return const Center(child: Text('Tidak ada berita tersedia'));
            }

            if (_articles.isEmpty) {
              _articles = snapshot.data!.data.articles;
              _hasMoreData = snapshot.data!.data.pagination.hasMore;
            }

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _articles.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _articles.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final article = _articles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: article.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    article.category,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (article.isTrending) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'TRENDING',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage:
                                      CachedNetworkImageProvider(article.author.avatar),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  article.author.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                const Text('•', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 8),
                                Text(
                                  article.publishedAt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${article.readTime} baca',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}