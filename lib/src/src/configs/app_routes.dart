import 'package:berita_garut/src/src/models/news_model.dart';
import 'package:berita_garut/src/src/screens/article_detail_screen.dart';
import 'package:berita_garut/src/src/screens/bookmark_screen.dart';
import 'package:berita_garut/src/src/screens/halaman_edit.dart';
import 'package:berita_garut/src/src/screens/home_screen.dart';
import 'package:berita_garut/src/src/screens/login_screen.dart';
import 'package:berita_garut/src/src/screens/main_wrapper_screen.dart';
import 'package:berita_garut/src/src/screens/my_article_screen.dart';
import 'package:berita_garut/src/src/screens/profile_screen.dart';
import 'package:berita_garut/src/src/screens/splash_screen.dart';
import 'package:berita_garut/src/src/screens/register_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const splash = '/';
  static const introduction = '/intro';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const main = '/main';
  static const articleDetail = '/article';
  static const profile = '/profile';
  static const explore = '/explore';
  static const trending = '/trending';
  static const saved = '/saved';
  static const myArticles = '/my-articles';
  static const createArticle = '/create-article';
  static const editArticle = '/edit-article';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const NewsScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainWrapperScreen());
      case articleDetail:
        final article = settings.arguments as NewsArticle;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(article: article),
        );
      case editArticle:
        final args = settings.arguments as Map<String, dynamic>;
        final articleId = args['articleId'] as String;
        return MaterialPageRoute(
          builder: (_) => EditArticlePage(articleId: articleId),
        );
      case saved:
        return MaterialPageRoute(builder: (_) => const BookmarkScreen());
      case myArticles:
        return MaterialPageRoute(builder: (_) => const MyArticlesScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
