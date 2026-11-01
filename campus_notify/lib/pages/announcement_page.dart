import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text('Pengumuman #$id'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          id == '3'
              ? 'Jadwal kuliah berubah\nKelas Mobile pindah ke Ruang A2 jam 13.00.'
              : 'Detail pengumuman $id belum tersedia.',
        ),
      ),
    );
  }
}
