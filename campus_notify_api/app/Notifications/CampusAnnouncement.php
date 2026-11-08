<?php

namespace App\Notifications;

use Illuminate\Notifications\Notification;

class CampusAnnouncement extends Notification
{
    public function __construct(
        public string $title,
        public string $body,
        public string $route,
    ) {}

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array{title: string, body: string, route: string}
     */
    public function toDatabase(object $notifiable): array
    {
        return [
            'title' => $this->title,
            'body' => $this->body,
            'route' => $this->route,
        ];
    }
}
