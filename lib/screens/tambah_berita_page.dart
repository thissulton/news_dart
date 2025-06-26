// tambah_berita_page.dart - update dan validasi lengkap

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:berita_garut/screens/login_controller.dart';

class TambahBeritaPage extends StatefulWidget {
  final Map<String, dynamic>? berita;
  final bool isEdit;
  const TambahBeritaPage({super.key, this.berita, this.isEdit = false});

  @override
  State<TambahBeritaPage> createState() => _TambahBeritaPageState();
}

class _TambahBeritaPageState extends State<TambahBeritaPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _gambarController = TextEditingController();
  final _isiController = TextEditingController();

  bool isLoading = false;
  final String baseUrl = 'https://rest-api-berita.vercel.app';
  final LoginController loginController = LoginController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.berita != null) {
      _judulController.text = widget.berita!['title'] ?? '';
      _kategoriController.text = widget.berita!['category'] ?? '';
      _gambarController.text = widget.berita!['imageUrl'] ?? '';
      _isiController.text = widget.berita!['content'] ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final token = await loginController.getToken();
    if (!mounted) return; // ✅ penting

    if (token == null) {
      setState(() => isLoading = false);
      if (!mounted) return; // ✅ tambahkan lagi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan.')),
      );
      return;
    }

    final beritaData = {
      'title': _judulController.text.trim(),
      'category': _kategoriController.text.trim(),
      'imageUrl': _gambarController.text.trim(),
      'content': _isiController.text.trim(),
      'publishedAt': DateTime.now().toString().split(' ')[0],
      'readTime': '3 min',
      'isTrending': false,
    };

    late http.Response response;
    if (widget.isEdit && widget.berita != null) {
      final id = widget.berita!['id'];
      response = await http.put(
        Uri.parse('$baseUrl/api/v1/news/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(beritaData),
      );
    } else {
      response = await http.post(
        Uri.parse('$baseUrl/api/v1/news'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(beritaData),
      );
    }

    if (!mounted) return; // ✅ cek lagi sebelum pakai context

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan berita: ${response.body}')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit Berita' : 'Tambah Berita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) => value!.isEmpty ? 'Kategori tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _gambarController,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
                validator: (value) => value!.isEmpty ? 'URL gambar diperlukan' : null,
              ),
              TextFormField(
                controller: _isiController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Isi Berita'),
                validator: (value) => value!.isEmpty ? 'Isi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(widget.isEdit ? 'Update Berita' : 'Simpan Berita'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
