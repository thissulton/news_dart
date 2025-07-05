import 'package:berita_garut/src/src/controller/news_controller.dart';
import 'package:berita_garut/src/src/models/news_model.dart';
import 'package:berita_garut/src/src/provider/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArticleDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final NewsService _newsService = NewsService();
  bool _isBookmarked = false;
  bool _isLoading = false;
  bool _isCheckingBookmark = true;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      setState(() => _isCheckingBookmark = false);
      return;
    }

    try {
      final isBookmarked = await _newsService.checkBookmarkStatus(
        widget.article.id,
      );
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
          _isCheckingBookmark = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingBookmark = false);
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success;
      if (_isBookmarked) {
        success = await _newsService.removeBookmark(widget.article.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel dihapus dari simpanan')),
          );
        }
      } else {
        success = await _newsService.addBookmark(widget.article.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil disimpan')),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          _buildBookmarkButton(),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implementasi fitur share
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur berbagi akan segera hadir'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ArticleDetailView(article: widget.article),
      ),
    );
  }

  Widget _buildBookmarkButton() {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return IconButton(
        icon: const Icon(Icons.bookmark_border),
        onPressed: _toggleBookmark,
      );
    }

    if (_isCheckingBookmark) {
      return const IconButton(
        icon: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        onPressed: null,
      );
    }

    return IconButton(
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? Colors.yellow : null,
            ),
      onPressed: _isLoading ? null : _toggleBookmark,
    );
  }
}

class ArticleDetailView extends StatelessWidget {
  final NewsArticle article;

  const ArticleDetailView({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildFeaturedImage(), _buildArticleContent()],
    );
  }

  Widget _buildFeaturedImage() {
    return CachedNetworkImage(
      imageUrl: article.imageUrl,
      width: double.infinity,
      height: 250,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Container(height: 250, color: Colors.grey[200]),
      errorWidget: (context, url, error) => Container(
        height: 250,
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 50),
      ),
    );
  }

  Widget _buildArticleContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildArticleHeader(),
          const SizedBox(height: 16),
          _buildTags(),
          const SizedBox(height: 16),
          Text(
            article.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildArticleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildMetaInfo(),
      ],
    );
  }

  Widget _buildMetaInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: CachedNetworkImageProvider(article.author.avatar),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.author.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${article.publishedAt} • ${article.readTime}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (article.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: article.tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
    );
  }
}
