import 'package:flutter/material.dart';
import '../models/berita_model.dart';

class BeritaDetailPage extends StatelessWidget {
  final BeritaModel berita;

  const BeritaDetailPage({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(berita.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              berita.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    berita.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${berita.publishedAt} • ${berita.readTime}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(berita.author.avatar),
                        radius: 20,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            berita.author.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            berita.author.title,
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    berita.content,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: berita.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
