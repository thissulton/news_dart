// admin_dashboard.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:berita_garut/screens/login_controller.dart';
import 'tambah_berita_page.dart';

class AdminDashboard extends StatefulWidget {
  final bool isAdmin;
  const AdminDashboard({super.key, required this.isAdmin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final String baseUrl = 'https://rest-api-berita.vercel.app';
  final LoginController loginController = LoginController();
  List<dynamic> beritaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/news'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        beritaList = data['data']['articles'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data berita')),
      );
    }
  }

  Future<void> deleteBerita(String id) async {
    final token = await loginController.getToken();
    if (token == null) return;

    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/news/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      fetchBerita();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus berita')),
      );
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: const Text('Yakin ingin menghapus berita ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteBerita(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void navigateToTambahBerita() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahBeritaPage()),
    );
    if (result == true) {
      fetchBerita();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchBerita,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToTambahBerita,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: beritaList.length,
              itemBuilder: (context, index) {
                final berita = beritaList[index];
                return ListTile(
                  title: Text(berita['title'] ?? '-'),
                  subtitle: Text(berita['publishedAt'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(berita['id']),
                  ),
                );
              },
            ),
    );
  }
}
