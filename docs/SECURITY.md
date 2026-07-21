# DOKUMEN KEAMANAN & CHECKLIST REVIEW - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Threat Model
3. OWASP API Top 10 2023 & Mitigasi
4. OWASP Mobile Top 10 2024 & Mitigasi
5. Autentikasi (Sanctum + OTP + Consent)
6. Rate Limit Terpusat Redis
7. RBAC + Cluster Scope + Pencegahan IDOR
8. Validasi Input + SQL Injection + XSS
9. Keamanan Upload (S3 Private, tempUrl, Mime, UUID, Lifecycle)
10. Mass Assignment + CSRF
11. Audit Log (transaction_logs)
12. Enkripsi & Rotasi Kunci
13. Backup & S3 Versioning
14. Kebijakan Pengungkapan Kerentanan
15. OWASP API Top 10 2023 Checklist
16. OWASP Mobile Top 10 2024 Checklist
17. UU PDP Checklist
18. Infrastruktur, S3, Backup & SSL Checklist
19. Template Hasil Test
20. Sign-off & Persetujuan
21. Ringkasan & Rekomendasi

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Mengapa Keamanan Sangat Penting?

Grosirun adalah platform patungan yang menangani transaksi uang riil dan data pribadi warga. Keamanan adalah prioritas utama karena:

**Aset yang Dilindungi:**

| Kategori                  | Aset                                       | Contoh                                     |
| ------------------------- | ------------------------------------------ | ------------------------------------------ |
| **Data Pribadi (UU PDP)** | Nomor HP, nama, cluster, riwayat transaksi | `users.phone_number`, `orders.total_price` |
| **Data Keuangan**         | GMV, platform fee, margin initiator        | Rp8.400.000 per PO                         |
| **Bukti Transaksi**       | Gambar QRIS di S3                          | `order_proofs/{uuid}.jpg`                  |
| **Audit Trail**           | Log validasi, override, reject             | `transaction_logs`                         |

**Konsekuensi Jika Keamanan Gagal:**

| Skenario                       | Dampak                                    |
| ------------------------------ | ----------------------------------------- |
| Data breach (PII bocor)        | Pelanggaran UU PDP, denda hingga 2% omzet |
| IDOR (akses data orang lain)   | Kehilangan kepercayaan warga RT           |
| Oversell karena race condition | Sengketa dana, refund manual              |
| S3 bucket public               | Bukti QRIS bocor ke publik                |
| Akun diretas                   | Transaksi fiktif, kerugian finansial      |

### 1.2 Referensi BUSINESS_ANALYSIS.md

| Komponen              | Nilai               |
| --------------------- | ------------------- |
| Platform Fee          | 1% GMV + PPN 11%    |
| GMV per PO AT_70      | Rp8.400.000         |
| Laba Initiator per PO | Rp956.760           |
| Target Adopsi         | 70% (35 dari 50 KK) |

**Setiap pelanggaran keamanan dapat mengancam model bisnis ini.**

### 1.3 Ruang Lingkup

| Area              | Detail                                         |
| ----------------- | ---------------------------------------------- |
| **Backend API**   | Laravel 11, Sanctum, MySQL, Redis, S3          |
| **Mobile App**    | Flutter 3.22+, Hive, SecureStorage, Dio        |
| **Infrastruktur** | VPS Ubuntu, Nginx, PHP-FPM, Supervisor, Docker |
| **Third-party**   | Firebase FCM, Fonnte WA, Sentry, AWS S3        |

### 1.4 Level Keparahan

| Level        | Keterangan                                                                 | Wajib Lulus?     |
| ------------ | -------------------------------------------------------------------------- | ---------------- |
| **Critical** | Dapat menyebabkan data breach, kerugian finansial, atau pelanggaran UU PDP | ✅ WAJIB         |
| **High**     | Dapat dieksploitasi untuk akses tidak sah                                  | ✅ WAJIB         |
| **Medium**   | Risiko sedang, perbaikan di V1.1                                           | ❌ Boleh ditunda |
| **Low**      | Risiko rendah, nice-to-have                                                | ❌ Boleh ditunda |

---

## 2. Threat Model

### 2.1 Aset yang Dilindungi

**Data Pengguna (PII):**

- Nomor HP (E.164: 628xxx)
- Nama lengkap
- Cluster ID (RT)
- FCM Token
- Riwayat transaksi (orders)
- Bukti QRIS (gambar di S3)

**Data Bisnis:**

- `campaigns`: target_kg, current_kg, price_total_supplier
- `campaign_variants`: quota, sold
- `orders`: total_price, payment_status

**Audit:**

- `transaction_logs`: notes override, ip_address, initiator_id

### 2.2 Threat Actors

| Actor                   | Motivasi                                                                          | Kemampuan         |
| ----------------------- | --------------------------------------------------------------------------------- | ----------------- |
| **Buyer Malicious**     | Akses order orang lain (IDOR), oversell bypass, upload malware                    | Rendah - sedang   |
| **Initiator Malicious** | Validasi order bukan cluster sendiri, override tanpa notes, akses S3 cluster lain | Sedang            |
| **External Attacker**   | DDoS, brute force OTP, SQL injection, XSS, token theft                            | Tinggi            |
| **Insider (Dev)**       | Akses tidak sah ke database, S3, secrets                                          | Tinggi (dibatasi) |

### 2.3 Attack Vectors

| Vektor                  | Deskripsi                               | Mitigasi                                        |
| ----------------------- | --------------------------------------- | ----------------------------------------------- |
| **Unauthenticated API** | Endpoint tanpa auth                     | Semua endpoint (kecuali health, otp) pakai auth |
| **No Cluster Scope**    | Akses data cluster lain                 | Global Scope + Policy                           |
| **No Rate Limit**       | Brute force OTP, DDoS                   | Redis Rate Limiter                              |
| **File Upload**         | Path traversal `../../.env`, mime spoof | Random UUID, mime check, Intervention           |
| **Token Theft**         | Token di Hive (tidak aman)              | `flutter_secure_storage`                        |
| **S3 Public**           | Bucket public list, guessable filename  | Private bucket, tempUrl 1h, random UUID         |

### 2.4 Dampak

| Dampak                | Level    | Konsekuensi                    |
| --------------------- | -------- | ------------------------------ |
| Data breach UU PDP    | Critical | Denda, kehilangan kepercayaan  |
| Financial discrepancy | Critical | Sengketa dana, refund manual   |
| Reputation loss RT/RW | High     | Warga tidak mau pakai Grosirun |
| Service downtime      | Medium   | Kehilangan GMV sementara       |

---

## 3. OWASP API Top 10 2023 & Mitigasi

### 3.1 Ringkasan Mitigasi

