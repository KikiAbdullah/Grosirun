# KEBIJAKAN PRIVASI - Grosirun V3.1

**Sesuai UU Pelindungan Data Pribadi No.27/2022**  
**Tanggal Efektif:** 20 Juli 2026  
**Versi:** 1.0  
**Owner:** Legal & Security
**Review Cycle:** Setiap release
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)
**Status Dokumen:** Final
**Status Implementasi:** Belum Dimulai

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Data yang Dikumpulkan
3. Dasar Pengolahan Data (UU PDP)
4. Tujuan Penggunaan Data
5. Retensi Data & S3 Lifecycle 90 Hari
6. Hak Subjek Data
7. Keamanan Data
8. Pihak Ketiga
9. Consent & ToS
10. Kontak DPO
11. Ringkasan untuk Warga RT

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Selamat Datang di Grosirun

Grosirun adalah aplikasi patungan belanja sembako berbasis RT/RW yang membantu warga mendapatkan harga grosir lebih murah. Kebijakan privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Bapak/Ibu sesuai dengan **Undang-Undang Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP)**.

### 1.2 Konteks Bisnis (Referensi [BUSINESS_ANALYSIS.md](BUSINESS_ANALYSIS.md))

| Komponen              | Nilai               |
| --------------------- | ------------------- |
| Platform Fee          | 1% GMV + PPN 11%    |
| GMV per PO AT_70      | Rp8.400.000         |
| Laba Initiator per PO | Rp956.760           |
| Target Adopsi         | 70% (35 dari 50 KK) |

**Prinsip Privasi Kami:**

1. **Transparan** - Kami jelaskan data apa yang dikumpulkan dan untuk apa
2. **Minimal** - Kami hanya kumpulkan data yang benar-benar diperlukan
3. **Aman** - Data dilindungi dengan enkripsi dan akses terbatas
4. **Hak Anda** - Anda bisa akses, koreksi, atau hapus data kapan saja
5. **Tidak Dijual** - Data Bapak/Ibu tidak pernah dijual kepada pihak ketiga

---

## 2. Data yang Dikumpulkan

### 2.1 Data Identitas

| Data              | Keterangan                                       | Wajib?   |
| ----------------- | ------------------------------------------------ | -------- |
| **Nama lengkap**  | Diisi sendiri oleh pengguna                      | ✅ Wajib |
| **Nomor HP (WA)** | Format E.164 (628xxx), digunakan untuk login OTP | ✅ Wajib |
| **Cluster ID**    | RT tempat tinggal (contoh: PGH-RT03)             | ✅ Wajib |
| **Role**          | Buyer, Initiator, Seller, atau Admin; satu user dapat memiliki lebih dari satu role | ✅ Wajib |

### 2.2 Data Teknis

| Data              | Keterangan                                | Wajib?      |
| ----------------- | ----------------------------------------- | ----------- |
| **FCM Token**     | Token untuk push notification (Firebase)  | ❌ Opsional |
| **Sanctum Token** | Token autentikasi (hash)                  | ✅ Wajib    |
| **IP Address**    | Dicatat di `transaction_logs` untuk audit | ✅ Wajib    |
| **User Agent**    | Browser/device info (tidak disimpan)      | ❌ Tidak    |

### 2.3 Data Transaksi

| Data                 | Keterangan                                                                        | Wajib?             |
| -------------------- | --------------------------------------------------------------------------------- | ------------------ |
| **Orders**           | Pesanan: variant, quantity, total_quantity, total_price, payment_method, payment_status | ✅ Wajib           |
| **Proof Path**       | Path S3 bukti QRIS (gambar)                                                       | ❌ Hanya jika QRIS |
| **is_taken**         | Status pengambilan barang                                                         | ✅ Wajib           |
| **Taken_at**         | Waktu pengambilan                                                                 | ✅ Wajib           |
| **Transaction Logs** | Audit trail: validasi, reject, override, dll                                      | ✅ Wajib           |

### 2.4 Data Notifikasi

| Data          | Keterangan                                    | Wajib?   |
| ------------- | --------------------------------------------- | -------- |
| **Title**     | Judul notifikasi                              | ✅ Wajib |
| **Body**      | Isi notifikasi                                | ✅ Wajib |
| **Data JSON** | Data tambahan (type, campaign_id, order_uuid) | ✅ Wajib |
| **read_at**   | Waktu notifikasi dibaca                       | ✅ Wajib |

### 2.5 Data yang TIDAK Dikumpulkan

