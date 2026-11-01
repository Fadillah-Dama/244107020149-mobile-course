import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _topicBusy = false;
  bool? _topicSubscribed;

  Future<void> _setTopicSubscription(bool subscribe) async {
    if (_topicBusy) return;
    setState(() => _topicBusy = true);
    try {
      if (subscribe) {
        await subscribeCampusTopic();
      } else {
        await unsubscribeCampusTopic();
      }
      if (!mounted) return;
      setState(() => _topicSubscribed = subscribe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            subscribe
                ? 'Berlangganan pengumuman kampus berhasil'
                : 'Berhenti berlangganan pengumuman kampus berhasil',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal mengubah langganan. Periksa koneksi lalu coba lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _topicBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            child: const Text('Keluar'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Selamat datang di Campus Notify.'),
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: const Text('Jadwal kuliah berubah'),
            subtitle: const Text('Lihat pengumuman #3'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/pengumuman/3'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Siapkan uji notifikasi'),
            subtitle: const Text(
              'Izinkan notifikasi dan salin token perangkat',
            ),
            onTap: () async {
              var stage = 'meminta izin notifikasi';
              try {
                final allowed = await requestNotificationPermission();
                if (!context.mounted) return;

                if (!allowed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Izin notifikasi belum diberikan. Aktifkan melalui Setelan HP > Aplikasi > Campus Notify > Notifikasi.',
                      ),
                    ),
                  );
                  return;
                }

                stage = 'mengambil token FCM';
                final token = await FirebaseMessaging.instance.getToken();
                if (token == null || token.isEmpty) {
                  throw StateError('Token belum tersedia');
                }

                stage = 'menyalin token ke clipboard';
                await Clipboard.setData(ClipboardData(text: token));
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token FCM disalin')),
                );
              } catch (error) {
                if (!context.mounted) return;

                // Tampilkan kode dan penyebab yang dikenal, tanpa token atau
                // isi exception mentah yang mungkin memuat data perangkat.
                final String code;
                final String details;
                if (error is FirebaseException) {
                  code = '${error.plugin}/${error.code}';
                  details = error.message ?? '';
                } else if (error is PlatformException) {
                  code = error.code;
                  details = error.message ?? '';
                } else {
                  code = error is StateError ? 'token-unavailable' : 'unknown';
                  details = '';
                }

                final reason = details.toUpperCase();
                String advice;
                if (reason.contains('SERVICE_NOT_AVAILABLE') ||
                    reason.contains('NETWORK') ||
                    reason.contains('TIMEOUT')) {
                  advice =
                      'Layanan Firebase belum dapat dijangkau. Coba ganti '
                      'Wi-Fi/data seluler, nonaktifkan VPN bila digunakan, '
                      'lalu coba lagi.';
                } else if (reason.contains('FIS_AUTH_ERROR') ||
                    reason.contains('API_KEY') ||
                    reason.contains('AUTHENTICATION_FAILED') ||
                    reason.contains('BAD_CONFIG')) {
                  advice =
                      'Periksa konfigurasi aplikasi di Firebase Console '
                      'dan gunakan google-services.json dari aplikasi Android '
                      'yang sama. Periksa juga pembatasan API key.';
                } else if (reason.contains('MISSING_INSTANCEID_SERVICE')) {
                  advice =
                      'Periksa apakah Google Play services aktif dan '
                      'sudah diperbarui pada perangkat ini.';
                } else if (reason.contains('TOO_MANY_REGISTRATIONS')) {
                  advice =
                      'Perangkat memiliki terlalu banyak registrasi FCM. '
                      'Coba perangkat lain untuk pengujian.';
                } else {
                  advice =
                      'Catat tahap dan kode di bawah untuk pemeriksaan '
                      'lebih lanjut. Penyebab pastinya belum diketahui.';
                }

                await showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Persiapan notifikasi gagal'),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        'Tahap: $stage\nKode: $code\n\n$advice',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Topik pengumuman-kampus'),
            subtitle: Text(
              _topicSubscribed == null
                  ? 'Pilih aksi untuk mengatur langganan perangkat ini.'
                  : _topicSubscribed!
                  ? 'Berlangganan (aksi terakhir berhasil).'
                  : 'Tidak berlangganan (aksi terakhir berhasil).',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _topicBusy
                      ? null
                      : () => _setTopicSubscription(true),
                  child: const Text('Berlangganan'),
                ),
                OutlinedButton(
                  onPressed: _topicBusy
                      ? null
                      : () => _setTopicSubscription(false),
                  child: const Text('Berhenti berlangganan'),
                ),
                if (_topicBusy)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
