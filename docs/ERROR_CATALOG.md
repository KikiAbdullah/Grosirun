# KATALOG ERROR - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Format:** ERR_XXX + HTTP + Pesan + Aksi Frontend  
**Total:** 50+ Kode Error  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Error Autentikasi (ERR_001 - ERR_010)
3. Error Cluster (ERR_040 - ERR_049)
4. Error Campaign (ERR_011 - ERR_019)
5. Error Order (ERR_020 - ERR_029)
6. Error Validasi & Admin (ERR_030 - ERR_039)
7. Error Upload (ERR_050 - ERR_059)
8. Error Rate Limit & Keamanan
9. Error Sistem (ERR_100 - ERR_109)
10. Mapping Frontend
11. Panduan Penggunaan

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Tujuan Katalog Error

Katalog error ini menjadi **sumber kebenaran tunggal** untuk semua kode error yang digunakan di Grosirun V3.1. Setiap error memiliki:

- **Kode Error Unik** (format ERR_XXX)
- **HTTP Status Code** (sesuai standar REST)
- **Pesan Error** (human-readable dalam Bahasa Indonesia)
- **Penyebab** (technical cause untuk debugging)
- **Aksi Frontend** (apa yang harus dilakukan aplikasi)

### 1.2 Konteks Bisnis (Referensi BUSINESS_ANALYSIS.md)

| Komponen              | Nilai                            |
| --------------------- | -------------------------------- |
| Platform Fee          | 1% GMV + PPN 11%                 |
| GMV per PO AT_70      | Rp8.400.000                      |
| Laba Initiator per PO | Rp956.760                        |
| Zero Oversell         | Kritis untuk menjaga kepercayaan |

**Error yang Paling Kritis:**

- `ERR_024 OUT_OF_STOCK` → Menjaga zero oversell
- `ERR_030 ALREADY_VALIDATED` → Mencegah admin race condition
- `ERR_040 CLUSTER_MISMATCH` → Menjaga isolasi data antar RT

### 1.3 Format Error Response

**Struktur JSON:**

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

| Field       | Tipe    | Keterangan                                    |
| ----------- | ------- | --------------------------------------------- |
| `message`   | string  | Pesan error human-readable (Bahasa Indonesia) |
| `code`      | string  | Kode error unik (ERR_XXX)                     |
| `http_code` | integer | HTTP status code                              |
| `errors`    | object  | Detail error per field (untuk validasi)       |
| `trace_id`  | string  | UUID untuk tracing di Sentry                  |

---

## 2. Error Autentikasi (ERR_001 - ERR_010)

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

## 3. Error Cluster (ERR_040 - ERR_049)

| Kode      | HTTP | Pesan                                                          | Penyebab                                  | Aksi Frontend                                                                                                |
| --------- | ---- | -------------------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `ERR_040` | 403  | CLUSTER_MISMATCH - Kamu beda cluster, tidak bisa pesan di sini | `buyer.cluster_id != campaign.cluster_id` | Tampilkan dialog "PO ini hanya untuk warga RT [Nama RT]. Hubungi initiator cluster tersebut." → refresh home |
| `ERR_041` | 404  | CLUSTER_NOT_FOUND - Cluster code tidak ditemukan               | `cluster_code` invite invalid             | Tampilkan "Kode cluster tidak valid. Hubungi Ketua RT untuk mendapatkan kode yang benar."                    |

---

## 4. Error Campaign (ERR_011 - ERR_019)