| Data                | Alasan                                         |
| ------------------- | ---------------------------------------------- |
| **KTP**             | Tidak diperlukan                               |
| **Rekening bank**   | Dana langsung ke Initiator, bukan via aplikasi |
| **Password**        | Passwordless OTP                               |
| **Lokasi GPS**      | Tidak diperlukan                               |
| **Email**           | Tidak diperlukan                               |
| **Keluarga/Relasi** | Tidak diperlukan                               |

---

### 2.6 Data Penjual dan Pemisahan Data Pembeli

Untuk akun seller, Grosirun memproses nama, nomor kontak bisnis, supplier membership, identitas usaha, NPWP jika diwajibkan, alamat, area layanan, produk, penawaran, invoice, dan surat jalan. Data verifikasi hanya dapat diakses Admin aplikasi yang berwenang.

Seller tidak memperoleh nama, nomor HP, bukti pembayaran, atau riwayat transaksi individual Pembeli. Data yang diberikan untuk fulfillment dibatasi pada total agregat per item, alamat dan kontak bisnis Inisiator, serta nomor purchase order. Dasar pengolahan data seller adalah pelaksanaan perjanjian kemitraan supplier dan kewajiban hukum yang berlaku.

---

## 3. Dasar Pengolahan Data (UU PDP)

Berdasarkan **UU PDP No.27/2022**, pengolahan data pribadi harus memiliki dasar hukum yang jelas. Grosirun menggunakan 3 dasar pengolahan:

### 3.1 Persetujuan (Consent) - Pasal 20 UU PDP

Bapak/Ibu memberikan persetujuan secara eksplisit dengan:

1. **Centang checkbox** "Saya setuju data WA disimpan untuk PO RT sesuai UU PDP No.27/2022" saat login pertama.
2. **Tanda tangan digital** saat menyetujui Syarat Layanan Non-Escrow.

**Data yang diproses dengan consent:**

- Nama, nomor HP, cluster_id, roles, active_role
- Orders dan transaksi
- Notifikasi

**Consent dicatat di database:**

- `users.consent_at` = waktu consent
- `users.consent_version` = versi kebijakan privasi (v1.0)

### 3.2 Kewajiban Kontrak - Pasal 21 UU PDP

Untuk menjalankan PO patungan RT (buyer ↔ initiator), diperlukan data WA dan nama untuk:

- Rekap pembayaran
- Distribusi barang
- Komunikasi antar warga

**Data yang diproses untuk kontrak:**

- Nama, nomor HP, orders, payment_status, is_taken

### 3.3 Kepentingan Sah - Pasal 22 UU PDP

Audit log untuk:

- Mencegah sengketa (dispute)
- Backup dan monitoring
- Keamanan sistem

**Data yang diproses untuk kepentingan sah:**

- Transaction_logs, IP address, timestamps

---

## 4. Tujuan Penggunaan Data

### 4.1 Tabel Tujuan Penggunaan

| Tujuan                          | Data yang Digunakan          | Dasar Hukum       |
| ------------------------------- | ---------------------------- | ----------------- |
| **Login OTP**                   | Nomor HP                     | Consent + Kontrak |
| **Buat & Rekap PO**             | Nama, nomor HP, orders       | Kontrak           |
| **Validasi Pembayaran**         | Nama, orders, proof_path     | Kontrak           |
| **Checklist Distribusi**        | Nama, is_taken, taken_at     | Kontrak           |
| **Notifikasi (FCM + Fallback)** | FCM token, title, body, data | Consent           |
| **Audit & Sengketa**            | transaction_logs, IP address | Kepentingan sah   |
| **Analytics (anonymized)**      | cluster_id, event            | Kepentingan sah   |

### 4.2 Data TIDAK Digunakan Untuk

| Tujuan                     | Keterangan                                   |
| -------------------------- | -------------------------------------------- |
| **Dijual ke pihak ketiga** | Tidak pernah                                 |
| **Iklan/Remarketing**      | Tidak pernah                                 |
| **Profiling perilaku**     | Tidak pernah                                 |
| **Dibagikan ke supplier**  | Hanya rekap anonim (total Kg, total revenue) |

---

## 5. Retensi Data & S3 Lifecycle 90 Hari

### 5.1 Tabel Retensi Data

