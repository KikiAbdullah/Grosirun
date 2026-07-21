# SPESIFIKASI API - Grosirun V3.1 Enterprise

**Base URL:** `https://api.grosirun.id/api/v1` (Produksi) | `http://localhost:8000/api/v1` (Pengembangan)  
**Autentikasi:** Bearer Token (Sanctum) + Idempotency-Key + ETag  
**Versioning:** URL `/api/v1/` + Header `Accept: application/vnd.grosirun.v1+json` + `X-App-Version`  
**Tanggal:** 20 Juli 2026  
**Format:** JSON dengan struktur `data` + `meta` + `code` (Error Catalog)  
**OpenAPI:** Generate via Scribe `storage/docs/v1/openapi.yaml`
**Owner:** Backend
**Review Cycle:** Setiap release
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)
**Status Dokumen:** Final
**Status Implementasi:** Belum Dimulai

---

## Daftar Isi

1. Konvensi Umum
2. Strategi Versioning V2
3. Autentikasi, Consent UU PDP, ToS & Penghapusan Akun
4. Cluster
5. Supplier, Produk, Penawaran & Purchase Order
6. Campaign (PO)
7. Varian
8. Order + Batch + Idempotency
9. Upload Bukti (Proof) S3 tempUrl
10. Distribusi
11. Notifikasi Fallback (FCM Fallback)
12. Feature Flags
13. Webhook & Batch Operations
14. Health & Version
15. OpenAPI / Scribe
16. Ringkasan Perubahan dari V3.0
17. Admin Application Operations

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

**Error Catalog Lengkap:** Lihat `[API Specification §1.4](API_SPEC.md#14-format-error--error-catalog)` (50+ error codes)

**Frontend Mapping:** Tampilkan `message` ke user, log `code` + `trace_id` ke Sentry.

#### Katalog Error Canonical dan Mapping Client

Katalog berikut adalah bagian normatif kontrak API. Penambahan atau perubahan kode error wajib memperbarui OpenAPI, test backend, mapper Flutter, analytics, dan changelog. Kode tidak boleh digunakan ulang untuk makna berbeda.

#### Error Autentikasi (ERR_001 - ERR_010)

| Kode         | HTTP | Pesan                                                               | Penyebab                                                    | Aksi Frontend                                                                                                      |
| ------------ | ---- | ------------------------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `ERR_001`    | 401  | OTP_EXPIRED - Kode OTP kadaluarsa                                   | `otp_codes.expires_at < now()` (5 menit)                    | Tampilkan dialog "Kode OTP kadaluarsa, minta ulang" → tombol "Minta Ulang"                                         |
| `ERR_001_RL` | 429  | OTP_RATE_LIMIT - Terlalu banyak percobaan, coba lagi dalam 15 menit | `attempts >= 5` atau RateLimiter 5/menit                    | Tampilkan countdown timer sampai `locked_until`, disable tombol verifikasi                                         |
| `ERR_002`    | 422  | CONSENT_REQUIRED - Harus setuju privasi UU PDP                      | `consent = false`                                           | Tampilkan checkbox Privacy Policy, disable tombol verifikasi jika belum centang                                    |
| `ERR_003`    | 422  | TOS_REQUIRED - Harus setuju Terms of Service non-escrow             | `tos = false`                                               | Tampilkan modal ToS scroll + checkbox, wajib centang                                                               |
| `ERR_004`    | 401  | OTP_INVALID - Kode OTP salah                                        | `Hash::check(otp, otp_hash)` gagal                          | Tampilkan "Kode OTP salah, sisa X percobaan". Jika attempts == 4, peringatkan "1 kali lagi akan terkunci 15 menit" |
| `ERR_005`    | 401  | UNAUTHENTICATED - Token tidak valid atau kadaluarsa                 | Bearer token missing, Sanctum expired 30 hari, atau revoked | Clear SecureStorage → navigasi ke login → dialog "Sesi habis, silakan login ulang"                                 |
| `ERR_006`    | 403  | FORBIDDEN_ROLE - Role tidak cukup                                   | Buyer mencoba POST `/campaigns` (hanya initiator)           | Tampilkan dialog "Anda tidak memiliki akses ke fitur ini"                                                          |
| `ERR_007`    | 403  | FORBIDDEN_CLUSTER - Role ok tapi beda cluster                       | (Digabung dengan ERR_040)                                   | -                                                                                                                  |
| `ERR_008`    | 202  | ACCOUNT_DELETION_ACCEPTED - Permintaan hapus akun diproses <24 jam  | DELETE `/auth/account` berhasil                             | Tampilkan "Data akan dianonimkan dalam <24 jam" → logout otomatis                                                  |
| `ERR_009`    | 422  | PHONE_INVALID - Format nomor HP tidak valid                         | Nomor tidak sesuai E.164 (628xxx)                           | Tampilkan "Masukkan nomor HP dengan format 08xx"                                                                   |

---

#### Error Cluster (ERR_040 - ERR_049)

| Kode      | HTTP | Pesan                                                          | Penyebab                                  | Aksi Frontend                                                                                                |
| --------- | ---- | -------------------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `ERR_040` | 403  | CLUSTER_MISMATCH - Kamu beda cluster, tidak bisa pesan di sini | `buyer.cluster_id != campaign.cluster_id` | Tampilkan dialog "PO ini hanya untuk warga RT [Nama RT]. Hubungi initiator cluster tersebut." → refresh home |
| `ERR_041` | 404  | CLUSTER_NOT_FOUND - Cluster code tidak ditemukan               | `cluster_code` invite invalid             | Tampilkan "Kode cluster tidak valid. Hubungi Ketua RT untuk mendapatkan kode yang benar."                    |

---

#### Error Campaign (ERR_011 - ERR_019)

