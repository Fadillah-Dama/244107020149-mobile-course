<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceController;
use App\Http\Controllers\Api\NotificationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/auth/login', [AuthController::class, 'login'])
    ->middleware('throttle:10,1');

Route::post('/auth/refresh', [AuthController::class, 'refresh'])
    ->middleware('throttle:20,1');

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::post('/devices', [DeviceController::class, 'store'])
        ->name('devices.store');

    Route::delete('/devices', [DeviceController::class, 'destroy'])
        ->name('devices.destroy');

    Route::get('/notifications', [NotificationController::class, 'index'])
        ->name('notifications.index');

    Route::get('/notifications/{id}', [NotificationController::class, 'show'])
        ->whereUuid('id')
        ->name('notifications.show');

    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markAsRead'])
        ->whereUuid('id')
        ->name('notifications.read');
});
