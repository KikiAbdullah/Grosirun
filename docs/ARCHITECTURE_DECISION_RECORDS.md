# ARSITEKTUR DECISION RECORDS (ADR) - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Tujuan:** Mendokumentasikan keputusan arsitektur penting agar pengembang baru dapat memahami mengapa memilih Laravel daripada Node, Cubit daripada Riverpod, dan keputusan strategis lainnya tanpa harus bertanya kepada tech lead.
**Owner:** Architecture & Engineering
**Review Cycle:** Setiap release
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)
**Status Dokumen:** Final
**Status Implementasi:** Belum Dimulai

---

## Daftar Isi

- ADR-001: Laravel 11 vs Node.js/NestJS vs Golang
- ADR-002: MySQL 8 vs PostgreSQL 15
- ADR-003: S3 Primary vs Local Storage
- ADR-004: Cubit vs Riverpod vs Bloc vs Provider
- ADR-005: Hive + SQLite vs Drift vs Isar
- ADR-006: Sanctum vs JWT vs Passport
- ADR-007: Dio vs http
- ADR-008: Penawaran Supplier, Campaign Inisiator, dan Multi-Role
- Template ADR Baru

---


## Decision Index

| ADR | Keputusan | Status | Changelog |
| --- | --- | --- | --- |
| [ADR-001](#adr-001-laravel-11-vs-nodejsnestjs-vs-golang) | Laravel 11 untuk backend | Accepted | [Decision Log](CHANGELOG.md#decision-log) |
| [ADR-002](#adr-002-mysql-8-vs-postgresql-15) | MySQL 8 sebagai primary database | Accepted | [Decision Log](CHANGELOG.md#decision-log) |
| [ADR-003](#adr-003-s3-primary-vs-local-storage) | S3 private sebagai storage produksi | Accepted | [Decision Log](CHANGELOG.md#decision-log) |
| [ADR-004](#adr-004-cubit-vs-riverpod-vs-bloc-vs-provider) | Cubit untuk state management | Accepted | [Decision Log](CHANGELOG.md#decision-log) |
| [ADR-005](#adr-005-hive--sqlite-vs-drift-vs-isar) | Hive dan SQLite untuk local/offline data | Accepted | [Decision Log](CHANGELOG.md#decision-log) |
| [ADR-006](#adr-006-sanctum-vs-jwt-vs-passport) | Sanctum untuk API token | Accepted | [Decision Log](CHANGELOG.md#decision-log) |
| [ADR-007](#adr-007-dio-vs-http-package) | Dio untuk HTTP client | Accepted | [Decision Log](CHANGELOG.md#decision-log) |
| [ADR-008](#adr-008-penawaran-supplier-campaign-inisiator-dan-multi-role) | Penawaran Supplier, campaign Inisiator, dan multi-role | Accepted | [Decision Log](CHANGELOG.md#decision-log) |

Perubahan keputusan accepted wajib memperbarui ADR, Decision Log di Changelog, traceability matrix, dan dokumen source of truth pada PR yang sama.

---

## ADR-001: Laravel 11 vs Node.js/NestJS vs Golang

**Konteks**

Proyek Grosirun membutuhkan API REST yang cepat dan stabil untuk menangani proses checkout dengan transaksi ACID (Atomicity, Consistency, Isolation, Durability) serta fitur antrian (queue) untuk pengiriman notifikasi. Tim pengembang saat ini didominasi oleh talenta PHP yang sudah berpengalaman dengan ekosistem Laravel. Infrastruktur pengembangan dan produksi harus hemat biaya namun tetap andal untuk menangani lonjakan permintaan (thundering herd) hingga 100 pengguna bersamaan.

**Alternatif yang Dipertimbangkan**

| Alternatif                 | Kelebihan                                               | Kekurangan                                                                                                                  |
| -------------------------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **NestJS + Node.js**       | Performa baik, TypeScript, ekosistem modern             | Tim tidak familiar, ORM TypeORM kurang matang untuk `SELECT ... FOR UPDATE`, biaya hosting Node.js di Indonesia lebih mahal |
| **Golang + Fiber/GORM**    | Performa sangat tinggi, konkurensi bawaan               | Kurva pembelajaran tinggi, kecepatan pengembangan lambat, talenta Golang di Indonesia masih terbatas                        |
| **Firebase Functions**     | Serverless, skala otomatis                              | Vendor lock-in, biaya tidak terduga untuk 500 pengguna, kontrol terbatas atas database                                      |
| **Laravel 11 (Keputusan)** | Ekosistem matang, talenta melimpah, harga hosting murah | Perlu tuning OPcache dan FPM untuk performa optimal                                                                         |

**Keputusan**

Menggunakan **Laravel 11 dengan PHP 8.3** sebagai backend utama.

**Alasan**

1. **Ekosistem dan Talenta**: Ekosistem Laravel sangat besar di Indonesia. Hosting murah (IDCloudHost, Niagahoster) mendukung PHP secara native. Talenta PHP lebih mudah ditemukan dibandingkan Golang atau Node.js untuk skala UMKM.

2. **Fitur Enterprise Siap Pakai**:

   - **Eloquent ORM**: `lockForUpdate()` untuk pessimistic locking sudah matang dan teruji.
   - **Database Transaction**: `DB::transaction()` memastikan atomicity pada proses checkout dan validasi.
   - **Horizon**: Dashboard antrian Redis yang powerful untuk menangani notifikasi FCM.
   - **Pennant**: Feature flags yang memungkinkan toggle fitur tanpa deploy ulang.
   - **Pulse**: Observability untuk memonitor query lambat dan performa API.
   - **Scribe**: Generate dokumentasi OpenAPI secara otomatis.

3. **Kecepatan Pengembangan**: Dengan artisan, factory, seeder, dan testing bawaan (Pest/ PHPUnit), siklus pengembangan fitur baru menjadi lebih cepat.

**Konsekuensi**

- Perlu melakukan tuning OPcache (`opcache.validate_timestamps=0` di produksi) dan PHP-FPM (`pm.max_children=30`) untuk menangani beban 100 concurrent.
- Deployment menggunakan Docker dengan PHP-FPM dan Nginx untuk konsistensi environment.
- Pembaruan dependency harus dilakukan secara berkala untuk menjaga keamanan.

**Status:** Accepted

---

## ADR-002: MySQL 8 vs PostgreSQL 15

**Konteks**

Aplikasi membutuhkan sistem basis data relasional yang mendukung transaksi ACID, pessimistic locking (`SELECT ... FOR UPDATE`) untuk mencegah oversell pada kuota varian, serta kemampuan partisi tabel (partitioning) di masa depan untuk tabel `orders` yang akan tumbuh besar. Tim pengembang lebih familiar dengan MySQL dan ekosistem pendukungnya.

**Alternatif yang Dipertimbangkan**

| Alternatif                       | Kelebihan                                            | Kekurangan                                                                           |
| -------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------ |
| **PostgreSQL 15**                | JSONB lebih baik, partisi lebih canggih, MVCC handal | Talent lebih jarang, hosting managed lebih mahal, kurva belajar untuk fitur advanced |
| **SQLite**                       | Ringan, tanpa instalasi                              | Tidak mendukung concurrent write tinggi (100 VU), lock database file                 |
| **MySQL 8.0 InnoDB (Keputusan)** | Familiar, harga hosting murah, `FOR UPDATE` matang   | Partisi membutuhkan perhatian khusus pada primary key                                |

**Keputusan**

Menggunakan **MySQL 8.0 dengan storage engine InnoDB**.

**Alasan**

1. **Kemudahan dan Familiaritas**: Mayoritas VPS di Indonesia menyediakan MySQL sebagai default. phpMyAdmin/Adminer memudahkan debugging data.
2. **Pessimistic Locking Teruji**: `SELECT ... FOR UPDATE` pada InnoDB sudah teruji dengan beban 100 VU (k6) tanpa menghasilkan oversell.
3. **Biaya**: Managed MySQL dari IDCloudHost sekitar Rp150.000/bulan, lebih murah daripada PostgreSQL yang sekitar Rp250.000/bulan.
4. **Dukungan Partisi**: MySQL 8 mendukung `PARTITION BY RANGE (YEAR(created_at))` untuk V2, cukup untuk kebutuhan hingga 1 juta order.
5. **Read Replica**: Mendukung konfigurasi `mysql_read` untuk memisahkan query berat (recap) dari database utama.

**Konsekuensi**

- Perlu merancang indeks strategis secara manual (`(cluster_id, status, deadline)`, `(campaign_id, payment_status)`, dll).
- Penggunaan `EXPLAIN` wajib dilakukan untuk setiap query baru yang kompleks.
- Partisi V2 memerlukan migrasi yang direncanakan dengan baik (expand-contract pattern).

**Status:** Accepted

---

## ADR-003: S3 Primary vs Local Storage

**Konteks**

Terdapat inkonsistensi dalam dokumentasi lama: PRD dan DEPLOYMENT menyebutkan S3 sebagai backup, sedangkan TECHNICAL_SPEC dan API_SPEC menyebutkan penyimpanan lokal sebagai primary. VPS dengan kapasitas 4GB akan cepat penuh jika 500 pengguna mengupload bukti 2MB × 200 order × 10 campaign = 4GB. Selain itu, penyimpanan lokal tidak memiliki mekanisme lifecycle otomatis untuk menghapus bukti setelah 90 hari (sesuai UU PDP).

**Alternatif yang Dipertimbangkan**

| Alternatif                               | Kelebihan                                                                     | Kekurangan                                                   |
| ---------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **Local Storage (`storage/app/public`)** | Sederhana, tanpa biaya tambahan                                               | VPS cepat penuh, tidak ada lifecycle otomatis, backup manual |
| **S3 Private Bucket (Keputusan)**        | Skalabilitas tak terbatas, lifecycle 90 hari otomatis, keamanan tempUrl 1 jam | Perlu konfigurasi IAM dan SDK tambahan                       |
| **CloudFlare R2 / IDCloud S3**           | Kompatibel S3, biaya lebih murah                                              | Ekosistem belum seluas AWS S3                                |

**Keputusan**

Menggunakan **S3 Primary** untuk produksi, dan Local Storage hanya untuk pengembangan (development).

**Alasan**

1. **Skalabilitas**: Tidak perlu khawatir disk VPS penuh. Penyimpanan S3 dapat bertambah sesuai kebutuhan (scalable).
2. **Lifecycle Otomatis (UU PDP)**: S3 Lifecycle Rule dapat menghapus file di folder `order_proofs/` setelah 90 hari secara otomatis, ditambah dengan `CleanOldProofsJob` sebagai lapisan keamanan kedua.
3. **Keamanan**: Bucket di-private (Block Public Access ON). Akses file menggunakan `temporaryUrl()` yang hanya berlaku 1 jam dan dilindungi oleh Policy (hanya pemilik order atau initiator campaign).
4. **Biaya**: Biaya S3 IDCloud sekitar Rp20.000 per 100GB, sangat murah dibandingkan risiko kehilangan data atau biaya upgrade VPS.

**Konsekuensi**

- Menambahkan package `league/flysystem-aws-s3-v3` ke dalam proyek.
- Menggunakan MinIO di environment development untuk mensimulasikan S3 secara lokal.
- Semua environment variable AWS harus diatur di `.env.prod` (tidak boleh di-commit ke repository).
- S3 Versioning diaktifkan, tetapi penghapusan bukti karena lifecycle adalah operasi yang disengaja (tidak dibackup).

**Status:** Accepted

---

## ADR-004: Cubit vs Riverpod vs Bloc vs Provider

**Konteks**

Aplikasi Flutter harus ringan (target APK <10MB), mendukung offline-first dengan Hive, melakukan polling setiap 15 detik untuk pembaruan campaign, dan memiliki struktur state management yang mudah dipahami oleh tim. Tim sudah memiliki pengalaman dengan pola Bloc/Cubit.

**Alternatif yang Dipertimbangkan**

| Alternatif               | Kelebihan                                              | Kekurangan                                                                                                          |
| ------------------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| **Provider**             | Sederhana, ringan                                      | Tidak memiliki event/state separation, rebuild berlebihan pada widget tree, sulit untuk flow checkout yang kompleks |
| **Riverpod**             | Modern, compile-safe dengan code generation            | Membutuhkan build_runner, menambah ukuran APK ~0.5MB, kurva pembelajaran tinggi                                     |
| **Bloc (Event + State)** | Struktur sangat jelas, cocok untuk kompleksitas tinggi | Terlalu banyak boilerplate untuk V1.0 (event class untuk setiap aksi)                                               |
| **Cubit (Keputusan)**    | Ringan, tanpa event class, langsung panggil fungsi     | Kurang cocok untuk real-time streaming (tidak dibutuhkan)                                                           |

**Keputusan**

Menggunakan **Cubit** dari package `flutter_bloc ^8.1.6`.

**Alasan**

1. **Ringan**: Tidak memerlukan code generation seperti Riverpod, sehingga menjaga ukuran APK tetap kecil.
2. **Boilerplate Minimal**: Cukup dengan `emit(state)` langsung di dalam fungsi, tidak perlu membuat class event terpisah.
3. **Familiaritas**: Tim sudah terbiasa dengan pola Bloc/Cubit, sehingga mempercepat onboarding.
4. **Testability**: `bloc_test` sangat mudah digunakan untuk menguji state loading, success, dan error.
5. **Kecukupan**: Aplikasi ini menggunakan offline-first repository dan polling, bukan real-time stream yang membutuhkan power dari Riverpod.

**Konsekuensi**

- Setiap state harus meng-extend `Equatable` untuk mencegah rebuild yang tidak perlu.
- Perlu menambahkan `BlocObserver` untuk mengirim log error ke Sentry.
- Jika kompleksitas meningkat di V2 (misalnya real-time chat), migrasi ke Riverpod masih memungkinkan tetapi tidak direncanakan untuk V1.0.

**Status:** Accepted

---

## ADR-005: Hive + SQLite vs Drift vs Isar

**Konteks**

Aplikasi membutuhkan penyimpanan lokal (offline-first) untuk caching daftar campaign, order, antrian pending (create_order dan upload_proof), notifikasi, state aplikasi (appState), serta penyimpanan ETag dan Idempotency-Key. Data ini bersifat key-value, tidak memerlukan relasi SQL yang kompleks.

**Alternatif yang Dipertimbangkan**

| Alternatif            | Kelebihan                                             | Kekurangan                                                                  |
| --------------------- | ----------------------------------------------------- | --------------------------------------------------------------------------- |
| **SharedPreferences** | Sangat ringan, bawaan Flutter                         | Tidak cocok untuk menyimpan daftar campaign yang besar (slow, blocking)     |
| **Drift (moor)**      | SQLite dengan type-safety, relasi kuat                | Membutuhkan code generation, menambah APK ~0.8MB, overkill untuk key-value  |
| **Isar**              | Cepat, NoSQL, mendukung indeks                        | Kurang stabil dibandingkan Hive? Ekosistem lebih baru, dokumentasi terbatas |
| **Hive (Keputusan)**  | Sangat ringan (<200KB), cepat (<50ms), tanpa code gen | Tidak mendukung query relasi (tidak dibutuhkan)                             |

**Keputusan**

Menggunakan **Hive** sebagai penyimpanan lokal utama (NoSQL key-value) tanpa menggunakan `hive_generator` untuk menghindari code generation. Data disimpan sebagai JSON string.

**Alasan**

1. **Ukuran Kecil**: <200KB, sangat penting untuk menjaga APK tetap di bawah 10MB.
2. **Kecepatan**: Operasi baca/tulis sangat cepat (<50ms) bahkan untuk 100+ item.
3. **Tanpa Code Generation**: Menghindari kompleksitas build_runner dan menjaga kecepatan compile.
4. **Persistensi**: Data bertahan meskipun aplikasi dimatikan (killed) - sangat krusial untuk state persistence.
5. **Struktur Box yang Jelas**:
   - `campaignsBox`: Cache daftar campaign
   - `ordersBox`: Cache daftar order
   - `pendingQueueBox`: Antrian offline (create_order & upload_proof)
   - `notificationsBox`: Cache notifikasi fallback
   - `appStateBox`: Menyimpan lastRoute, lastCampaignId, pendingDeepLink
   - `etagBox`: Menyimpan ETag untuk conditional GET
   - `idempotencyBox`: Menyimpan mapping Idempotency-Key

**Konsekuensi**

- Data disimpan sebagai JSON string, bukan model terenkripsi. Untuk keamanan, token disimpan di `flutter_secure_storage`, bukan di Hive.
- Jika struktur data berubah, perlu melakukan migrasi manual atau clear box saat update versi major.

**Status:** Accepted

---

## ADR-006: Sanctum vs JWT vs Passport

**Konteks**

Aplikasi mobile Flutter membutuhkan autentikasi token yang sederhana, memiliki masa berlaku (expiry), dapat dicabut (revokable) saat logout atau hapus akun, dan tidak memerlukan kompleksitas OAuth2 (karena hanya first-party client).

**Alternatif yang Dipertimbangkan**

| Alternatif                      | Kelebihan                                   | Kekurangan                                                                                            |
| ------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| **JWT (`tymon/jwt-auth`)**      | Stateless, scaling mudah                    | Revocation sulit (butuh blacklist Redis), refresh token kompleks, tidak ada built-in logout sederhana |
| **Laravel Passport**            | OAuth2 standar, mendukung multiple client   | Overkill untuk satu client mobile, tabel sangat banyak, biaya resource tinggi                         |
| **Firebase Auth**               | Managed, integrasi dengan FCM               | Vendor lock-in, biaya untuk autentikasi (tergantung usage)                                            |
| **Laravel Sanctum (Keputusan)** | Sederhana, personal access token, revokable | Memerlukan tabel `personal_access_tokens`                                                             |

**Keputusan**

Menggunakan **Laravel Sanctum 4.0** dengan Personal Access Token.

**Alasan**

1. **Kesederhanaan**: Cukup dengan `$user->createToken('mobile', ['*'], now()->addDays(30))->plainTextToken`.
2. **Revokasi Mudah**: Token di-hash dan disimpan di database. Saat logout: `$user->currentAccessToken()->delete()`. Saat hapus akun: semua token di-revoke.
3. **Tanpa Scopes**: Aplikasi memiliki 4 peran utama (buyer, initiator, seller, admin) yang dihandle oleh middleware Role, tidak perlu OAuth scopes.
4. **Expiry 30 Hari**: Sesuai dengan kebutuhan keamanan, setelah 30 hari user harus login ulang via OTP.
5. **Integrasi Native Laravel**: Tidak perlu package tambahan, mengurangi dependency.

**Konsekuensi**

- Token harus disimpan di `flutter_secure_storage` di sisi mobile (bukan di Hive) untuk keamanan.
- Karena token tidak bisa di-refresh secara otomatis, user harus login ulang setelah 30 hari (ini baik dari sisi keamanan).
- Tidak mendukung multiple device login secara terpisah? (Cukup dengan token per perangkat).

**Status:** Accepted

---

## ADR-007: Dio vs http package

**Konteks**

Aplikasi Flutter membutuhkan HTTP client yang kuat untuk berkomunikasi dengan backend Laravel. Fitur yang dibutuhkan meliputi: interceptor untuk menambahkan Bearer token secara otomatis, Idempotency-Key UUID per POST, ETag dan If-None-Match untuk caching, retry mechanism untuk error 503, serta upload file multipart untuk bukti QRIS.

**Alternatif yang Dipertimbangkan**

| Alternatif                  | Kelebihan                                                 | Kekurangan                                                                                                  |
| --------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **http package (official)** | Ringan, bawaan Flutter                                    | Tidak ada interceptor, header harus di-set manual setiap request, tidak ada retry built-in, multipart rumit |
| **Chopper/Retrofit**        | Code generation, deklaratif                               | Membutuhkan code generation tambahan, setup lebih kompleks                                                  |
| **Dio 5.x (Keputusan)**     | Interceptor chain lengkap, multipart mudah, timeout/retry | Menambah ukuran APK ~300KB                                                                                  |

**Keputusan**

Menggunakan **Dio 5.x** sebagai HTTP client, dikombinasikan dengan **Retrofit** untuk code generation endpoint API (opsional/clean code).

**Alasan**

1. **Interceptor Chain**:
   - `AuthInterceptor`: Menambahkan `Authorization: Bearer` secara otomatis.
   - `IdempotencyInterceptor`: Generate UUID v4 untuk setiap method `POST`/`PATCH` dan menyimpannya di header.
   - `ETagInterceptor`: Menyimpan ETag dari response dan mengirimkan `If-None-Match` pada request berikutnya.
   - `RetryInterceptor`: Retry 3 kali dengan exponential backoff (2s, 5s, 10s) untuk error 503 (maintenance/blue-green).
2. **Multipart Upload**: Mendukung `FormData` dengan mudah untuk upload bukti, sekaligus memantau progress.
3. **Timeout**: Mendukung `connectTimeout` dan `receiveTimeout` secara native.
4. **Retrofit (Opsional)**: Membantu membuat kode API menjadi lebih terstruktur dan type-safe dengan `@GET`, `@POST`, `@Body`, dll.

**Konsekuensi**

- Menambah ukuran bundle sekitar ~300KB, namun masih dalam batas aman (<10MB total).
- Perlu mengelola `Dio` instance sebagai Singleton agar interceptor tidak berlipat.
- Harus berhati-hati dengan `IdempotencyInterceptor` agar key tidak digenerate ulang saat retry.

**Status:** Accepted

---


## ADR-008: Penawaran Supplier, Campaign Inisiator, dan Multi-Role

**Konteks**

Supplier perlu mengendalikan katalog, harga, kapasitas, dan fulfillment, sementara Inisiator harus tetap mengendalikan campaign komunitas dan hubungan pembayaran dengan Pembeli.

**Keputusan**

Gunakan arsitektur perdagangan berbasis penawaran: Seller membuat penawaran Supplier dan Inisiator membuat campaign dari penawaran aktif. Gunakan `roles` dan `user_roles` untuk empat role (`buyer`, `initiator`, `seller`, `admin`) karena Inisiator juga dapat menjadi Pembeli. Seller mewakili organisasi `suppliers` melalui `supplier_members`.

**Konsekuensi**

- Penawaran dan campaign menjadi lifecycle terpisah dengan snapshot komersial.
- Purchase order menjadi kontrak pemenuhan antara Inisiator dan supplier.
- Data Pembeli tidak dibagikan kepada seller.
- Otorisasi memerlukan role, membership, cluster, ownership, dan audit log.
- Kompleksitas bertambah, tetapi batas domain dan tanggung jawab setiap aktor menjadi eksplisit.

**Status:** Accepted

## Template ADR Baru

Jika di masa depan terdapat keputusan arsitektur baru (misalnya memilih Web Dashboard Livewire vs Inertia, atau mengubah storage ke Cloud R2), maka tambahkan dengan format berikut:

```markdown
## ADR-009: Judul Keputusan

**Konteks**

Jelaskan situasi dan masalah yang mendasari keputusan ini.

**Alternatif yang Dipertimbangkan**

Tuliskan 2-3 alternatif beserta kelebihan dan kekurangannya.

**Keputusan**

Sebutkan opsi yang dipilih secara tegas.

**Alasan**

Jelaskan secara mendetail mengapa opsi tersebut dipilih, minimal 3 poin kuat.

**Konsekuensi**

Jelaskan dampak dari keputusan ini terhadap kode, tim, biaya, atau jadwal.

**Status:** Proposed / Accepted / Deprecated / Superseded by ADR-00X
```

---

**Semua ADR di atas wajib dibaca oleh pengembang baru sebelum memulai Sprint 1. Dokumen ini menjadi sumber kebenaran untuk pertanyaan "Kenapa memilih X daripada Y?".**

---

**Signed:** Lead Architect Grosirun, 20 Juli 2026