| #         | OWASP API                                 | Mitigasi Grosirun V3.1                                                                                               | Status |
| --------- | ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------ |
| **API1**  | BOLA (Broken Object Level Auth)           | `OrderPolicy`: buyer hanya lihat order sendiri, initiator lihat order campaign sendiri + cluster sendiri. Test Pest. | ✅     |
| **API2**  | Broken Authentication                     | Sanctum expiry 30d, Hash OTP bcrypt, lock 15m after 5 fails, rate limit 5/min, SecureStorage token                   | ✅     |
| **API3**  | BOPLA (Broken Object Property Level Auth) | Mass assignment `$fillable` strict, buyer tidak bisa update `is_taken`                                               | ✅     |
| **API4**  | Unrestricted Resource Consumption         | Upload max 2MB proof, 5MB campaign, rate limit 60/min, S3 private tempUrl 1h                                         | ✅     |
| **API5**  | BFLA (Broken Function Level Auth)         | `RoleMiddleware` initiator untuk POST campaigns, admin untuk features                                                | ✅     |
| **API6**  | Unrestricted Sensitive Business Flows     | Batch max 100, override 10/min, extend max 2x, cancel only if target not reached                                     | ✅     |
| **API7**  | SSRF                                      | Tidak ada fetch URL dari user input, hanya upload file                                                               | ✅     |
| **API8**  | Security Misconfig                        | `APP_DEBUG=false` prod, `TELESCOPE_ENABLED=false`, S3 private, nginx deny dot files                                  | ✅     |
| **API9**  | Improper Inventory Management             | Versioning `/api/v1/`, Deprecation header, OpenAPI Scribe per version                                                | ✅     |
| **API10** | Unsafe Consumption APIs                   | Fonnte response validated, S3 SDK official, Firebase Admin SDK official                                              | ✅     |

### 3.2 Detail Mitigasi per OWASP

#### API1: Broken Object Level Authorization (BOLA)

**Implementasi OrderPolicy:**

```php
// app/Policies/OrderPolicy.php
class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        // Buyer: hanya order sendiri
        if ($user->id === $order->user_id) {
            return true;
        }

        // Initiator: hanya order campaign sendiri + cluster sendiri
        if ($user->role === 'initiator' &&
            $order->campaign->initiator_id === $user->id &&
            $order->cluster_id === $user->cluster_id) {
            return true;
        }

        return false;
    }

    public function validate(User $user, Order $order): bool
    {
        return $user->role === 'initiator' &&
               $order->campaign->initiator_id === $user->id &&
               $order->cluster_id === $user->cluster_id;
    }
}
```

**Testing:**

```php
// tests/Feature/OrderTest.php
test('buyer cannot view other buyer order', function () {
    $buyerA = User::factory()->create();
    $buyerB = User::factory()->create();
    $order = Order::factory()->create(['user_id' => $buyerB->id]);

    $response = $this->actingAs($buyerA)
        ->getJson("/api/v1/orders/{$order->uuid}");

    $response->assertStatus(403);
    $response->assertJson(['code' => 'ERR_021']);
});
```

#### API2: Broken Authentication

**OTP Flow:**

```php
// app/Services/OtpService.php
public function generateOtp(string $phone): string
{
    // Rate limit check
    $this->rateLimiter->check('otp', $phone, 5, 60);

    $otp = rand(1000, 9999);
    $hash = Hash::make($otp);

    OtpCode::create([
        'phone_number' => $phone,
        'otp_hash' => $hash,
        'expires_at' => now()->addMinutes(5),
        'attempts' => 0,
    ]);

    return $otp;
}

public function verifyOtp(string $phone, string $otp): bool
{
    $otpCode = OtpCode::where('phone_number', $phone)
        ->where('expires_at', '>', now())
        ->first();

    if (!$otpCode) {
        throw new HttpException(401, 'ERR_001 OTP_EXPIRED');
    }

    if ($otpCode->locked_until && $otpCode->locked_until > now()) {
        throw new HttpException(429, 'ERR_001_RL');
    }

    if (Hash::check($otp, $otpCode->otp_hash)) {
        $otpCode->delete();
        return true;
    }

    $otpCode->increment('attempts');

    if ($otpCode->attempts >= 5) {
        $otpCode->update(['locked_until' => now()->addMinutes(15)]);
        throw new HttpException(429, 'ERR_001_RL');
    }

    throw new HttpException(401, 'ERR_004 OTP_INVALID');
}
```

#### API4: Unrestricted Resource Consumption

**Upload Proof Validation:**

```php
// app/Http/Requests/UploadProofRequest.php
class UploadProofRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'proof' => [
                'required',
                'file',
                'mimes:jpg,png',
                'mimetypes:image/jpeg,image/png',
                'max:2048', // 2MB
            ],
        ];
    }
}
```

**Rate Limit Global:**

```php
// app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        'throttle:global-api',
        // ...
    ],
];

// app/Providers/AppServiceProvider.php
RateLimiter::for('global-api', function ($job) {
    return Limit::perMinute(60)->by($job->user()?->id ?: $job->ip());
});
```

---

## 4. OWASP Mobile Top 10 2024 & Mitigasi

### 4.1 Ringkasan Mitigasi

| #       | Mobile Top 10                        | Mitigasi Flutter                                                                      | Status |
| ------- | ------------------------------------ | ------------------------------------------------------------------------------------- | ------ |
| **M1**  | Improper Credential Usage            | Token di `flutter_secure_storage`, no hardcoded secrets, dart-define untuk SENTRY_DSN | ✅     |
| **M2**  | Inadequate Supply Chain              | Dependencies pinned `pubspec.lock`, Dependabot alerts                                 | ✅     |
| **M3**  | Insecure Authentication              | OTP + lock + consent + ToS, expiry 30d, logout clear SecureStorage                    | ✅     |
| **M4**  | Insufficient Input/Output Validation | Varian +/- no manual input, mime check client + server                                | ✅     |
| **M5**  | Insecure Communication               | HTTPS prod, `usesCleartextTraffic=false` prod, S3 tempUrl HTTPS                       | ✅     |
| **M6**  | Inadequate Privacy Controls          | Consent checkbox, DELETE account anonymize, proof lifecycle 90d                       | ✅     |
| **M7**  | Insufficient Binary Protection       | `--obfuscate`, `minifyEnabled=true`, `shrinkResources=true`                           | ✅     |
| **M8**  | Security Misconfig                   | `allowBackup=false`, `usesCleartextTraffic=false`, `extractNativeLibs=false`          | ✅     |
| **M9**  | Insecure Data Storage                | Token di SecureStorage, Hive tidak simpan token, S3 private tempUrl                   | ✅     |
| **M10** | Insufficient Cryptography            | OTP hash bcrypt, Sanctum hash SHA-256, S3 SSE-S3, TLS 1.2+                            | ✅     |

### 4.2 Detail Mitigasi per OWASP Mobile

#### M1: Improper Credential Usage

**Token di SecureStorage (bukan Hive):**

```dart
// lib/core/storage/secure_storage.dart
class SecureStorage {
  static const _tokenKey = 'auth_token';
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

**❌ Jangan:**

```dart
// ❌ BURUK - token di Hive tidak aman
await Hive.box('tokenBox').put('token', token);
```

#### M5: Insecure Communication

**AndroidManifest.xml (Production):**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="false"
    android:allowBackup="false"
    android:extractNativeLibs="false">
```

**Dio Base URL (Production):**

```dart
// lib/core/constants.dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.grosirun.id/api/v1', // Prod default
  );
}
```

#### M7: Insufficient Binary Protection

**Build Command:**

```bash
flutter build apk --release --split-per-abi --obfuscate \
    --split-debug-info=./build/debug-info \
    --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1 \
    --dart-define=SENTRY_DSN=...
```

**build.gradle:**