| Kode      | HTTP | Pesan                                                                 | Penyebab                                            | Aksi Frontend                                                                                   |
| --------- | ---- | --------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `ERR_011` | 422  | CAMPAIGN_TARGET_INVALID - Target harus kelipatan varian terkecil      | `target_quantity % min_variant_size != 0`                 | Tampilkan error di form: "Target harus kelipatan [varian terkecil] Kg"                          |
| `ERR_012` | 422  | CAMPAIGN_DEADLINE_INVALID - Deadline minimal +24 jam                  | `deadline < now() + 24 hours`                       | Tampilkan error di form: "Tenggat waktu minimal 24 jam dari sekarang"                           |
| `ERR_013` | 404  | CAMPAIGN_NOT_FOUND - PO tidak ditemukan                               | Campaign ID tidak ada atau sudah dihapus            | Tampilkan ErrorView "PO tidak ditemukan" + tombol "Kembali ke Beranda"                          |
| `ERR_014` | 409 | CAMPAIGN_NOT_ACTIVE - PO tidak menerima checkout | `campaign.status != active` (`draft`, `target_reached`, `po_submitted`, `fulfillment`, `distribution`, `completed`, `expired`, `cancelled`) | Tampilkan status aktual dan nonaktifkan tombol checkout |
| `ERR_015` | 403  | CAMPAIGN_OWNERSHIP - Bukan pemilik campaign                           | `auth.user_id != campaign.initiator_id`             | Tampilkan "Anda bukan pemilik PO ini"                                                           |
| `ERR_016` | 409  | CAMPAIGN_ALREADY_COMPLETED - PO sudah selesai                         | `status = completed`                                | Tampilkan badge "Selesai" di detail, tidak bisa order                                           |
| `ERR_017` | 409  | CAMPAIGN_EXTEND_LIMIT - Maksimal 2 kali perpanjang                    | `extend_count >= 2`                                 | Tampilkan dialog "Sudah 2 kali perpanjang, tidak bisa perpanjang lagi"                          |
| `ERR_018` | 409  | CAMPAIGN_CANCEL_NOT_ALLOWED - Tidak bisa batal jika sudah ada paid >0 | `orders.paid > 0` (tetapi diizinkan dengan warning) | Tampilkan confirm dialog: "Ada [X] pembayaran lunas. Anda wajib refund manual 2×24 jam. Yakin?" |
| `ERR_019` | 422  | CAMPAIGN_VARIANTS_MIN - Minimal 1 packaging dipilih | `selected_offer_variant_ids` kosong | Tampilkan error: "Pilih minimal 1 packaging"                                                   |

---

#### Error Order (ERR_020 - ERR_029)

| Kode      | HTTP | Pesan                                                               | Penyebab                                                               | Aksi Frontend                                                                                                  |
| --------- | ---- | ------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `ERR_020` | 404  | ORDER_NOT_FOUND - Pesanan tidak ditemukan                           | `uuid` tidak valid                                                     | Tampilkan ErrorView "Pesanan tidak ditemukan"                                                                  |
| `ERR_021` | 403  | ORDER_OWNERSHIP - Bukan pemilik order                               | `user_id != order.user_id` dan `initiator_id != campaign.initiator_id` | Tampilkan "Anda tidak memiliki akses ke pesanan ini"                                                           |
| `ERR_022` | 409  | ORDER_ALREADY_CANCELLED - Sudah batal                               | `cancelled_at != null`                                                 | Tampilkan "Pesanan sudah dibatalkan"                                                                           |
| `ERR_023` | 409  | ORDER_CANNOT_CANCEL - Tidak bisa batal karena sudah paid            | `payment_status = paid`                                                | Tampilkan "Pesanan sudah lunas, tidak bisa dibatalkan. Hubungi initiator."                                     |
| `ERR_024` | 409  | OUT_OF_STOCK - Stok varian habis                                    | `variant.quota - variant.sold < quantity` (lockForUpdate)              | Tampilkan dialog "Stok varian [size]Kg habis. Pilih varian lain." → hapus dari pending queue jika offline sync |
| `ERR_025` | 422  | ORDER_QUANTITY_INVALID - Jumlah tidak valid                         | `quantity < 1 atau quantity > 100`                                     | Tampilkan error di form: "Minimal 1, maksimal 100"                                                             |
| `ERR_026` | 422  | VARIANT_NOT_FOUND - Varian bukan milik campaign                     | `variant.campaign_id != campaign.id`                                   | Tampilkan "Varian tidak valid"                                                                                 |
| `ERR_027` | 403  | CLUSTER_MISMATCH_ORDER - Beda cluster                               | (Duplikat ERR_040)                                                     | -                                                                                                              |
| `ERR_028` | 409  | ORDER_PENDING_PAYMENT_EXISTS - Sudah ada order pending untuk PO ini | (Tidak di MVP, diizinkan multiple order)                               | -                                                                                                              |
| `ERR_029` | 422  | PAYMENT_METHOD_INVALID - Metode pembayaran tidak valid              | `payment_method not in [cash, qris]`                                   | Tampilkan error di form: "Pilih cash atau QRIS"                                                                |

---

#### Error Validasi & Admin (ERR_030 - ERR_039)

| Kode      | HTTP | Pesan                                                        | Penyebab                                            | Aksi Frontend                                                                                   |
| --------- | ---- | ------------------------------------------------------------ | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `ERR_030` | 409  | ALREADY_VALIDATED - Sudah divalidasi di device lain          | Admin race condition (2 device validate same order) | Snackbar "Sudah divalidasi di device lain, refresh daftar" → panggil `loadOrders()`             |
| `ERR_031` | 412  | STALE_DATA - Data sudah lama, refresh dulu                   | ETag mismatch (If-Match)                            | Dialog "Data sudah berubah. Refresh halaman untuk mendapatkan data terbaru." → tombol "Refresh" |
| `ERR_032` | 403  | VALIDATION_OWNERSHIP - Bukan initiator pemilik campaign      | `auth.user_id != campaign.initiator_id`             | Tampilkan "Anda tidak bisa memvalidasi PO ini"                                                  |
| `ERR_033` | 422  | REJECT_REASON_REQUIRED - Alasan reject wajib                 | `reason = null atau empty`                          | Tampilkan form "Alasan penolakan wajib diisi (min 10 karakter)"                                 |
| `ERR_034` | 403  | UNDO_EXPIRED - Undo hanya 5 menit setelah validasi           | `validated_at > 5 minutes ago`                      | Tampilkan dialog "Sudah lewat 5 menit, gunakan fitur Override"                                  |
| `ERR_035` | 422  | OVERRIDE_NOTES_REQUIRED - Override wajib notes               | `notes = null atau empty`                           | Tampilkan form "Catatan override wajib diisi"                                                   |
| `ERR_036` | 429  | OVERRIDE_RATE_LIMIT - Terlalu banyak override                | RateLimiter 10/menit                                | Tampilkan "Terlalu banyak override, tunggu sebentar" + `retry_after`                            |
| `ERR_037` | 207  | BATCH_PARTIAL_SUCCESS - Batch validate sebagian berhasil     | 207 Multi-Status                                    | Tampilkan dialog: "Berhasil: [list]. Gagal: [list dengan reason]"                               |
| `ERR_038` | 403  | TAKEN_OWNERSHIP - Bukan initiator                            | `auth.user_id != campaign.initiator_id`             | Tampilkan "Anda tidak bisa menandai pengambilan"                                                |
| `ERR_039` | 422  | DISTRIBUTION_INCOMPLETE - Masih ada order yang belum diambil | `orders.is_taken = false`                           | Tampilkan "Masih ada [X] order yang belum diambil. Selesaikan distribusi terlebih dahulu."      |

