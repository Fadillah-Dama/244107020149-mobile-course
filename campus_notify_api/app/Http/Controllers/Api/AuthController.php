<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuthSession;
use App\Models\RefreshToken;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'max:255'],
            'device_name' => ['required', 'string', 'max:255'],
        ]);

        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json([
                'message' => 'Email atau kata sandi tidak valid.',
            ], 401);
        }

        return DB::transaction(function () use ($user, $data): JsonResponse {
            $accessExpiresAt = now()->addMinutes(15);
            $refreshExpiresAt = now()->addDays(7);

            $session = AuthSession::create([
                'user_id' => $user->id,
                'device_name' => $data['device_name'],
                'expires_at' => $refreshExpiresAt,
            ]);

            $accessToken = $user->createToken(
                $data['device_name'],
                ['*'],
                $accessExpiresAt,
            );

            $accessToken->accessToken->forceFill([
                'auth_session_id' => $session->id,
            ])->save();

            $refreshToken = bin2hex(random_bytes(32));

            RefreshToken::create([
                'auth_session_id' => $session->id,
                'token_hash' => hash('sha256', $refreshToken),
                'expires_at' => $refreshExpiresAt,
            ]);

            return response()->json([
                'message' => 'Login berhasil.',
                'access_token' => $accessToken->plainTextToken,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
                'expires_in' => 900,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            ]);
        });
    }

    public function refresh(Request $request): JsonResponse
    {
        $data = $request->validate([
            'refresh_token' => ['required', 'string', 'size:64'],
        ]);

        $storedToken = RefreshToken::where(
            'token_hash',
            hash('sha256', $data['refresh_token']),
        )->first();

        if (! $storedToken) {
            return response()->json([
                'message' => 'Refresh token tidak valid.',
            ], 401);
        }

        return DB::transaction(function () use ($storedToken): JsonResponse {
            $session = AuthSession::whereKey($storedToken->auth_session_id)
                ->lockForUpdate()
                ->first();

            $refreshToken = RefreshToken::whereKey($storedToken->id)
                ->lockForUpdate()
                ->first();

            if (! $session || ! $refreshToken) {
                return response()->json([
                    'message' => 'Sesi tidak ditemukan.',
                ], 401);
            }

            if (
                $session->revoked_at !== null ||
                $session->expires_at->isPast() ||
                $refreshToken->revoked_at !== null ||
                $refreshToken->used_at !== null ||
                $refreshToken->expires_at->isPast()
            ) {
                $this->revokeSession($session);

                return response()->json([
                    'message' => 'Sesi tidak valid. Silakan login kembali.',
                ], 401);
            }

            $user = User::findOrFail($session->user_id);

            $refreshToken->update([
                'used_at' => now(),
            ]);

            DB::table('personal_access_tokens')
                ->where('auth_session_id', $session->id)
                ->delete();

            $accessExpiresAt = now()->addMinutes(15);

            if ($accessExpiresAt->greaterThan($session->expires_at)) {
                $accessExpiresAt = $session->expires_at->copy();
            }

            $newAccessToken = $user->createToken(
                $session->device_name,
                ['*'],
                $accessExpiresAt,
            );

            $newAccessToken->accessToken->forceFill([
                'auth_session_id' => $session->id,
            ])->save();

            $newRefreshToken = bin2hex(random_bytes(32));

            RefreshToken::create([
                'auth_session_id' => $session->id,
                'token_hash' => hash('sha256', $newRefreshToken),
                'expires_at' => $session->expires_at,
            ]);

            return response()->json([
                'message' => 'Token berhasil diperbarui.',
                'access_token' => $newAccessToken->plainTextToken,
                'refresh_token' => $newRefreshToken,
                'token_type' => 'Bearer',
                'expires_in' => max(
                    0,
                    $accessExpiresAt->getTimestamp() - now()->getTimestamp(),
                ),
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            ]);
        }, 5);
    }

    public function logout(Request $request): JsonResponse
    {
        $token = $request->user()->currentAccessToken();

        if (! $token instanceof PersonalAccessToken) {
            return response()->json([
                'message' => 'Access token tidak valid.',
            ], 401);
        }

        return DB::transaction(function () use ($request, $token): JsonResponse {
            $session = AuthSession::whereKey($token->auth_session_id)
                ->where('user_id', $request->user()->id)
                ->lockForUpdate()
                ->first();

            if ($session) {
                $this->revokeSession($session);
            } else {
                $token->delete();
            }

            return response()->json([
                'message' => 'Logout berhasil.',
            ]);
        }, 5);
    }

    private function revokeSession(AuthSession $session): void
    {
        $session->update([
            'revoked_at' => now(),
        ]);

        RefreshToken::where('auth_session_id', $session->id)
            ->whereNull('revoked_at')
            ->update([
                'revoked_at' => now(),
            ]);

        DB::table('personal_access_tokens')
            ->where('auth_session_id', $session->id)
            ->delete();
    }
}