| Kode      | HTTP | Pesan                                                                 | Penyebab                                            | Aksi Frontend                                                                                   |
| --------- | ---- | --------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `ERR_011` | 422  | CAMPAIGN_TARGET_INVALID - Target harus kelipatan varian terkecil      | `target_kg % min_variant_size != 0`                 | Tampilkan error di form: "Target harus kelipatan [varian terkecil] Kg"                          |
| `ERR_012` | 422  | CAMPAIGN_DEADLINE_INVALID - Deadline minimal +24 jam                  | `deadline < now() + 24 hours`                       | Tampilkan error di form: "Tenggat waktu minimal 24 jam dari sekarang"                           |
| `ERR_013` | 404  | CAMPAIGN_NOT_FOUND - PO tidak ditemukan                               | Campaign ID tidak ada atau sudah dihapus            | Tampilkan ErrorView "PO tidak ditemukan" + tombol "Kembali ke Beranda"                          |
| `ERR_014` | 409  | CAMPAIGN_NOT_ACTIVE - PO tidak aktif                                  | Status `completed`, `expired`, atau `cancelled`     | Tampilkan card berwarna abu-abu, tombol "Ikut Patungan" disabled dengan badge status            |
| `ERR_015` | 403  | CAMPAIGN_OWNERSHIP - Bukan pemilik campaign                           | `auth.user_id != campaign.initiator_id`             | Tampilkan "Anda bukan pemilik PO ini"                                                           |
| `ERR_016` | 409  | CAMPAIGN_ALREADY_COMPLETED - PO sudah selesai                         | `status = completed`                                | Tampilkan badge "Selesai" di detail, tidak bisa order                                           |
| `ERR_017` | 409  | CAMPAIGN_EXTEND_LIMIT - Maksimal 2 kali perpanjang                    | `extend_count >= 2`                                 | Tampilkan dialog "Sudah 2 kali perpanjang, tidak bisa perpanjang lagi"                          |
| `ERR_018` | 409  | CAMPAIGN_CANCEL_NOT_ALLOWED - Tidak bisa batal jika sudah ada paid >0 | `orders.paid > 0` (tetapi diizinkan dengan warning) | Tampilkan confirm dialog: "Ada [X] pembayaran lunas. Anda wajib refund manual 2×24 jam. Yakin?" |
| `ERR_019` | 422  | CAMPAIGN_VARIANTS_MIN - Minimal 1 varian                              | `variants < 1`                                      | Tampilkan error: "Tambahkan minimal 1 varian"                                                   |

---

## 5. Error Order (ERR_020 - ERR_029)

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

## 6. Error Validasi & Admin (ERR_030 - ERR_039)

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

## 7. Error Upload (ERR_050 - ERR_059)

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

## 8. Error Rate Limit & Keamanan

| Kode      | HTTP | Pesan                                         | Penyebab                                       | Aksi Frontend                                                                                      |
| --------- | ---- | --------------------------------------------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `ERR_060` | 429  | RATE_LIMIT_GLOBAL - Terlalu banyak request    | RateLimiter global 60/menit per user/IP        | Tampilkan "Terlalu banyak permintaan. Tunggu `retry_after` detik."                                 |
| `ERR_061` | 429  | RATE_LIMIT_OVERRIDE - Terlalu banyak override | Override 10/menit                              | Tampilkan countdown                                                                                |
| `ERR_062` | 429  | RATE_LIMIT_VALIDATE - Terlalu banyak validasi | Validate 30/menit                              | Tampilkan countdown                                                                                |
| `ERR_063` | 403  | IDOR_ATTEMPT - Akses data orang lain          | IDOR attempt (accessing order of another user) | Log Sentry critical + Slack alert. Tampilkan "Anda tidak memiliki akses"                           |
| `ERR_064` | 403  | FEATURE_DISABLED - Fitur dimatikan            | Feature flag inactive (Pennant)                | Hide UI elemen (QRIS button, Extend button). Jika tetap diakses: "Fitur sedang dalam pemeliharaan" |
| `ERR_065` | 403  | ACCOUNT_SUSPENDED - Akun ditangguhkan         | Platform fee overdue > 7 hari                  | Tampilkan banner merah "Akun Anda ditangguhkan karena belum bayar platform fee. Hubungi admin."    |

---

## 9. Error Sistem (ERR_100 - ERR_109)

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

## 10. Mapping Frontend

### 10.1 Dart Mapping Function

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

### 10.2 Error Dialog Widget

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

## 11. Panduan Penggunaan

### 11.1 Backend (Laravel)

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

### 11.2 Menambahkan Error Code Baru

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

### 11.3 Error Code Range

| Range             | Kategori              |
| ----------------- | --------------------- |
| ERR_001 - ERR_010 | Autentikasi           |
| ERR_011 - ERR_019 | Campaign              |
| ERR_020 - ERR_029 | Order                 |
| ERR_030 - ERR_039 | Validasi & Admin      |
| ERR_040 - ERR_049 | Cluster               |
| ERR_050 - ERR_059 | Upload                |
| ERR_060 - ERR_069 | Rate Limit & Keamanan |
| ERR_100 - ERR_109 | Sistem                |

---

## 12. Ringkasan Error Kritis

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

**Katalog Error V3.1 Production Ready - 50+ Error Codes, Frontend Mapping, Trace ID, Action untuk Setiap Error!** 🚀