---

#### Error Upload (ERR_050 - ERR_059)

| Kode      | HTTP | Pesan                                                                      | Penyebab                                    | Aksi Frontend                                                                                 |
| --------- | ---- | -------------------------------------------------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `ERR_050` | 413  | UPLOAD_TOO_LARGE - File kegedean                                           | Proof > 2MB, Campaign image > 5MB           | Kompres lebih kecil (70% → 60%), snackbar "File maksimal 2MB untuk bukti / 5MB untuk foto PO" |
| `ERR_051` | 422  | UPLOAD_MIME_INVALID - Format harus jpg/png                                 | Mime type not `image/jpeg` or `image/png`   | Tampilkan "Format file tidak didukung. Gunakan JPG atau PNG."                                 |
| `ERR_052` | 422  | UPLOAD_NO_FILE - Tidak ada file                                            | `file = null`                               | Button upload disabled jika tidak ada file, tampilkan "Pilih file terlebih dahulu"            |
| `ERR_053` | 403  | UPLOAD_OWNERSHIP - Bukan pemilik order                                     | `auth.user_id != order.user_id`             | Tampilkan "Anda tidak bisa upload bukti untuk pesanan orang lain"                             |
| `ERR_054` | 409  | UPLOAD_STATUS_INVALID - Upload hanya saat waiting_validation atau rejected | `payment_status not in [waiting, rejected]` | Tampilkan "Status pesanan tidak memungkinkan upload bukti"                                    |
| `ERR_055` | 410  | PROOF_URL_EXPIRED - Link bukti kadaluarsa                                  | S3 tempUrl 1h expired                       | Tampilkan "Link bukti kadaluarsa. Generate ulang." → panggil `GET /orders/{uuid}/proof-url`   |
| `ERR_056` | 422  | UPLOAD_COMPRESS_FAILED - Gagal kompres gambar                              | Intervention Image error                    | Tampilkan "Gagal memproses gambar. Coba file lain."                                           |

---

#### Error Rate Limit & Keamanan

| Kode      | HTTP | Pesan                                         | Penyebab                                       | Aksi Frontend                                                                                      |
| --------- | ---- | --------------------------------------------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `ERR_060` | 429  | RATE_LIMIT_GLOBAL - Terlalu banyak request    | RateLimiter global 60/menit per user/IP        | Tampilkan "Terlalu banyak permintaan. Tunggu `retry_after` detik."                                 |
| `ERR_061` | 429  | RATE_LIMIT_OVERRIDE - Terlalu banyak override | Override 10/menit                              | Tampilkan countdown                                                                                |
| `ERR_062` | 429  | RATE_LIMIT_VALIDATE - Terlalu banyak validasi | Validate 30/menit                              | Tampilkan countdown                                                                                |
| `ERR_063` | 403  | IDOR_ATTEMPT - Akses data orang lain          | IDOR attempt (accessing order of another user) | Log Sentry critical + Slack alert. Tampilkan "Anda tidak memiliki akses"                           |
| `ERR_064` | 403  | FEATURE_DISABLED - Fitur dimatikan            | Feature flag inactive (Pennant)                | Hide UI elemen (QRIS button, Extend button). Jika tetap diakses: "Fitur sedang dalam pemeliharaan" |
| `ERR_065` | 403  | ACCOUNT_SUSPENDED - Akun ditangguhkan         | Platform fee overdue > 7 hari                  | Tampilkan banner merah "Akun Anda ditangguhkan karena belum bayar platform fee. Hubungi admin."    |

---

#### Error Sistem (ERR_100 - ERR_109)

| Kode      | HTTP | Pesan                                                    | Penyebab                             | Aksi Frontend                                                                                                                      |
| --------- | ---- | -------------------------------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `ERR_100` | 500  | INTERNAL_SERVER_ERROR - Terjadi kesalahan server         | Exception tidak tertangani           | Log Sentry + tampilkan "Terjadi kesalahan server, coba lagi". Tampilkan ErrorView dengan tombol Retry (tidak auto retry untuk 500) |
| `ERR_101` | 503  | SERVICE_UNAVAILABLE - Maintenance                        | Blue-green deploy / maintenance mode | Dio interceptor retry 3x dengan backoff (2s, 5s, 10s). Tampilkan banner "Aplikasi sedang maintenance, coba lagi nanti"             |
| `ERR_102` | 503  | DB_CONNECTION_FAILED - Koneksi database gagal            | MySQL down                           | Sentry + Slack alert. Tampilkan "Koneksi database bermasalah"                                                                      |
| `ERR_103` | 503  | REDIS_CONNECTION_FAILED - Koneksi Redis gagal            | Redis down                           | Cache miss, aplikasi tetap berjalan (fallback). Log warning.                                                                       |
| `ERR_104` | 503  | S3_CONNECTION_FAILED - Koneksi S3 gagal                  | S3 down                              | Retry 3x, fallback local temp + queue upload later. Alert Slack. Tampilkan "Gagal upload, akan dicoba ulang nanti"                 |
| `ERR_105` | 503  | FCM_CONNECTION_FAILED - FCM down                         | Firebase Cloud Messaging error       | Fallback notifications DB inserted. Flutter polling 60s works. Log warning.                                                        |
| `ERR_106` | 400  | IDEMPOTENCY_KEY_MISSING - Header wajib tidak ada         | Idempotency-Key tidak dikirim        | Frontend generate UUID mandatory untuk semua POST/PATCH kritis                                                                     |
| `ERR_107` | 400  | IDEMPOTENCY_KEY_REUSE - Key reuse dengan payload berbeda | Sama key, payload berbeda            | Generate UUID baru per intent. Jangan reuse key untuk payload berbeda.                                                             |
| `ERR_108` | 304  | NOT_MODIFIED - Data tidak berubah                        | ETag If-None-Match match             | Keep previous state, no rebuild (INFO, bukan error)                                                                                |
| `ERR_109` | 503  | THIRD_PARTY_TIMEOUT - Timeout pihak ketiga               | Fonnte WA timeout / Xendit timeout   | Log error, retry queue job. Tampilkan "Gagal mengirim notifikasi, akan dicoba ulang"                                               |

---

##### Error Seller, Offer, dan Purchase Order