```gradle
// android/app/build.gradle
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

---

## 5. Autentikasi (Sanctum + OTP + Consent)

### 5.1 OTP Flow

| Langkah | Detail        | Keamanan                                              |
| ------- | ------------- | ----------------------------------------------------- |
| 1       | Request OTP   | Rate limit 5/menit per phone+IP                       |
| 2       | Generate OTP  | 4 digit random, hash bcrypt, expiry 5 menit           |
| 3       | Kirim OTP     | Via Fonnte WA (atau log di local dev)                 |
| 4       | Verify OTP    | Hash::check, attempts++, lock 15 menit jika >=5 gagal |
| 5       | Create User   | `firstOrCreate` dengan cluster_id                     |
| 6       | Consent Check | `consent_at` dan `tos_accepted_at` wajib              |
| 7       | Token         | Sanctum personal access token expiry 30 hari          |

### 5.2 Consent & ToS (UU PDP)

**Fields di `users` table:**

| Field             | Tipe        | Keterangan                  |
| ----------------- | ----------- | --------------------------- |
| `consent_at`      | datetime    | Waktu consent UU PDP        |
| `consent_version` | varchar(20) | Versi privacy policy (v1.0) |
| `tos_accepted_at` | datetime    | Waktu accept ToS non-escrow |
| `tos_version`     | varchar(20) | Versi ToS (v1.0)            |

**API Endpoints:**

```php
// routes/api/v1.php
Route::post('/auth/consent', [AuthController::class, 'consent']);
Route::post('/auth/tos-accept', [AuthController::class, 'tosAccept']);
Route::delete('/auth/account', [AuthController::class, 'deleteAccount']);
```

### 5.3 Token Expiry & Revocation

```php
// Login - create token
$token = $user->createToken('mobile', ['*'], now()->addDays(30))->plainTextToken;

// Logout - revoke token
$user->currentAccessToken()->delete();

// Delete account - revoke all tokens
$user->tokens()->delete();
```

---

## 6. Rate Limit Terpusat Redis

### 6.1 Konfigurasi Rate Limiter

| Route Group           | Limit    | Per             | Key Redis               |
| --------------------- | -------- | --------------- | ----------------------- |
| **Global API**        | 60/menit | user_id atau IP | `rl:global:{id}`        |
| **Request OTP**       | 5/menit  | phone+IP        | `rl:otp:{phone}:{ip}`   |
| **Verify OTP**        | 10/menit | phone           | `rl:otp-verify:{phone}` |
| **Validate Order**    | 30/menit | initiator_id    | `rl:validate:{user}`    |
| **Override Validate** | 10/menit | initiator_id    | `rl:override:{user}`    |
| **Upload Proof**      | 20/menit | user_id         | `rl:upload:{user}`      |

### 6.2 Implementasi

```php
// app/Providers/AppServiceProvider.php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

public function boot(): void
{
    RateLimiter::for('global-api', function ($job) {
        return Limit::perMinute(60)
            ->by($job->user()?->id ?: $job->ip())
            ->response(function () {
                return response()->json([
                    'message' => 'Too many requests',
                    'code' => 'ERR_060',
                    'retry_after' => 60,
                ], 429);
            });
    });

    RateLimiter::for('otp', function ($job) {
        $phone = $job->input('phone_number');
        $ip = $job->ip();
        return Limit::perMinute(5)
            ->by($phone . '|' . $ip)
            ->response(function () {
                return response()->json([
                    'message' => 'Terlalu banyak percobaan OTP',
                    'code' => 'ERR_001_RL',
                    'locked_until' => now()->addMinutes(15)->toIso8601String(),
                ], 429);
            });
    });
}
```

### 6.3 Testing

```bash
# Test rate limit OTP
for i in {1..6}; do
  curl -X POST https://api.grosirun.id/api/v1/auth/request-otp \
    -H "Content-Type: application/json" \
    -d '{"phone_number":"081234567890"}'
done
# Ke-6 harus 429

# Cek Redis keys
redis-cli KEYS "rl:*"
# rl:otp:6281234567890:127.0.0.1
```

---

## 7. RBAC + Cluster Scope + Pencegahan IDOR

### 7.1 Role & Middleware

**Role enum:** `buyer`, `initiator`, `admin`

**RoleMiddleware:**

```php
// app/Http/Middleware/RoleMiddleware.php
class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string $role): mixed
    {
        if (!$request->user() || $request->user()->role !== $role) {
            throw new HttpException(403, 'ERR_006 FORBIDDEN_ROLE');
        }
        return $next($request);
    }
}

// routes/api/v1.php
Route::middleware(['auth:sanctum', 'role:initiator'])->group(function () {
    Route::post('/campaigns', [CampaignController::class, 'store']);
});
```

### 7.2 Cluster Scope (Global)

**ClusterScope:**

```php
// app/Scopes/ClusterScope.php
class ClusterScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        if (auth()->check()) {
            $builder->where('cluster_id', auth()->user()->cluster_id);
        }
    }
}

// app/Models/Campaign.php
protected static function booted(): void
{
    static::addGlobalScope(new ClusterScope());
}
```

### 7.3 Policy

**OrderPolicy:**

```php
// app/Policies/OrderPolicy.php
class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        // Buyer: hanya order sendiri
        if ($user->id === $order->user_id) {
            return true;
        }

        // Initiator: hanya order campaign sendiri + cluster sendiri
        if ($user->role === 'initiator' &&
            $order->campaign->initiator_id === $user->id &&
            $order->cluster_id === $user->cluster_id) {
            return true;
        }

        return false;
    }
}
```

### 7.4 Testing IDOR

```bash
# Buyer A mencoba akses order Buyer B
curl -X GET https://api.grosirun.id/api/v1/orders/{uuid_B} \
  -H "Authorization: Bearer {token_A}"
# 403 ERR_021

# Buyer cluster 1 mencoba pesan campaign cluster 2
curl -X POST https://api.grosirun.id/api/v1/campaigns/2/orders \
  -H "Authorization: Bearer {token}" \
  -d '{"variant_id":1,"quantity":1,"payment_method":"cash"}'
# 403 ERR_040 CLUSTER_MISMATCH
```

---

## 8. Validasi Input + SQL Injection + XSS

### 8.1 FormRequest Validation

```php
// app/Http/Requests/StoreOrderRequest.php
class StoreOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'variant_id' => ['required', 'integer', 'exists:campaign_variants,id'],
            'quantity' => ['required', 'integer', 'min:1', 'max:100'],
            'payment_method' => ['required', 'string', 'in:cash,qris'],
        ];
    }

    public function messages(): array
    {
        return [
            'variant_id.exists' => 'ERR_026 VARIANT_NOT_FOUND',
            'quantity.min' => 'ERR_025 Minimal 1',
            'quantity.max' => 'ERR_025 Maksimal 100',
        ];
    }
}
```

### 8.2 Pencegahan SQL Injection

**✅ Aman - Eloquent ORM:**

```php
// Otomatis pakai binding
Campaign::where('name', 'LIKE', "%{$search}%")->get();
User::where('phone_number', $phone)->first();
```

**✅ Aman - Raw Query dengan Binding:**

```php
// Jangan tanpa binding!
DB::select('SELECT * FROM users WHERE id = ?', [$id]);
DB::select('SELECT * FROM users WHERE id = :id', ['id' => $id]);
```

**❌ Bahaya - Raw Query tanpa Binding:**

```php
// ❌ JANGAN PERNAH!
DB::select("SELECT * FROM users WHERE id = {$id}");
```

### 8.3 Pencegahan XSS

**✅ Aman - Resource escape otomatis:**

```php
// app/Http/Resources/CampaignResource.php
public function toArray($request): array
{
    return [
        'name' => $this->name, // Otomatis escape di JSON
        'description' => $this->description, // Otomatis escape
    ];
}
```

**✅ Aman - Flutter Text auto escape:**

```dart
// Flutter Text widget otomatis escape HTML
Text(campaign.name) // Aman
```

**❌ Bahaya - HTML widget tanpa sanitasi:**

```dart
// ❌ JANGAN - jika campaign.description mengandung script tag
HtmlWidget(campaign.description) // Berbahaya!
```

---

## 9. Keamanan Upload (S3 Private, tempUrl, Mime, UUID, Lifecycle)

### 9.1 Flow Upload

```
User Pick Image
    │
    ▼
