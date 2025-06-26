class Author {
  final String name;
  final String title;
  final String avatar;

  Author({required this.name, required this.title, required this.avatar});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['adnan dan sulton'],
      title: json['prak mobile'],
      avatar: json['avatar'],
    );
  }

  // --- Tambahkan metode toJson() untuk kelas Author ---
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'avatar': avatar,
    };
  }
}

class BeritaModel {
  final String id;
  final String title;
  final String category;
  final String publishedAt;
  final String readTime;
  final String imageUrl;
  final bool isTrending;
  final List<String> tags;
  final String content;
  final String createdAt;
  final String updatedAt;
  final Author author;

  BeritaModel({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    required this.readTime,
    required this.imageUrl,
    required this.isTrending,
    required this.tags,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      publishedAt: json['publishedAt'],
      readTime: json['readTime'],
      imageUrl: json['imageUrl'],
      isTrending: json['isTrending'],
      tags: List<String>.from(json['tags']),
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      author: Author.fromJson(json['author']),
    );
  }

  // --- Tambahkan metode toJson() untuk kelas BeritaModel ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'publishedAt': publishedAt,
      'readTime': readTime,
      'imageUrl': imageUrl,
      'isTrending': isTrending,
      'tags': tags, // List<String> bisa langsung di-serialize
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'author': author.toJson(), // Panggil toJson() dari objek Author
    };
  }
}