| Kode | HTTP | Pesan | Aksi frontend |
| --- | --- | --- | --- |
| `ERR_060_SUPPLIER_NOT_VERIFIED` | 403 | Supplier belum diverifikasi | Buka status verifikasi |
| `ERR_061_OFFER_EXPIRED` | 409 | Penawaran sudah berakhir | Refresh daftar offer |
| `ERR_062_OFFER_CAPACITY_EXCEEDED` | 409 | Kapasitas tidak mencukupi | Tampilkan kapasitas terbaru |
| `ERR_063_INVALID_PRICE_TIER` | 422 | Tier harga tidak valid | Sorot tier bermasalah |
| `ERR_064_PURCHASE_ORDER_INVALID_TRANSITION` | 409 | Perubahan status tidak diizinkan | Muat ulang timeline PO |
| `ERR_065_SUPPLIER_MEMBERSHIP_REQUIRED` | 403 | Akses supplier ditolak | Kembali ke role selector |
| `ERR_066_BUYER_DATA_FORBIDDEN` | 403 | Data Pembeli tidak tersedia untuk Penjual | Hentikan request dan log security |
| `ERR_067_OFFER_VERSION_STALE` | 412 | Penawaran telah berubah | Refresh offer dan minta konfirmasi ulang |
| `ERR_068_SUPPLIER_DOCUMENT_INVALID` | 422 | Dokumen supplier tidak valid | Tampilkan aturan file |
| `ERR_069_FULFILLMENT_DISCREPANCY` | 409 | Jumlah diterima berbeda | Buka formulir dispute fulfillment |
| `ERR_070_INVITATION_EXPIRED` | 410 | Undangan supplier tidak berlaku | Minta owner mengirim undangan baru |
| `ERR_071_LAST_OWNER_REQUIRED` | 409 | Owner terakhir tidak dapat dihapus | Tunjuk owner pengganti |
| `ERR_072_OFFER_RESERVED` | 409 | Perubahan mengganggu reservation aktif | Buat versi offer baru |
| `ERR_073_PURCHASE_ORDER_TIMEOUT` | 409 | SLA respons PO terlewati | Tampilkan eskalasi atau cancel |
| `ERR_074_DISPUTE_WINDOW_EXPIRED` | 410 | Batas pengajuan dispute terlewati | Hubungi Admin dengan bukti |
| `ERR_075_DOCUMENT_REQUIRED` | 422 | Dokumen fulfillment belum lengkap | Sorot invoice/surat jalan yang wajib |

#### Mapping Frontend

##### Dart Mapping Function

```dart
// lib/core/error/error_mapper.dart

String humanMessage(DioException e) {
  final code = e.response?.data['code'];
  final message = e.response?.data['message'] ?? 'Koneksi terputus';
  final traceId = e.response?.data['trace_id'] ?? '';

  // Log trace_id ke Sentry
  if (traceId.isNotEmpty) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'Error: $code', data: {'trace_id': traceId}),
    );
  }

  switch (code) {
    // Auth Errors
    case 'ERR_001':
      return 'Kode OTP kadaluarsa, minta ulang';
    case 'ERR_001_RL':
      final lockedUntil = e.response?.data['locked_until'];
      return 'Terlalu banyak percobaan. Coba lagi ${_formatTime(lockedUntil)}';
    case 'ERR_002':
      return 'Harus setuju privasi UU PDP';
    case 'ERR_003':
      return 'Harus setuju Syarat Layanan Non-Escrow';
    case 'ERR_004':
      final attempts = e.response?.data['attempts'] ?? 0;
      return 'Kode OTP salah. Sisa $attempts percobaan.';
    case 'ERR_005':
      return 'Sesi habis, silakan login ulang';
    case 'ERR_006':
      return 'Anda tidak memiliki akses ke fitur ini';

    // Cluster Errors
    case 'ERR_040':
      return 'Beda cluster RT, tidak bisa pesan di sini';
    case 'ERR_041':
      return 'Kode cluster tidak valid';

    // Campaign Errors
    case 'ERR_011':
      return 'Target harus kelipatan varian terkecil';
    case 'ERR_012':
      return 'Tenggat waktu minimal 24 jam dari sekarang';
    case 'ERR_013':
      return 'PO tidak ditemukan';
    case 'ERR_014':
      return 'PO sudah tidak aktif';
    case 'ERR_017':
      return 'Maksimal 2 kali perpanjangan';
    case 'ERR_018':
      return 'Ada pembayaran lunas. Refund manual 2×24 jam wajib.';

    // Order Errors
    case 'ERR_020':
      return 'Pesanan tidak ditemukan';
    case 'ERR_021':
      return 'Anda tidak memiliki akses ke pesanan ini';
    case 'ERR_024':
      return 'Stok habis, pilih varian lain';
    case 'ERR_025':
      return 'Minimal 1, maksimal 100';

    // Validation Errors
    case 'ERR_030':
      return 'Sudah divalidasi di device lain, refresh';
    case 'ERR_031':
      return 'Data sudah lama, refresh dulu';
    case 'ERR_033':
      return 'Alasan penolakan wajib diisi';
    case 'ERR_034':
      return 'Sudah lewat 5 menit, gunakan Override';
    case 'ERR_035':
      return 'Catatan override wajib diisi';
    case 'ERR_036':
      return 'Terlalu banyak override, tunggu sebentar';
    case 'ERR_037':
      return 'Validasi sebagian berhasil. Cek detail.';

    // Upload Errors
    case 'ERR_050':
      return 'File terlalu besar (max 2MB)';
    case 'ERR_051':
      return 'Format harus JPG atau PNG';
    case 'ERR_054':
      return 'Status tidak bisa upload bukti';
    case 'ERR_055':
      return 'Link bukti kadaluarsa, generate ulang';

    // Rate Limit
    case 'ERR_060':
      return 'Terlalu banyak permintaan, tunggu sebentar';
    case 'ERR_061':
      return 'Terlalu banyak override, tunggu sebentar';
    case 'ERR_062':
      return 'Terlalu banyak validasi, tunggu sebentar';

    // System
    case 'ERR_100':
      return 'Terjadi kesalahan server, coba lagi';
    case 'ERR_101':
      return 'Aplikasi sedang maintenance, coba lagi nanti';
    case 'ERR_104':
      return 'Gagal upload, akan dicoba ulang nanti';
    case 'ERR_106':
      return 'Idempotency-Key tidak valid';
    case 'ERR_107':
      return 'Key idempotency tidak valid untuk payload ini';

    default:
      return message; // fallback ke message dari server
  }
}

String _formatTime(String? isoTime) {
  if (isoTime == null) return 'nanti';
  try {
    final date = DateTime.parse(isoTime);
    final diff = date.difference(DateTime.now());
    if (diff.inSeconds < 60) return '${diff.inSeconds} detik';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit';
    return '${diff.inHours} jam';
  } catch (_) {
    return 'nanti';
  }
}
```

