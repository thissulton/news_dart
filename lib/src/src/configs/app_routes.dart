import 'package:berita_garut/src/src/screens/halaman%20_create.dart';
import 'package:berita_garut/src/src/screens/home_screen.dart';
import 'package:berita_garut/src/src/screens/login_screen.dart';
import 'package:berita_garut/src/src/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const splash = '/';
  static const introduction = '/intro';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
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
        return MaterialPageRoute(builder: (_) => const HomePage());
      case createArticle:
        return MaterialPageRoute(builder: (_) => const CreateArticlePage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
