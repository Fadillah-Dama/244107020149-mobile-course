import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_notify/core/failures.dart';

import 'package:campus_notify/features/announcements/domain/entities/inbox_notification.dart';
import 'package:campus_notify/core/format.dart';
import 'package:campus_notify/features/announcements/presentation/providers/notification_providers.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String? _openingId;

  Future<void> _openNotification(InboxNotification notification) async {
    if (_openingId != null) return;
    setState(() => _openingId = notification.id);

    try {
      final route = routeFromMessage({
        'route': notification.route,
        'notification_id': notification.id,
      });
      await context.push<void>(route);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal membuka notifikasi. Periksa koneksi lalu coba kembali.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(unreadNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Notifikasi belum dibaca'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _openingId != null
                ? null
                : () {
                    ref.invalidate(unreadNotificationsProvider);
                  },
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failureMessage(error)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(unreadNotificationsProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Tidak ada notifikasi belum dibaca.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final opening = _openingId == item.id;
              return ListTile(
                leading: const Icon(Icons.mark_email_unread_outlined),
                title: Text(item.title),
                subtitle: Text(
                  item.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: opening
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                enabled: _openingId == null,
                onTap: () => _openNotification(item),
              );
            },
          );
        },
      ),
    );
  }
}