Flutter: compress 70% (800x800)
    │
    ▼
API: validasi mime (jpg/png)
    │
    ▼
API: Intervention compress 80% (600x600)
    │
    ▼
API: generate random UUID filename
    │
    ▼
API: upload ke S3 private bucket
    │
    ▼
API: generate tempUrl 1h
    │
    ▼
Response: tempUrl ke user
```

### 9.2 Validasi Mime

```php
// app/Http/Requests/UploadProofRequest.php
public function rules(): array
{
    return [
        'proof' => [
            'required',
            'file',
            'mimes:jpg,png', // Extension
            'mimetypes:image/jpeg,image/png', // MIME type
            'max:2048', // 2MB
        ],
    ];
}

// app/Services/ImageService.php
public function validateImage(UploadedFile $file): void
{
    // Intervention memastikan file benar-benar gambar
    try {
        ImageManager::read($file->getPathname());
    } catch (\Exception $e) {
        throw new HttpException(422, 'ERR_051 UPLOAD_MIME_INVALID');
    }
}
```

### 9.3 Random UUID Filename

```php
// app/Services/ImageService.php
public function upload(UploadedFile $file, string $directory): string
{
    $uuid = (string) Str::uuid();
    $extension = $file->getClientOriginalExtension();
    $filename = "{$uuid}.{$extension}";
    $path = "{$directory}/{$filename}";

    // Upload ke S3 private
    Storage::disk('s3')->put($path, file_get_contents($file));

    return $path;
}
```

### 9.4 S3 Private & tempUrl

```php
// app/Services/ImageService.php
public function getTempUrl(string $path): string
{
    // Policy check di controller sebelum panggil ini
    return Storage::disk('s3')->temporaryUrl($path, now()->addHour());
}

// S3 Bucket Policy - Block Public Access ON
// Tidak ada public list
```

### 9.5 Lifecycle 90 Hari

**S3 Lifecycle Rule:**

```json
{
  "Rules": [
    {
      "ID": "delete-old-proofs-90d",
      "Filter": { "Prefix": "order_proofs/" },
      "Status": "Enabled",
      "Expiration": { "Days": 90 },
      "NoncurrentVersionExpiration": { "NoncurrentDays": 7 }
    }
  ]
}
```

**CleanOldProofsJob (Double Safety):**

```php
// app/Jobs/CleanOldProofsJob.php
Campaign::where('status', 'completed')
    ->where('distribution_completed_at', '<', now()->subDays(90))
    ->each(function ($campaign) {
        Order::where('campaign_id', $campaign->id)
            ->whereNotNull('proof_path')
            ->each(function ($order) {
                Storage::disk('s3')->delete($order->proof_path);
                $order->update(['proof_path' => null]);
            });
    });
```

---

## 10. Mass Assignment + CSRF

### 10.1 $fillable Strict

```php
// app/Models/Campaign.php
class Campaign extends Model
{
    // ✅ WHITELIST - hanya field ini yang boleh diisi massal
    protected $fillable = [
        'cluster_id',
        'initiator_id',
        'slug',
        'name',
        'description',
        'image_path',
        'target_kg',
        'current_kg',
        'price_total_supplier',
        'deadline',
        'status',
        'pickup_location',
        'distribution_completed_at',
    ];

    // ❌ JANGAN gunakan $guarded=[] (blacklist) - berisiko
    // protected $guarded = []; // ❌ BERBAHAYA!
}
```

### 10.2 CSRF

**API (Sanctum):** Tidak perlu CSRF token (stateless).

**Web Dashboard (Livewire V1.1):** Perlu CSRF token.

```blade
<!-- web/dashboard.blade.php -->
<form method="POST" action="/admin/campaigns">
    @csrf
    <!-- ... -->
</form>
```

---

## 11. Audit Log (transaction_logs)

### 11.1 Table Structure

```php
// database/migrations/create_transaction_logs_table.php
Schema::create('transaction_logs', function (Blueprint $table) {
    $table->id();
    $table->foreignId('order_id')->nullable()->constrained()->cascadeOnDelete();
    $table->foreignId('initiator_id')->constrained('users');
    $table->enum('type', [
        'validation', 'rejection', 'override', 'undo',
        'transfer', 'extend', 'cancel_campaign',
        'distribution', 'tos_accept', 'delete_account'
    ]);
    $table->string('notes', 500)->nullable();
    $table->string('ip_address', 45)->nullable();
    $table->timestamp('created_at')->useCurrent();

    $table->index('order_id');
    $table->index('initiator_id');
    $table->index('type');
    $table->index('created_at');
});
```

### 11.2 Logging

```php
// app/Services/OrderService.php
public function validate(Order $order, User $initiator): Order
{
    DB::transaction(function () use ($order, $initiator) {
        // ... validate logic ...

        TransactionLog::create([
            'order_id' => $order->id,
            'initiator_id' => $initiator->id,
            'type' => 'validation',
            'notes' => null,
            'ip_address' => request()->ip(),
        ]);
    });

    return $order;
}

public function override(Order $order, User $initiator, string $notes): Order
{
    DB::transaction(function () use ($order, $initiator, $notes) {
        // ... override logic ...

        TransactionLog::create([
            'order_id' => $order->id,
            'initiator_id' => $initiator->id,
            'type' => 'override',
            'notes' => $notes,
            'ip_address' => request()->ip(),
        ]);
    });

    return $order;
}
```

### 11.3 Data yang TIDAK boleh di log

| Data                 | Alasan                   |
| -------------------- | ------------------------ |
| OTP plain            | Password equivalent      |
| Nomor HP full        | PII, masking `62812****` |
| Password (tidak ada) | -                        |

---

## 12. Enkripsi & Rotasi Kunci

### 12.1 APP_KEY

**Generate:**

```bash
php artisan key:generate
# APP_KEY=base64:abc123def456...
```

**Lokasi:** `.env.prod` (di VPS + 1Password Vault)

**Rotasi:** `php artisan key:generate` → update `.env.prod` → reload FPM

### 12.2 S3 Encryption

| Level                  | Enkripsi       | Keterangan       |
| ---------------------- | -------------- | ---------------- |
| **At Rest**            | SSE-S3         | Default, AES-256 |
| **At Rest (Opsional)** | SSE-KMS        | Biaya tambahan   |
| **In Transit**         | HTTPS TLS 1.2+ | Let's Encrypt    |

### 12.3 Rotasi Kunci

| Kunci                    | Prosedur                                                   | Frekuensi |
| ------------------------ | ---------------------------------------------------------- | --------- |
| **APP_KEY**              | `php artisan key:generate` + update .env.prod + reload FPM | 1 tahun   |
| **S3 IAM Keys**          | Buat key baru → update .env.prod → revoke old              | 1 tahun   |
| **Firebase Credentials** | Generate new Service Account → update JSON → revoke old    | 1 tahun   |
| **FONNTE Token**         | Regenerate di dashboard Fonnte → update .env.prod          | 6 bulan   |
| **Database Password**    | Buat user baru → update .env.prod → delete old             | 1 tahun   |

---

## 13. Backup & S3 Versioning

### 13.1 Backup Strategy

| Komponen        | Frekuensi     | Retention | Lokasi          | Enkripsi |
| --------------- | ------------- | --------- | --------------- | -------- |
| **Database**    | Daily 02:00   | 7 hari    | S3 `backups/`   | SSE-S3   |
| **S3 Files**    | Versioning ON | Forever   | S3 bucket       | SSE-S3   |
| **Source Code** | Tag vX.Y.Z    | Forever   | GitHub          | -        |
| **Secrets**     | Manual        | Forever   | 1Password Vault | -        |

### 13.2 Backup Command

```bash
# Spatie Backup
php artisan backup:run --only-db

