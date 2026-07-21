# SPESIFIKASI API - Grosirun V3.1 Enterprise

**Base URL:** `https://api.grosirun.id/api/v1` (Produksi) | `http://localhost:8000/api/v1` (Pengembangan)  
**Autentikasi:** Bearer Token (Sanctum) + Idempotency-Key + ETag  
**Versioning:** URL `/api/v1/` + Header `Accept: application/vnd.grosirun.v1+json` + `X-App-Version`  
**Tanggal:** 20 Juli 2026  
**Format:** JSON dengan struktur `data` + `meta` + `code` (Error Catalog)  
**OpenAPI:** Generate via Scribe `storage/docs/v1/openapi.yaml`

---

## Daftar Isi

1. Konvensi Umum
2. Strategi Versioning V2
3. Autentikasi, Consent UU PDP, ToS & Penghapusan Akun
4. Cluster
5. Campaign (PO)
6. Varian
7. Order + Batch + Idempotency
8. Upload Bukti (Proof) S3 tempUrl
9. Distribusi
10. Notifikasi Fallback (FCM Fallback)
11. Feature Flags
12. Webhook & Batch Operations
13. Health & Version

---

## 1. Konvensi Umum

### 1.1 Header Wajib

| Header            | Nilai                                  | Keterangan                    |
| ----------------- | -------------------------------------- | ----------------------------- |
| `Accept`          | `application/json`                     | Format respons selalu JSON    |
| `Content-Type`    | `application/json` (kecuali multipart) | Format request                |
| `Authorization`   | `Bearer <sanctum_token>`               | Token dari login              |
| `X-App-Version`   | `1.0.0+1`                              | VersionCode Flutter           |
| `Idempotency-Key` | `uuid-v4`                              | Wajib untuk POST/PATCH kritis |
| `If-Match`        | `W/"etag-version"`                     | Opsional untuk concurrency    |

### 1.2 Response Headers

| Header                  | Contoh                                         | Keterangan                  |
| ----------------------- | ---------------------------------------------- | --------------------------- |
| `Cache-Control`         | `public, max-age=60`                           | Cache untuk GET /campaigns  |
| `ETag`                  | `W/"33a64df551425fcc55e4d42a148795d9f25f89d4"` | Hash berdasarkan updated_at |
| `Deprecation`           | `true`                                         | Endpoint akan dihapus       |
| `Sunset`                | `Sat, 31 Dec 2026 23:59:59 GMT`                | Tanggal penghapusan         |
| `X-RateLimit-Limit`     | `60`                                           | Batas request per menit     |
| `X-RateLimit-Remaining` | `59`                                           | Sisa request                |

### 1.3 Pagination & Filtering

**Parameter Query Umum:**

| Parameter    | Contoh         | Keterangan                        |
| ------------ | -------------- | --------------------------------- |
| `page`       | `1`            | Halaman saat ini                  |
| `per_page`   | `15`           | Jumlah item per halaman (max 100) |
| `cluster_id` | `1`            | Filter berdasarkan cluster        |
| `status`     | `active`       | Filter status campaign            |
| `search`     | `beras`        | Pencarian teks                    |
| `sort`       | `deadline_asc` | Urutan sorting                    |

**Response Meta:**

```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 120,
    "last_page": 8
  }
}
```

### 1.4 Format Error & Error Catalog

**Struktur Error Response:**

