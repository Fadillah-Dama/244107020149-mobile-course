import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/app/di/providers.dart';
import 'package:campus_notify/features/announcements/presentation/providers/notification_providers.dart';

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
      await ref.read(pushPreferencesProvider).setTopicSubscription(subscribe);
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
    final unreadCount = ref
        .watch(unreadNotificationsProvider)
        .asData
        ?.value
        .length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final serverRevoked = await ref
                  .read(authStateProvider.notifier)
                  .logout();
              if (!serverRevoked && messenger.mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sesi lokal dihapus. Pencabutan sesi atau pelepasan perangkat di server belum terkonfirmasi.',
                    ),
                  ),
                );
              }
            },
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
            leading: Badge.count(
              count: unreadCount ?? 0,
              isLabelVisible: unreadCount != null && unreadCount > 0,
              child: const Icon(Icons.inbox_outlined),
            ),
            title: const Text('Notifikasi belum dibaca'),
            subtitle: const Text('Lihat notifikasi yang belum Anda buka'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/notifikasi'),
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
              try {
                final allowed = await ref
                    .read(pushPreferencesProvider)
                    .prepareAndCopyToken();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      allowed ? 'Token FCM disalin' : 'Izin notifikasi belum diberikan. Aktifkan melalui Setelan HP > Aplikasi > Campus Notify > Notifikasi.',
                    ),
                  ),
                );
              } on Failure catch (failure) {
                if (!context.mounted) return;
                await showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Persiapan notifikasi gagal'),
                    content: Text(failure.message),
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