# Restore
php artisan backup:restore

# Manual MySQL
mysql -u grosirun -p grosirun < /path/to/backup.sql
```

### 13.3 S3 Versioning

**Versioning ON:** Setiap file punya versi history.

**Lifecycle:** Noncurrent version expiration 7 hari (setelah 7 hari, old version dihapus).

**Recovery:**

```bash
# Restore file dari versioning
aws s3api list-object-versions --bucket grosirun-prod-private --prefix order_proofs/uuid.jpg
aws s3api get-object --bucket grosirun-prod-private --key order_proofs/uuid.jpg --version-id <version-id> restored.jpg
```

---

## 14. Kebijakan Pengungkapan Kerentanan

### 14.1 Kontak

**Email:** `security@grosirun.id`

**PGP Key:** [Tersedia di security@grosirun.id]

### 14.2 Kebijakan

| Aspek              | Detail                                                                                       |
| ------------------ | -------------------------------------------------------------------------------------------- |
| **Pelaporan**      | Email ke `security@grosirun.id` dengan detail langkah-langkah. **Jangan buka issue publik.** |
| **Acknowledgment** | Kami akan merespons dalam 24 jam                                                             |
| **Perbaikan**      | Critical: 7 hari, Medium: 30 hari, Low: 60 hari                                              |
| **Cakupan**        | Grosirun API (api.grosirun.id), Mobile App (com.grosirun.app)                                |
| **Tidak termasuk** | DDoS, social engineering, physical attacks                                                   |
| **Credit**         | Kami akan cantumkan nama reporter di Hall of Fame (kecuali anonim)                           |
| **Bounty**         | Tidak ada untuk MVP (mungkin V1.1)                                                           |

### 14.3 Hall of Fame

| Nama | Kerentanan | Tahun |
| ---- | ---------- | ----- |
| -    | -          | -     |

---

## 15. OWASP API Top 10 2023 Checklist

### 15.1 API1: Broken Object Level Authorization (BOLA)

| #   | Test Case                              | Prosedur                                             | Ekspektasi                       | Level    | Hasil           | Bukti                  |
| --- | -------------------------------------- | ---------------------------------------------------- | -------------------------------- | -------- | --------------- | ---------------------- |
| 1   | Buyer A akses order Buyer B            | Buyer A login, GET `/orders/{uuid_B}` milik Buyer B  | 403 ERR_021, log Sentry critical | Critical | ☐ Pass / ☐ Fail | Screenshot Postman 403 |
| 2   | Buyer akses endpoint admin             | Buyer login, GET `/campaigns/12/orders` (admin only) | 403 ERR_006                      | Critical | ☐ Pass / ☐ Fail | Screenshot Postman 403 |
| 3   | Buyer pesan campaign cluster lain      | Buyer cluster 1 POST orders campaign cluster 2       | 403 ERR_040 CLUSTER_MISMATCH     | Critical | ☐ Pass / ☐ Fail | Screenshot Postman 403 |
| 4   | Buyer akses proof URL order orang lain | Buyer A GET proof-url order Buyer B                  | 403 Policy                       | Critical | ☐ Pass / ☐ Fail | Screenshot Postman 403 |

### 15.2 API2: Broken Authentication

| #   | Test Case                           | Prosedur                                                                                    | Ekspektasi                               | Level    | Hasil           | Bukti                                   |
| --- | ----------------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------- | -------- | --------------- | --------------------------------------- |
| 5   | Rate limit OTP 5/menit              | POST `/auth/request-otp` 6x dalam 1 menit (phone+IP sama)                                   | 5 sukses 200, ke-6 429 + `locked_until`  | Critical | ☐ Pass / ☐ Fail | Screenshot Redis keys `rl:otp:*`        |
| 6   | Lock OTP setelah 5 gagal            | Verify OTP salah 5x berturut-turut                                                          | `attempts` naik, ke-5 lock 15 menit, 429 | High     | ☐ Pass / ☐ Fail | DB `otp_codes.attempts`, `locked_until` |
| 7   | Token expiry 30 hari                | Gunakan token >30 hari (simulasikan)                                                        | 401 UNAUTHENTICATED                      | Critical | ☐ Pass / ☐ Fail | Screenshot 401                          |
| 8   | Token di SecureStorage (bukan Hive) | Cek kode Flutter: token disimpan di `flutter_secure_storage`, tidak ada `Hive.box('token')` | Token di SecureStorage                   | Critical | ☐ Pass / ☐ Fail | Code snippet                            |

### 15.3 API3: Broken Object Property Level Authorization (BOPLA) & Mass Assignment

| #   | Test Case                            | Prosedur                                                                    | Ekspektasi                                         | Level | Hasil           | Bukti                  |
| --- | ------------------------------------ | --------------------------------------------------------------------------- | -------------------------------------------------- | ----- | --------------- | ---------------------- |
| 9   | Buyer ubah `is_taken`                | Buyer PATCH `/orders/{uuid}` dengan field `is_taken=true` (hanya initiator) | 403                                                | High  | ☐ Pass / ☐ Fail | Screenshot Postman 403 |
| 10  | Mass assignment pada create campaign | POST `/campaigns` dengan extra field `is_taken` atau `status=completed`     | Field extra tidak tersimpan, status tetap `active` | High  | ☐ Pass / ☐ Fail | Test Pest              |
| 11  | Mass assignment pada update profil   | PUT `/auth/profile` dengan field `role=admin`                               | Role tidak berubah                                 | High  | ☐ Pass / ☐ Fail | Test Pest              |

### 15.4 API4: Unrestricted Resource Consumption

| #   | Test Case                  | Prosedur                             | Ekspektasi  | Level    | Hasil           | Bukti       |
| --- | -------------------------- | ------------------------------------ | ----------- | -------- | --------------- | ----------- |
| 12  | Upload proof >2MB          | POST `/orders/{uuid}/proof` file 3MB | 422 ERR_050 | High     | ☐ Pass / ☐ Fail | Postman 422 |
| 13  | Upload campaign image >5MB | POST `/campaigns` file 6MB           | 422         | High     | ☐ Pass / ☐ Fail | Postman 422 |
| 14  | Rate limit global 60/menit | 61 request dalam 1 menit             | 61st 429    | Critical | ☐ Pass / ☐ Fail | k6 70 VUs   |

### 15.5 API5: Broken Function Level Authorization (BFLA)

| #   | Test Case                   | Prosedur                                                 | Ekspektasi         | Level    | Hasil           | Bukti       |
| --- | --------------------------- | -------------------------------------------------------- | ------------------ | -------- | --------------- | ----------- |
| 15  | Buyer POST /campaigns       | Buyer login, POST `/campaigns`                           | 403 role initiator | Critical | ☐ Pass / ☐ Fail | Postman 403 |
| 16  | Buyer POST /admin/features  | Buyer login, POST `/admin/features/qris-upload/activate` | 403 admin only     | Critical | ☐ Pass / ☐ Fail | Postman 403 |
| 17  | Buyer akses dashboard admin | Buyer login, GET `/campaigns/12/orders`                  | 403                | Critical | ☐ Pass / ☐ Fail | Postman 403 |

### 15.6 API6: Unrestricted Access to Sensitive Business Flows

| #   | Test Case                   | Prosedur                             | Ekspektasi                    | Level | Hasil           | Bukti       |
| --- | --------------------------- | ------------------------------------ | ----------------------------- | ----- | --------------- | ----------- |
| 18  | Batch validate >100 uuids   | POST batch-validate dengan 101 uuids | 422 max 100                   | High  | ☐ Pass / ☐ Fail | Postman 422 |
| 19  | Extend >2 kali              | Perpanjang campaign 3 kali           | 3rd 409 CAMPAIGN_EXTEND_LIMIT | High  | ☐ Pass / ☐ Fail | Postman 409 |
| 20  | Override validate >10/menit | Override 11x dalam 1 menit           | 11th 429                      | High  | ☐ Pass / ☐ Fail | Postman 429 |

### 15.7 API7: SSRF

| #   | Test Case                      | Prosedur                                               | Ekspektasi                                   | Level  | Hasil           | Bukti       |
| --- | ------------------------------ | ------------------------------------------------------ | -------------------------------------------- | ------ | --------------- | ----------- |
| 21  | Upload campaign via URL remote | POST `/campaigns` dengan field `image_url` (tidak ada) | Tidak ada fitur fetch URL, hanya upload file | Medium | ☐ Pass / ☐ Fail | Code review |

### 15.8 API8: Security Misconfiguration

| #   | Test Case                 | Prosedur              | Ekspektasi                                   | Level    | Hasil           | Bukti                |
| --- | ------------------------- | --------------------- | -------------------------------------------- | -------- | --------------- | -------------------- |
| 22  | `APP_DEBUG=false` di prod | Cek `.env.prod`       | `APP_DEBUG=false`, `TELESCOPE_ENABLED=false` | Critical | ☐ Pass / ☐ Fail | Screenshot .env.prod |
| 23  | S3 bucket private         | Cek AWS console       | Block public access ON, no public list       | Critical | ☐ Pass / ☐ Fail | Screenshot console   |
| 24  | CORS terbatas             | Cek `config/cors.php` | `allowed_origins` hanya domain Grosirun      | High     | ☐ Pass / ☐ Fail | Code snippet         |
| 25  | Nginx deny dot files      | Cek `nginx.conf`      | `location ~ /\. {deny all;}`                 | High     | ☐ Pass / ☐ Fail | nginx.conf snippet   |

### 15.9 API9: Improper Inventory Management

| #   | Test Case                        | Prosedur                                   | Ekspektasi                                 | Level  | Hasil           | Bukti              |
| --- | -------------------------------- | ------------------------------------------ | ------------------------------------------ | ------ | --------------- | ------------------ |
| 26  | Endpoint deprecated punya header | GET `/campaigns/{id}/old-recap` (jika ada) | Header `Deprecation: true`, `Sunset: date` | Medium | ☐ Pass / ☐ Fail | `curl -I`          |
| 27  | OpenAPI docs tersedia            | Akses `/docs`                              | OpenAPI spec untuk v1                      | Low    | ☐ Pass / ☐ Fail | Browser screenshot |

### 15.10 API10: Unsafe Consumption of APIs

| #   | Test Case                  | Prosedur              | Ekspektasi                                                | Level  | Hasil           | Bukti         |
| --- | -------------------------- | --------------------- | --------------------------------------------------------- | ------ | --------------- | ------------- |
| 28  | Fonnte response divalidasi | Cek kode `OtpService` | `Http::post()` response JSON divalidasi, tidak ada `eval` | High   | ☐ Pass / ☐ Fail | Code review   |
| 29  | Firebase SDK official      | Cek `composer.json`   | `kreait/laravel-firebase` official                        | Medium | ☐ Pass / ☐ Fail | composer.json |

---

## 16. OWASP Mobile Top 10 2024 Checklist

### 16.1 M1: Improper Credential Usage

| #   | Test Case                   | Prosedur                                                        | Ekspektasi                                       | Level    | Hasil           | Bukti        |
| --- | --------------------------- | --------------------------------------------------------------- | ------------------------------------------------ | -------- | --------------- | ------------ |
| 30  | Tidak ada hardcoded secrets | `grep -r "AKIA\|FONNTE\|SENTRY" lib/`                           | Tidak ada hardcoded, semua via dart-define / env | Critical | ☐ Pass / ☐ Fail | Grep output  |
| 31  | Token di SecureStorage      | `grep -r "SecureStorage" lib/` vs `grep -r "Hive.box('token')"` | Token di SecureStorage, bukan Hive               | Critical | ☐ Pass / ☐ Fail | Code snippet |

### 16.2 M2: Inadequate Supply Chain

| #   | Test Case           | Prosedur           | Ekspektasi                    | Level  | Hasil           | Bukti             |
| --- | ------------------- | ------------------ | ----------------------------- | ------ | --------------- | ----------------- |
| 32  | Dependencies pinned | Cek `pubspec.lock` | Versi pinned, tidak ada `any` | Medium | ☐ Pass / ☐ Fail | pubspec.lock      |
| 33  | Dependabot aktif    | Cek GitHub         | Dependabot alerts enabled     | Low    | ☐ Pass / ☐ Fail | GitHub screenshot |

### 16.3 M3: Insecure Authentication

| #   | Test Case                  | Prosedur            | Ekspektasi           | Level    | Hasil           | Bukti         |
| --- | -------------------------- | ------------------- | -------------------- | -------- | --------------- | ------------- |
| 34  | OTP lock 15 menit          | 5 gagal → lock      | 5th lock, 429        | Critical | ☐ Pass / ☐ Fail | Manual test   |
| 35  | Consent wajib              | Login tanpa consent | 422 CONSENT_REQUIRED | Critical | ☐ Pass / ☐ Fail | Screenshot UI |
| 36  | Token expiry 30 hari       | Simulasikan         | 401 setelah 30 hari  | Critical | ☐ Pass / ☐ Fail | Manual test   |
| 37  | Logout clear SecureStorage | Logout, cek token   | Token dihapus        | High     | ☐ Pass / ☐ Fail | Code + manual |

### 16.4 M4: Insufficient Input/Output Validation

| #   | Test Case                       | Prosedur         | Ekspektasi                                       | Level  | Hasil           | Bukti         |
| --- | ------------------------------- | ---------------- | ------------------------------------------------ | ------ | --------------- | ------------- |
| 38  | Varian paten +/- no manual text | Cek UI checkout  | Hanya tombol + dan -, tidak ada text field angka | Medium | ☐ Pass / ☐ Fail | Screenshot UI |
| 39  | Proof mime jpg/png              | Upload file .exe | Gagal, mime validation                           | High   | ☐ Pass / ☐ Fail | Manual test   |

### 16.5 M5: Insecure Communication

| #   | Test Case         | Prosedur                  | Ekspektasi                                      | Level    | Hasil           | Bukti            |
| --- | ----------------- | ------------------------- | ----------------------------------------------- | -------- | --------------- | ---------------- |
| 40  | Prod HTTPS only   | Cek `AndroidManifest.xml` | `android:usesCleartextTraffic="false"` prod     | Critical | ☐ Pass / ☐ Fail | Manifest snippet |
| 41  | Dio baseUrl HTTPS | Cek `constants.dart`      | `API_BASE_URL` prod = `https://api.grosirun.id` | Critical | ☐ Pass / ☐ Fail | Code snippet     |
| 42  | S3 tempUrl HTTPS  | Cek generated URL         | `https://s3...`                                 | High     | ☐ Pass / ☐ Fail | Manual test      |

