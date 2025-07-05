import 'package:berita_garut/src/src/controller/news_controller.dart';
import 'package:berita_garut/src/src/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:berita_garut/src/src/models/news_model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  final ScrollController _scrollController = ScrollController();
  List<NewsArticle> _articles = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
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
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _newsService.fetchNews(
        _buildApiUrl(page: 1, limit: 10),
      );

      setState(() {
        _articles = response.data.articles;
        _hasMore = response.data.pagination.hasMore;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final response = await _newsService.fetchNews(
        _buildApiUrl(page: _currentPage, limit: 10),
      );

      setState(() {
        _articles.addAll(response.data.articles);
        _hasMore = response.data.pagination.hasMore;
      });
    } catch (e) {
      _currentPage--;
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  String _buildApiUrl({required int page, required int limit}) {
    final baseUrl = 'https://rest-api-berita.vercel.app/api/v1/news';
    if (_selectedCategory == 'All') {
      return '$baseUrl?page=$page&limit=$limit';
    }
    return '$baseUrl?page=$page&limit=$limit&category=$_selectedCategory';
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _articles.clear();
      _hasMore = true;
    });
    await _loadInitialData();
  }

  void _navigateToArticleDetail(NewsArticle article) {
    Navigator.pushNamed(context, '/article', arguments: article);
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 1;
      _articles.clear();
      _hasMore = true;
    });
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Berita Terkini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search',
          ),
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateArticleDialog(context),
              tooltip: 'Create Article',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) => _onCategorySelected(category),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              },
            ),
          ),
          // News List
          Expanded(child: _buildContent(authProvider, isDarkMode)),
        ],
      ),
      floatingActionButton: _isLoadingMore
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: theme.colorScheme.primary,
              child: const CircularProgressIndicator(color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent(AuthProvider authProvider, bool isDarkMode) {
    if (_isLoading && _articles.isEmpty) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) =>
            ArticleCardShimmer(isDarkMode: isDarkMode),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No articles found', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              _selectedCategory == 'All'
                  ? 'Check back later for new articles'
                  : 'No articles in $_selectedCategory category',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _articles.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _articles.length) {
            return const SizedBox.shrink();
          }

          final article = _articles[index];
          return ArticleCard(
            article: article,
            onTap: () => _navigateToArticleDetail(article),
            isAuthenticated: authProvider.isAuthenticated,
          );
        },
      ),
    );
  }

  void _showCreateArticleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateArticleDialog(
        newsService: _newsService,
        onSuccess: _refreshData,
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Articles'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by title, author, or category',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final bool isAuthenticated;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImage(), _buildArticleContent(theme, isDarkMode)],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: article.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(height: 200, color: Colors.grey[200]),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.error, size: 48),
            ),
          ),
          if (article.isTrending)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'TRENDING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArticleContent(ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryChip(theme),
          const SizedBox(height: 8),
          Text(
            article.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          _buildAuthorRow(theme, isDarkMode),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(article.readTime, style: theme.textTheme.bodySmall),
              const Spacer(),
              Text(
                _formatDate(article.publishedAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Chip(
      label: Text(
        article.category,
        style: TextStyle(color: theme.colorScheme.onPrimary),
      ),
      backgroundColor: theme.colorScheme.primary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAuthorRow(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
          backgroundImage: CachedNetworkImageProvider(article.author.avatar),
          onBackgroundImageError: (exception, stackTrace) =>
              const Icon(Icons.person),
        ),
        const SizedBox(width: 8),
        Text(article.author.name, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class ArticleCardShimmer extends StatelessWidget {
  final bool isDarkMode;

  const ArticleCardShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 200, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(radius: 14),
                      const SizedBox(width: 8),
                      Container(width: 100, height: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this widget class at the bottom of your NewsScreen file
class CreateArticleDialog extends StatefulWidget {
  final NewsService newsService;
  final VoidCallback onSuccess;

  const CreateArticleDialog({
    super.key,
    required this.newsService,
    required this.onSuccess,
  });

  @override
  State<CreateArticleDialog> createState() => _CreateArticleDialogState();
}

class _CreateArticleDialogState extends State<CreateArticleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  List<String> _tags = [];
  String _category = 'Technology';
  bool _isTrending = false;
  bool _isSubmitting = false;

  final List<String> categories = [
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
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Article'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildImageUrlField(),
              const SizedBox(height: 16),
              _buildTrendingSwitch(),
              const SizedBox(height: 16),
              _buildTagsInput(),
              const SizedBox(height: 16),
              _buildContentField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: 'Title'),
      validator: (value) => value!.isEmpty ? 'Title is required' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      items: categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) => setState(() => _category = value!),
      decoration: const InputDecoration(labelText: 'Category'),
    );
  }

  Widget _buildImageUrlField() {
    return TextFormField(
      controller: _imageUrlController,
      decoration: const InputDecoration(labelText: 'Image URL'),
    );
  }

  Widget _buildTrendingSwitch() {
    return SwitchListTile(
      title: const Text('Trending Article'),
      value: _isTrending,
      onChanged: (value) => setState(() => _isTrending = value),
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            labelText: 'Tags',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTag,
            ),
          ),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: _tags.map((tag) {
              return Chip(label: Text(tag), onDeleted: () => _removeTag(tag));
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(labelText: 'Content'),
      maxLines: 5,
      validator: (value) => value!.isEmpty ? 'Content is required' : null,
    );
  }

  void _addTag() {
    if (_tagsController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagsController.text);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final articleData = {
        "title": _titleController.text,
        "category": _category,
        "content": _contentController.text,
        "imageUrl": _imageUrlController.text,
        "isTrending": _isTrending,
        "tags": _tags,
        "readTime": "5 min read",
        "publishedAt": DateTime.now().toIso8601String(),
      };

      final success = await widget.newsService.createArticle(articleData);

      if (success) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create article')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
