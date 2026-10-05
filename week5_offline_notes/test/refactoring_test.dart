import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/main.dart';
import 'package:week5_offline_notes/providers/note_providers.dart';
import 'package:week5_offline_notes/providers/prefs_providers.dart';
import 'package:week5_offline_notes/router.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

class DetailRepository extends NoteRepository {
  DetailRepository({this.note, this.fail = false, this.showInList = false})
    : super(openDb: () => throw StateError('Test tidak boleh membuka SQLite'));

  Note? note;
  bool fail;
  final bool showInList;
  final requestedIds = <int>[];

  @override
  Future<List<Note>> fetchNotes() async =>
      showInList && note != null ? [note!] : [];

  @override
  Future<int> countDirty() async => note?.dirty == true ? 1 : 0;

  @override
  Future<Note?> getNoteById(int id) async {
    requestedIds.add(id);
    if (fail) throw Exception('Simulasi database gagal');
    return note?.id == id ? note : null;
  }

  @override
  Future<void> updateNote(Note value) async {
    note = value.copyWith(dirty: true, updatedAt: DateTime.now());
  }
}

class TestTheme extends DarkModeNotifier {
  @override
  Future<bool> build() async => false;
}

Note sampleNote({bool dirty = false}) => Note(
  id: 42,
  title: 'Judul dari repository',
  body: 'Isi lengkap dari penyimpanan lokal',
  updatedAt: DateTime(2026, 10, 5),
  dirty: dirty,
);

Future<void> pumpApp(
  WidgetTester tester,
  DetailRepository repo, {
  String location = '/note/42',
}) async {
  final router = createRouter(initialLocation: location);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
  await tester.pumpWidget(
    ProviderScope(
      retry: (count, error) => null,
      overrides: [
        routerProvider.overrideWithValue(router),
        noteRepositoryProvider.overrideWithValue(repo),
        darkModeProvider.overrideWith(TestTheme.new),
      ],
      child: const OfflineNotesApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('NoteTile menampilkan badge dirty dan meneruskan aksi', (
    tester,
  ) async {
    var tapped = false;
    var deleted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(
            note: sampleNote(dirty: true),
            onTap: () => tapped = true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );
    expect(find.text('belum tersinkron'), findsOneWidget);
    await tester.tap(find.text('Judul dari repository'));
    await tester.tap(find.byTooltip('Hapus'));
    expect(tapped, isTrue);
    expect(deleted, isTrue);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(note: sampleNote(), onTap: () {}, onDelete: () {}),
        ),
      ),
    );
    expect(find.text('belum tersinkron'), findsNothing);
  });

  testWidgets('Rute detail membaca id meskipun daftar kosong', (tester) async {
    final repo = DetailRepository(note: sampleNote());
    await pumpApp(tester, repo);
    expect(repo.requestedIds, contains(42));
    expect(find.text('Judul dari repository'), findsOneWidget);
    expect(find.text('Isi lengkap dari penyimpanan lokal'), findsOneWidget);
  });

  testWidgets('Detail menangani catatan yang sudah tidak ada', (tester) async {
    await pumpApp(tester, DetailRepository());
    expect(find.text('Catatan tidak ditemukan'), findsOneWidget);
  });

  testWidgets('Detail dapat mencoba lagi setelah pembacaan gagal', (
    tester,
  ) async {
    final repo = DetailRepository(note: sampleNote(), fail: true);
    await pumpApp(tester, repo);
    expect(find.text('Gagal membaca catatan'), findsOneWidget);
    repo.fail = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Judul dari repository'), findsOneWidget);
  });

  testWidgets('Ubah dari detail memperbarui detail dan daftar', (tester) async {
    final repo = DetailRepository(note: sampleNote(), showInList: true);
    await pumpApp(tester, repo, location: '/');
    await tester.tap(find.text('Judul dari repository'));
    await tester.pumpAndSettle();
    expect(find.text('Detail catatan'), findsOneWidget);
    await tester.tap(find.text('Ubah catatan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Judul diperbarui');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Judul diperbarui'), findsOneWidget);
    expect(find.text('belum tersinkron'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Judul diperbarui'), findsOneWidget);
    expect(find.text('belum tersinkron'), findsOneWidget);
  });

  testWidgets('ID rute tidak valid ditangani tanpa parsing exception', (
    tester,
  ) async {
    final repo = DetailRepository();
    await pumpApp(tester, repo, location: '/note/bukan-angka');
    expect(find.text('ID catatan tidak valid'), findsOneWidget);
    expect(repo.requestedIds, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