### 16.6 M6: Inadequate Privacy Controls

| #   | Test Case                | Prosedur         | Ekspektasi                         | Level    | Hasil           | Bukti                 |
| --- | ------------------------ | ---------------- | ---------------------------------- | -------- | --------------- | --------------------- |
| 43  | Consent checkbox ada     | Login flow       | Checkbox "Setuju UU PDP"           | Critical | ☐ Pass / ☐ Fail | Screenshot            |
| 44  | Privacy Policy link ada  | Login flow       | Link ke PRIVACY_POLICY.md          | Critical | ☐ Pass / ☐ Fail | Screenshot            |
| 45  | DELETE account anonymize | Hapus akun       | 202 Accepted, job AnonymizeUserJob | Critical | ☐ Pass / ☐ Fail | Manual test           |
| 46  | Proof lifecycle 90d      | Cek S3 lifecycle | S3 rule 90d + CleanOldProofsJob    | High     | ☐ Pass / ☐ Fail | Screenshot S3 console |

### 16.7 M7: Insufficient Binary Protection

| #   | Test Case          | Prosedur           | Ekspektasi                                        | Level  | Hasil           | Bukti                |
| --- | ------------------ | ------------------ | ------------------------------------------------- | ------ | --------------- | -------------------- |
| 47  | APK obfuscate      | Build command      | Mengandung `--obfuscate` dan `--split-debug-info` | Medium | ☐ Pass / ☐ Fail | Build script         |
| 48  | minifyEnabled true | Cek `build.gradle` | `isMinifyEnabled true`, `isShrinkResources true`  | Medium | ☐ Pass / ☐ Fail | build.gradle snippet |

