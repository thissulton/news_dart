import 'package:flutter/material.dart';
import '../services/berita_service.dart';
import '../models/berita_model.dart';
import 'berita_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<BeritaModel>> futureBerita;
  final BeritaService beritaService = BeritaService();

  @override
  void initState() {
    super.initState();
    futureBerita = beritaService.fetchBerita();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berita Garut')),
      body: FutureBuilder<List<BeritaModel>>(
        future: futureBerita,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada berita'));
          }
          final beritaList = snapshot.data!;
          return ListView.builder(
            itemCount: beritaList.length,
            itemBuilder: (context, index) {
              final berita = beritaList[index];
              return ListTile(
                leading: Image.network(berita.imageUrl, width: 60, fit: BoxFit.cover),
                title: Text(berita.title),
                subtitle: Text(berita.publishedAt),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BeritaDetailPage(berita: berita),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
