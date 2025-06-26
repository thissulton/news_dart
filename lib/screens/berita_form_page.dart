import 'package:flutter/material.dart';
import '../models/berita_model.dart';

class BeritaFormPage extends StatefulWidget {
  final Function(BeritaModel) onSubmit;
  final BeritaModel? berita;

  const BeritaFormPage({super.key, required this.onSubmit, this.berita});

  @override
  State<BeritaFormPage> createState() => _BeritaFormPageState();
}

class _BeritaFormPageState extends State<BeritaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController categoryController;
  late TextEditingController contentController;
  late TextEditingController imageUrlController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.berita?.title ?? '');
    categoryController = TextEditingController(text: widget.berita?.category ?? '');
    contentController = TextEditingController(text: widget.berita?.content ?? '');
    imageUrlController = TextEditingController(text: widget.berita?.imageUrl ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    contentController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final berita = BeritaModel(
        id: widget.berita?.id ?? '',
        title: titleController.text,
        category: categoryController.text,
        publishedAt: DateTime.now().toString(),
        readTime: '5 menit',
        imageUrl: imageUrlController.text,
        isTrending: false,
        tags: [],
        content: contentController.text,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        author: Author(
          name: 'Admin',
          title: 'Editor',
          avatar: 'https://i.pravatar.cc/150?img=3',
        ),
      );
      widget.onSubmit(berita);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.berita == null ? 'Tambah Berita' : 'Edit Berita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
              ),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi Berita'),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.berita == null ? 'Tambah' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