| Data                       | Masa Retensi                       | Tindakan Setelah                                 | Job                                |
| -------------------------- | ---------------------------------- | ------------------------------------------------ | ---------------------------------- |
| **users (PII)**            | Forever sampai DELETE account      | Anonimisasi <24 jam                              | `AnonymizeUserJob`                 |
| **otp_codes**              | 1 jam setelah expiry               | Hapus                                            | `CleanExpiredOtpsJob` (hourly)     |
| **campaigns**              | Forever                            | Simpan                                           | -                                  |
| **campaign_variants**      | Forever                            | Simpan                                           | -                                  |
| **orders**                 | Forever (anonim jika user dihapus) | `user_id` → null, `deleted_user_name` → snapshot | `AnonymizeUserJob`                 |
| **proof S3**               | 90 hari setelah campaign selesai   | Hapus S3 + clear DB                              | S3 lifecycle + `CleanOldProofsJob` |
| **transaction_logs**       | Forever                            | Simpan                                           | -                                  |
| **notifications**          | 30 hari                            | Hapus                                            | `CleanOldNotificationsJob` (daily) |
| **personal_access_tokens** | 30 hari                            | Revoke pada logout/delete                        | Sanctum expiry                     |

### 5.2 S3 Lifecycle Rule (90 Hari)

**File:** Bukti QRIS di `order_proofs/{uuid}.jpg`

```json
{
  "Rules": [
    {
      "ID": "delete-old-proofs-90d",
      "Filter": {
        "Prefix": "order_proofs/"
      },
      "Status": "Enabled",
      "Expiration": {
        "Days": 90
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 7
      }
    }
  ]
}
```

**Double Safety:**

1. **S3 Lifecycle Rule** (otomatis dari AWS)
2. **CleanOldProofsJob** (Laravel scheduler daily)

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

### 5.3 Backup Database

| Komponen     | Frekuensi       | Retention | Lokasi        | Enkripsi |
| ------------ | --------------- | --------- | ------------- | -------- |
| **Database** | Daily 02:00 WIB | 7 hari    | S3 `backups/` | SSE-S3   |
| **S3 Files** | Versioning ON   | Forever   | S3 bucket     | SSE-S3   |

---

## 6. Hak Subjek Data

Berdasarkan **UU PDP Pasal 26-31**, Bapak/Ibu memiliki hak atas data pribadi:

### 6.1 Hak Akses (Pasal 26)

Bapak/Ibu berhak mengetahui data apa saja yang kami simpan.

**Cara:**

1. Buka aplikasi → Profil → Lihat Data Saya
2. Atau request ke DPO: `privacy@grosirun.id`

**Data yang ditampilkan:**

- Nama, nomor HP, cluster, roles, active_role
- Riwayat orders (5 terakhir)
- Riwayat notifikasi

### 6.2 Hak Koreksi (Pasal 27)

Bapak/Ibu berhak memperbaiki data yang tidak akurat.

**Cara:**

1. Buka aplikasi → Profil → Edit Profil
2. Ubah nama (nomor HP tidak bisa diubah untuk keamanan)

### 6.3 Hak Hapus (Right to be Forgotten - Pasal 28)

Bapak/Ibu berhak meminta penghapusan data pribadi.

**Cara:**

1. Buka aplikasi → Profil → Hapus Akun
2. Konfirmasi dengan checkbox "Saya yakin ingin menghapus akun"
3. Masukkan alasan (opsional)
4. Klik "Hapus Akun"

**Flow Deletion (SLA <24 jam):**

```
User tap "Hapus Akun"
    │
    ▼
API DELETE /auth/account → 202 Accepted
    │
    ▼
Job: AnonymizeUserJob (async)
    ├── users: name → 'Deleted User {id}', phone → 'DELETED_{id}', fcm_token → null
    ├── personal_access_tokens: delete all
    ├── S3: delete semua proof images milik user
    ├── orders: user_id → null, deleted_user_name → 'Deleted User {id}'
    └── transaction_logs: keep (audit), initiator_id tetap
    │
    ▼
✅ Data dianonimkan dalam <24 jam
```

**Yang TETAP tersimpan setelah anonimisasi:**

- Orders (total Kg, total price, payment_status) - untuk audit
- Transaction_logs - untuk audit sengketa
- Campaign contributions - untuk rekap

**Yang DIHAPUS setelah anonimisasi:**

- Nama asli → `Deleted User {id}`
- Nomor HP → `DELETED_{id}`
- FCM Token → null
- S3 Proof Images → dihapus permanent
- Token autentikasi → revoked

### 6.4 Hak Tarik Consent (Pasal 29)

Bapak/Ibu dapat menarik persetujuan kapan saja.

**Cara:**

1. Hapus akun (lihat 6.3)
2. Atau email ke DPO: `privacy@grosirun.id`

**Konsekuensi:** Tidak bisa menggunakan aplikasi.

### 6.5 Hak Lapor (Pasal 31)

Jika Bapak/Ibu merasa data disalahgunakan, bisa melapor ke:

1. **DPO Grosirun:** `privacy@grosirun.id`
2. **Kementerian Kominfo:** `https://pse.kominfo.go.id`

---

## 7. Keamanan Data

### 7.1 Keamanan Fisik & Infrastruktur

| Aspek          | Implementasi                                                             |
| -------------- | ------------------------------------------------------------------------ |
| **S3 Bucket**  | Private Block Public Access ON, versioning ON, SSE-S3 encryption at rest |
| **S3 TempUrl** | 1 jam expiry, hanya authorized user (Policy check owner/initiator)       |
| **HTTPS**      | TLS 1.2+ dengan Let's Encrypt, SSL expiry monitoring <7 hari             |
| **Database**   | MySQL 8 dengan enkripsi transparan (opsional)                            |
| **Backup**     | S3 encrypted, retention 7 hari, restore drill RTO 1h RPO 24h             |

### 7.2 Keamanan Aplikasi

| Aspek                | Implementasi                                                          |
| -------------------- | --------------------------------------------------------------------- |
| **Token**            | Sanctum, disimpan di `flutter_secure_storage` (bukan Hive)            |
| **OTP**              | Hash bcrypt, expiry 5 menit, rate limit 5/menit + lock 15 menit       |
| **Rate Limit**       | Redis: global 60/min user + 100/min per IP, OTP 5/min, override 10/min                      |
| **RBAC**             | Role buyer/initiator/seller/admin, Policy check cluster_id                   |
| **Input Validation** | FormRequest, $fillable strict, no SQL injection                       |
| **Upload Security**  | Mime check, random UUID filename, Intervention compress, max 2MB      |
| **Audit Log**        | `transaction_logs` semua aksi sensitif (validation, reject, override) |

### 7.3 Logging & Masking

**Data yang TIDAK boleh muncul di log:**

- OTP plain (hanya di dev `storage/logs/otp.log`)
- Password (tidak ada)
- Nomor HP full (masked: `62812****`)

**Contoh Log yang Aman:**

```php
// ✅ Benar
Log::info('OTP sent', [
    'phone_masked' => substr($phone, 0, 4) . '****',
    'cluster_code' => $clusterCode,
]);

// ❌ Salah - OTP plain
Log::info('OTP sent', ['phone' => $phone, 'otp' => $otp]);
```

### 7.4 Secrets Management

| Secret                 | Lokasi                  | Rotasi                     |
| ---------------------- | ----------------------- | -------------------------- |
| `.env.prod`            | VPS + 1Password Vault   | Manual                     |
| `APP_KEY`              | .env.prod               | `php artisan key:generate` |
| `AWS_*`                | .env.prod               | IAM key rotation           |
| `SENTRY_DSN`           | dart-define (Flutter)   | Manual                     |
| `FIREBASE_CREDENTIALS` | `storage/app/firebase/` | Service Account rotation   |

---

## 8. Pihak Ketiga

### 8.1 Daftar Pihak Ketiga

| Pihak Ketiga            | Data yang Dikirim               | Tujuan            | Lokasi Data                 |
| ----------------------- | ------------------------------- | ----------------- | --------------------------- |
| **Fonnte (WA Gateway)** | Nomor HP + OTP plain            | Kirim OTP via WA  | Indonesia (server Fonnte)   |
| **Firebase FCM**        | FCM token + title + body + data | Push notification | Google Cloud (multi-region) |
| **S3 (AWS/IDCloud)**    | Proof images, campaign images   | Penyimpanan file  | Singapore (ap-southeast-1)  |
| **Sentry**              | Error stack trace (no PII)      | Error tracking    | Sentry cloud                |

### 8.2 Data Sharing Policy

| Penerima                      | Data                                  | Tujuan         | Status                 |
| ----------------------------- | ------------------------------------- | -------------- | ---------------------- |
| **Supplier (CV Makmur Jaya)** | Rekap anonim: total Kg, total revenue | Pesanan barang | ✅ Hanya rekap agregat |
| **Ketua RW**                  | Audit logs (jika sengketa)            | Mediasi        | ✅ Hanya jika sengketa |
| **Pihak ketiga lainnya**      | -                                     | -              | ❌ Tidak pernah        |

**Supplier tidak pernah menerima:**

- Nama buyer
- Nomor HP buyer
- Detail transaksi per buyer

### 8.3 Firebase FCM Privacy

Firebase Cloud Messaging adalah layanan dari Google. Data yang dikirim:

- `fcm_token` (token perangkat)
- `title`, `body`, `data` (isi notifikasi)