##### Error Dialog Widget

```dart
// lib/presentation/widgets/error_dialog.dart

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.code,
    required this.message,
    this.onRetry,
  });

  final String code;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text('Error $code'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 8),
          Text(
            'Trace ID: ${_getTraceId()}',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!();
            },
            child: const Text('Coba Lagi'),
          ),
      ],
    );
  }

  String _getTraceId() {
    // Ambil dari context atau global state
    return 'trace-${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

---

#### Panduan Penggunaan

##### Backend (Laravel)

**Throwing Error di Controller/Service:**

```php
// app/Exceptions/Handler.php
throw new HttpException(409, 'Stok varian habis', null, ['code' => 'ERR_024']);

// Atau dengan response helper
return response()->json([
    'message' => 'Stok varian habis',
    'code' => 'ERR_024',
    'http_code' => 409,
    'trace_id' => (string) Str::uuid(),
], 409);
```

**Error Code di Form Request:**

```php
// app/Http/Requests/StoreOrderRequest.php
public function rules(): array
{
    return [
        'quantity' => ['required', 'integer', 'min:1', 'max:100'],
    ];
}

public function messages(): array
{
    return [
        'quantity.min' => 'Minimal 1',
        'quantity.max' => 'Maksimal 100',
    ];
}
```

##### Menambahkan Error Code Baru

1. Tambahkan kode di katalog ini dengan format:

   ```
   | `ERR_XXX` | HTTP | Pesan | Penyebab | Aksi |
   ```

2. Tambahkan mapping di `error_mapper.dart`:

   ```dart
   case 'ERR_XXX':
     return 'Pesan error';
   ```

3. Update test di `TEST_PLAN.md` security matrix

4. Update `CHANGELOG.md`

##### Error Code Range

| Range             | Kategori              |
| ----------------- | --------------------- |
| ERR_001 - ERR_010 | Autentikasi           |
| ERR_011 - ERR_019 | Campaign              |
| ERR_020 - ERR_029 | Order                 |
| ERR_030 - ERR_039 | Validasi & Admin      |
| ERR_040 - ERR_049 | Cluster               |
| ERR_050 - ERR_059 | Upload                |
| ERR_060 - ERR_075 | Seller, Supplier, Offer, Purchase Order, dan Fulfillment |
| ERR_100 - ERR_109 | Sistem                |

---

#### Ringkasan Error Kritis

| Kode         | HTTP | Pesan                 | Prioritas                   |
| ------------ | ---- | --------------------- | --------------------------- |
| `ERR_024`    | 409  | OUT_OF_STOCK          | 🔴 Critical (zero oversell) |
| `ERR_030`    | 409  | ALREADY_VALIDATED     | 🔴 Critical (admin race)    |
| `ERR_040`    | 403  | CLUSTER_MISMATCH      | 🟡 High (isolasi data)      |
| `ERR_050`    | 413  | UPLOAD_TOO_LARGE      | 🟡 High (UX)                |
| `ERR_001_RL` | 429  | OTP_RATE_LIMIT        | 🟡 High (security)          |
| `ERR_005`    | 401  | UNAUTHENTICATED       | 🟡 High (security)          |
| `ERR_063`    | 403  | IDOR_ATTEMPT          | 🔴 Critical (security)      |
| `ERR_100`    | 500  | INTERNAL_SERVER_ERROR | 🔴 Critical (stability)     |

---

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

1. `GET /campaigns/{id}` return `ETag: W/"{campaign.updated_at}-{current_quantity}"`
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
| Komunikasi          | [CHANGELOG.md](CHANGELOG.md), Slack, in-app banner       |
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
6. Kirim WA via Fonnte (atau log ke file di local)
7. Return 200 OK

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
      "roles": ["buyer"],
      "active_role": "buyer",
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
    "roles": ["buyer"],
    "active_role": "buyer",
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


### 3.10 PUT /auth/active-role

**Auth:** Required. Mengganti konteks role aktif tanpa membuat identitas atau token baru. Role yang diminta wajib terdapat pada `roles` milik user.

```json
{"active_role":"initiator"}
```

Response mengembalikan kontrak identitas canonical:

```json
{"data":{"roles":["buyer","initiator"],"active_role":"initiator"}}
```

Pergantian dicatat sebagai event `role_switch`. Seluruh Policy tetap memeriksa membership role, active role, ownership, cluster, atau supplier membership.

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

## 5. Seller, Supplier, Offer, Purchase Order & Fulfillment Dispute

Semua endpoint seller memerlukan `active_role=seller` dan supplier membership aktif. Semua list memakai `page`, `per_page` maksimum 100, `sort`, filter terdokumentasi, response `data+meta`, ETag, dan rate limit global. Semua mutation memakai Idempotency-Key; update/transition memakai If-Match.

### 5.1 POST /suppliers

Seller membuat supplier `pending_verification` dan menjadi owner. Wajib: `name`, `legal_name`, alamat, kota, provinsi, kontak bisnis; tax ID/dokumen mengikuti kebijakan verifikasi. Response 201 mengembalikan UUID, status, version. Rate limit 3/hari/user.

### 5.2 GET /suppliers dan GET /suppliers/{uuid}

Inisiator hanya melihat supplier `verified+active` sesuai area; Seller melihat membership sendiri; Admin dapat filter seluruh status. Response publik tidak memuat tax ID atau dokumen verifikasi.

### 5.3 PATCH /suppliers/{uuid}

Seller owner, supplier sendiri, If-Match wajib. Perubahan identitas legal pada supplier verified mengubah status menjadi `pending_reverification`; offer aktif dapat dibekukan oleh policy.

### 5.4 POST /suppliers/{uuid}/members/invite

Seller owner mengundang user seller dengan `member_role=owner|sales|warehouse`. Invitation token single-use, hash disimpan, kedaluwarsa 48 jam. Owner terakhir tidak dapat dihapus atau diturunkan.

### 5.5 POST /supplier-invitations/{token}/accept

Seller menerima invitation yang belum dipakai/kedaluwarsa. Unique `(supplier_id,user_id)` mencegah duplikasi.

### 5.6 PATCH /suppliers/{uuid}/members/{user_uuid}/role

Owner mengubah member role dengan If-Match. Larangan owner terakhir berlaku.

### 5.7 DELETE /suppliers/{uuid}/members/{user_uuid}

Owner mencabut membership. Self-removal diizinkan kecuali owner terakhir. Session seller target kehilangan akses segera.

### 5.8 POST /suppliers/{uuid}/products dan PATCH /products/{uuid}

Owner/sales mengelola produk. `base_unit` wajib dari controlled vocabulary `kg|liter|piece|pack`; unit tambahan memerlukan Admin configuration. Product tidak dapat berpindah supplier.

### 5.9 POST /products/{uuid}/offers

Membuat offer `draft` dengan `minimum_quantity`, `available_quantity`, delivery fee/radius, validity, tiers, variants, dan areas.

```json
{
  "minimum_quantity": 500,
  "available_quantity": 3000,
  "delivery_fee": 0,
  "valid_from": "2026-08-01T00:00:00+07:00",
  "valid_until": "2026-08-31T23:59:59+07:00",
  "tiers": [{"minimum_quantity":500,"unit_price":10500},{"minimum_quantity":1000,"unit_price":10000}],
  "variants": [{"name":"Sak 5 Kg","package_quantity":5,"sku":"BM-5"},{"name":"Sak 10 Kg","package_quantity":10,"sku":"BM-10"}],
  "areas": [{"city":"Surabaya"}]
}
```

Harga tier adalah harga per base unit. Variant hanya packaging dan menggunakan pool kapasitas base unit yang sama.

### 5.10 GET /offers dan GET /offers/{uuid}

Filter: supplier, product, category, city, district, status, valid_at, min_capacity. Inisiator hanya melihat offer active yang valid; Seller melihat supplier sendiri; Admin seluruh status. Response memuat `available_quantity`, `reserved_quantity`, `committed_quantity`, version, tiers, variants, dan areas sesuai authorization.

### 5.11 PATCH /offers/{uuid}

Owner/sales mengubah draft/rejected. Untuk offer active, perubahan komersial membuat versi baru draft; versi lama tetap melayani snapshot campaign dan tidak berubah.

### 5.12 POST /offers/{uuid}/submit|pause|resume|expire

- `submit`: draft/rejected → pending_review.
- `pause`: active → paused; tidak memengaruhi campaign snapshot, mencegah campaign baru.
- `resume`: paused → active jika verified, valid, dan kapasitas tersedia.
- `expire`: sistem/Admin saat melewati validity; tidak mengubah campaign lama.

### 5.13 POST /campaigns/{id}/purchase-orders

Inisiator owner; campaign wajib `target_reached`, payment threshold terpenuhi, dan belum memiliki PO aktif. Server membuat item snapshot, subtotal, delivery cost, total; transisi atomik `draft→submitted`, campaign menjadi `po_submitted`.

### 5.14 GET /seller/purchase-orders dan GET /purchase-orders/{uuid}

Seller hanya PO supplier membership; Inisiator hanya campaign sendiri; Admin read/audit. Seller menerima item agregat tanpa identitas/proof Pembeli. Filter status/date/campaign; ETag dari version.

### 5.15 PATCH /seller/purchase-orders/{uuid}/decision

Owner/sales memutuskan `accepted|rejected` maksimal 12 jam. Reject wajib `reason`. Accept atomik menjalankan `submitted→accepted→awaiting_payment`, memindahkan offer reserved menjadi committed, dan mengubah campaign ke `fulfillment`.

### 5.16 POST /purchase-orders/{uuid}/payment-proof

Inisiator upload proof transfer supplier private S3, max 5 MB, mime jpg/png/pdf, SHA-256. Ini bukan proof Buyer.

### 5.17 PATCH /seller/purchase-orders/{uuid}/payment-confirmation

Owner/sales memilih confirmed/rejected dengan alasan. Confirmed menjalankan `awaiting_payment→paid`; rejected mempertahankan awaiting_payment dan mengirim notifikasi Inisiator.

### 5.18 PATCH /seller/purchase-orders/{uuid}/status

Owner/sales: `paid→processing`; owner/sales/warehouse: `processing→shipped`. Shipped wajib invoice, delivery note, dan tracking/reference. Invalid transition 409.

### 5.19 POST /purchase-orders/{uuid}/documents

Jenis: `invoice`, `delivery_note`, `initiator_payment_proof`, `delivery_evidence`, `dispute_evidence`. Authorization per tipe, private S3, max 5 MB, checksum, malware scan, metadata sanitasi.

### 5.20 PATCH /purchase-orders/{uuid}/delivered

Inisiator mengirim expected/received/damaged quantity dan evidence. Sesuai → PO delivered, campaign distribution. Selisih → PO tetap shipped dan fulfillment dispute otomatis dibuka.

### 5.21 POST /purchase-orders/{uuid}/disputes

Inisiator membuka dispute maksimal 1×24 jam setelah penerimaan.

```json
{"reason":"quantity_shortage","expected_quantity":1000,"received_quantity":950,"damaged_quantity":0,"notes":"Kurang 50 kg","document_ids":[12]}
```

### 5.22 GET /purchase-orders/{uuid}/disputes dan POST /fulfillment-disputes/{uuid}/responses

Pihak PO dan Admin dapat membaca. Seller merespons maksimal 1×24 jam dengan notes, proposed resolution, dan evidence. Data Buyer tidak tersedia.

### 5.23 PATCH /admin/fulfillment-disputes/{uuid}/resolve

Admin re-authenticated memilih `replacement|partial_refund|full_refund|accepted_as_is|cancelled`, nominal/quantity resolusi, alasan, dan bukti. Semua pihak diberi notifikasi; audit append-only.

### 5.24 Kegagalan, Refund, dan Reservation

| Kejadian | Campaign/PO | Kapasitas | Tindakan |
| --- | --- | --- | --- |
| Offer stale/expired sebelum campaign | Tidak dibuat | Tidak berubah | 409/412, refresh offer |
| Kapasitas habis saat create | Tidak dibuat | Tidak berubah | 409 atomic |
| Campaign expired/cancelled sebelum accept | terminal | reserved dilepas | Inisiator refund Buyer paid 2×24 jam |
| Seller reject PO | campaign perlu keputusan; PO rejected | reserved dilepas | pilih offer baru melalui campaign baru atau cancel/refund |
| Seller tidak respons 12 jam | PO tetap submitted, eskalasi | reserved tetap | Admin reminder/escalation; Inisiator boleh cancel |
| Seller cancel setelah accept | dispute kritis | committed ditahan sampai resolusi | Admin, supplier sanction, refund/replacement |
| Partial/damaged delivery | PO shipped + dispute | committed tetap | replacement/refund supplier; refund Buyer oleh Inisiator bila perlu |

### 5.25 Error Supply Domain

Gunakan katalog canonical `ERR_060`–`ERR_075` untuk seluruh kegagalan supply domain.

---

## 6. Campaign (PO)

### 6.1 GET /campaigns

**Deskripsi:** Ambil daftar campaign (PO) aktif di cluster user.

**Auth:** Required (auto-filter cluster via Global Scope)

**Query Params:**

| Parameter    | Tipe   | Keterangan                                         |
| ------------ | ------ | -------------------------------------------------- |
| `page`       | int    | Halaman (default 1)                                |
| `per_page`   | int    | Item per halaman (default 15, max 100)             |
| `status`     | string | `draft`, `active`, `target_reached`, `po_submitted`, `fulfillment`, `distribution`, `completed`, `expired`, `cancelled`      |
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
    "supplier_offer_id": 123,
    "offer_version": 4,
    "supplier_unit_price": 10000,
    "buyer_unit_price": 12000,
    "supplier_subtotal": 10000000,
    "delivery_cost": 0,
    "reserved_quantity": 1000,
      "name": "Beras Mahkota Premium",
      "description": "Pulen langsung dari pabrik Makmur Jaya",
      "image_url": "https://s3.../campaigns/uuid.jpg",
      "target_quantity": 1000,
      "current_quantity": 750,
      "progress_percent": 75,
      "supplier_subtotal": 10000000,
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
          "package_quantity": 5,
          "price": 60000,
          "quota": 100,
          "sold": 75,
          "remaining": 25
        },
        {
          "id": 2,
          "package_quantity": 10,
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

### 6.2 GET /campaigns/{id}

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
    "supplier_offer_id": 123,
    "offer_version": 4,
    "supplier_unit_price": 10000,
    "buyer_unit_price": 12000,
    "supplier_subtotal": 10000000,
    "delivery_cost": 0,
    "reserved_quantity": 1000,
    "name": "Beras Mahkota Premium",
    "description": "Pulen langsung dari pabrik Makmur Jaya",
    "image_url": "https://s3.../campaigns/uuid.jpg",
    "target_quantity": 1000,
    "current_quantity": 750,
    "supplier_subtotal": 10000000,
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
        "package_quantity": 5,
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

### 6.3 GET /campaigns/{id}/activities

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

### 6.4 POST /campaigns

**Deskripsi:** Endpoint canonical untuk membuat campaign berbasis penawaran. Inisiator wajib memilih satu penawaran aktif melalui `supplier_offer_id`. Campaign tanpa penawaran ditolak.

**Auth:** Initiator role required

**Request (multipart/form-data):**

| Field                  | Tipe    | Wajib | Keterangan                                        |
| ---------------------- | ------- | ----- | ------------------------------------------------- |
| `name`                 | string  | ✅    | Nama campaign (max 150 chars)                     |
| `description`          | string  | ❌    | Deskripsi campaign                                |
| `target_quantity`            | integer | ✅    | Target kilogram (harus kelipatan varian terkecil) |
| `supplier_offer_id`     | integer | ✅    | Penawaran aktif sumber campaign; immutable setelah dibuat |
| `buyer_unit_price`      | integer | ✅    | Harga per unit kepada Pembeli; harus memenuhi validasi margin |
| `deadline`             | string  | ✅    | Tenggat waktu (min +24 jam dari sekarang)         |
| `pickup_location`      | string  | ❌    | Lokasi pengambilan barang                         |
| `image`                | file    | ❌    | Foto campaign (max 5MB, jpg/png)                  |
| `selected_offer_variant_ids` | array | ✅ | ID packaging milik offer yang dipilih (min 1) |

**Request Contoh (JSON):**

```json
{
  "supplier_offer_id": 123,
  "name": "Beras Mahkota Premium",
  "description": "Pulen langsung dari pabrik Makmur Jaya",
  "target_quantity": 1000,
  "buyer_unit_price": 12000,
  "deadline": "2026-07-22T10:00:00+07:00",
  "pickup_location": "Rumah Pak RT Jl Mawar 12",
  "selected_offer_variant_ids": [501, 502]
}
```

**Response 201:**

```json
{
  "message": "Campaign berhasil dibuat",
  "data": {
    "id": 1,
    "slug": "beras-mahkota-premium-abc123",
    "supplier_offer_id": 123,
    "offer_version": 4,
    "supplier_unit_price": 10000,
    "buyer_unit_price": 12000,
    "supplier_subtotal": 10000000,
    "delivery_cost": 0,
    "reserved_quantity": 1000,
    "image_url": "https://s3.../campaigns/uuid.jpg",
    "share_link": "https://grosirun.id/c/beras-mahkota-premium-abc123",
    "deep_link": "grosirun://campaign/1"
  }
}
```

### 6.5 PUT /campaigns/{id}

**Deskripsi:** Update campaign (hanya initiator pemilik).

**Auth:** Initiator owner required

**Request:** Hanya metadata campaign yang dapat diubah. `supplier_offer_id`, `offer_snapshot`, `supplier_unit_price`, `supplier_subtotal`, dan reservasi kapasitas bersifat immutable. Penggantian offer menggunakan prosedur pembatalan dan pembuatan campaign baru sebelum purchase order diterima.

**Response 200:** Sama seperti GET detail.

### 6.6 POST /campaigns/{id}/extend

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

### 6.7 POST /campaigns/{id}/cancel

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

### 6.8 GET /campaigns/{id}/recap

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
      "target_quantity": 1000,
      "current_quantity": 750
    },
    "summary": {
      "total_buyers": 35,
      "total_quantity": 700,
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

## 7. Varian

### 7.1 GET /campaigns/{id}/variants

**Deskripsi:** Ambil varian campaign.

**Auth:** Required

**Response 200:**

```json
{
  "data": [
    {
      "id": 1,
      "package_quantity": 5.0,
      "price": 60000,
      "quota": 100,
      "sold": 75,
      "remaining": 25
    }
  ]
}
```

### 7.2 GET /variants/{id}

**Deskripsi:** Ambil detail varian.

**Auth:** Required

**Response 200:** Sama seperti di atas.

---

## 8. Order + Batch + Idempotency

### 8.1 POST /campaigns/{id}/orders

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
      "total_quantity": 5,
      "total_price": 60000,
      "payment_method": "cash",
      "payment_status": "pending",
      "idempotency_key": "550e8400-e29b-41d4-a716-446655440001",
      "created_at": "2026-07-20T10:00:00+07:00"
    },
    "campaign": {
      "current_quantity": 755,
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

### 8.2 POST /campaigns/{id}/orders/batch-create

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

### 8.3 GET /my/orders

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
      "total_quantity": 5,
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

### 8.4 GET /campaigns/{id}/orders

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

### 8.5 GET /orders/{uuid}

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
    "total_quantity": 5,
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

### 8.6 PATCH /orders/{uuid}/validate

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

### 8.7 PATCH /orders/{uuid}/reject

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

### 8.8 PATCH /orders/{uuid}/undo-validation

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

### 8.9 PATCH /orders/{uuid}/override-validate

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

### 8.10 PATCH /orders/{uuid}/cancel

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

### 8.11 POST /orders/{uuid}/transfer

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

### 8.12 POST /campaigns/{id}/orders/batch-validate

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

## 9. Upload Bukti (Proof) S3 tempUrl

### 9.1 POST /orders/{uuid}/proof

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
6. Generate tempUrl 1 jam
7. Update order: `proof_path`, `payment_status` = `waiting`

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

### 9.2 GET /orders/{uuid}/proof-url

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

## 10. Distribusi

### 10.1 GET /campaigns/{id}/distribution

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
        "total_quantity": 5,
        "is_taken": false,
        "taken_at": null
      }
    ]
  }
}
```

