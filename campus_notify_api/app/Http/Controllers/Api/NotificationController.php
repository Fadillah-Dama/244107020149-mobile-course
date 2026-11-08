<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class NotificationController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $notifications = $request->user()
            ->unreadNotifications()
            ->get();

        return NotificationResource::collection($notifications);
    }

    public function show(Request $request, string $id): NotificationResource
    {
        return new NotificationResource($request->user()->notifications()->whereKey($id)->firstOrFail());
    }

    public function markAsRead(Request $request, string $id): Response
    {
        $notification = $request->user()
            ->notifications()
            ->whereKey($id)
            ->firstOrFail();

        $notification->markAsRead();

        return response()->noContent();
    }
}