```json
{
  "message": "Stok varian habis",
  "code": "ERR_024",
  "http_code": 409,
  "errors": {
    "quantity": ["Sisa 0"]
  },
  "trace_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Daftar Error Code Penting:**

| Code         | HTTP | Pesan                 | Action Frontend    |
| ------------ | ---- | --------------------- | ------------------ |
| `ERR_001`    | 401  | OTP_EXPIRED           | Minta ulang OTP    |
| `ERR_001_RL` | 429  | OTP_RATE_LIMIT        | Tunggu 15 menit    |
| `ERR_002`    | 422  | CONSENT_REQUIRED      | Centang consent    |
| `ERR_003`    | 422  | TOS_REQUIRED          | Centang ToS        |
| `ERR_024`    | 409  | OUT_OF_STOCK          | Pilih varian lain  |
| `ERR_030`    | 409  | ALREADY_VALIDATED     | Refresh data       |
| `ERR_031`    | 412  | STALE_DATA            | Refresh halaman    |
| `ERR_040`    | 403  | CLUSTER_MISMATCH      | Beda cluster RT    |
| `ERR_050`    | 413  | UPLOAD_TOO_LARGE      | Kompres file       |
| `ERR_055`    | 410  | PROOF_URL_EXPIRED     | Generate ulang URL |
| `ERR_060`    | 429  | RATE_LIMIT_GLOBAL     | Tunggu sebentar    |
| `ERR_100`    | 500  | INTERNAL_SERVER_ERROR | Coba lagi          |

**Error Catalog Lengkap:** Lihat `ERROR_CATALOG.md` (50+ error codes)

**Frontend Mapping:** Tampilkan `message` ke user, log `code` + `trace_id` ke Sentry.

### 1.5 Rate Limit Terpusat (Redis)

| Route Group       | Limit    | Per             | Key Redis               |
| ----------------- | -------- | --------------- | ----------------------- |
| Global API        | 60/menit | user_id atau IP | `rl:global:{id}`        |
| Request OTP       | 5/menit  | phone+IP        | `rl:otp:{phone}:{ip}`   |
| Verify OTP        | 10/menit | phone           | `rl:otp-verify:{phone}` |
| Validate Order    | 30/menit | initiator_id    | `rl:validate:{user}`    |
| Override Validate | 10/menit | initiator_id    | `rl:override:{user}`    |
| Upload Proof      | 20/menit | user_id         | `rl:upload:{user}`      |

**Response 429:**

```json
{
  "message": "Terlalu banyak percobaan. Coba lagi dalam 15 menit",
  "code": "ERR_001_RL",
  "locked_until": "2026-07-20T10:15:00+07:00",
  "retry_after": 60
}
```

### 1.6 Idempotency-Key

**Tujuan:** Mencegah duplikasi order saat Flutter retry atau offline queue replay.

**Mekanisme:**

1. Client generate UUID v4 per request POST/PATCH kritis
2. Kirim header `Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000`
3. Middleware `IdempotencyMiddleware`:
   - Cek Redis `idempotency:{user_id}:{key}`
   - Jika ada → return cached response (tanpa eksekusi ulang)
   - Jika tidak → proses request, cache response di Redis TTL 24 jam

**Endpoint Wajib Idempotency-Key:**

- `POST /campaigns/{id}/orders`
- `POST /orders/{uuid}/proof`
- `PATCH /orders/{uuid}/validate`
- `POST /campaigns/{id}/orders/batch-validate`

### 1.7 ETag & Optimistic Concurrency

**Tujuan:** Mencegah konflik update data basi (stale data).

**Mekanisme:**

1. `GET /campaigns/{id}` return `ETag: W/"{campaign.updated_at}-{current_kg}"`
2. Client simpan ETag
3. `PATCH /orders/{uuid}/validate` kirim `If-Match: W/"etag-version"`
4. Server bandingkan ETag:
   - Match → proses update
   - Mismatch → 412 Precondition Failed `ERR_031 STALE_DATA`

### 1.8 Cache-Control

| Endpoint                    | Cache-Control          | TTL      | Keterangan          |
| --------------------------- | ---------------------- | -------- | ------------------- |
| `GET /campaigns`            | `public, max-age=60`   | 60 detik | Redis cache backend |
| `GET /campaigns/{id}`       | `max-age=15`           | 15 detik | + ETag              |
| `GET /campaigns/{id}/recap` | `private, max-age=300` | 5 menit  | PDF berat           |
| `POST/PUT/PATCH`            | `no-cache`             | -        | Tidak boleh cache   |

---

## 2. Strategi Versioning V2

### 2.1 URL Versioning

- **Saat Ini:** `/api/v1/` (aktif)
- **Masa Depan:** `/api/v2/` (breaking change)

**Implementasi Route:**

```php
// routes/api.php
Route::prefix('v1')->group(fn() => require __DIR__.'/api/v1.php');
Route::prefix('v2')->group(fn() => require __DIR__.'/api/v2.php');
```

### 2.2 Header Versioning (Content Negotiation)

- Accept Header: `application/vnd.grosirun.v1+json` atau `v2`
- Default jika tidak ada: `v1`

### 2.3 Deprecation Policy

| Kebijakan           | Detail                                   |
| ------------------- | ---------------------------------------- |
| Periode Deprecation | Minimal 6 bulan setelah V2 launch        |
| Header Deprecation  | `Deprecation: true`, `Sunset: date`      |
| Komunikasi          | CHANGELOG.md, Slack, in-app banner       |
| Monitoring          | Pulse tracking usage deprecated endpoint |

**Contoh Response Deprecated:**

```
HTTP/1.1 200 OK
Deprecation: true
Sunset: Sat, 31 Dec 2026 23:59:59 GMT
X-API-Deprecation-Notice: Use GET /campaigns/{id}/recap instead.
```

### 2.4 Non-Breaking Changes (Stay di V1)

- Penambahan field baru (optional)
- Penambahan query parameter baru
- Penambahan endpoint baru
- Perbaikan bug

### 2.5 Breaking Changes (Wajib V2)

- Perubahan struktur response
- Penghapusan endpoint
- Perubahan status code
- Perubahan format request

---

## 3. Autentikasi, Consent UU PDP, ToS & Penghapusan Akun

### 3.1 POST /auth/request-otp

**Deskripsi:** Kirim OTP 4 digit ke nomor WA user via Fonnte.

**Request:**

```json
{
  "phone_number": "081234567890",
  "cluster_code": "PGH-RT03"
}
```

| Field          | Tipe   | Wajib | Keterangan                                  |
| -------------- | ------ | ----- | ------------------------------------------- |
| `phone_number` | string | ✅    | Format 08xxx (akan dinormalisasi ke 628xxx) |
| `cluster_code` | string | ❌    | Kode cluster untuk verifikasi invite        |

**Flow:**

1. Validasi Rate Limit 5/menit per phone+IP
2. Generate OTP 4 digit random
3. Hash OTP dengan bcrypt
4. Simpan di `otp_codes` (expiry 5 menit)
5. Kirim WA via Fonnte (atau log ke file di local)
6. Return 200 OK

**Response 200:**

```json
{
  "message": "OTP dikirim ke nomor Anda",
  "data": {
    "expires_in": 300,
    "phone_masked": "62812****"
  }
}
```

**Response 429:**

```json
{
  "message": "Terlalu banyak percobaan. Coba lagi dalam 15 menit",
  "code": "ERR_001_RL",
  "locked_until": "2026-07-20T10:15:00+07:00",
  "retry_after": 60
}
```

### 3.2 POST /auth/verify-otp

**Deskripsi:** Verifikasi OTP, buat user baru atau login, kirim token Sanctum.

**Request:**

```json
{
  "phone_number": "081234567890",
  "otp": "1234",
  "fcm_token": "e5tY...",
  "consent": true,
  "tos": true,
  "cluster_code": "PGH-RT03",
  "consent_version": "v1.0",
  "tos_version": "v1.0"
}
```

| Field             | Tipe    | Wajib | Keterangan                     |
| ----------------- | ------- | ----- | ------------------------------ |
| `phone_number`    | string  | ✅    | Format 08xxx                   |
| `otp`             | string  | ✅    | 4 digit dari WA                |
| `fcm_token`       | string  | ❌    | Token Firebase Cloud Messaging |
| `consent`         | boolean | ✅    | Harus true (UU PDP)            |
| `tos`             | boolean | ✅    | Harus true (non-escrow)        |
| `cluster_code`    | string  | ❌    | Kode cluster (jika ada)        |
| `consent_version` | string  | ❌    | Versi privacy policy           |
| `tos_version`     | string  | ❌    | Versi terms of service         |

**Response 200:**

```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "Siti",
      "phone": "6281234567890",
      "role": "buyer",
      "cluster_id": 1,
      "consent_at": "2026-07-20T10:00:00+07:00",
      "tos_accepted_at": "2026-07-20T10:00:00+07:00",
      "created_at": "2026-07-20T10:00:00+07:00"
    },
    "token": "1|abcdefghijklmnopqrstuvwxyz123456",
    "expires_at": "2026-08-19T10:00:00+07:00"
  }
}
```

**Response 422 (Consent Missing):**

```json
{
  "message": "Harus setuju privasi UU PDP",
  "code": "ERR_002",
  "http_code": 422
}
```

### 3.3 POST /auth/consent

**Deskripsi:** Update consent user (untuk versi baru privacy policy).

**Auth:** Required

**Request:**

```json
{
  "consent": true,
  "consent_version": "v1.1"
}
```

**Response 200:**

```json
{
  "message": "Consent berhasil diperbarui",
  "data": {
    "consent_at": "2026-07-20T10:00:00+07:00",
    "consent_version": "v1.1"
  }
}
```

### 3.4 POST /auth/tos-accept

**Deskripsi:** Update ToS user (untuk versi baru terms of service).

**Auth:** Required

**Request:**

```json
{
  "tos": true,
  "tos_version": "v1.1"
}
```

**Response 200:** Sama seperti consent.

### 3.5 GET /auth/me

**Deskripsi:** Ambil data profil user saat ini.

**Auth:** Required

**Response 200:**

```json
{
  "data": {
    "id": 1,
    "name": "Siti",
    "phone": "6281234567890",
    "role": "buyer",
    "cluster": {
      "id": 1,
      "code": "PGH-RT03",
      "name": "Permata Hijau RT03"
    },
    "consent_at": "2026-07-20T10:00:00+07:00",
    "tos_accepted_at": "2026-07-20T10:00:00+07:00",
    "reputation_score": 100
  }
}
```

### 3.6 PUT /auth/profile

**Deskripsi:** Update profil user (hanya name).

**Auth:** Required

**Request:**

```json
{
  "name": "Siti Rahayu"
}
```

**Response 200:**

```json
{
  "message": "Profil berhasil diperbarui",
  "data": {
    "id": 1,
    "name": "Siti Rahayu"
  }
}
```

### 3.7 POST /auth/fcm-token

**Deskripsi:** Update FCM token untuk push notification.

**Auth:** Required

**Request:**

```json
{
  "fcm_token": "e5tY..."
}
```

**Response 200:**

```json
{
  "message": "FCM token berhasil diperbarui"
}
```

### 3.8 DELETE /auth/account

**Deskripsi:** Hapus akun (anonimisasi data sesuai UU PDP). SLA <24 jam.

**Auth:** Required

**Request (Opsional):**

```json
{
  "reason": "Pindah cluster"
}
```

**Flow:**

1. Validasi user memiliki hak hapus
2. Dispatch job `AnonymizeUserJob` (async):
   - Ubah `name` → `Deleted User {id}`
   - Ubah `phone` → `DELETED_{id}`
   - Hapus `fcm_token`
   - Revoke semua `personal_access_tokens`
   - Hapus S3 proofs milik user
   - Update `orders.user_id` → null
   - Insert `transaction_logs` type `delete_account`
3. Return 202 Accepted

**Response 202:**

```json
{
  "message": "Permintaan hapus akun diproses. Data akan dianonimkan <24 jam",
  "code": "ERR_000_ACCEPTED"
}
```

### 3.9 POST /auth/logout

**Deskripsi:** Logout, revoke token saat ini.

**Auth:** Required

**Response 200:**

```json
{
  "message": "Berhasil logout"
}
```

---

## 4. Cluster

### 4.1 GET /clusters

**Deskripsi:** Ambil daftar cluster (untuk validasi invite code).

**Auth:** Public (atau optional)

**Query Params:**

| Parameter | Tipe   | Keterangan                      |
| --------- | ------ | ------------------------------- |
| `code`    | string | Filter berdasarkan kode cluster |

**Response 200:**

```json
{
  "data": [
    {
      "id": 1,
      "code": "PGH-RT03",
      "name": "Permata Hijau RT03",
      "rw": "03",
      "kelurahan": "Ngoro",
      "city": "Mojokerto"
    }
  ]
}
```

### 4.2 GET /clusters/{id}

**Deskripsi:** Ambil detail cluster + statistik.

**Auth:** Required (scoped)

**Response 200:**

```json
{
  "data": {
    "id": 1,
    "code": "PGH-RT03",
    "name": "Permata Hijau RT03",
    "stats": {
      "total_users": 35,
      "total_campaigns_active": 2,
      "total_campaigns_completed": 5
    }
  }
}
```

### 4.3 POST /clusters (Admin Only)

**Deskripsi:** Buat cluster baru (untuk ekspansi multi-RT).

**Auth:** Admin role required

**Request:**

```json
{
  "name": "Permata Hijau RT04",
  "code": "PGH-RT04",
  "rw": "04",
  "kelurahan": "Ngoro",
  "city": "Mojokerto"
}
```

**Response 201:**

```json
{
  "message": "Cluster berhasil dibuat",
  "data": {
    "id": 2,
    "code": "PGH-RT04"
  }
}
```

---

## 5. Campaign (PO)

### 5.1 GET /campaigns

**Deskripsi:** Ambil daftar campaign (PO) aktif di cluster user.

**Auth:** Required (auto-filter cluster via Global Scope)

**Query Params:**

| Parameter    | Tipe   | Keterangan                                         |
| ------------ | ------ | -------------------------------------------------- |
| `page`       | int    | Halaman (default 1)                                |
| `per_page`   | int    | Item per halaman (default 15, max 100)             |
| `status`     | string | `active`, `completed`, `expired`, `cancelled`      |
| `cluster_id` | int    | Admin override (hanya admin)                       |
| `search`     | string | Pencarian nama campaign                            |
| `sort`       | string | `deadline_asc`, `deadline_desc`, `created_at_desc` |
| `include`    | string | `variants,initiator,cluster` (comma separated)     |

**Headers:**

```
Cache-Control: public, max-age=60
ETag: W/"33a64df551425fcc55e4d42a148795d9f25f89d4"
```

**Response 200:**

```json
{
  "data": [
    {
      "id": 1,
      "cluster_id": 1,
      "slug": "beras-mahkota-premium-abc123",
      "name": "Beras Mahkota Premium",
      "description": "Pulen langsung dari pabrik Makmur Jaya",
      "image_url": "https://s3.../campaigns/uuid.jpg",
      "target_kg": 1000,
      "current_kg": 750,
      "progress_percent": 75,
      "price_total_supplier": 10000000,
      "deadline": "2026-07-22T10:00:00+07:00",
      "status": "active",
      "pickup_location": "Rumah Pak RT Jl Mawar 12",
      "initiator": {
        "id": 2,
        "name": "Pak Agus Setiawan"
      },
      "cluster": {
        "id": 1,
        "code": "PGH-RT03",
        "name": "Permata Hijau RT03"
      },
      "variants": [
        {
          "id": 1,
          "size_kg": 5,
          "price": 60000,
          "quota": 100,
          "sold": 75,
          "remaining": 25
        },
        {
          "id": 2,
          "size_kg": 10,
          "price": 115000,
          "quota": 50,
          "sold": 37,
          "remaining": 13
        }
      ],
      "created_at": "2026-07-20T10:00:00+07:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 2,
    "last_page": 1
  }
}
```

### 5.2 GET /campaigns/{id}

**Deskripsi:** Ambil detail campaign.

**Auth:** Required (cluster scoped)

**Headers:** `If-None-Match: W/"etag-version"` (opsional)

**Response 304 (Not Modified):**

```
HTTP/1.1 304 Not Modified
```

**Response 200:**

```json
{
  "data": {
    "id": 1,
    "cluster_id": 1,
    "slug": "beras-mahkota-premium-abc123",
    "name": "Beras Mahkota Premium",
    "description": "Pulen langsung dari pabrik Makmur Jaya",
    "image_url": "https://s3.../campaigns/uuid.jpg",
    "target_kg": 1000,
    "current_kg": 750,
    "price_total_supplier": 10000000,
    "deadline": "2026-07-22T10:00:00+07:00",
    "status": "active",
    "pickup_location": "Rumah Pak RT Jl Mawar 12",
    "initiator": {
      "id": 2,
      "name": "Pak Agus Setiawan",
      "phone": "6281234567890"
    },
    "cluster": {
      "id": 1,
      "code": "PGH-RT03",
      "name": "Permata Hijau RT03"
    },
    "variants": [
      {
        "id": 1,
        "size_kg": 5,
        "price": 60000,
        "quota": 100,
        "sold": 75
      }
    ],
    "activities": [
      {
        "user_name": "Bu Nengsih",
        "action": "pesan 5Kg",
        "time_ago": "2 menit lalu"
      }
    ],
    "created_at": "2026-07-20T10:00:00+07:00",
    "updated_at": "2026-07-20T10:00:00+07:00"
  }
}
```

### 5.3 GET /campaigns/{id}/activities

**Deskripsi:** Ambil aktivitas terbaru campaign (social ticker).

**Auth:** Required

**Response 200:**

```json
{
  "data": [
    {
      "user_name": "Bu Nengsih",
      "action": "pesan 5Kg",
      "time_ago": "2 menit lalu"
    },
    {
      "user_name": "Pak Joko",
      "action": "pesan 10Kg",
      "time_ago": "5 menit lalu"
    }
  ]
}
```

### 5.4 POST /campaigns

**Deskripsi:** Buat campaign baru (hanya initiator).

**Auth:** Initiator role required

**Request (multipart/form-data):**

| Field                  | Tipe    | Wajib | Keterangan                                        |
| ---------------------- | ------- | ----- | ------------------------------------------------- |
| `name`                 | string  | ✅    | Nama campaign (max 150 chars)                     |
| `description`          | string  | ❌    | Deskripsi campaign                                |
| `target_kg`            | integer | ✅    | Target kilogram (harus kelipatan varian terkecil) |
| `price_total_supplier` | integer | ✅    | Total harga dari supplier (untuk rekap)           |
| `deadline`             | string  | ✅    | Tenggat waktu (min +24 jam dari sekarang)         |
| `pickup_location`      | string  | ❌    | Lokasi pengambilan barang                         |
| `image`                | file    | ❌    | Foto campaign (max 5MB, jpg/png)                  |
| `variants`             | array   | ✅    | Array varian (min 1, max 5)                       |

**Variant Schema:**

| Field     | Tipe    | Wajib | Keterangan                       |
| --------- | ------- | ----- | -------------------------------- |
| `size_kg` | decimal | ✅    | Ukuran varian (5.00, 10.00, dst) |
| `price`   | integer | ✅    | Harga per varian (Rp)            |
| `quota`   | integer | ✅    | Kuota tersedia                   |

**Request Contoh (JSON):**

```json
{
  "name": "Beras Mahkota Premium",
  "description": "Pulen langsung dari pabrik Makmur Jaya",
  "target_kg": 1000,
  "price_total_supplier": 10000000,
  "deadline": "2026-07-22T10:00:00+07:00",
  "pickup_location": "Rumah Pak RT Jl Mawar 12",
  "variants": [
    {
      "size_kg": 5.0,
      "price": 60000,
      "quota": 100
    },
    {
      "size_kg": 10.0,
      "price": 115000,
      "quota": 50
    }
  ]
}
```

**Response 201:**

```json
{
  "message": "Campaign berhasil dibuat",
  "data": {
    "id": 1,
    "slug": "beras-mahkota-premium-abc123",
    "image_url": "https://s3.../campaigns/uuid.jpg",
    "share_link": "https://grosirun.id/c/beras-mahkota-premium-abc123",
    "deep_link": "grosirun://campaign/1"
  }
}
```

### 5.5 PUT /campaigns/{id}

**Deskripsi:** Update campaign (hanya initiator pemilik).

**Auth:** Initiator owner required

**Request:** Sama seperti POST (semua field opsional)

**Response 200:** Sama seperti GET detail.

### 5.6 POST /campaigns/{id}/extend

**Deskripsi:** Perpanjang deadline campaign (+24 jam, max 2 kali).

**Auth:** Initiator owner required

**Feature Flag:** `extend-deadline` harus aktif

**Rate Limit:** 10/menit

**Response 200:**

```json
{
  "message": "Tenggat diperpanjang 24 jam",
  "data": {
    "new_deadline": "2026-07-23T10:00:00+07:00",
    "extend_count": 1,
    "max_extend": 2
  }
}
```

**Response 409:**

```json
{
  "message": "Maksimal 2 kali perpanjangan",
  "code": "ERR_017",
  "http_code": 409
}
```

### 5.7 POST /campaigns/{id}/cancel

**Deskripsi:** Batalkan campaign (hanya jika belum 100%).

**Auth:** Initiator owner required

**Response 200:**

```json
{
  "message": "Campaign berhasil dibatalkan",
  "data": {
    "status": "cancelled",
    "refund_notice": "Refund manual 2x24h hubungi Initiator"
  }
}
```

### 5.8 GET /campaigns/{id}/recap

**Deskripsi:** Ambil rekap campaign (PDF + JSON).

**Auth:** Initiator owner required

**Cache:** `private, max-age=300` (5 menit)

**Response 200:**

```json
{
  "data": {
    "campaign": {
      "id": 1,
      "name": "Beras Mahkota Premium",
      "target_kg": 1000,
      "current_kg": 750
    },
    "summary": {
      "total_buyers": 35,
      "total_kg": 700,
      "total_revenue": 8400000,
      "total_supplier_cost": 7350000,
      "margin_bruto": 1050000,
      "platform_fee": 93240,
      "margin_bersih": 956760
    },
    "orders": [
      {
        "user_name": "Bu Siti",
        "variant_size": 5,
        "quantity": 1,
        "total_price": 60000,
        "payment_status": "paid",
        "is_taken": true
      }
    ],
    "pdf_url": "https://s3.../recaps/uuid.pdf?X-Amz-... (tempUrl 1h)"
  }
}
```

---

## 6. Varian

### 6.1 GET /campaigns/{id}/variants

**Deskripsi:** Ambil varian campaign.

**Auth:** Required

**Response 200:**

```json
{
  "data": [
    {
      "id": 1,
      "size_kg": 5.0,
      "price": 60000,
      "quota": 100,
      "sold": 75,
      "remaining": 25
    }
  ]
}
```

### 6.2 GET /variants/{id}

**Deskripsi:** Ambil detail varian.

**Auth:** Required

**Response 200:** Sama seperti di atas.

---

## 7. Order + Batch + Idempotency

### 7.1 POST /campaigns/{id}/orders

**Deskripsi:** Buat order baru (checkout).

**Auth:** Buyer role required (cluster harus sama dengan campaign)

**Headers Wajib:**

```
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

**Request:**

```json
{
  "variant_id": 1,
  "quantity": 1,
  "payment_method": "cash"
}
```

| Field            | Tipe    | Wajib | Keterangan              |
| ---------------- | ------- | ----- | ----------------------- |
| `variant_id`     | integer | ✅    | ID varian campaign      |
| `quantity`       | integer | ✅    | Jumlah (min 1, max 100) |
| `payment_method` | string  | ✅    | `cash` atau `qris`      |

**Response 201:**

```json
{
  "message": "Order berhasil dibuat",
  "data": {
    "order": {
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "cluster_id": 1,
      "campaign_id": 1,
      "variant_size": 5,
      "quantity": 1,
      "total_kg": 5,
      "total_price": 60000,
      "payment_method": "cash",
      "payment_status": "pending",
      "idempotency_key": "550e8400-e29b-41d4-a716-446655440001",
      "created_at": "2026-07-20T10:00:00+07:00"
    },
    "campaign": {
      "current_kg": 755,
      "progress_percent": 75.5
    }
  }
}
```

**Response 403 (Cluster Mismatch):**

```json
{
  "message": "Kamu beda cluster, tidak bisa pesan di sini",
  "code": "ERR_040",
  "http_code": 403
}
```

**Response 409 (Out of Stock):**

```json
{
  "message": "Stok varian habis",
  "code": "ERR_024",
  "http_code": 409,
  "errors": {
    "variant_id": ["Sisa 0"]
  }
}
```

### 7.2 POST /campaigns/{id}/orders/batch-create

**Deskripsi:** Buat order massal (untuk initiator mencatatkan warga tanpa HP).

**Auth:** Initiator owner required

**Request:**

```json
{
  "orders": [
    {
      "variant_id": 1,
      "quantity": 1,
      "payment_method": "cash",
      "user_id": 5
    },
    {
      "variant_id": 2,
      "quantity": 2,
      "payment_method": "cash",
      "on_behalf_name": "Bu Mimin",
      "on_behalf_phone": "081234567892"
    }
  ]
}
```

**Response 207 (Multi-Status):**

```json
{
  "data": {
    "success": [
      {
        "uuid": "550e8400-e29b-41d4-a716-446655440000",
        "user_id": 5
      },
      {
        "uuid": "550e8400-e29b-41d4-a716-446655440001",
        "on_behalf_name": "Bu Mimin"
      }
    ],
    "failed": []
  }
}
```

### 7.3 GET /my/orders

**Deskripsi:** Ambil daftar order user sendiri.

**Auth:** Required (cluster scoped)

**Query Params:**

| Parameter  | Tipe   | Keterangan                                            |
| ---------- | ------ | ----------------------------------------------------- |
| `status`   | string | `pending`, `waiting`, `paid`, `rejected`, `cancelled` |
| `page`     | int    | Halaman                                               |
| `per_page` | int    | Item per halaman                                      |

**Response 200:**

```json
{
  "data": [
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "campaign": {
        "id": 1,
        "name": "Beras Mahkota Premium"
      },
      "variant_size": 5,
      "quantity": 1,
      "total_kg": 5,
      "total_price": 60000,
      "payment_method": "cash",
      "payment_status": "pending",
      "proof_url": null,
      "created_at": "2026-07-20T10:00:00+07:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 5,
    "last_page": 1
  }
}
```

### 7.4 GET /campaigns/{id}/orders

**Deskripsi:** Ambil daftar order campaign (hanya initiator).

**Auth:** Initiator owner required (cluster scoped)

**Query Params:**

| Parameter        | Tipe   | Keterangan                               |
| ---------------- | ------ | ---------------------------------------- |
| `payment_status` | string | `pending`, `waiting`, `paid`, `rejected` |
| `search`         | string | Cari nama buyer                          |
| `page`           | int    | Halaman                                  |
| `per_page`       | int    | Item per halaman                         |

**Response 200:** Sama seperti GET /my/orders.

### 7.5 GET /orders/{uuid}

**Deskripsi:** Ambil detail order.

**Auth:** Required (owner atau initiator own campaign)

**Response 200:**

```json
{
  "data": {
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "cluster_id": 1,
    "campaign": {
      "id": 1,
      "name": "Beras Mahkota Premium"
    },
    "user": {
      "id": 1,
      "name": "Bu Siti"
    },
    "variant_size": 5,
    "quantity": 1,
    "total_kg": 5,
    "total_price": 60000,
    "payment_method": "cash",
    "payment_status": "pending",
    "proof_url": null,
    "is_taken": false,
    "taken_at": null,
    "created_at": "2026-07-20T10:00:00+07:00"
  }
}
```

### 7.6 PATCH /orders/{uuid}/validate

**Deskripsi:** Validasi pembayaran order (hanya initiator).

**Auth:** Initiator owner required

**Headers Wajib:**

```
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
If-Match: W/"etag-version" (opsional)
```

**Rate Limit:** 30/menit

**Response 200:**

```json
{
  "message": "Pembayaran berhasil divalidasi",
  "data": {
    "payment_status": "paid",
    "validated_at": "2026-07-20T10:00:00+07:00"
  }
}
```

**Response 409 (Already Validated):**

```json
{
  "message": "Sudah divalidasi di device lain",
  "code": "ERR_030",
  "http_code": 409
}
```

**Response 412 (Stale Data):**

```json
{
  "message": "Data sudah lama, refresh dulu",
  "code": "ERR_031",
  "http_code": 412
}
```

### 7.7 PATCH /orders/{uuid}/reject

**Deskripsi:** Tolak bukti QRIS blur.

**Auth:** Initiator owner required

**Request:**

```json
{
  "reason": "Foto blur nominal tidak terlihat"
}
```

**Response 200:**

```json
{
  "message": "Bukti ditolak",
  "data": {
    "payment_status": "rejected",
    "rejected_at": "2026-07-20T10:00:00+07:00"
  }
}
```

### 7.8 PATCH /orders/{uuid}/undo-validation

**Deskripsi:** Batalkan validasi dalam 5 menit.

**Auth:** Initiator owner required

**Response 200:**

```json
{
  "message": "Validasi berhasil dibatalkan",
  "data": {
    "payment_status": "pending"
  }
}
```

**Response 403 (Expired):**

```json
{
  "message": "Undo hanya 5 menit setelah validasi",
  "code": "ERR_034",
  "http_code": 403
}
```

### 7.9 PATCH /orders/{uuid}/override-validate

**Deskripsi:** Validasi paksa dengan catatan (untuk kasus khusus).

**Auth:** Initiator owner required

**Rate Limit:** 10/menit

**Request:**

```json
{
  "notes": "Salah klik, sudah cek mutasi BCA jam 10:05"
}
```

**Response 200:** Sama seperti validate.

### 7.10 PATCH /orders/{uuid}/cancel

**Deskripsi:** Batalkan order (hanya buyer pemilik).

**Auth:** Buyer owner required

**Response 200:**

```json
{
  "message": "Order berhasil dibatalkan",
  "data": {
    "payment_status": "cancelled",
    "cancelled_at": "2026-07-20T10:00:00+07:00"
  }
}
```

### 7.11 POST /orders/{uuid}/transfer

**Deskripsi:** Transfer order ke user lain (admin only).

**Auth:** Initiator owner required

**Request:**

```json
{
  "to_user_id": 5
}
```

**Response 200:**

```json
{
  "message": "Order berhasil ditransfer",
  "data": {
    "user_id": 5,
    "user_name": "Bu Mimin"
  }
}
```

### 7.12 POST /campaigns/{id}/orders/batch-validate

**Deskripsi:** Validasi massal multiple orders (checkbox UI).

**Auth:** Initiator owner required

**Request:**

```json
{
  "order_uuids": [
    "550e8400-e29b-41d4-a716-446655440000",
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002"
  ],
  "notes": "Validasi massal tunai RT"
}
```

**Response 207 (Multi-Status):**

```json
{
  "data": {
    "success": [
      "550e8400-e29b-41d4-a716-446655440000",
      "550e8400-e29b-41d4-a716-446655440001"
    ],
    "failed": [
      {
        "uuid": "550e8400-e29b-41d4-a716-446655440002",
        "reason": "Already validated"
      }
    ]
  }
}
```

---

## 8. Upload Bukti (Proof) S3 tempUrl

### 8.1 POST /orders/{uuid}/proof

**Deskripsi:** Upload bukti pembayaran QRIS.

**Auth:** Owner required

**Headers Wajib:**

```
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
Content-Type: multipart/form-data
```

**Request (multipart/form-data):**

| Field   | Tipe | Wajib | Keterangan                     |
| ------- | ---- | ----- | ------------------------------ |
| `proof` | file | ✅    | File gambar (max 2MB, jpg/png) |

**Flow:**

1. Client kompres 70% di Flutter
2. Server validasi mime jpg/png
3. Server kompres 80% dengan Intervention
4. Upload ke S3 private bucket: `order_proofs/{uuid}.jpg`
5. Generate tempUrl 1 jam
6. Update order: `proof_path`, `payment_status` = `waiting`

**Response 200:**

```json
{
  "message": "Bukti berhasil diupload",
  "data": {
    "proof_url": "https://s3.amazonaws.com/bucket/order_proofs/uuid.jpg?X-Amz-Expires=3600&X-Amz-Signature=...",
    "proof_path": "order_proofs/uuid.jpg",
    "payment_status": "waiting"
  }
}
```

### 8.2 GET /orders/{uuid}/proof-url

**Deskripsi:** Generate fresh tempUrl untuk bukti yang sudah diupload.

**Auth:** Required (owner atau initiator own campaign)

**Response 200:**

```json
{
  "data": {
    "proof_url": "https://s3.amazonaws.com/bucket/order_proofs/uuid.jpg?X-Amz-Expires=3600&X-Amz-Signature=...",
    "expires_in": 3600
  }
}
```

**Response 410 (Expired):**

```json
{
  "message": "Link bukti kadaluarsa, generate ulang",
  "code": "ERR_055",
  "http_code": 410
}
```

---

## 9. Distribusi

### 9.1 GET /campaigns/{id}/distribution

**Deskripsi:** Ambil daftar order untuk distribusi (hanya initiator).

**Auth:** Initiator owner required

**Query Params:**

| Parameter  | Tipe    | Keterangan               |
| ---------- | ------- | ------------------------ |
| `is_taken` | boolean | Filter sudah/belum ambil |
| `search`   | string  | Cari nama buyer          |
| `page`     | int     | Halaman                  |
| `per_page` | int     | Item per halaman         |

**Response 200:**

```json
{
  "data": {
    "summary": {
      "total_paid": 35,
      "total_taken": 20,
      "remaining": 15
    },
    "orders": [
      {
        "uuid": "550e8400-e29b-41d4-a716-446655440000",
        "user": {
          "name": "Bu Siti"
        },
        "variant_size": 5,
        "quantity": 1,
        "total_kg": 5,
        "is_taken": false,
        "taken_at": null
      }
    ]
  }
}
```

### 9.2 PATCH /orders/{uuid}/taken

**Deskripsi:** Tandai order sudah diambil buyer.

**Auth:** Initiator owner required

**Headers Wajib:**

```
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

**Response 200:**

```json
{
  "message": "Berhasil ditandai sudah diambil",
  "data": {
    "is_taken": true,
    "taken_at": "2026-07-20T10:00:00+07:00",
    "taken_by": "Pak Agus Setiawan"
  }
}
```

### 9.3 POST /campaigns/{id}/complete-distribution

**Deskripsi:** Selesaikan distribusi (tutup campaign).

**Auth:** Initiator owner required

**Prerequisite:** Semua paid orders sudah `is_taken = true`

**Response 200:**

```json
{
  "message": "Distribusi selesai",
  "data": {
    "distribution_completed_at": "2026-07-20T10:00:00+07:00",
    "total_taken": 35,
    "platform_fee_invoice": {
      "invoice_id": "INV-GR-2026-07-001",
      "amount": 93240,
      "payment_url": "https://xendit.com/invoice/...",
      "due_date": "2026-07-22T10:00:00+07:00"
    }
  }
}
```

**Response 422 (Belum semua diambil):**

```json
{
  "message": "Masih ada 5 order yang belum diambil",
  "code": "ERR_039",
  "http_code": 422
}
```

---

## 10. Notifikasi Fallback (FCM Fallback)

### 10.1 GET /notifications

**Deskripsi:** Ambil notifikasi fallback (polling saat FCM down).

**Auth:** Required

**Query Params:**

| Parameter  | Tipe    | Keterangan                |
| ---------- | ------- | ------------------------- |
| `unread`   | boolean | Filter hanya belum dibaca |
| `page`     | int     | Halaman                   |
| `per_page` | int     | Item per halaman          |

**Response 200:**

```json
{
  "data": [
    {
      "id": 1,
      "title": "Pesanan Baru",
      "body": "Bu Siti pesan 5Kg di PO Beras Mahkota",
      "data": {
        "type": "NEW_ORDER",
        "campaign_id": 1,
        "order_uuid": "550e8400-e29b-41d4-a716-446655440000"
      },
      "read_at": null,
      "created_at": "2026-07-20T10:00:00+07:00"
    },
    {
      "id": 2,
      "title": "Pembayaran Lunas",
      "body": "Pembayaran PO Beras Mahkota telah divalidasi",
      "data": {
        "type": "PAYMENT_VALIDATED",
        "campaign_id": 1,
        "order_uuid": "550e8400-e29b-41d4-a716-446655440001"
      },
      "read_at": "2026-07-20T10:05:00+07:00",
      "created_at": "2026-07-20T10:02:00+07:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 5,
    "last_page": 1
  }
}
```

### 10.2 PATCH /notifications/{id}/read

**Deskripsi:** Tandai notifikasi sudah dibaca.

**Auth:** Required

**Response 200:**

```json
{
  "message": "Notifikasi ditandai sudah dibaca",
  "data": {
    "read_at": "2026-07-20T10:00:00+07:00"
  }
}
```

### 10.3 POST /notifications/read-all

**Deskripsi:** Tandai semua notifikasi sudah dibaca.

**Auth:** Required

**Response 200:**

```json
{
  "message": "Semua notifikasi ditandai sudah dibaca",
  "data": {
    "count": 3
  }
}
```

### 10.4 POST /notifications/test (Admin Only)

**Deskripsi:** Kirim test notifikasi (dev only).

**Auth:** Admin required

**Request:**

```json
{
  "user_id": 1,
  "title": "Test Notifikasi",
  "body": "Ini adalah test notifikasi",
  "data": {
    "type": "TEST"
  }
}
```

**Response 200:**

```json
{
  "message": "Test notifikasi terkirim",
  "data": {
    "fcm_sent": true,
    "fallback_saved": true
  }
}
```

---

## 11. Feature Flags

### 11.1 GET /features

**Deskripsi:** Ambil daftar feature flags aktif untuk user.

**Auth:** Required

**Response 200:**

```json
{
  "data": {
    "qris-upload": true,
    "extend-deadline": true,
    "batch-validate": true,
    "dark-mode": false,
    "webhook-supplier": false
  }
}
```

### 11.2 POST /admin/features/{feature}/activate (Admin Only)

**Deskripsi:** Aktifkan/nonaktifkan feature flag.

**Auth:** Admin required

**Request:**

```json
{
  "active": true,
  "scope": "cluster",
  "scope_id": 1
}
```

| Field      | Tipe    | Wajib | Keterangan                                |
| ---------- | ------- | ----- | ----------------------------------------- |
| `active`   | boolean | ✅    | Aktif/nonaktif                            |
| `scope`    | string  | ❌    | `global`, `cluster`, `user`               |
| `scope_id` | integer | ❌    | ID cluster/user (jika scope bukan global) |

**Response 200:**

```json
{
  "message": "Feature flag berhasil diperbarui",
  "data": {
    "feature": "qris-upload",
    "active": true,
    "scope": "global"
  }
}
```

---

## 12. Webhook & Batch Operations

### 12.1 POST /webhooks/supplier/order-status (Future V2)

**Deskripsi:** Webhook untuk supplier update status pesanan.

**Headers Wajib:**

```
X-Webhook-Signature: hmac_sha256_signature
```

**Request:**

```json
{
  "supplier_invoice": "INV-MJ-2026-07-001",
  "status": "shipped",
  "tracking_number": "TRK-001",
  "estimated_arrival": "2026-07-22T10:00:00+07:00"
}
```

**Response 200:**

```json
{
  "message": "Webhook diterima",
  "data": {
    "campaign_id": 1,
    "status_updated": true
  }
}
```

**Feature Flag:** `webhook-supplier` harus aktif.

### 12.2 Batch Operations Summary

| Endpoint                                     | Deskripsi         | Auth      |
| -------------------------------------------- | ----------------- | --------- |
| `POST /campaigns/{id}/orders/batch-create`   | Buat order massal | Initiator |
| `POST /campaigns/{id}/orders/batch-validate` | Validasi massal   | Initiator |

---

## 13. Health & Version

### 13.1 GET /health

**Deskripsi:** Health check aplikasi.

**Auth:** Public (no auth)

**Cache:** `Cache-Control: no-cache`

**Response 200:**

```json
{
  "status": "ok",
  "db": "connected",
  "redis": "connected",
  "s3": "connected",
  "version": "v1.0.0",
  "ssl_expires_in_days": 30,
  "time": "2026-07-20T10:00:00+07:00"
}
```

**Response 503 (Jika ada yang disconnected):**

```json
{
  "status": "degraded",
  "db": "connected",
  "redis": "disconnected",
  "s3": "connected",
  "version": "v1.0.0"
}
```

### 13.2 GET /version

**Deskripsi:** Informasi versioning untuk client check.

**Auth:** Public

**Response 200:**

```json
{
  "api_version": "v1",
  "app_version": "1.0.0",
  "deprecation": null,
  "min_supported_flutter_version": "1.0.0+1",
  "deprecation_date": null,
  "sunset_date": null
}
```

**Response dengan Deprecation:**

```json
{
  "api_version": "v1",
  "app_version": "1.0.0",
  "deprecation": true,
  "min_supported_flutter_version": "1.0.0+1",
  "deprecation_date": "2026-06-01",
  "sunset_date": "2026-12-31"
}
```

---

## 14. OpenAPI / Scribe

### 14.1 Generate Dokumentasi

```bash
# Generate V1
php artisan scribe:generate --config=scribe.v1.config

# Generate V2 (future)
php artisan scribe:generate --config=scribe.v2.config
```

### 14.2 Akses Dokumentasi

| Environment | URL                                    |
| ----------- | -------------------------------------- |
| Development | `http://localhost:8000/docs`           |
| Staging     | `https://api.staging.grosirun.id/docs` |
| Production  | `https://api.grosirun.id/docs`         |

### 14.3 Postman Collection

File: `backend/postman/Grosirun_API_V1.1_GAP_Closed.postman_collection.json`

**Include Semua Endpoint:**

- Auth (OTP, login, consent, ToS, delete account)
- Cluster
- Campaign (CRUD, extend, cancel, recap)
- Order (create, batch create, validate, reject, override, cancel, transfer, batch validate)
- Proof (upload, fresh URL)
- Distribution (list, taken, complete)
- Notifications (list, read, read-all)
- Features (list, activate)
- Health & Version

---

## 15. Ringkasan Perubahan dari V3.0

| No  | Perubahan                  | Keterangan                                        |
| --- | -------------------------- | ------------------------------------------------- |
| 1   | **S3 Primary Storage**     | Proof disimpan di S3 private, tempUrl 1 jam       |
| 2   | **Cluster_id**             | Semua endpoint cluster scoped, mismatch 403       |
| 3   | **Consent & ToS**          | Endpoint baru consent, tos-accept, delete account |
| 4   | **Idempotency-Key**        | Wajib untuk POST/PATCH kritis, Redis cache 24 jam |
| 5   | **ETag & If-Match**        | Concurrency control, 304 Not Modified, 412 Stale  |
| 6   | **Cache-Control**          | GET /campaigns max-age=60, Redis cache            |
| 7   | **Rate Limit**             | Terpusat Redis, per-route override                |
| 8   | **Batch Validate**         | Endpoint baru 207 multi-status                    |
| 9   | **Notifications Fallback** | Endpoint baru GET /notifications polling          |
| 10  | **Feature Flags**          | Endpoint baru GET /features, admin activate       |
| 11  | **Versioning Strategy**    | Deprecation header, Sunset, upgrade guide         |
| 12  | **Webhook**                | Placeholder untuk supplier integration V2         |

---

**Spesifikasi API V3.1 GAP Closed - Siap Implementasi** 🚀