### 10.2 PATCH /orders/{uuid}/taken

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

### 10.3 POST /campaigns/{id}/complete-distribution

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

## 11. Notifikasi Fallback (FCM Fallback)

### 11.1 GET /notifications

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

### 11.2 PATCH /notifications/{id}/read

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

### 11.3 POST /notifications/read-all

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

### 11.4 POST /notifications/test (Admin Only)

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

## 12. Feature Flags

### 12.1 GET /features

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
    "seller-onboarding": false,
    "supplier-offers": false,
    "purchase-orders": false
  }
}
```

Endpoint client hanya mengembalikan flag yang memengaruhi UI user tersebut. Flag backend-only tidak dikirim.

| Flag | Exposure | Scope | Default sebelum implementasi | Tujuan |
| --- | --- | --- | --- | --- |
| `qris-upload` | Client | global/user | false | Upload proof QRIS |
| `extend-deadline` | Client | cluster | false | Perpanjang campaign |
| `batch-validate` | Client | cluster | false | Validasi order massal |
| `dark-mode` | Client | user | false | Tema gelap |
| `seller-onboarding` | Client | user/global | false | Registrasi Seller/Supplier |
| `supplier-offers` | Client | supplier/global | false | Offer marketplace dan management |
| `purchase-orders` | Client | supplier/cluster/global | false | PO dan fulfillment berbasis penawaran |
| `supplier-erp-webhook` | Backend-only | supplier | false | Integrasi ERP opsional |
| `canary-new-order-service` | Backend-only | percentage | false | Canary service order; tidak dikirim ke mobile |

### 12.2 POST /admin/features/{feature}/activate (Admin Only)

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
| `scope`    | string  | ❌    | `global`, `cluster`, `user`, `supplier`, `percentage`               |
| `scope_id` | integer | ❌    | ID cluster/user/supplier atau nilai percentage sesuai scope |

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

## 13. Webhook & Batch Operations

### 13.1 POST /webhooks/supplier-erp/order-status (Future V2)

**Deskripsi:** Webhook opsional untuk integrasi ERP supplier. Seller workspace dan endpoint purchase order tetap menjadi kontrak utama untuk perubahan status.

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

**Feature Flag:** `supplier-erp-webhook` harus aktif.

### 13.2 Batch Operations Summary

| Endpoint                                     | Deskripsi         | Auth      |
| -------------------------------------------- | ----------------- | --------- |
| `POST /campaigns/{id}/orders/batch-create`   | Buat order massal | Initiator |
| `POST /campaigns/{id}/orders/batch-validate` | Validasi massal   | Initiator |

---

## 14. Health & Version

### 14.1 GET /health

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

### 14.2 GET /version

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

## 15. OpenAPI / Scribe

### 15.1 Generate Dokumentasi

```bash
# Generate V1
php artisan scribe:generate --config=scribe.v1.config