### 16.8 M8: Security Misconfiguration

| #   | Test Case               | Prosedur                  | Ekspektasi                          | Level | Hasil           | Bukti            |
| --- | ----------------------- | ------------------------- | ----------------------------------- | ----- | --------------- | ---------------- |
| 49  | allowBackup false       | Cek `AndroidManifest.xml` | `android:allowBackup="false"`       | Low   | ☐ Pass / ☐ Fail | Manifest snippet |
| 50  | extractNativeLibs false | Cek `AndroidManifest.xml` | `android:extractNativeLibs="false"` | Low   | ☐ Pass / ☐ Fail | Manifest snippet |

### 16.9 M9: Insecure Data Storage

| #   | Test Case                       | Prosedur | Ekspektasi                           | Level    | Hasil           | Bukti |
| --- | ------------------------------- | -------- | ------------------------------------ | -------- | --------------- | ----- |
| 51  | Token di SecureStorage          | Cek      | Token di SecureStorage               | Critical | ☐ Pass / ☐ Fail | Code  |
| 52  | Proof tidak di external storage | Cek      | File sementara di app docs (private) | High     | ☐ Pass / ☐ Fail | Code  |

### 16.10 M10: Insufficient Cryptography

| #   | Test Case          | Prosedur         | Ekspektasi                    | Level  | Hasil           | Bukti     |
| --- | ------------------ | ---------------- | ----------------------------- | ------ | --------------- | --------- |
| 53  | OTP hash bcrypt    | Cek `OtpService` | `Hash::make()` bcrypt         | High   | ☐ Pass / ☐ Fail | Code      |
| 54  | Sanctum token hash | Cek              | SHA-256 di DB                 | High   | ☐ Pass / ☐ Fail | Code      |
| 55  | S3 SSE-S3          | Cek S3 bucket    | Encryption at rest SSE-S3     | Medium | ☐ Pass / ☐ Fail | Console   |
| 56  | APP_KEY random     | Cek .env.prod    | `APP_KEY=base64:...` 32 chars | High   | ☐ Pass / ☐ Fail | .env.prod |

---

## 17. UU PDP Checklist

| #   | Check                             | Ekspektasi                                                                                   | Level    | Hasil           | Bukti                  |
| --- | --------------------------------- | -------------------------------------------------------------------------------------------- | -------- | --------------- | ---------------------- |
| 57  | Consent checkbox ada              | UI checkbox + POST `/auth/consent` log `consent_at`                                          | Critical | ☐ Pass / ☐ Fail | Screenshot UI          |
| 58  | ToS non-escrow scroll + checkbox  | UI scroll + checkbox + POST `/auth/tos-accept` log `tos_accepted_at`                         | Critical | ☐ Pass / ☐ Fail | Screenshot UI          |
| 59  | Privacy Policy screen             | Full text PRIVACY_POLICY.md di app                                                           | Critical | ☐ Pass / ☐ Fail | Screenshot UI          |
| 60  | DELETE /auth/account anonymize    | 202 Accepted + job AnonymizeUserJob + S3 proofs deleted + orders anonymized + tokens revoked | Critical | ☐ Pass / ☐ Fail | Manual test            |
| 61  | Retensi proof 90d auto delete     | S3 lifecycle rule 90d + CleanOldProofsJob daily                                              | High     | ☐ Pass / ☐ Fail | S3 console + scheduler |
| 62  | Data retention policy doc         | PRIVACY_POLICY.md tabel retensi                                                              | High     | ☐ Pass / ☐ Fail | PRIVACY_POLICY.md      |
| 63  | Log tidak mengandung PII plain    | `Log::info` phone masked (628\*\*\*\*), tidak ada OTP plain di prod                          | Critical | ☐ Pass / ☐ Fail | Code review            |
| 64  | Hak akses data via GET /auth/me   | User bisa lihat data pribadi                                                                 | Medium   | ☐ Pass / ☐ Fail | Manual test            |
| 65  | Hak koreksi via PUT /auth/profile | User bisa update nama                                                                        | Medium   | ☐ Pass / ☐ Fail | Manual test            |

---

## 18. Infrastruktur, S3, Backup & SSL Checklist

| #   | Check                                    | Ekspektasi                                                              | Level    | Hasil           | Bukti                  |
| --- | ---------------------------------------- | ----------------------------------------------------------------------- | -------- | --------------- | ---------------------- |
| 66  | S3 bucket private Block public access ON | AWS console screenshot Block public ON                                  | Critical | ☐ Pass / ☐ Fail | Screenshot console     |
| 67  | S3 tempUrl 1h hanya authorized           | Test Buyer A GET proof-url Buyer B → 403 Policy                         | Critical | ☐ Pass / ☐ Fail | Manual test            |
| 68  | S3 lifecycle 90d proofs                  | S3 Management Lifecycle rule 90d                                        | High     | ☐ Pass / ☐ Fail | Screenshot console     |
| 69  | S3 versioning ON                         | Console versioning ON                                                   | Medium   | ☐ Pass / ☐ Fail | Screenshot console     |
| 70  | Backup daily S3 retention 7d             | S3 `backups/` folder daily, cron 02:00                                  | High     | ☐ Pass / ☐ Fail | S3 listing + cron      |
| 71  | Restore drill done <1h RTO               | DISASTER_RECOVERY_DRILL_REPORT.md filled (time <1h)                     | Critical | ☐ Pass / ☐ Fail | Drill report           |
| 72  | SSL expiry >7 days monitoring            | GET `/health` returns `ssl_expires_in_days >7`, `check-ssl.sh` cron     | High     | ☐ Pass / ☐ Fail | Health response + cron |
| 73  | Blue-green zero-downtime health check    | `deploy-blue-green.sh` health check before switch, no 503 during deploy | High     | ☐ Pass / ☐ Fail | Deploy log             |
| 74  | Rollback automation `rollback.sh`        | Tested switch back, supervisor restart, Slack notify                    | High     | ☐ Pass / ☐ Fail | Rollback log           |
| 75  | Rate limit Redis keys                    | `redis-cli KEYS "rl:*"` exists after 6 OTP requests                     | High     | ☐ Pass / ☐ Fail | Redis screenshot       |
| 76  | Feature flags Pennant                    | `php artisan pennant:feature list` + toggle tanpa deploy                | Medium   | ☐ Pass / ☐ Fail | Terminal output        |
| 77  | Idempotency Redis                        | `redis-cli KEYS "idempotency:*"` after POST orders                      | High     | ☐ Pass / ☐ Fail | Redis screenshot       |
| 78  | ETag header present                      | `curl -I /campaigns` returns ETag, Cache-Control max-age=60             | Medium   | ☐ Pass / ☐ Fail | curl output            |
| 79  | .env.prod tidak di repo                  | Cek repo, tidak ada .env.prod                                           | Critical | ☐ Pass / ☐ Fail | Repo check             |
| 80  | Secrets di 1Password vault               | .env.prod tersimpan di 1Password                                        | High     | ☐ Pass / ☐ Fail | 1Password screenshot   |