**Firebase Privacy Policy:** https://firebase.google.com/support/privacy

---

## 9. Consent & ToS

### 9.1 Alur Consent

```
User Login OTP
    │
    ▼
[Layar Consent UU PDP]
    "Saya setuju data WA disimpan untuk PO RT sesuai UU PDP No.27/2022"
    Link: Kebijakan Privasi (scroll)
    ☐ Saya setuju
    [Tombol: Verifikasi] ← disabled jika tidak centang
    │
    ▼
[Layar ToS Non-Escrow]
    Scroll ToS: "Grosirun hanya catat status, dana langsung ke Initiator..."
    ☐ Saya mengerti dan setuju
    [Tombol: Setuju Lanjut] ← disabled jika tidak centang
    │
    ▼
✅ Login berhasil, consent_at dan tos_accepted_at tercatat
```

### 9.2 API Consent

**POST /auth/consent:**

```json
{
  "consent": true,
  "consent_version": "v1.0"
}
```

**POST /auth/tos-accept:**

```json
{
  "tos": true,
  "tos_version": "v1.0"
}
```

### 9.3 Versi & Update

| Versi | Tanggal      | Perubahan           | Action                |
| ----- | ------------ | ------------------- | --------------------- |
| v1.0  | 20 Juli 2026 | Initial             | -                     |
| v1.1  | Future       | Perubahan kebijakan | User harus re-consent |

Jika kebijakan privasi berubah ke v1.1:

1. User login → popup "Kebijakan Privasi telah diperbarui"
2. Wajib centang consent baru
3. `users.consent_version` = v1.1

---

## 10. Kontak DPO (Data Protection Officer)

### 10.1 Informasi Kontak

| Detail             | Informasi                                            |
| ------------------ | ---------------------------------------------------- |
| **Email DPO**      | `privacy@grosirun.id`                                |
| **Email Keamanan** | `security@grosirun.id`                               |
| **Alamat Fisik**   | Cluster Permata Hijau RT03, Ngoro, Mojokerto (Pilot) |
| **Waktu Respons**  | 2×24 jam (2 hari kerja)                              |
| **Bahasa**         | Bahasa Indonesia                                     |

### 10.2 Cara Menghubungi DPO

1. **Email** ke `privacy@grosirun.id` dengan subjek:

   - "Hak Akses Data" - untuk minta data
   - "Hapus Data" - untuk minta hapus akun
   - "Laporan Pelanggaran" - untuk melapor

2. **Sertakan:**

   - Nama lengkap
   - Nomor HP (untuk verifikasi)
   - Deskripsi permintaan

3. **DPO akan:**
   - Merespons dalam 2×24 jam
   - Memverifikasi identitas via OTP
   - Memproses permintaan dalam 7 hari

### 10.3 Hak Lapor ke Kominfo

Jika tidak puas dengan respons DPO, Bapak/Ibu dapat melapor ke:

**Kementerian Komunikasi dan Informatika (Kominfo)**

- Website: https://pse.kominfo.go.id
- Email: pengaduan@kominfo.go.id
- Hotline: 159

---

## 11. Ringkasan untuk Warga RT

### 11.1 Bahasa Sederhana

| Pertanyaan                             | Jawaban                                                                    |
| -------------------------------------- | -------------------------------------------------------------------------- |
| **Data apa yang dikumpulkan?**         | Nama, nomor WA, cluster RT, dan riwayat pesanan.                           |
| **Untuk apa?**                         | Untuk urusan patungan: rekap, validasi pembayaran, dan distribusi barang.  |
| **Apakah data dijual?**                | **Tidak pernah.**                                                          |
| **Berapa lama disimpan?**              | Selama akun aktif. Bukti QRIS dihapus setelah 90 hari.                     |
| **Bagaimana hapus data?**              | Buka Profil → Hapus Akun. Data akan dihapus dalam <24 jam.                 |
| **Siapa yang bisa melihat data saya?** | Hanya Anda, Ketua RT (Initiator), dan tim Grosirun untuk keperluan teknis. |
| **Aman kah?**                          | Data dienkripsi, server aman, dan akses dibatasi.                          |

### 11.2 Poin Penting

1. ✅ **Centang consent** saat pertama kali login - ini bukti Bapak/Ibu setuju.
2. ✅ **Data hanya untuk PO RT** - tidak pernah dijual.
3. ✅ **Bukti QRIS otomatis dihapus** setelah 90 hari.
4. ✅ **Bisa hapus akun** kapan saja via menu Profil.
5. ✅ **Hubungi DPO** jika ada pertanyaan atau masalah.

---
