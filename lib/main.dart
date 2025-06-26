import 'package:flutter/material.dart';
import 'package:berita_garut/screens/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // optional jika tidak ada async init lain
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Berita Garut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
