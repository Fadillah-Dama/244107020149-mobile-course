<?php

namespace App\Console\Commands;

use App\Models\Device;
use App\Models\User;
use App\Notifications\CampusAnnouncement;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Throwable;

#[Signature('campus:notify {email : Email penerima} {--title=Jadwal kuliah berubah} {--body=Kelas Mobile pindah ke Ruang A2 jam 13.00.} {--route=/pengumuman/3}')]
#[Description('Simpan notifikasi pengguna dan kirim push ke perangkat terdaftar')]
class SendCampusNotification extends Command
{
    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $input = [
            'email' => $this->argument('email'),
            'title' => $this->option('title'),
            'body' => $this->option('body'),
            'route' => $this->option('route'),
        ];
        $validator = Validator::make($input, [
            'email' => ['required', 'email'],
            'title' => ['required', 'string', 'max:200'],
            'body' => ['required', 'string', 'max:1000'],
            'route' => ['required', 'string', 'regex:~^/(?:pengumuman/[a-zA-Z0-9_-]+)?$~'],
        ]);
        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->error($error);
            }

            return self::FAILURE;
        }

        $user = User::query()->where('email', $input['email'])->first();
        if ($user === null) {
            $this->error('Pengguna tidak ditemukan.');

            return self::FAILURE;
        }

        $notification = new CampusAnnouncement($input['title'], $input['body'], $input['route']);
        $notification->id = (string) Str::uuid();
        $user->notify($notification);
        $this->info('Notifikasi tersimpan. ID: '.$notification->id);
        $unreadCount = $user->unreadNotifications()->count();

        $devices = Device::query()->where('user_id', $user->id)->get();
        if ($devices->isEmpty()) {
            $this->warn('Belum ada perangkat terdaftar. Notifikasi tetap tersedia dalam daftar aplikasi.');

            return self::FAILURE;
        }

        try {
            $messaging = app(Messaging::class);
        } catch (Throwable $exception) {
            $this->error('Firebase belum siap ('.class_basename($exception).'). Periksa konfigurasi kredensial. Notifikasi tetap tersimpan.');

            return self::FAILURE;
        }

        $sent = 0;
        foreach ($devices as $device) {
            try {
                $message = CloudMessage::fromArray([
                    'token' => $device->fcm_token,
                    'notification' => ['title' => $input['title'], 'body' => $input['body']],
                    'data' => [
                        'notification_id' => $notification->id,
                        'route' => $input['route'],
                        'unread_count' => (string) $unreadCount,
                    ],
                    'android' => [
                        'priority' => 'high',
                        'notification' => [
                            'channel_id' => 'pengumuman',
                            'sound' => 'default',
                            'tag' => 'campus-notification:'.$notification->id,
                            'notification_count' => 1,
                        ],
                    ],
                    'apns' => ['payload' => ['aps' => ['badge' => $unreadCount, 'sound' => 'default']]],
                ]);
                $messaging->send($message);
                $sent++;
            } catch (Throwable $exception) {
                $this->warn('Push perangkat #'.$device->id.' gagal ('.class_basename($exception).'). Periksa koneksi, konfigurasi Firebase, dan registrasi perangkat.');
            }
        }

        $this->info('FCM menerima '.$sent.' dari '.$devices->count().' pengiriman. Penerimaan FCM belum menjamin banner tampil di HP.');

        return $sent === $devices->count() ? self::SUCCESS : self::FAILURE;
    }
}
