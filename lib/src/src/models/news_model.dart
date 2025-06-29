import 'dart:convert';

NewsResponse newsResponseFromJson(String str) =>
    NewsResponse.fromJson(json.decode(str));

String newsResponseToJson(NewsResponse data) => json.encode(data.toJson());

class NewsResponse {
  final bool success;
  final String message;
  final NewsData data;

  NewsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) => NewsResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    data: NewsData.fromJson(json["data"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class NewsData {
  final List<NewsArticle> articles;
  final Pagination pagination;

  NewsData({required this.articles, required this.pagination});

  factory NewsData.fromJson(Map<String, dynamic> json) => NewsData(
    articles: json["articles"] == null
        ? []
        : List<NewsArticle>.from(
            json["articles"].map((x) => NewsArticle.fromJson(x)),
          ),
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "articles": List<dynamic>.from(articles.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class NewsArticle {
  final String id;
  final String title;
  final String category;
  final String publishedAt;
  final String readTime;
  final String imageUrl;
  final bool isTrending;
  final List<String> tags;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author author;

  NewsArticle({
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

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
    id: json["id"] ?? "",
    title: json["title"] ?? "",
    category: json["category"] ?? "",
    publishedAt: json["publishedAt"] ?? "",
    readTime: json["readTime"] ?? "",
    imageUrl: json["imageUrl"] ?? "",
    isTrending: json["isTrending"] ?? false,
    tags: json["tags"] == null
        ? []
        : List<String>.from(json["tags"].map((x) => x)),
    content: json["content"] ?? "",
    createdAt: json["createdAt"] == null
        ? DateTime.now()
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? DateTime.now()
        : DateTime.parse(json["updatedAt"]),
    author: Author.fromJson(json["author"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "category": category,
    "publishedAt": publishedAt,
    "readTime": readTime,
    "imageUrl": imageUrl,
    "isTrending": isTrending,
    "tags": List<dynamic>.from(tags.map((x) => x)),
    "content": content,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "author": author.toJson(),
  };
}

class Author {
  final String name;
  final String title;
  final String avatar;

  Author({required this.name, required this.title, required this.avatar});

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    name: json["name"] ?? "",
    title: json["title"] ?? "",
    avatar: json["avatar"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "title": title,
    "avatar": avatar,
  };
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"] ?? 0,
    limit: json["limit"] ?? 0,
    total: json["total"] ?? 0,
    hasMore: json["hasMore"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "hasMore": hasMore,
  };
}
