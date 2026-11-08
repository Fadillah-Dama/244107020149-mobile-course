<?php

namespace Database\Seeders;

use App\Models\User;
use App\Notifications\CampusAnnouncement;
use Illuminate\Database\Seeder;

class DemoNotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $user = User::where('email', 'mahasiswa@kampus.ac.id')->firstOrFail();

        $user->notify(new CampusAnnouncement(
            title: 'Jadwal kuliah berubah',
            body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00.',
            route: '/pengumuman/3',
        ));
    }
}