# Generate V2 (future)
php artisan scribe:generate --config=scribe.v2.config
```

### 15.2 Akses Dokumentasi

| Environment | URL                                    |
| ----------- | -------------------------------------- |
| Development | `http://localhost:8000/docs`           |
| Staging     | `https://api.staging.grosirun.id/docs` |
| Production  | `https://api.grosirun.id/docs`         |

### 15.3 Postman Collection

File: `backend/postman/Grosirun_API_V1.1.postman_collection.json`

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

## 16. Ringkasan Perubahan dari V3.0
17. Admin Application Operations

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
| 12  | **Webhook**                | Integrasi ERP supplier opsional; bukan pengganti Seller workspace         |

---

---

## 17. Admin Application Operations

Semua endpoint memakai active role Admin, re-authentication untuk mutation sensitif, Idempotency-Key, If-Match, reason, audit log, dan rate limit 30/min.

### 17.1 GET /admin/suppliers/pending dan PATCH /admin/suppliers/{uuid}/verification

Queue verifikasi; keputusan `approved|rejected`, checklist dokumen, notes wajib untuk reject. Identitas legal terenkripsi dan tidak masuk log.

### 17.2 GET /admin/offers/pending dan PATCH /admin/offers/{uuid}/moderation

Moderasi unit, tier, variant, kapasitas, area, validity, serta konten. Approved → active; rejected wajib reason.

### 17.3 POST /admin/users/{uuid}/roles dan DELETE /admin/users/{uuid}/roles/{role}

Grant/revoke role. Admin tidak dapat self-escalate, menghapus role owner terakhir, atau menghapus role yang masih memiliki operasi aktif tanpa transfer ownership.

### 17.4 PATCH /admin/users/{uuid}/status dan PATCH /admin/suppliers/{uuid}/status

Status `active|suspended|blocked`. Wajib reason, expiry opsional, revoke session, notifikasi, dan audit.

### 17.5 Cluster, Feature Flag, Audit, dan Emergency Override

Admin mengelola cluster dan feature flags melalui endpoint existing. Audit viewer filter actor/resource/action/trace/date tanpa dapat mengubah log. Emergency override tersedia hanya untuk incident terdaftar, re-authentication, reason, ticket ID, before/after values, serta notifikasi pihak terdampak.

### 17.6 Dashboard Admin

Metrik: verification queue age, offer moderation SLA, seller response SLA, PO shipment SLA, dispute backlog, security events, failed jobs, dan feature rollout. Data Buyer ditampilkan minimum dan dimasking secara default.
