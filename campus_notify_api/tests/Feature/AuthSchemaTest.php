<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class AuthSchemaTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        // Selalu gunakan database sementara, termasuk jika .env memakai MySQL.
        config([
            'database.default' => 'sqlite',
            'database.connections.sqlite.database' => ':memory:',
            'database.connections.sqlite.url' => null,
            'database.connections.sqlite.foreign_key_constraints' => true,
        ]);
        DB::purge('sqlite');
        $this->artisan('migrate', ['--force' => true])->assertSuccessful();
    }

    public function test_deleting_a_session_removes_only_its_tokens(): void
    {
        $user = User::factory()->create();
        $sessionId = $this->createSession($user->id);
        $otherSessionId = $this->createSession($user->id);
        $this->createTokens($user->id, $sessionId, 'a');
        $this->createTokens($user->id, $otherSessionId, 'b');
        $this->createDevice($user->id);

        DB::table('auth_sessions')->where('id', $sessionId)->delete();

        $this->assertDatabaseMissing('personal_access_tokens', ['auth_session_id' => $sessionId]);
        $this->assertDatabaseMissing('refresh_tokens', ['auth_session_id' => $sessionId]);
        $this->assertDatabaseHas('personal_access_tokens', ['auth_session_id' => $otherSessionId]);
        $this->assertDatabaseHas('refresh_tokens', ['auth_session_id' => $otherSessionId]);
        $this->assertDatabaseHas('devices', ['user_id' => $user->id]);
        $this->assertModelExists($user);
    }

    public function test_deleting_a_user_removes_their_authentication_and_device_records(): void
    {
        $user = User::factory()->create();
        $sessionId = $this->createSession($user->id);
        $this->createTokens($user->id, $sessionId, 'a');
        $this->createDevice($user->id);

        $user->delete();

        $this->assertDatabaseEmpty('auth_sessions');
        $this->assertDatabaseEmpty('personal_access_tokens');
        $this->assertDatabaseEmpty('refresh_tokens');
        $this->assertDatabaseEmpty('devices');
    }

    public function test_the_same_fcm_token_cannot_belong_to_multiple_users(): void
    {
        $firstUser = User::factory()->create();
        $secondUser = User::factory()->create();
        $this->createDevice($firstUser->id);

        $this->expectException(QueryException::class);

        $this->createDevice($secondUser->id);
    }

    public function test_a_refresh_token_hash_cannot_be_reused_in_another_session(): void
    {
        $user = User::factory()->create();
        $firstSessionId = $this->createSession($user->id);
        $secondSessionId = $this->createSession($user->id);
        $this->createTokens($user->id, $firstSessionId, 'a');

        $this->expectException(QueryException::class);

        DB::table('refresh_tokens')->insert([
            'auth_session_id' => $secondSessionId,
            'token_hash' => str_repeat('a', 64),
            'expires_at' => '2030-01-08 00:00:00',
        ]);
    }

    public function test_authentication_migrations_can_be_rolled_back_and_reapplied(): void
    {
        $this->artisan('migrate:rollback', ['--step' => 5, '--force' => true])->assertSuccessful();

        $this->assertTrue(Schema::hasTable('users'));
        $this->assertFalse(Schema::hasTable('auth_sessions'));
        $this->assertFalse(Schema::hasTable('personal_access_tokens'));
        $this->assertFalse(Schema::hasTable('refresh_tokens'));
        $this->assertFalse(Schema::hasTable('devices'));

        $this->artisan('migrate', ['--force' => true])->assertSuccessful();
        $user = User::factory()->create();
        $sessionId = $this->createSession($user->id);
        $this->createTokens($user->id, $sessionId, 'a');
        $this->createDevice($user->id);

        $this->assertDatabaseHas('personal_access_tokens', ['auth_session_id' => $sessionId]);
        $this->assertDatabaseHas('refresh_tokens', ['auth_session_id' => $sessionId]);
        $this->assertDatabaseHas('devices', ['user_id' => $user->id]);
    }

    private function createSession(int $userId): int
    {
        return DB::table('auth_sessions')->insertGetId([
            'user_id' => $userId,
            'device_name' => 'Android praktikum',
            'expires_at' => '2030-01-08 00:00:00',
        ]);
    }

    private function createTokens(int $userId, int $sessionId, string $marker): void
    {
        DB::table('personal_access_tokens')->insert([
            'tokenable_type' => User::class,
            'tokenable_id' => $userId,
            'auth_session_id' => $sessionId,
            'name' => 'mobile-access',
            'token' => hash('sha256', 'access-'.$marker),
            'abilities' => '["*"]',
            'expires_at' => '2030-01-01 00:15:00',
        ]);
        DB::table('refresh_tokens')->insert([
            'auth_session_id' => $sessionId,
            'token_hash' => str_repeat($marker, 64),
            'expires_at' => '2030-01-08 00:00:00',
        ]);
    }

    private function createDevice(int $userId): void
    {
        $token = str_repeat('fcm-token-', 300);
        DB::table('devices')->insert([
            'user_id' => $userId,
            'platform' => 'android',
            'fcm_token' => $token,
            'fcm_token_hash' => hash('sha256', $token),
        ]);
    }
}
