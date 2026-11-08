/// Hanya buka halaman aplikasi yang memang tersedia, bukan URL dari luar.
String routeFromMessage(Map<String, dynamic> data) {
  final value = data['route'];
  if (value is! String || value.trim().isEmpty) return '/';
  final route = value.trim().startsWith('/')
      ? value.trim()
      : '/${value.trim()}';
  final uri = Uri.tryParse(route);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return '/';
  var path = uri.path;
  if (path != '/' && !RegExp(r'^/pengumuman/[a-zA-Z0-9_-]+$').hasMatch(path)) {
    return '/';
  }
  final id = data['notification_id'] ?? uri.queryParameters['notification_id'];
  final validId =
      id is String &&
      RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(id);
  if (!validId) return path;
  if (path == '/') path = '/pengumuman/notifikasi';
  return Uri(path: path, queryParameters: {'notification_id': id}).toString();
}
