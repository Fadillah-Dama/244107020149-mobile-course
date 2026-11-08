import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> dartFiles(String path) =>
    Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

List<String> imports(File file) =>
    RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''')
        .allMatches(file.readAsStringSync())
        .map((match) => match.group(1)!)
        .toList();

String? localTarget(File source, String uri) {
  if (uri.startsWith('dart:')) return null;
  if (uri.startsWith('package:campus_notify/')) {
    return 'lib/${uri.substring('package:campus_notify/'.length)}';
  }
  if (uri.startsWith('package:')) return null;
  return source.uri.resolve(uri).toFilePath().replaceAll('\\', '/');
}

void main() {
  final files = dartFiles('lib');
  final domains = files.where(
    (file) => file.path.replaceAll('\\', '/').contains('/domain/'),
  );
  final core = dartFiles('lib/core');

  test('domain dan core hanya bergantung pada Dart, core, atau domain', () {
    for (final file in [...domains, ...core]) {
      for (final uri in imports(file)) {
        expect(
          uri.startsWith('package:') &&
              !uri.startsWith('package:campus_notify/'),
          isFalse,
          reason: '${file.path} mengimpor SDK/framework eksternal: $uri',
        );
        final target = localTarget(file, uri);
        if (target != null) {
          expect(
            target.contains('/domain/') || target.contains('/core/'),
            isTrue,
            reason: '${file.path} mengarah keluar domain/core: $uri',
          );
        }
      }
    }
  });

  test(
    'presentation tidak mengimpor implementasi data atau SDK infrastruktur',
    () {
      final forbidden = RegExp(
        r'package:(dio|firebase[^/]*|flutter_secure_storage|flutter_local_notifications|app_badge_plus)/',
      );
      for (final file in files.where(
        (file) => file.path.replaceAll('\\', '/').contains('/presentation/'),
      )) {
        for (final uri in imports(file)) {
          expect(
            forbidden.hasMatch(uri),
            isFalse,
            reason: '${file.path}: $uri',
          );
          final target = localTarget(file, uri);
          expect(
            target?.contains('/data/') ?? false,
            isFalse,
            reason: '${file.path}: $uri',
          );
        }
      }
    },
  );

  test('data tidak mengimpor presentation atau composition root', () {
    for (final file in files.where(
      (file) => file.path.replaceAll('\\', '/').contains('/data/'),
    )) {
      for (final uri in imports(file)) {
        final target = localTarget(file, uri);
        expect(
          target != null &&
              (target.contains('/presentation/') || target.contains('/app/')),
          isFalse,
          reason: '${file.path}: $uri',
        );
      }
    }
  });

  test('entity domain tidak berisi mapping JSON/database', () {
    final mapping = RegExp(r'\b(fromJson|toJson|fromMap|toMap)\s*\(');
    for (final file in domains.where(
      (file) => file.path.replaceAll('\\', '/').contains('/entities/'),
    )) {
      expect(
        mapping.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
}
