<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class DeviceController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'fcm_token' => ['required', 'string', 'max:4096'],
            'platform' => ['required', 'in:android,ios,web'],
            'device_name' => ['nullable', 'string', 'max:255'],
        ]);

        $device = Device::updateOrCreate(
            [
                'fcm_token_hash' => hash('sha256', $data['fcm_token']),
            ],
            [
                'user_id' => $request->user()->id,
                'device_name' => $data['device_name'] ?? null,
                'platform' => $data['platform'],
                'fcm_token' => $data['fcm_token'],
                'last_seen_at' => now(),
            ],
        );

        return response()->json([
            'message' => 'Perangkat berhasil didaftarkan.',
            'device' => [
                'id' => $device->id,
                'device_name' => $device->device_name,
                'platform' => $device->platform,
                'last_seen_at' => $device->last_seen_at
                    ->toIso8601String(),
            ],
        ], $device->wasRecentlyCreated ? 201 : 200);
    }

    public function destroy(Request $request): Response
    {
        $data = $request->validate([
            'fcm_token' => ['required', 'string', 'max:4096'],
        ]);

        Device::where('user_id', $request->user()->id)
            ->where(
                'fcm_token_hash',
                hash('sha256', $data['fcm_token']),
            )
            ->delete();

        return response()->noContent();
    }
}
