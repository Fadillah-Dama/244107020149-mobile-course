import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_notify/core/failures.dart';

import 'package:campus_notify/features/announcements/presentation/providers/notification_providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id, this.notificationId});

  final String id;
  final String? notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = notificationId == null
        ? null
        : ref.watch(notificationDetailsProvider(notificationId!));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(notification?.asData?.value.title ?? 'Pengumuman #$id'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child:
            notification?.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(failureMessage(error)),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(
                        notificationDetailsProvider(notificationId!),
                      ),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
              data: (item) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(item.body),
                  ],
                ),
              ),
            ) ??
            Text(
              id == '3'
                  ? 'Jadwal kuliah berubah\nKelas Mobile pindah ke Ruang A2 jam 13.00.'
                  : 'Detail pengumuman $id belum tersedia.',
            ),
      ),
    );
  }
}