---

## 19. Template Hasil Test

### 19.1 Laporan Ringkasan

```markdown
# LAPORAN REVIEW KEAMANAN - Grosirun V3.1

**Tanggal:** 20 Juli 2026
**Tester:** Backend Lead, Mobile Lead
**Environment:** Docker prod clone + S3 MinIO + Firebase dev + VPS staging api.staging.grosirun.id

## Ringkasan

| Kategori            | Total  | Pass  | Fail  | Critical Fail |
| ------------------- | ------ | ----- | ----- | ------------- |
| OWASP API Top 10    | 29     | 0     | 0     | 0             |
| OWASP Mobile Top 10 | 27     | 0     | 0     | 0             |
| UU PDP              | 9      | 0     | 0     | 0             |
| Infra & Security    | 15     | 0     | 0     | 0             |
| **Total**           | **80** | **0** | **0** | **0**         |

## Critical Items (Wajib Lulus)

| #   | Item                           | Result | Evidence              |
| --- | ------------------------------ | ------ | --------------------- |
| 1   | BOLA Buyer A GET Buyer B order | Pass   | Screenshot: [link]    |
| 2   | OTP rate limit 5/min           | Pass   | Redis keys screenshot |
| 3   | S3 bucket private              | Pass   | Console screenshot    |
| ... | ...                            | ...    | ...                   |

## High Items

| #   | Item | Result | Evidence |
| --- | ---- | ------ | -------- |
| ... | ...  | ...    | ...      |

## Medium & Low Items (Nice-to-Have)

| #   | Item | Result | Evidence |
| --- | ---- | ------ | -------- |
| ... | ...  | ...    | ...      |

## Issues Found (Jika ada)

| #   | Severity | Issue                           | Fix             | Status          |
| --- | -------- | ------------------------------- | --------------- | --------------- |
| 1   | High     | [Contoh: CORS terlalu permisif] | [Fix di config] | ✅ Fixed        |
| 2   | Medium   | [Contoh: allowBackup true]      | [Set false]     | ⏳ Pending V1.1 |

## Kesimpulan

- **Critical & High:** ✅ SEMUA LULUS
- **Medium & Low:** [Jumlah] fail (akan di V1.1)
- **Overall:** ✅ PASS / ❌ FAIL (jika ada critical fail)

## Sign-off

- [ ] Backend Lead
- [ ] Mobile Lead
- [ ] Product Owner
- [ ] Infra (opsional)
```

### 19.2 Cara Mengisi

1. **Jalankan semua test case** sesuai prosedur
2. **Catat hasil** (Pass/Fail) di kolom "Hasil"
3. **Sertakan bukti** (screenshot, log, code snippet) di kolom "Bukti"
4. **Jika Fail Critical**: buat issue, fix, re-test
5. **Tandatangani** setelah semua Critical & High lulus

---

## 20. Sign-off & Persetujuan

### 20.1 Kriteria Go-Live

| Syarat                      | Status |
| --------------------------- | ------ |
| Semua Critical checklist ✅ | ☐      |
| Semua High checklist ✅     | ☐      |
| Tidak ada Critical fail     | ☐      |
| Tidak ada High fail         | ☐      |
| UU PDP checklist ✅         | ☐      |
| S3 + Backup + SSL ✅        | ☐      |

### 20.2 Tanda Tangan

| Peran                   | Nama   | Tanggal   | Tanda Tangan |
| ----------------------- | ------ | --------- | ------------ |
| **Backend Lead**        | [Nama] | [Tanggal] | [ ]          |
| **Mobile Lead**         | [Nama] | [Tanggal] | [ ]          |
| **Product Owner**       | [Nama] | [Tanggal] | [ ]          |
| **Infra (opsional)**    | [Nama] | [Tanggal] | [ ]          |
| **Security (opsional)** | [Nama] | [Tanggal] | [ ]          |

### 20.3 Catatan Tambahan

```markdown
[Isi catatan jika ada, misalnya: "3rd party pentest akan dilakukan V1.1 sebelum public launch"]
```

---

## 21. Ringkasan & Rekomendasi

### 21.1 Ringkasan Mitigasi

| Kategori                | Status | Keterangan                           |
| ----------------------- | ------ | ------------------------------------ |
| **OWASP API Top 10**    | ✅     | 10/10 mitgasi                        |
| **OWASP Mobile Top 10** | ✅     | 10/10 mitgasi                        |
| **UU PDP**              | ✅     | Consent, retensi 90d, hak hapus      |
| **S3 Security**         | ✅     | Private, tempUrl 1h, lifecycle 90d   |
| **Rate Limit**          | ✅     | Redis terpusat, 6 route groups       |
| **Auth**                | ✅     | OTP + Sanctum + Consent              |
| **Audit Log**           | ✅     | transaction_logs semua aksi sensitif |
| **Backup & DR**         | ✅     | Daily S3, RTO 1h, RPO 24h            |

### 21.2 Rekomendasi V1.1

| #   | Rekomendasi                                              | Priority |
| --- | -------------------------------------------------------- | -------- |
| 1   | Hive encryption untuk ordersBox (key dari SecureStorage) | Medium   |
| 2   | 3rd Party Penetration Testing (OWASP ZAP / Burp Suite)   | High     |
| 3   | Security Headers (HSTS, CSP, X-Frame-Options)            | Medium   |
| 4   | API Rate Limit per endpoint yang lebih granular          | Low      |
| 5   | Web Application Firewall (WAF) Cloudflare                | Medium   |

### 21.3 Checklist Final

| Item                                | Status |
| ----------------------------------- | ------ |
| [ ] Threat Model documented         | ☐      |
| [ ] OWASP API Top 10 mitgasi        | ☐      |
| [ ] OWASP Mobile Top 10 mitgasi     | ☐      |
| [ ] UU PDP compliance               | ☐      |
| [ ] Rate Limit Redis aktif          | ☐      |
| [ ] S3 private + tempUrl 1h         | ☐      |
| [ ] Audit Log aktif                 | ☐      |
| [ ] Backup S3 daily                 | ☐      |
| [ ] SSL expiry monitoring           | ☐      |
| [ ] Vulnerability Disclosure Policy | ☐      |

---

**Dokumen Keamanan & Checklist Review V3.1 Production Ready - Threat Model, OWASP API+Mobile, S3 Private, UU PDP, Audit Log, Key Rotation, Review Checklist!** 🔒✅
