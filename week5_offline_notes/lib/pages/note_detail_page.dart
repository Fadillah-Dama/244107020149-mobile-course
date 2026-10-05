import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});

  final int id;

  Future<void> _edit(BuildContext context, WidgetRef ref, Note note) async {
    final result = await showDialog<NoteFormResult>(
      context: context,
      builder: (_) => NoteFormDialog(initial: note),
    );
    if (result == null || !context.mounted) return;
    try {
      await ref
          .read(noteActionsProvider)
          .update(note.copyWith(title: result.title, body: result.body));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan catatan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail catatan')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gagal membaca catatan'),
              FilledButton(
                onPressed: () => ref.invalidate(noteByIdProvider(id)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              SelectableText(note.body.isEmpty ? '(tanpa isi)' : note.body),
              const SizedBox(height: 16),
              Text('Diperbarui: ${note.updatedAt.toLocal()}'),
              if (note.dirty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('belum tersinkron')),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _edit(context, ref, note),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Ubah catatan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
