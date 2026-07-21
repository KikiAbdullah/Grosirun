# MANAJEMEN DATABASE & MIGRASI DATA - Grosirun V3.1

**DB:** MySQL 8.0 InnoDB  
**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Desain Database
   - 2.1 ERD Lengkap & Kardinalitas
   - 2.2 Diagram Foreign Key & Constraint Actions
   - 2.3 Detail Tabel, Kolom, Tipe & Indeks
   - 2.4 Strategi Indeks & Optimalisasi Query
   - 2.5 Dependency Graph Migrasi
   - 2.6 Siklus Hidup Data & Retensi
   - 2.7 Strategi Partisi Orders
   - 2.8 Read Replica & Connection Pooling
3. Rencana Migrasi Data
   - 3.1 Sumber Data
   - 3.2 Firebase → MySQL Migration
   - 3.3 Excel Manual → MySQL Bulk Create
   - 3.4 Local Storage → S3 Migration
   - 3.5 Rollback Plan
   - 3.6 Checklist Migration PR
4. Panduan Migrasi Database
   - 4.1 Filosofi Migrasi
   - 4.2 Cara Membuat Migrasi Baru
   - 4.3 Strategi Rollback yang Aman
   - 4.4 Seed & Factory
   - 4.5 Expand-Contract Pattern (Safe untuk Blue-Green)
   - 4.6 Migrasi Data Firebase → MySQL (Detail Command)
   - 4.7 Migrasi S3 & Cluster
5. Backup & Disaster Recovery
6. Lampiran
   - 6.1 Troubleshooting
   - 6.2 Perintah Penting

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Tujuan Desain Database

Database Grosirun V3.1 dirancang untuk mendukung operasional platform patungan belanja sembako berbasis RT/RW dengan karakteristik:

- **Multi-Cluster**: 1 cluster = 1 RT (max 500 user), dengan isolasi data antar cluster
- **Zero Oversell**: Menggunakan pessimistic locking (`SELECT ... FOR UPDATE`) untuk mencegah penjualan melebihi kuota
- **Audit Trail**: Semua transaksi sensitif tercatat di `transaction_logs`
- **UU PDP Compliance**: Consent, retensi data 90 hari, hak hapus akun
- **Offline-First**: Data dapat di-cache di Hive (mobile) dan disinkronisasi saat online
- **Idempotency**: Mencegah duplikasi order melalui Redis cache 24 jam

### 1.2 Konteks Bisnis (Referensi BUSINESS_ANALYSIS.md)

| Komponen              | Nilai                          |
| --------------------- | ------------------------------ |
| Platform Fee          | 1% GMV + PPN 11%               |
| GMV per PO AT_70      | Rp8.400.000 (700Kg × Rp12.000) |
| Laba Initiator per PO | Rp956.760                      |
| Target Adopsi         | 70% (35 dari 50 KK)            |
| Cluster               | 1 RT = 50 KK = 1 cluster       |

### 1.3 Gap yang Ditutup V3.1

| #   | Gap                                                | Solusi                                                         |
| --- | -------------------------------------------------- | -------------------------------------------------------------- |
| 1   | DB tanpa cluster_id padahal PRD 1 cluster=500 user | Tambah `clusters` table + FK di `users`, `campaigns`, `orders` |
| 2   | Storage lokal vs S3 inkonsisten                    | `image_path` dan `proof_path` menyimpan path S3, bukan local   |
| 3   | Tidak ada audit trail                              | `transaction_logs` untuk semua aksi sensitif                   |
| 4   | Tidak ada fallback notifikasi                      | `notifications` table untuk FCM fallback                       |

### 1.4 Total Tabel

**9 Tabel Utama + 3 Tabel Pendukung:**

| #   | Tabel                      | Fungsi                                    |
| --- | -------------------------- | ----------------------------------------- |
| 1   | `clusters`                 | Data RT/Cluster                           |
| 2   | `users`                    | Data pengguna (buyer/initiator/admin)     |
| 3   | `otp_codes`                | Kode OTP untuk login                      |
| 4   | `campaigns`                | Data PO (campaign)                        |
| 5   | `campaign_variants`        | Varian produk dalam campaign              |
| 6   | `orders`                   | Data pesanan                              |
| 7   | `transaction_logs`         | Audit trail                               |
| 8   | `notifications`            | Fallback notifikasi FCM                   |
| 9   | `personal_access_tokens`   | Sanctum token                             |
| 10  | `failed_jobs`              | Queue failed jobs                         |
| 11  | `jobs`                     | Queue jobs                                |
| 12  | `idempotency_keys` (Redis) | Cache idempotency (table backup opsional) |

---

## 2. Desain Database

### 2.1 ERD Lengkap & Kardinalitas

#### Diagram ERD Mermaid

```mermaid
erDiagram
    clusters ||--o{ users : "1:N (1 cluster memiliki N users)"
    clusters ||--o{ campaigns : "1:N (1 cluster memiliki N campaigns)"
    clusters ||--o{ orders : "1:N (1 cluster memiliki N orders - denormalized)"
    users ||--o{ campaigns : "1:N (1 initiator membuat N campaigns)"
    users ||--o{ orders : "1:N (1 buyer memiliki N orders)"
    users ||--o{ otp_codes : "1:N (1 phone memiliki N OTP attempts)"
    users ||--o{ notifications : "1:N (1 user memiliki N fallback notifs)"
    users ||--o{ personal_access_tokens : "1:N (1 user memiliki N Sanctum tokens)"
    users ||--o{ transaction_logs : "1:N (1 initiator mencatat N actions)"
    campaigns ||--o{ campaign_variants : "1:N (1 campaign memiliki 2-3 variants)"
    campaigns ||--o{ orders : "1:N (1 campaign memiliki N orders)"
    campaign_variants ||--o{ orders : "1:N (1 variant memiliki N orders)"
    orders ||--o{ transaction_logs : "1:N (1 order memiliki N audit logs)"
    orders ||--o{ notifications : "1:N (order event trigger notifs)"

    clusters {
        bigint id PK
        varchar code UK "PGH-RT03"
        varchar name "Permata Hijau RT03"
        varchar rw
        varchar kelurahan
        varchar city "Surabaya"
        timestamps
    }

    users {
        bigint id PK
        bigint cluster_id FK
        varchar name "100"
        varchar phone_number UK "628..."
        enum role "buyer_initiator_admin"
        text fcm_token
        datetime consent_at "UU PDP"
        varchar consent_version
        datetime tos_accepted_at
        varchar tos_version
        datetime phone_verified_at
        timestamps
    }

    campaigns {
        bigint id PK
        bigint cluster_id FK
        bigint initiator_id FK
        varchar slug UK "beras-mahkota-abc"
        varchar name "150"
        text description
        varchar image_path "S3 campaigns/uuid.jpg"
        int target_kg
        int current_kg "default 0"
        bigint price_total_supplier
        datetime deadline "IDX"
        enum status "active_completed_expired_cancelled"
        varchar pickup_location
        datetime distribution_completed_at
        timestamps
    }

    campaign_variants {
        bigint id PK
        bigint campaign_id FK
        decimal size_kg "5,2"
        bigint price "60000"
        int quota "100"
        int sold "default 0"
        timestamps
        unique campaign_id+size_kg
    }

    orders {
        bigint id PK
        uuid uuid UK "external"
        bigint cluster_id FK
        bigint campaign_id FK
        bigint campaign_variant_id FK
        bigint user_id FK
        int quantity "1-100"
        decimal total_kg "8,2"
        bigint total_price
        enum payment_method "cash_qris"
        enum payment_status "pending_waiting_paid_rejected_cancelled"
        varchar proof_path "S3 order_proofs/uuid.jpg"
        bool is_taken "default false"
        datetime taken_at
        bigint taken_by_initiator_id FK
        datetime cancelled_at
        varchar idempotency_key
        varchar deleted_user_name
        timestamps
    }

    transaction_logs {
        bigint id PK
        bigint order_id FK
        bigint initiator_id FK
        enum type "validation_rejection_override_undo_transfer_extend_cancel_distribution_tos_accept_delete_account"
        varchar notes "500"
        varchar ip_address "45"
        datetime created_at
    }

    notifications {
        bigint id PK
        bigint user_id FK
        bigint cluster_id FK
        varchar title "Pesanan Baru"
        varchar body "Bu Siti pesan 5Kg"
        json data
        datetime read_at
        timestamps
    }

    otp_codes {
        bigint id PK
        varchar phone_number
        varchar otp_hash
        tinyint attempts "default 0"
        datetime expires_at
        datetime locked_until
        timestamps
    }
```

#### Penjelasan Kardinalitas

| Relasi                            | Kardinalitas | Penjelasan                                                             |
| --------------------------------- | ------------ | ---------------------------------------------------------------------- |
| `clusters` → `users`              | 1:N          | 1 cluster dapat memiliki max 500 user (app logic, bukan DB constraint) |
| `clusters` → `campaigns`          | 1:N          | 1 cluster memiliki banyak campaign (PO)                                |
| `clusters` → `orders`             | 1:N          | Denormalized untuk fast filter                                         |
| `users` (initiator) → `campaigns` | 1:N          | 1 initiator dapat membuat banyak campaign                              |
| `users` (buyer) → `orders`        | 1:N          | 1 buyer memiliki banyak order                                          |
| `campaigns` → `campaign_variants` | 1:N          | 1 campaign memiliki 2-3 varian (5Kg, 10Kg)                             |
| `campaign_variants` → `orders`    | 1:N          | 1 varian dapat memiliki banyak order (dibatasi quota)                  |
| `orders` → `transaction_logs`     | 1:N          | 1 order memiliki banyak audit log                                      |
| `orders` → `notifications`        | 1:N          | Order event trigger notifikasi                                         |

### 2.2 Diagram Foreign Key & Constraint Actions

#### Diagram FK

```
┌─────────────────┐
│    clusters     │
│  - id (PK)      │
│  - code (UK)    │
│  - name         │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐         ┌─────────────────┐
│     users       │         │    campaigns    │
│  - id (PK)      │         │  - id (PK)      │
│  - cluster_id ──┼────────►│  - cluster_id   │
│  - phone (UK)   │         │  - initiator_id─┼───┐
│  - role         │         │  - slug (UK)    │   │
└────────┬────────┘         └────────┬────────┘   │
         │                           │ 1:N        │
         │ 1:N                       ▼            │
         │                  ┌─────────────────┐   │
         │                  │campaign_variants│   │
         │                  │  - id (PK)      │   │
         │                  │  - campaign_id  │   │
         │                  │  - size_kg      │   │
         │                  └────────┬────────┘   │
         │                           │ 1:N        │
         │                           ▼            │
         │                  ┌─────────────────┐   │
         │                  │     orders      │   │
         │                  │  - id (PK)      │   │
         │                  │  - uuid (UK)    │   │
         ├─────────────────►│  - user_id      │   │
         │                  │  - cluster_id   │   │
         │                  │  - campaign_id  │   │
         │                  │  - variant_id   │   │
         │                  └────────┬────────┘   │
         │                           │ 1:N        │
         │                           ▼            │
         │                  ┌─────────────────┐   │
         │                  │ transaction_logs│   │
         │                  │  - id (PK)      │   │
         │                  │  - order_id     │   │
         │                  │  - initiator_id─┼───┘
         │                  └─────────────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│  notifications  │
│  - id (PK)      │
│  - user_id      │
│  - cluster_id   │
└─────────────────┘
```

#### Constraint Actions

| Foreign Key                     | Referensi              | Action     | Alasan                                                    |
| ------------------------------- | ---------------------- | ---------- | --------------------------------------------------------- |
| `users.cluster_id`              | `clusters.id`          | `SET NULL` | Jika cluster dihapus, user tetap ada (anonymized)         |
| `campaigns.cluster_id`          | `clusters.id`          | `RESTRICT` | Tidak boleh hapus cluster jika ada campaign               |
| `campaigns.initiator_id`        | `users.id`             | `RESTRICT` | Tidak boleh hapus initiator jika ada campaign             |
| `campaign_variants.campaign_id` | `campaigns.id`         | `CASCADE`  | Hapus campaign → hapus variants (jika tidak ada orders)   |
| `orders.campaign_id`            | `campaigns.id`         | `RESTRICT` | Tidak boleh hapus campaign jika ada orders                |
| `orders.campaign_variant_id`    | `campaign_variants.id` | `RESTRICT` | Tidak boleh hapus variant jika ada orders                 |
| `orders.user_id`                | `users.id`             | `SET NULL` | Jika user dihapus (anonymize), order tetap ada            |
| `orders.taken_by_initiator_id`  | `users.id`             | `SET NULL` | Jika initiator dihapus, data taken tetap ada              |
| `orders.cluster_id`             | `clusters.id`          | `SET NULL` | Denormalized, jika cluster dihapus tetap ada              |
| `transaction_logs.order_id`     | `orders.id`            | `CASCADE`  | Hapus order → hapus logs (audit tetap, order soft delete) |
| `transaction_logs.initiator_id` | `users.id`             | `RESTRICT` | Tidak boleh hapus initiator jika ada logs                 |
| `notifications.user_id`         | `users.id`             | `CASCADE`  | Hapus user → hapus notifikasi                             |

#### Safe Delete Strategy (UU PDP)

| Operasi                               | Strategy                         | Detail                                                                                            |
| ------------------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Hapus User (DELETE /auth/account)** | Anonimize (bukan hard delete)    | `name` → `Deleted User {id}`, `phone` → `DELETED_{id}`, `fcm_token` null, `orders.user_id` → null |
| **Hapus Campaign**                    | Soft delete (status `cancelled`) | Tidak hard delete jika ada orders paid >0                                                         |
| **Hapus Order**                       | Soft delete (`cancelled_at`)     | Tidak hard delete untuk audit                                                                     |
| **Hapus Variant**                     | Restrict jika `sold > 0`         | Tidak bisa hapus jika sudah ada pembelian                                                         |

### 2.3 Detail Tabel, Kolom, Tipe & Indeks

#### Tabel `clusters`

| Kolom        | Tipe            | Null | Default        | Keterangan                               |
| ------------ | --------------- | ---- | -------------- | ---------------------------------------- |
| `id`         | bigint unsigned | NO   | AUTO_INCREMENT | Primary Key                              |
| `code`       | varchar(20)     | NO   | -              | Unique, contoh: PGH-RT03                 |
| `name`       | varchar(100)    | NO   | -              | Nama cluster, contoh: Permata Hijau RT03 |
| `rw`         | varchar(10)     | YES  | NULL           | Nomor RW                                 |
| `kelurahan`  | varchar(50)     | YES  | NULL           | Nama kelurahan                           |
| `city`       | varchar(50)     | NO   | 'Surabaya'     | Kota                                     |
| `created_at` | timestamp       | YES  | NULL           | Waktu dibuat                             |
| `updated_at` | timestamp       | YES  | NULL           | Waktu diperbarui                         |

**Indeks:**

- PRIMARY: `id`
- UNIQUE: `code`

#### Tabel `users`

| Kolom               | Tipe            | Null | Default        | Keterangan                     |
| ------------------- | --------------- | ---- | -------------- | ------------------------------ |
| `id`                | bigint unsigned | NO   | AUTO_INCREMENT | Primary Key                    |
| `cluster_id`        | bigint unsigned | YES  | NULL           | Foreign Key ke `clusters.id`   |
| `name`              | varchar(100)    | NO   | -              | Nama lengkap                   |
| `phone_number`      | varchar(20)     | NO   | -              | Unique, format E.164 (628...)  |
| `role`              | enum            | NO   | 'buyer'        | `buyer`, `initiator`, `admin`  |
| `fcm_token`         | text            | YES  | NULL           | Firebase Cloud Messaging token |
| `consent_at`        | datetime        | YES  | NULL           | Waktu consent UU PDP           |
| `consent_version`   | varchar(20)     | YES  | NULL           | Versi privacy policy           |
| `tos_accepted_at`   | datetime        | YES  | NULL           | Waktu accept Terms of Service  |
| `tos_version`       | varchar(20)     | YES  | NULL           | Versi ToS                      |
| `phone_verified_at` | datetime        | YES  | NULL           | Waktu verifikasi OTP           |
| `created_at`        | timestamp       | YES  | NULL           | Waktu dibuat                   |
| `updated_at`        | timestamp       | YES  | NULL           | Waktu diperbarui               |

**Indeks:**

- PRIMARY: `id`
- UNIQUE: `phone_number`
- INDEX: `cluster_id`
- INDEX: `(cluster_id, role)`
- INDEX: `consent_at`

#### Tabel `campaigns`

| Kolom                       | Tipe            | Null | Default        | Keterangan                                    |
| --------------------------- | --------------- | ---- | -------------- | --------------------------------------------- |
| `id`                        | bigint unsigned | NO   | AUTO_INCREMENT | Primary Key                                   |
| `cluster_id`                | bigint unsigned | NO   | -              | FK ke `clusters.id`                           |
| `initiator_id`              | bigint unsigned | NO   | -              | FK ke `users.id` (initiator)                  |
| `slug`                      | varchar(160)    | NO   | -              | Unique, URL-friendly name                     |
| `name`                      | varchar(150)    | NO   | -              | Nama campaign                                 |
| `description`               | text            | YES  | NULL           | Deskripsi                                     |
| `image_path`                | varchar(255)    | YES  | NULL           | S3 path: campaigns/{uuid}.jpg                 |
| `target_kg`                 | int unsigned    | NO   | -              | Target kilogram (min 100)                     |
| `current_kg`                | int unsigned    | NO   | 0              | Kilogram terkumpul (counter cache)            |
| `price_total_supplier`      | bigint unsigned | NO   | -              | Total harga dari supplier                     |
| `deadline`                  | datetime        | NO   | -              | Tenggat waktu                                 |
| `status`                    | enum            | NO   | 'active'       | `active`, `completed`, `expired`, `cancelled` |
| `pickup_location`           | varchar(255)    | YES  | NULL           | Lokasi pengambilan                            |
| `distribution_completed_at` | datetime        | YES  | NULL           | Waktu distribusi selesai                      |
| `created_at`                | timestamp       | YES  | NULL           | Waktu dibuat                                  |
| `updated_at`                | timestamp       | YES  | NULL           | Waktu diperbarui                              |

**Indeks:**

- PRIMARY: `id`
- UNIQUE: `slug`
- INDEX: `(cluster_id, status, deadline)` → untuk query GET /campaigns
- INDEX: `initiator_id`
- INDEX: `status`

#### Tabel `campaign_variants`

| Kolom         | Tipe            | Null | Default        | Keterangan                     |
| ------------- | --------------- | ---- | -------------- | ------------------------------ |
| `id`          | bigint unsigned | NO   | AUTO_INCREMENT | Primary Key                    |
| `campaign_id` | bigint unsigned | NO   | -              | FK ke `campaigns.id` (CASCADE) |
| `size_kg`     | decimal(5,2)    | NO   | -              | Ukuran varian (5.00, 10.00)    |
| `price`       | bigint unsigned | NO   | -              | Harga per varian (Rp)          |
| `quota`       | int unsigned    | NO   | 100            | Kuota tersedia                 |
| `sold`        | int unsigned    | NO   | 0              | Terjual (counter cache)        |
| `created_at`  | timestamp       | YES  | NULL           | Waktu dibuat                   |
| `updated_at`  | timestamp       | YES  | NULL           | Waktu diperbarui               |

**Indeks:**

- PRIMARY: `id`
- UNIQUE: `(campaign_id, size_kg)`
- INDEX: `campaign_id`

#### Tabel `orders`

| Kolom                   | Tipe            | Null | Default        | Keterangan                                            |
| ----------------------- | --------------- | ---- | -------------- | ----------------------------------------------------- |
| `id`                    | bigint unsigned | NO   | AUTO_INCREMENT | Primary Key                                           |
| `uuid`                  | char(36)        | NO   | -              | Unique, external ID                                   |
| `cluster_id`            | bigint unsigned | YES  | NULL           | Denormalized FK ke `clusters.id`                      |
| `campaign_id`           | bigint unsigned | NO   | -              | FK ke `campaigns.id`                                  |
| `campaign_variant_id`   | bigint unsigned | NO   | -              | FK ke `campaign_variants.id`                          |
| `user_id`               | bigint unsigned | YES  | NULL           | FK ke `users.id` (null jika anonymized)               |
| `quantity`              | int unsigned    | NO   | -              | Jumlah (1-100)                                        |
| `total_kg`              | decimal(8,2)    | NO   | -              | `quantity * variant.size_kg`                          |
| `total_price`           | bigint unsigned | NO   | -              | `quantity * variant.price`                            |
| `payment_method`        | enum            | NO   | 'cash'         | `cash`, `qris`                                        |
| `payment_status`        | enum            | NO   | 'pending'      | `pending`, `waiting`, `paid`, `rejected`, `cancelled` |
| `proof_path`            | varchar(255)    | YES  | NULL           | S3 path: order_proofs/{uuid}.jpg                      |
| `is_taken`              | boolean         | NO   | false          | Sudah diambil buyer?                                  |
| `taken_at`              | datetime        | YES  | NULL           | Waktu diambil                                         |
| `taken_by_initiator_id` | bigint unsigned | YES  | NULL           | FK ke `users.id` (initiator yang menandai)            |
| `cancelled_at`          | datetime        | YES  | NULL           | Waktu dibatalkan                                      |
| `idempotency_key`       | varchar(100)    | YES  | NULL           | Key untuk deduplikasi                                 |
| `deleted_user_name`     | varchar(100)    | YES  | NULL           | Snapshot nama user jika di-anonymize                  |
| `created_at`            | timestamp       | YES  | NULL           | Waktu dibuat                                          |
| `updated_at`            | timestamp       | YES  | NULL           | Waktu diperbarui                                      |

**Indeks:**

- PRIMARY: `id`
- UNIQUE: `uuid`
- UNIQUE: `idempotency_key` (opsional, Redis lebih utama)
- INDEX: `(campaign_id, payment_status)` → dashboard admin
- INDEX: `(user_id, created_at DESC)` → my orders
- INDEX: `payment_status`
- INDEX: `cluster_id`
- INDEX: `campaign_id`

#### Tabel `transaction_logs`

| Kolom          | Tipe            | Null | Default        | Keterangan                                                                                                                             |
| -------------- | --------------- | ---- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `id`           | bigint unsigned | NO   | AUTO_INCREMENT | Primary Key                                                                                                                            |
| `order_id`     | bigint unsigned | YES  | NULL           | FK ke `orders.id` (CASCADE)                                                                                                            |
| `initiator_id` | bigint unsigned | NO   | -              | FK ke `users.id`                                                                                                                       |
| `type`         | enum            | NO   | -              | `validation`, `rejection`, `override`, `undo`, `transfer`, `extend`, `cancel_campaign`, `distribution`, `tos_accept`, `delete_account` |
| `notes`        | varchar(500)    | YES  | NULL           | Catatan tambahan (override reason)                                                                                                     |
| `ip_address`   | varchar(45)     | YES  | NULL           | IP address pengguna                                                                                                                    |
| `created_at`   | timestamp       | NO   | -              | Waktu kejadian                                                                                                                         |

**Indeks:**

- PRIMARY: `id`
- INDEX: `order_id`
- INDEX: `initiator_id`
- INDEX: `type`
- INDEX: `created_at`

#### Tabel `notifications`

| Kolom        | Tipe            | Null | Default        | Keterangan                                       |
| ------------ | --------------- | ---- | -------------- | ------------------------------------------------ |
| `id`         | bigint unsigned | NO   | AUTO_INCREMENT | Primary Key                                      |
| `user_id`    | bigint unsigned | NO   | -              | FK ke `users.id` (CASCADE)                       |
| `cluster_id` | bigint unsigned | YES  | NULL           | Denormalized FK ke `clusters.id`                 |
| `title`      | varchar(150)    | NO   | -              | Judul notifikasi                                 |
| `body`       | varchar(255)    | NO   | -              | Body notifikasi                                  |
| `data`       | json            | YES  | NULL           | Data tambahan: `{type, campaign_id, order_uuid}` |
| `read_at`    | datetime        | YES  | NULL           | Waktu dibaca                                     |
| `created_at` | timestamp       | YES  | NULL           | Waktu dibuat                                     |
| `updated_at` | timestamp       | YES  | NULL           | Waktu diperbarui                                 |

**Indeks:**

- PRIMARY: `id`
- INDEX: `(user_id, read_at)`
- INDEX: `cluster_id`

#### Tabel `otp_codes`

| Kolom          | Tipe             | Null | Default        | Keterangan                     |
| -------------- | ---------------- | ---- | -------------- | ------------------------------ |
| `id`           | bigint unsigned  | NO   | AUTO_INCREMENT | Primary Key                    |
| `phone_number` | varchar(20)      | NO   | -              | Nomor HP (E.164)               |
| `otp_hash`     | varchar(255)     | NO   | -              | Hash bcrypt dari OTP 4 digit   |
| `attempts`     | tinyint unsigned | NO   | 0              | Jumlah percobaan gagal         |
| `expires_at`   | datetime         | NO   | -              | Waktu kadaluarsa (5 menit)     |
| `locked_until` | datetime         | YES  | NULL           | Waktu lock (jika attempts >=5) |
| `created_at`   | timestamp        | YES  | NULL           | Waktu dibuat                   |
| `updated_at`   | timestamp        | YES  | NULL           | Waktu diperbarui               |

**Indeks:**

- PRIMARY: `id`
- INDEX: `phone_number`
- INDEX: `expires_at`

### 2.4 Strategi Indeks & Optimalisasi Query

#### Indeks Visual

```
campaigns:
  - PRIMARY (id)
  - UNIQUE (slug)
  - INDEX idx_cluster_status_deadline (cluster_id, status, deadline)  ← Query GET /campaigns
  - INDEX idx_initiator (initiator_id)
  - INDEX idx_status (status)

orders:
  - PRIMARY (id)
  - UNIQUE (uuid)
  - INDEX idx_campaign_status (campaign_id, payment_status)  ← Dashboard admin
  - INDEX idx_user_created (user_id, created_at DESC)  ← My orders
  - INDEX idx_payment_status (payment_status)
  - INDEX idx_cluster (cluster_id)
  - UNIQUE idx_idempotency (idempotency_key)  ← Redis juga

transaction_logs:
  - PRIMARY (id)
  - INDEX idx_order_id (order_id)
  - INDEX idx_initiator (initiator_id)
  - INDEX idx_type (type)
  - INDEX idx_created (created_at)

notifications:
  - PRIMARY (id)
  - INDEX idx_user_read (user_id, read_at)
  - INDEX idx_cluster (cluster_id)

otp_codes:
  - PRIMARY (id)
  - INDEX idx_phone (phone_number)
  - INDEX idx_expires (expires_at)
```

#### Query Optimalisasi

**Query 1: GET /campaigns?status=active&cluster_id=1&sort=deadline**

```sql
SELECT * FROM campaigns
WHERE cluster_id = 1
  AND status = 'active'
  AND deadline > NOW()
ORDER BY deadline ASC
LIMIT 15;
```

**EXPLAIN:**

```
type: range
key: idx_cluster_status_deadline
rows: 10
Extra: Using index condition; Using where
```

**Query 2: Dashboard Admin - Daftar Pending Orders**

```sql
SELECT o.*, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.campaign_id = 12
  AND o.payment_status = 'pending'
ORDER BY o.created_at ASC;
```

**EXPLAIN:**

```
type: ref
key: idx_campaign_status
rows: 5
Extra: Using index condition
```

**Query 3: My Orders**

```sql
SELECT *
FROM orders
WHERE user_id = 5
ORDER BY created_at DESC
LIMIT 15;
```

**EXPLAIN:**

```
type: ref
key: idx_user_created
rows: 15
Extra: Using index condition; Backward index scan
```

#### Tips Optimalisasi

| Tips                | Keterangan                                                                      |
| ------------------- | ------------------------------------------------------------------------------- |
| **Eager Loading**   | Gunakan `with(['variant','user:id,name','campaign:id,name'])` untuk hindari N+1 |
| **Select Specific** | Gunakan `select('id','name','slug')` di Resource untuk mengurangi payload       |
| **Counter Cache**   | `current_kg` dan `sold` di-increment atomic, bukan `SUM()` tiap query           |
| **Read Replica**    | Query berat (recap) gunakan `DB::connection('mysql_read')`                      |
| **Cache Redis**     | `Cache::remember('campaigns:active:cluster:1', 60, fn() => ...)`                |

#### Cara Cek EXPLAIN

```bash
php artisan tinker
```

```php
// Aktifkan query log
DB::enableQueryLog();

// Jalankan query
Campaign::where('cluster_id',1)
    ->where('status','active')
    ->orderBy('deadline')
    ->get();

// Lihat query dan EXPLAIN
dd(DB::getQueryLog());

// EXPLAIN langsung
DB::select('EXPLAIN SELECT * FROM campaigns WHERE cluster_id=1 AND status="active" ORDER BY deadline');
```

### 2.5 Dependency Graph Migrasi

#### Urutan Migrasi

```
1_create_clusters_table (no deps)
  │
  ▼
2_create_users_table (depends clusters)
  │
  ├─────────────────────────────┐
  │                             │
  ▼                             ▼
3_create_otp_codes_table    4_create_campaigns_table
  (no deps)                    (depends clusters, users initiator)
  │                             │
  │                             ▼
  │                     5_create_campaign_variants_table
  │                         (depends campaigns)
  │                             │
  ▼                             ▼
9_personal_access_tokens  6_create_orders_table
  (depends users)              (depends clusters, campaigns, variants, users)
  │                             │
  ▼                             ▼
                        7_create_transaction_logs_table
                           (depends orders, users)
  │                             │
  └─────────────────────────────┘
  │
  ▼
8_create_notifications_table
  (depends users, clusters)

10_create_failed_jobs_table
  (no deps, queue)
```

#### Aturan Migrasi

| Aturan              | Keterangan                                                                  |
| ------------------- | --------------------------------------------------------------------------- |
| **Timestamp**       | Migration file harus timestamp urut: `2026_07_20_000001_create_clusters...` |
| **Additive Only**   | Untuk blue-green deploy, migration hanya boleh menambah (tidak drop)        |
| **Rollback Safe**   | `up()` dan `down()` harus idempotent                                        |
| **Expand-Contract** | Untuk drop column, gunakan 3-phase: expand → migrate → contract             |

#### Rollback Order

```
10_failed_jobs
9_personal_access_tokens
8_notifications
7_transaction_logs
6_orders
5_campaign_variants
4_campaigns
3_otp_codes
2_users
1_clusters
```

```bash
# Rollback 1 step
php artisan migrate:rollback --step=1

# Rollback semua
php artisan migrate:rollback
```

### 2.6 Siklus Hidup Data & Retensi

#### Data Lifecycle

| Tabel               | Siklus                               | Retensi              | Job                                        |
| ------------------- | ------------------------------------ | -------------------- | ------------------------------------------ |
| `clusters`          | Forever                              | Forever              | -                                          |
| `users`             | Forever (anonymized on DELETE)       | Forever (anonymized) | `AnonymizeUserJob`                         |
| `otp_codes`         | 5 menit expiry                       | 1 jam                | `CleanExpiredOtpsJob` (hourly)             |
| `campaigns`         | Forever                              | Forever              | -                                          |
| `campaign_variants` | Forever                              | Forever              | -                                          |
| `orders`            | Forever (soft delete `cancelled_at`) | Forever              | -                                          |
| `transaction_logs`  | Forever                              | Forever              | -                                          |
| `notifications`     | 30 hari                              | 30 hari              | `CleanOldNotificationsJob` (daily)         |
| `proof S3`          | 90 hari setelah completed            | 90 hari              | S3 lifecycle + `CleanOldProofsJob` (daily) |

#### S3 Lifecycle Rule

```json
{
  "Rules": [
    {
      "ID": "delete-old-proofs-90d",
      "Filter": { "Prefix": "order_proofs/" },
      "Status": "Enabled",
      "Expiration": { "Days": 90 }
    }
  ]
}
```

#### CleanOldProofsJob (Double Safety)

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

#### Data Anonymization (UU PDP)

```php
// app/Jobs/AnonymizeUserJob.php
$user->update([
    'name' => 'Deleted User ' . $user->id,
    'phone_number' => 'DELETED_' . $user->id,
    'fcm_token' => null,
]);

// Revoke semua token
$user->tokens()->delete();

// Anonymize orders
Order::where('user_id', $user->id)
    ->update([
        'user_id' => null,
        'deleted_user_name' => 'Deleted User ' . $user->id,
    ]);

// Hapus S3 proofs
Storage::disk('s3')->delete(
    Order::where('user_id', $user->id)
        ->whereNotNull('proof_path')
        ->pluck('proof_path')
        ->toArray()
);

// Log
TransactionLog::create([
    'initiator_id' => $user->id,
    'type' => 'delete_account',
    'ip_address' => request()->ip(),
]);
```

### 2.7 Strategi Partisi Orders

#### Latar Belakang

Tabel `orders` akan tumbuh cepat:

- 1 cluster = 35 buyer × 2 PO/bulan × 12 bulan = 840 orders/tahun
- 100 cluster = 84.000 orders/tahun
- 1.000 cluster = 840.000 orders/tahun → perlu partisi

#### Strategi Partisi V2 (Future)

```sql
ALTER TABLE orders PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION p2028 VALUES LESS THAN (2029),
    PARTITION p2029 VALUES LESS THAN (2030),
    PARTITION pFuture VALUES LESS THAN MAXVALUE
);
```

#### Prerequisite

```sql
-- V2 Migration
ALTER TABLE orders DROP PRIMARY KEY;
ALTER TABLE orders ADD PRIMARY KEY (id, created_at);
```

#### Query dengan Partisi

```sql
-- Query dengan filter created_at akan prune partition
SELECT * FROM orders
WHERE created_at BETWEEN '2026-01-01' AND '2026-12-31'
  AND campaign_id = 12;
```

### 2.8 Read Replica & Connection Pooling

#### Read Replica Configuration

```php
// config/database.php
'connections' => [
    'mysql' => [
        'driver' => 'mysql',
        'host' => env('DB_HOST', '127.0.0.1'),
        'database' => env('DB_DATABASE', 'grosirun'),
        'username' => env('DB_USERNAME', 'grosirun'),
        'password' => env('DB_PASSWORD', 'secret'),
    ],
    'mysql_read' => [
        'driver' => 'mysql',
        'host' => env('DB_READ_HOST', '127.0.0.1'),
        'database' => env('DB_DATABASE', 'grosirun'),
        'username' => env('DB_READ_USERNAME', 'grosirun_readonly'),
        'password' => env('DB_READ_PASSWORD', 'secret'),
    ],
],
```

#### Penggunaan di Service

```php
// CampaignService@recap - menggunakan read replica
$orders = Order::on('mysql_read')
    ->where('campaign_id', $campaign->id)
    ->where('payment_status', 'paid')
    ->with(['variant', 'user:id,name'])
    ->get();

// Atau dengan DB facade
DB::connection('mysql_read')->table('orders')->where(...);
```

#### Connection Pooling

| Komponen    | Konfigurasi            | Nilai |
| ----------- | ---------------------- | ----- |
| **MySQL**   | `max_connections`      | 100   |
| **PHP-FPM** | `pm.max_children`      | 30    |
| **PHP-FPM** | `pm.start_servers`     | 10    |
| **PHP-FPM** | `pm.min_spare_servers` | 5     |
| **PHP-FPM** | `pm.max_spare_servers` | 20    |
| **PHP-FPM** | `pm.max_requests`      | 500   |
| **Redis**   | `maxclients`           | 10000 |
| **Redis**   | `timeout`              | 0     |

**Monitor:**

```sql
-- Cek koneksi MySQL
SHOW STATUS LIKE 'Threads_connected';

-- Cek proses aktif
SHOW PROCESSLIST;

-- Cek Redis clients
redis-cli INFO clients
```

---

## 3. Rencana Migrasi Data

### 3.1 Sumber Data

| Sumber          | Format | Lokasi                                                     |
| --------------- | ------ | ---------------------------------------------------------- |
| Firebase v0.5.0 | JSON   | `storage/app/firebase-export.json`                         |
| Excel Manual    | XLSX   | `storage/app/fallback-excel.xlsx`                          |
| Local Storage   | JPG    | `storage/app/public/campaigns/*.jpg`, `order_proofs/*.jpg` |

### 3.2 Firebase → MySQL Migration

#### Export Firebase

```bash
# Via gcloud CLI
gcloud firestore export gs://grosirun-backup/firebase-export \
  --collection-ids=users,products,orders,transactions

# Download ke local
gsutil cp -r gs://grosirun-backup/firebase-export/* storage/app/firebase-export/
```

#### Konversi ke JSON

```javascript
// scripts/convert-firestore-export.js
const fs = require("fs");
const path = require("path");

const collections = ["users", "products", "orders", "transactions"];
const result = {};

for (const col of collections) {
  const filePath = path.join(
    __dirname,
    "../storage/app/firebase-export",
    col + ".json"
  );
  const data = JSON.parse(fs.readFileSync(filePath, "utf8"));
  result[col] = data.documents.map((doc) => {
    const fields = doc.fields;
    const id = doc.name.split("/").pop();
    const obj = { uid: id };
    for (const [key, value] of Object.entries(fields)) {
      obj[key] = Object.values(value)[0] || null;
    }
    return obj;
  });
}

fs.writeFileSync(
  "storage/app/firebase-export.json",
  JSON.stringify(result, null, 2)
);
```

#### Artisan Command: FirebaseImportCommand

**File:** `app/Console/Commands/FirebaseImportCommand.php`

```php
<?php

namespace App\Console\Commands;

use App\Models\Campaign;
use App\Models\CampaignVariant;
use App\Models\Cluster;
use App\Models\Order;
use App\Models\TransactionLog;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class FirebaseImportCommand extends Command
{
    protected $signature = 'firebase:import
                            {--file=storage/app/firebase-export.json : Path ke file JSON export}
                            {--cluster=PGH-RT03 : Kode cluster tujuan}';

    protected $description = 'Import data dari Firebase JSON ke MySQL (users, campaigns, orders, transactions)';

    public function handle(): int
    {
        $filePath = $this->option('file');
        $clusterCode = $this->option('cluster');

        if (!file_exists($filePath)) {
            $this->error("File tidak ditemukan: $filePath");
            return self::FAILURE;
        }

        $json = json_decode(file_get_contents($filePath), true);
        if (!$json) {
            $this->error('JSON tidak valid');
            return self::FAILURE;
        }

        $this->info('📦 Memulai import dari Firebase...');
        $this->info("Cluster target: $clusterCode");

        DB::transaction(function () use ($json, $clusterCode) {
            // 1. Dapatkan atau buat cluster
            $cluster = Cluster::firstOrCreate(
                ['code' => $clusterCode],
                [
                    'name' => 'Permata Hijau RT03',
                    'rw' => '03',
                    'kelurahan' => 'Ngoro',
                    'city' => 'Mojokerto',
                ]
            );
            $this->info("✅ Cluster: {$cluster->code} (ID: {$cluster->id})");

            // 2. Mapping Firebase UID -> User ID
            $uidToUserId = [];

            // 3. Import Users
            $this->info('📥 Import users...');
            foreach ($json['users'] as $u) {
                $phone = $this->normalizePhone($u['phoneNumber'] ?? $u['phone'] ?? '');
                if (!$phone) continue;

                $user = User::firstOrCreate(
                    ['phone_number' => $phone],
                    [
                        'name' => $u['displayName'] ?? $u['name'] ?? 'User ' . substr($phone, -4),
                        'cluster_id' => $cluster->id,
                        'role' => $u['role'] ?? 'buyer',
                        'consent_at' => $u['consent_at'] ?? null,
                        'tos_accepted_at' => $u['tos_accepted_at'] ?? null,
                    ]
                );
                $uidToUserId[$u['uid']] = $user->id;
                $this->info("   ✅ User: {$user->name} ({$user->phone})");
            }

            // 4. Import Campaigns (dulu products)
            $this->info('📥 Import campaigns (products)...');
            $firebasePidToCampaignId = [];

            foreach ($json['products'] as $p) {
                $initiatorId = $uidToUserId[$p['initiatorId']] ?? null;
                if (!$initiatorId) {
                    $this->warn("   ⚠️ Initiator tidak ditemukan untuk product: {$p['name']}");
                    continue;
                }

                $slug = Str::slug($p['name']) . '-' . Str::random(6);
                $campaign = Campaign::create([
                    'cluster_id' => $cluster->id,
                    'initiator_id' => $initiatorId,
                    'slug' => $slug,
                    'name' => $p['name'],
                    'description' => $p['description'] ?? null,
                    'target_kg' => $p['targetKg'] ?? 1000,
                    'current_kg' => $p['currentKg'] ?? 0,
                    'price_total_supplier' => $p['priceTotalSupplier'] ?? 0,
                    'deadline' => $p['deadline'] ?? now()->addDays(2),
                    'status' => $p['status'] ?? 'active',
                    'pickup_location' => $p['pickupLocation'] ?? null,
                    'created_at' => $p['created_at'] ?? now(),
                ]);

                $firebasePidToCampaignId[$p['pid']] = $campaign->id;

                // Import variants
                foreach ($p['variants'] ?? [] as $v) {
                    CampaignVariant::create([
                        'campaign_id' => $campaign->id,
                        'size_kg' => $v['size'] ?? $v['size_kg'] ?? 5,
                        'price' => $v['price'] ?? 60000,
                        'quota' => $v['quota'] ?? 100,
                        'sold' => $v['sold'] ?? 0,
                    ]);
                }

                $this->info("   ✅ Campaign: {$campaign->name} (ID: {$campaign->id})");
            }

            // 5. Import Orders
            $this->info('📥 Import orders...');
            foreach ($json['orders'] as $o) {
                $campaignId = $firebasePidToCampaignId[$o['productId']] ?? null;
                if (!$campaignId) {
                    $this->warn("   ⚠️ Campaign tidak ditemukan untuk order: {$o['oid']}");
                    continue;
                }

                $userId = $uidToUserId[$o['userId']] ?? null;
                if (!$userId) {
                    $this->warn("   ⚠️ User tidak ditemukan untuk order: {$o['oid']}");
                    continue;
                }

                $variant = CampaignVariant::where('campaign_id', $campaignId)
                    ->where('size_kg', $o['variantSize'] ?? 5)
                    ->first();

                if (!$variant) {
                    $this->warn("   ⚠️ Varian tidak ditemukan untuk order: {$o['oid']}");
                    continue;
                }

                $order = Order::create([
                    'uuid' => Str::uuid(),
                    'cluster_id' => $cluster->id,
                    'campaign_id' => $campaignId,
                    'campaign_variant_id' => $variant->id,
                    'user_id' => $userId,
                    'quantity' => $o['quantity'] ?? 1,
                    'total_kg' => ($o['variantSize'] ?? 5) * ($o['quantity'] ?? 1),
                    'total_price' => $o['totalPrice'] ?? 0,
                    'payment_method' => $o['paymentMethod'] ?? 'cash',
                    'payment_status' => $o['paymentStatus'] ?? 'pending',
                    'created_at' => $o['created_at'] ?? now(),
                ]);

                $this->info("   ✅ Order: {$order->uuid}");

                // Import transactions jika ada (sebagai transaction_logs)
                foreach ($json['transactions'] ?? [] as $t) {
                    if ($t['orderId'] !== $o['oid']) continue;

                    TransactionLog::create([
                        'order_id' => $order->id,
                        'initiator_id' => $userId,
                        'type' => $t['type'] ?? 'validation',
                        'notes' => $t['notes'] ?? null,
                        'ip_address' => $t['ip_address'] ?? '127.0.0.1',
                        'created_at' => $t['created_at'] ?? now(),
                    ]);
                }
            }
        });

        $this->info('✅ Import selesai!');
        $this->table(
            ['Tabel', 'Jumlah'],
            [
                ['Cluster', Cluster::count()],
                ['User', User::count()],
                ['Campaign', Campaign::count()],
                ['Campaign Variant', CampaignVariant::count()],
                ['Order', Order::count()],
                ['Transaction Log', TransactionLog::count()],
            ]
        );

        return self::SUCCESS;
    }

    private function normalizePhone(?string $phone): ?string
    {
        if (!$phone) return null;
        $phone = preg_replace('/[\s\-+]/', '', $phone);
        if (str_starts_with($phone, '08')) {
            $phone = '628' . substr($phone, 2);
        }
        if (str_starts_with($phone, '8')) {
            $phone = '628' . $phone;
        }
        if (!str_starts_with($phone, '62')) {
            $phone = '62' . $phone;
        }
        return $phone;
    }
}
```

#### Menjalankan Import

```bash
# Di lingkungan Docker
docker compose exec app php artisan firebase:import \
  --file=storage/app/firebase-export.json \
  --cluster=PGH-RT03

# Native
cd backend
php artisan firebase:import --file=storage/app/firebase-export.json --cluster=PGH-RT03
```

#### Verifikasi

```bash
docker compose exec app php artisan tinker
```

```php
// Cek jumlah data
Cluster::count();      // Harus 1 (PGH-RT03)
User::count();         // Sesuai dengan jumlah user di Firebase
Campaign::count();     // Sesuai dengan jumlah products di Firebase
Order::count();        // Sesuai dengan jumlah orders di Firebase

// Cek tidak ada oversell
$variants = CampaignVariant::all();
foreach ($variants as $v) {
    $soldCheck = Order::where('campaign_variant_id', $v->id)
        ->where('payment_status', 'paid')
        ->sum('quantity');
    if ($v->sold != $soldCheck) {
        echo "⚠️ Oversell deteksi pada variant {$v->id}: sold={$v->sold}, actual={$soldCheck}\n";
    }
}

// Cek cluster_id konsisten
User::whereNull('cluster_id')->count();  // Harus 0
Campaign::whereNull('cluster_id')->count(); // Harus 0
```

### 3.3 Excel Manual → MySQL Bulk Create

#### Tujuan

Mengimpor data pesanan dari Excel yang dikelola Pak RT untuk warga yang tidak memiliki HP Android. Proses ini menggunakan `OrderService` yang sudah memiliki `lockForUpdate` sehingga **zero oversell** terjamin.

#### Format Excel

**File:** `storage/app/fallback-excel.xlsx`

| name     | phone        | variant_size | quantity | payment_method | cluster_code |
| -------- | ------------ | ------------ | -------- | -------------- | ------------ |
| Bu Mimin | 081234567892 | 5            | 1        | cash           | PGH-RT03     |
| Pak Joko | 081234567893 | 10           | 2        | cash           | PGH-RT03     |

#### Artisan Command: ExcelImportOrdersCommand

**File:** `app/Console/Commands/ExcelImportOrdersCommand.php`

```php
<?php

namespace App\Console\Commands;

use App\Models\Campaign;
use App\Models\Cluster;
use App\Models\User;
use App\Services\OrderService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\IOFactory;

class ExcelImportOrdersCommand extends Command
{
    protected $signature = 'orders:import-excel
                            {--file=storage/app/fallback-excel.xlsx : Path ke file Excel}
                            {--campaign= : ID campaign tujuan (wajib)}';

    protected $description = 'Import orders dari Excel untuk warga tanpa HP';

    public function handle(OrderService $orderService): int
    {
        $filePath = $this->option('file');
        $campaignId = $this->option('campaign');

        if (!file_exists($filePath)) {
            $this->error("File tidak ditemukan: $filePath");
            return self::FAILURE;
        }

        if (!$campaignId) {
            $this->error('Parameter --campaign wajib diisi');
            return self::FAILURE;
        }

        $campaign = Campaign::find($campaignId);
        if (!$campaign) {
            $this->error("Campaign ID $campaignId tidak ditemukan");
            return self::FAILURE;
        }

        $this->info("📦 Import Excel ke campaign: {$campaign->name} (ID: {$campaign->id})");

        // Load Excel
        $spreadsheet = IOFactory::load($filePath);
        $rows = $spreadsheet->getActiveSheet()->toArray();

        if (count($rows) < 2) {
            $this->error('Excel kosong');
            return self::FAILURE;
        }

        $headers = array_shift($rows); // Hapus header
        $this->info("📊 Menemukan " . count($rows) . " baris data");

        $successCount = 0;
        $failCount = 0;
        $failedRows = [];

        DB::transaction(function () use ($rows, $campaign, $orderService, &$successCount, &$failCount, &$failedRows) {
            foreach ($rows as $index => $row) {
                try {
                    // Parse row
                    $name = trim($row[0] ?? '');
                    $phone = $this->normalizePhone(trim($row[1] ?? ''));
                    $variantSize = (float) ($row[2] ?? 5);
                    $quantity = (int) ($row[3] ?? 1);
                    $paymentMethod = trim($row[4] ?? 'cash');
                    $clusterCode = trim($row[5] ?? 'PGH-RT03');

                    if (!$name || !$phone) {
                        throw new \Exception("Nama atau nomor HP kosong di baris " . ($index + 2));
                    }

                    // Dapatkan cluster
                    $cluster = Cluster::where('code', $clusterCode)->first();
                    if (!$cluster) {
                        throw new \Exception("Cluster $clusterCode tidak ditemukan");
                    }

                    // Buat user jika belum ada
                    $user = User::firstOrCreate(
                        ['phone_number' => $phone],
                        [
                            'name' => $name,
                            'cluster_id' => $cluster->id,
                            'role' => 'buyer',
                            'consent_at' => now(),
                            'tos_accepted_at' => now(),
                        ]
                    );

                    // Dapatkan variant
                    $variant = $campaign->variants()
                        ->where('size_kg', $variantSize)
                        ->first();

                    if (!$variant) {
                        throw new \Exception("Varian {$variantSize}Kg tidak ditemukan di campaign ini");
                    }

                    // Gunakan OrderService (dengan lockForUpdate)
                    $order = $orderService->create(
                        $campaign,
                        [
                            'variant_id' => $variant->id,
                            'quantity' => $quantity,
                            'payment_method' => $paymentMethod,
                            'on_behalf_name' => $name,
                        ],
                        $user
                    );

                    $successCount++;
                    $this->info("   ✅ Order berhasil: {$user->name} - {$variantSize}Kg x{$quantity}");

                } catch (\Exception $e) {
                    $failCount++;
                    $failedRows[] = [
                        'row' => $index + 2,
                        'error' => $e->getMessage(),
                    ];
                    $this->warn("   ⚠️ Gagal di baris " . ($index + 2) . ": {$e->getMessage()}");
                }
            }
        });

        $this->info('');
        $this->info('📊 Ringkasan Import:');
        $this->table(
            ['Status', 'Jumlah'],
            [
                ['Berhasil', $successCount],
                ['Gagal', $failCount],
            ]
        );

        if (!empty($failedRows)) {
            $this->warn('⚠️ Baris yang gagal:');
            $this->table(['Baris', 'Error'], $failedRows);
        }

        return self::SUCCESS;
    }

    private function normalizePhone(?string $phone): ?string
    {
        if (!$phone) return null;
        $phone = preg_replace('/[\s\-+]/', '', $phone);
        if (str_starts_with($phone, '08')) {
            $phone = '628' . substr($phone, 2);
        }
        if (str_starts_with($phone, '8')) {
            $phone = '628' . $phone;
        }
        if (!str_starts_with($phone, '62')) {
            $phone = '62' . $phone;
        }
        return $phone;
    }
}
```

#### Install Dependency

```bash
composer require phpoffice/phpspreadsheet
```

#### Menjalankan Import

```bash
# Di lingkungan Docker
docker compose exec app php artisan orders:import-excel \
  --file=storage/app/fallback-excel.xlsx \
  --campaign=12

# Native
cd backend
php artisan orders:import-excel --file=storage/app/fallback-excel.xlsx --campaign=12
```

#### Verifikasi

```bash
php artisan tinker
```

```php
// Cek order yang baru diimport
$campaign = Campaign::find(12);
$orders = $campaign->orders()->whereNotNull('on_behalf_name')->get();
echo "Total order on-behalf: " . $orders->count() . "\n";

// Cek tidak ada oversell
$variants = $campaign->variants;
foreach ($variants as $v) {
    $sold = Order::where('campaign_variant_id', $v->id)
        ->where('payment_status', 'paid')
        ->sum('quantity');
    echo "Variant {$v->size_kg}Kg: sold={$sold}, quota={$v->quota}\n";
}
```

### 3.4 Local Storage → S3 Migration

#### Tujuan

Memindahkan file gambar dari local storage (`storage/app/public/`) ke S3 private bucket sesuai dengan keputusan arsitektur S3 Primary (ADR-003).

#### Artisan Command: S3MigrateCommand

**File:** `app/Console/Commands/S3MigrateCommand.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class S3MigrateCommand extends Command
{
    protected $signature = 'storage:s3-migrate
                            {--dry-run : Jalankan tanpa benar-benar upload}';

    protected $description = 'Migrasi file dari local storage ke S3';

    public function handle(): int
    {
        $dryRun = $this->option('dry-run');

        if ($dryRun) {
            $this->warn('⚠️ DRY RUN MODE - Tidak ada file yang akan diupload');
        }

        $diskLocal = Storage::disk('public');
        $diskS3 = Storage::disk('s3');

        // Cek koneksi S3
        try {
            $diskS3->put('test-connection.txt', 'test');
            $diskS3->delete('test-connection.txt');
            $this->info('✅ Koneksi S3 berhasil');
        } catch (\Exception $e) {
            $this->error('❌ Koneksi S3 gagal: ' . $e->getMessage());
            return self::FAILURE;
        }

        $directories = [
            'campaigns' => 'Campaign images',
            'order_proofs' => 'Order proofs',
        ];

        $totalFiles = 0;
        $migratedFiles = 0;

        foreach ($directories as $dir => $label) {
            if (!$diskLocal->exists($dir)) {
                $this->warn("⚠️ Directory local $dir tidak ditemukan, skip");
                continue;
            }

            $files = $diskLocal->files($dir);
            $totalFiles += count($files);

            $this->info("📁 $label: " . count($files) . " file ditemukan");

            foreach ($files as $file) {
                $content = $diskLocal->get($file);
                $this->info("   📤 Migrating: $file (" . number_format(strlen($content) / 1024, 1) . " KB)");

                if (!$dryRun) {
                    try {
                        $diskS3->put($file, $content);
                        $migratedFiles++;
                        $this->info("   ✅ $file berhasil");
                    } catch (\Exception $e) {
                        $this->error("   ❌ Gagal migrate $file: " . $e->getMessage());
                    }
                } else {
                    $this->info("   [DRY RUN] Akan upload: $file");
                }
            }
        }

        $this->info('');
        $this->info('📊 Ringkasan:');
        $this->table(
            ['Status', 'Jumlah'],
            [
                ['Total file ditemukan', $totalFiles],
                ['Berhasil dimigrasi', $migratedFiles],
                ['Gagal', $totalFiles - $migratedFiles],
            ]
        );

        if (!$dryRun && $migratedFiles > 0) {
            $this->info('');
            $this->info('✅ Migrasi selesai!');
            $this->warn('⚠️ Jangan lupa set FILESYSTEM_DISK=s3 di .env.prod');
            $this->info('🔍 Verifikasi di S3 console: ' . Storage::disk('s3')->url(''));
        }

        return self::SUCCESS;
    }
}
```

#### Menjalankan Migrasi

```bash
# Dry run terlebih dahulu
docker compose exec app php artisan storage:s3-migrate --dry-run

# Jika sudah yakin, jalankan
docker compose exec app php artisan storage:s3-migrate
```

#### Verifikasi di S3

```bash
php artisan tinker
```

```php
// Cek file di S3
$files = Storage::disk('s3')->files('campaigns');
echo "Total campaign files: " . count($files) . "\n";

// Cek tempUrl berfungsi
$path = $files[0] ?? null;
if ($path) {
    $url = Storage::disk('s3')->temporaryUrl($path, now()->addHour());
    echo "TempUrl: $url\n";
}

// Bandingkan dengan local
$localFiles = Storage::disk('public')->files('campaigns');
echo "Local campaign files: " . count($localFiles) . "\n";
```

#### Update Environment

```ini
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=ap-southeast-1
AWS_BUCKET=grosirun-prod-private
AWS_USE_PATH_STYLE_ENDPOINT=false
```

### 3.5 Rollback Plan

#### Backup Sebelum Migrasi

```bash
# Backup database
php artisan backup:run --only-db

# Backup file local (jika ada)
tar -czf storage/backups/local-storage-$(date +%Y%m%d).tar.gz storage/app/public/
```

#### Rollback Firebase Import

```bash
# 1. Rollback migrasi terakhir
php artisan migrate:rollback --step=1

# 2. Restore database dari backup
php artisan backup:restore

# 3. Atau manual MySQL
mysql -u grosirun -p grosirun < storage/backups/latest.sql
```

#### Rollback Excel Import

```bash
php artisan tinker
```

```php
$campaign = Campaign::find(12);
$orders = $campaign->orders()->whereNotNull('on_behalf_name')->get();
foreach ($orders as $order) {
    // Restore quota
    $variant = $order->variant;
    $variant->decrement('sold', $order->quantity);
    $order->delete();
}
echo "Deleted " . count($orders) . " orders\n";
```

#### Rollback S3 Migration

```bash
php artisan tinker
```

```php
// Hapus file dari S3
Storage::disk('s3')->deleteDirectory('campaigns');
Storage::disk('s3')->deleteDirectory('order_proofs');

// S3 Versioning ON, bisa restore versi sebelumnya
// Atau copy dari local backup
$diskLocal = Storage::disk('public');
$diskS3 = Storage::disk('s3');

foreach ($diskLocal->files('campaigns') as $file) {
    $diskS3->put($file, $diskLocal->get($file));
}
```

### 3.6 Checklist Migration PR

#### Pra-Migrasi

- [ ] Backup database: `php artisan backup:run --only-db`
- [ ] Backup local storage: `tar -czf storage/backups/local-storage-*.tar.gz storage/app/public/`
- [ ] Firebase export JSON tersedia di `storage/app/firebase-export.json`
- [ ] Excel fallback tersedia di `storage/app/fallback-excel.xlsx`
- [ ] Cluster default PGH-RT03 sudah ada di database
- [ ] S3 bucket sudah dibuat dan credentials valid

#### Firebase Import

- [ ] `php artisan firebase:import --dry-run` (simulasi)
- [ ] `php artisan firebase:import` (aktual)
- [ ] Verifikasi jumlah: Cluster=1, User, Campaign, Order
- [ ] Tidak ada oversell: variant.sold <= variant.quota
- [ ] Cluster_id tidak null untuk semua user dan campaign
- [ ] Log error di `storage/logs/import-failed.log` kosong

#### Excel Import

- [ ] `composer require phpoffice/phpspreadsheet` sudah diinstall
- [ ] Campaign ID target sudah diketahui
- [ ] `php artisan orders:import-excel --campaign=12 --dry-run`
- [ ] `php artisan orders:import-excel --campaign=12`
- [ ] Verifikasi semua order on-behalf tersimpan
- [ ] Tidak ada oversell (lockForUpdate)

#### S3 Migration

- [ ] S3 credentials di `.env` valid
- [ ] `php artisan storage:s3-migrate --dry-run`
- [ ] `php artisan storage:s3-migrate`
- [ ] Verifikasi file di S3 console
- [ ] TempUrl berfungsi: `Storage::disk('s3')->temporaryUrl(...)`
- [ ] Update `.env.prod` FILESYSTEM_DISK=s3
- [ ] Restart queue worker: `supervisorctl restart grosirun-worker:*`

#### Post-Migrasi

- [ ] Test login OTP dengan user lama (Firebase)
- [ ] Test lihat campaign lama
- [ ] Test lihat order lama di My Orders
- [ ] Test upload proof baru ke S3
- [ ] Test S3 lifecycle 90d (simulasi dengan CleanOldProofsJob)
- [ ] Update dokumentasi: DATABASE_MIGRATION_GUIDE.md, DATABASE_DESIGN.md
- [ ] Update CHANGELOG.md

---

## 4. Panduan Migrasi Database

### 4.1 Filosofi Migrasi

| Aturan                         | Keterangan                                                                                                            |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| **Migration File**             | Setiap perubahan skema harus via migration file baru, jangan edit migration lama yang sudah merge ke `main`/`develop` |
| **Timestamp Order**            | `2026_07_20_000001_create_clusters_table.php` menentukan urutan dependency (clusters harus dibuat sebelum users)      |
| **Idempotent**                 | Migration harus bisa dijalankan berulang kali tanpa error                                                             |
| **Reversible**                 | Setiap migration harus memiliki `up()` dan `down()`                                                                   |
| **Additive Only (Blue-Green)** | Untuk zero-downtime, migration di production hanya boleh menambah (tidak menghapus/rename) dalam satu deploy          |
| **No DROP tanpa Check**        | Jangan gunakan `DB::statement('DROP ...')` tanpa pemeriksaan kondisi                                                  |

#### Blue-Green Safe Migration Principle

```
┌─────────────────────────────────────────────────────────────────┐
│                    Blue-Green Deployment                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  OLD Code (Blue)   │   NEW Code (Green)   │   NEW DB Schema    │
│  ───────────────────────────────────────────────────────────────│
│  Phase 1: ADD column (nullable)                                │
│    Old code: ignore new column (fine)                         │
│    New code: write to both old + new (dual-write)             │
│                                                                 │
│  Phase 2: BACKFILL + SWITCH READ                              │
│    Backfill: UPDATE table SET new_col = old_col               │
│    New code: read from new column                              │
│    Old code: still reads old column (still exists)            │
│                                                                 │
│  Phase 3: DROP old column (separate deploy)                   │
│    New code: only uses new column                              │
│    Old code: no longer used                                    │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Cara Membuat Migrasi Baru

#### Generate Migration

```bash
cd backend

# Migration untuk menambah kolom
php artisan make:migration add_cluster_id_to_users_table --table=users

# Migration untuk membuat tabel baru
php artisan make:migration create_notifications_table

# Migration untuk menambah indeks
php artisan make:migration add_index_cluster_status_deadline_to_campaigns_table --table=campaigns
```

#### Contoh Migration: Add Cluster ID ke Users

**File:** `database/migrations/2026_07_21_000001_add_cluster_id_to_users_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Jalankan migrasi.
     * ADDITIVE ONLY - safe untuk blue-green.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Tambah kolom cluster_id (nullable untuk backward compat)
            $table->foreignId('cluster_id')
                ->nullable()
                ->constrained('clusters')
                ->nullOnDelete()
                ->after('id');

            // Tambah indeks composite untuk query role per cluster
            $table->index(['cluster_id', 'role'], 'idx_users_cluster_role');
        });
    }

    /**
     * Rollback migrasi.
     * Safe - tidak ada data loss karena kolom nullable.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['cluster_id']);
            $table->dropIndex('idx_users_cluster_role');
            $table->dropColumn('cluster_id');
        });
    }
};
```

#### Contoh Migration: Tabel Notifications

**File:** `database/migrations/2026_07_20_000008_create_notifications_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('cluster_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title', 150);
            $table->string('body', 255);
            $table->json('data')->nullable();
            $table->datetime('read_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'read_at'], 'idx_notifications_user_read');
            $table->index('cluster_id', 'idx_notifications_cluster');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
```

#### Menjalankan Migrasi

```bash
# Jalankan semua migrasi yang pending
php artisan migrate

# Cek status migrasi
php artisan migrate:status

# Refresh database (DEV ONLY - jangan di production!)
php artisan migrate:fresh --seed

# Refresh dengan seeder tertentu
php artisan migrate:fresh --seeder=PilotSeeder
```

#### Testing Rollback

```bash
# Rollback 1 langkah
php artisan migrate:rollback --step=1

# Rollback semua migrasi di batch terakhir
php artisan migrate:rollback

# Jalankan migrasi lagi (verifikasi)
php artisan migrate
```

### 4.3 Strategi Rollback yang Aman

#### Jenis Migration & Keamanan Rollback

| Jenis Migration                                  | Safe Rollback?            | Prosedur                               | Risiko                     |
| ------------------------------------------------ | ------------------------- | -------------------------------------- | -------------------------- |
| **Add table** (clusters, notifications)          | ✅ Safe                   | `migrate:rollback --step=1` drop table | Tidak ada data loss        |
| **Add nullable column** (cluster_id, consent_at) | ✅ Safe                   | Rollback drop column                   | Tidak ada data loss        |
| **Add non-nullable column with default**         | ✅ Safe (dengan default)  | Rollback drop column                   | Data aman jika ada default |
| **Add index**                                    | ✅ Safe                   | Drop index                             | Tidak ada data loss        |
| **Add FK constraint**                            | ✅ Safe                   | Drop foreign key                       | Data aman                  |
| **Drop column**                                  | ❌ **Unsafe - Data Loss** | Harus 2-phase expand-contract          | Data hilang permanen       |
| **Rename column**                                | ❌ **Unsafe**             | Harus 2-phase expand-contract          | Data hilang jika salah     |
| **Change column type**                           | ⚠️ Risky                  | Add new column, backfill, switch       | Data bisa corrupt          |
| **Drop table**                                   | ❌ **Unsafe**             | Backup dulu, lalu drop                 | Semua data hilang          |

#### Perintah Rollback

```bash
# Rollback 1 migration terakhir
php artisan migrate:rollback --step=1

# Rollback semua migration di batch terakhir
php artisan migrate:rollback

# Rollback sampai migration tertentu (tidak built-in, pakai --step)
# Hitung jumlah langkah dari target ke sekarang
php artisan migrate:rollback --step=5
```

#### Restore dari Backup (Jika Data Loss)

```bash
# Backup menggunakan Spatie
php artisan backup:run --only-db

# Restore dari backup
php artisan backup:restore

# Atau manual MySQL
mysql -u grosirun -p grosirun < /path/to/backup-2026-07-20.sql

# Jika backup di S3
aws s3 cp s3://grosirun-prod-private/backups/latest.sql.gz .
gunzip latest.sql.gz
mysql -u grosirun -p grosirun < latest.sql
```

#### Production Rollback Plan

| Langkah | Action                       | Keterangan                                                               |
| ------- | ---------------------------- | ------------------------------------------------------------------------ |
| **1**   | Backup database              | `php artisan backup:run --only-db` ke S3 `backups/pre-deploy-v1.0.0.zip` |
| **2**   | Deploy green                 | Migration additive only, health check temp port 8001                     |
| **3**   | Switch symlink               | `ln -nfs /var/www/grosirun/green /var/www/grosirun/current`              |
| **4**   | Jika health check gagal      | `./rollback.sh` otomatis switch ke blue                                  |
| **5**   | Jika data loss (drop column) | Restore dari backup S3 + replay transaction_logs (manual)                |
| **6**   | Investigasi root cause       | Cek log, perbaiki migration, deploy ulang                                |

**Golden Rule:** Jangan pernah melakukan `DROP COLUMN` atau `RENAME COLUMN` dalam satu deploy. Selalu gunakan Expand-Contract Pattern (lihat Section 4.5).

### 4.4 Seed & Factory

#### Factory

```bash
php artisan make:factory ClusterFactory
php artisan make:factory CampaignFactory
php artisan make:factory CampaignVariantFactory
php artisan make:factory OrderFactory
```

**Contoh Factory:**

```php
// database/factories/ClusterFactory.php
<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class ClusterFactory extends Factory
{
    public function definition(): array
    {
        return [
            'code' => 'PGH-RT' . $this->faker->unique()->numberBetween(1, 10),
            'name' => 'Permata Hijau RT' . $this->faker->numberBetween(1, 10),
            'rw' => $this->faker->numberBetween(1, 5),
            'kelurahan' => $this->faker->city(),
            'city' => 'Mojokerto',
        ];
    }
}
```

**Factory untuk Campaign dengan Variants:**

```php
// database/factories/CampaignFactory.php
class CampaignFactory extends Factory
{
    public function definition(): array
    {
        return [
            'cluster_id' => Cluster::factory(),
            'initiator_id' => User::factory()->initiator(),
            'slug' => $this->faker->slug(3) . '-' . Str::random(6),
            'name' => $this->faker->sentence(3),
            'description' => $this->faker->paragraph(),
            'target_kg' => 1000,
            'current_kg' => 0,
            'price_total_supplier' => 10000000,
            'deadline' => now()->addDays(2),
            'status' => 'active',
        ];
    }

    public function withVariants(): static
    {
        return $this->afterCreating(function (Campaign $campaign) {
            $campaign->variants()->createMany([
                ['size_kg' => 5, 'price' => 60000, 'quota' => 100],
                ['size_kg' => 10, 'price' => 115000, 'quota' => 50],
            ]);
        });
    }
}
```

#### Seeder

**DatabaseSeeder:**

```php
// database/seeders/DatabaseSeeder.php
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            ClusterSeeder::class,      // Buat cluster default PGH-RT03
            UserSeeder::class,         // 1 initiator + 50 buyers
            CampaignSeeder::class,     // 2 campaign aktif
        ]);
    }
}
```

**PilotSeeder (untuk Load Test):**

```php
// database/seeders/PilotSeeder.php
class PilotSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Cluster PGH-RT03
        $cluster = Cluster::create([
            'code' => 'PGH-RT03',
            'name' => 'Permata Hijau RT03',
            'rw' => '03',
            'kelurahan' => 'Ngoro',
            'city' => 'Mojokerto',
        ]);

        // 2. Initiator
        $initiator = User::create([
            'cluster_id' => $cluster->id,
            'name' => 'Pak Agus Setiawan',
            'phone_number' => '6281234567890',
            'role' => 'initiator',
            'consent_at' => now(),
            'tos_accepted_at' => now(),
        ]);

        // 3. 50 Buyers
        User::factory(50)->create([
            'cluster_id' => $cluster->id,
            'role' => 'buyer',
        ]);

        // 4. 2 Campaigns with variants
        $campaign1 = Campaign::factory()
            ->withVariants()
            ->create([
                'cluster_id' => $cluster->id,
                'initiator_id' => $initiator->id,
                'name' => 'Beras Mahkota Premium',
                'target_kg' => 1000,
                'deadline' => now()->addDays(2),
            ]);

        $campaign2 = Campaign::factory()
            ->withVariants()
            ->create([
                'cluster_id' => $cluster->id,
                'initiator_id' => $initiator->id,
                'name' => 'Gula Pasir Rajawali',
                'target_kg' => 500,
                'deadline' => now()->addDays(3),
            ]);

        // 5. 100 Orders
        Order::factory(100)->create([
            'cluster_id' => $cluster->id,
            'campaign_id' => $campaign1->id,
        ]);
    }
}
```

#### Menjalankan Seeder

```bash
# Jalankan semua seeder
php artisan db:seed

# Jalankan seeder tertentu
php artisan db:seed --class=PilotSeeder

# Refresh dan seed (DEV ONLY!)
php artisan migrate:fresh --seed

# 🚨 NEVER di production!
php artisan migrate:fresh --seed  # JANGAN di production!
```

### 4.5 Expand-Contract Pattern (Safe untuk Blue-Green)

#### Masalah

Blue-green zero-downtime membutuhkan old code (blue) dan new code (green) berjalan bersama dengan database yang sama selama proses deploy. Jika migration langsung menghapus kolom, old code akan error karena kolom tidak ditemukan.

#### Solusi: 3-Phase Expand-Contract

**Contoh: Rename `price_total_supplier` → `supplier_total_price`**

**Phase 1 - Expand (Deploy 1 - Additive)**

**Migration 1:**

```php
// database/migrations/2026_08_01_000001_add_supplier_total_price_to_campaigns.php
public function up(): void
{
    Schema::table('campaigns', function (Blueprint $table) {
        // Tambah kolom baru (nullable)
        $table->bigInteger('supplier_total_price')
            ->nullable()
            ->after('price_total_supplier');
    });
}

public function down(): void
{
    Schema::table('campaigns', function (Blueprint $table) {
        $table->dropColumn('supplier_total_price');
    });
}
```

**Code V1.0 (Old):**

```php
// Hanya baca/tulis price_total_supplier
$campaign->price_total_supplier = 10000000;
```

**Code V1.1 (New):**

```php
// Dual-write: tulis ke kedua kolom
$campaign->price_total_supplier = 10000000;
$campaign->supplier_total_price = 10000000;

// Baca dari old kolom (backward compat)
$total = $campaign->price_total_supplier;
```

**Deploy:** Blue (V1.0) + Green (V1.1) berjalan bersama. Migration additive hanya menambah kolom, tidak menghapus. **Aman.**

---

**Phase 2 - Migrate (Deploy 2 - Backfill + Switch Read)**

**Migration 2 (Backfill):**

```php
// database/migrations/2026_08_15_000001_backfill_supplier_total_price.php
public function up(): void
{
    // Backfill data dari old ke new
    DB::table('campaigns')
        ->whereNull('supplier_total_price')
        ->update([
            'supplier_total_price' => DB::raw('price_total_supplier')
        ]);
}

public function down(): void
{
    // Reset ke null (opsional)
    DB::table('campaigns')->update(['supplier_total_price' => null]);
}
```

**Code V1.2 (New):**

```php
// Switch read ke new column
$total = $campaign->supplier_total_price;

// Tetap dual-write untuk backward compat
$campaign->price_total_supplier = 10000000;
$campaign->supplier_total_price = 10000000;
```

**Deploy:** Green sekarang membaca dari new column. Blue masih membaca dari old column. **Keduanya berfungsi.**

---

**Phase 3 - Contract (Deploy 3 - Drop Old Column)**

**Migration 3:**

```php
// database/migrations/2026_09_01_000001_drop_price_total_supplier.php
public function up(): void
{
    Schema::table('campaigns', function (Blueprint $table) {
        $table->dropColumn('price_total_supplier');
    });
}

public function down(): void
{
    Schema::table('campaigns', function (Blueprint $table) {
        $table->bigInteger('price_total_supplier')->nullable();
    });
}
```

**Code V1.3 (New):**

```php
// Hanya baca/tulis new column
$campaign->supplier_total_price = 10000000;
$total = $campaign->supplier_total_price;
// price_total_supplier sudah tidak digunakan
```

**Deploy:** Old code sudah tidak digunakan (semua sudah V1.3). **Aman.**

---

#### Ringkasan 3-Phase

| Phase                 | Migrasi                   | Code Change                      | Deploy   |
| --------------------- | ------------------------- | -------------------------------- | -------- |
| **Phase 1: Expand**   | Add new column (nullable) | Dual-write (old + new), read old | Deploy 1 |
| **Phase 2: Migrate**  | Backfill data             | Read new, dual-write             | Deploy 2 |
| **Phase 3: Contract** | Drop old column           | Read/write new only              | Deploy 3 |

#### Aplikasi untuk Skenario Lain

| Operasi          | Phase 1                                                      | Phase 2                | Phase 3         |
| ---------------- | ------------------------------------------------------------ | ---------------------- | --------------- |
| **Drop column**  | Stop reading/writing old column (code change)                | Drop column            | -               |
| **Change type**  | Add new column new type, dual-write                          | Backfill + switch read | Drop old column |
| **Add NOT NULL** | Add column nullable first, backfill, then change to NOT NULL | -                      | -               |
| **Add FK**       | Add column, backfill data, add FK constraint                 | -                      | -               |

#### Checklist Expand-Contract di PR

- [ ] Phase 1 migration hanya menambah (tidak drop/rename)
- [ ] Code mendukung dual-write jika diperlukan
- [ ] Phase 2 backfill query sudah di-test
- [ ] Phase 3 drop column dilakukan di deploy terpisah
- [ ] Dokumentasi di `DATABASE_MIGRATION_GUIDE.md` diperbarui
- [ ] Rollback tested: `migrate:rollback --step=1` lalu `migrate` berhasil

### 4.6 Migrasi Data Firebase → MySQL (Detail Command)

Sudah dibahas di Section 3.2. Command `firebase:import` dan `orders:import-excel` dijelaskan lengkap di sana.

### 4.7 Migrasi S3 & Cluster

#### Cluster Migration

**Migration:** `2026_07_20_000001_create_clusters_table.php`

```php
// 1. Buat tabel clusters
Schema::create('clusters', function (Blueprint $table) {
    $table->id();
    $table->string('code', 20)->unique();
    $table->string('name', 100);
    $table->string('rw', 10)->nullable();
    $table->string('kelurahan', 50)->nullable();
    $table->string('city', 50)->default('Surabaya');
    $table->timestamps();
});

// 2. Tambah cluster_id ke users
Schema::table('users', function (Blueprint $table) {
    $table->foreignId('cluster_id')
        ->nullable()
        ->constrained('clusters')
        ->nullOnDelete()
        ->after('id');
});

// 3. Tambah cluster_id ke campaigns
Schema::table('campaigns', function (Blueprint $table) {
    $table->foreignId('cluster_id')
        ->constrained('clusters')
        ->cascadeOnDelete()
        ->after('id');
});
```

**Backfill Existing Users:**

```bash
php artisan tinker
```

```php
$defaultCluster = Cluster::where('code', 'PGH-RT03')->first();
User::whereNull('cluster_id')->update(['cluster_id' => $defaultCluster->id]);
Campaign::whereNull('cluster_id')->update(['cluster_id' => $defaultCluster->id]);
```

#### S3 Migration

**Command:** `app/Console/Commands/S3MigrateCommand.php`

```bash
# Buat command
php artisan make:command S3MigrateCommand

# Dry run (cek dulu)
php artisan storage:s3-migrate --dry-run

# Jalankan migrasi
php artisan storage:s3-migrate
```

Kode command sudah lengkap di Section 3.4.

**Verifikasi:**

```bash
php artisan tinker
```

```php
// Cek file di S3
Storage::disk('s3')->files('campaigns');

// Cek tempUrl
$path = 'campaigns/example.jpg';
$url = Storage::disk('s3')->temporaryUrl($path, now()->addHour());
echo $url;
```

---

## 5. Backup & Disaster Recovery

### 5.1 Backup Strategy

| Komponen        | Frekuensi     | Retention | Lokasi          |
| --------------- | ------------- | --------- | --------------- |
| **Database**    | Daily 02:00   | 7 hari    | S3 `backups/`   |
| **S3 Files**    | Versioning ON | Forever   | S3 bucket       |
| **Source Code** | Tag vX.Y.Z    | Forever   | GitHub          |
| **Secrets**     | Manual        | Forever   | 1Password Vault |

### 5.2 Backup Command

```bash
# Spatie Backup
php artisan backup:run --only-db

# Restore
php artisan backup:restore

# Manual MySQL
mysql -u grosirun -p grosirun < storage/backups/latest.sql
```

### 5.3 Disaster Scenarios & RTO

| Disaster          | Recovery                                        | Est. Time |
| ----------------- | ----------------------------------------------- | --------- |
| VPS total down    | Spin new VPS, restore DB from S3 backup, deploy | 45 menit  |
| MySQL corrupted   | Restore from latest S3 backup                   | 30 menit  |
| S3 bucket deleted | Restore from versioning                         | 20 menit  |
| Redis down        | Restart container, retry queue jobs             | 5 menit   |

### 5.4 Disaster Recovery Drill

**RTO Target:** 1 jam  
**RPO Target:** 24 jam

**Drill Procedure (Pre-Pilot):**

1. Spin new VPS staging
2. Download latest backup from S3
3. Restore database
4. Deploy Docker stack
5. Health check 200
6. Test login OTP, create campaign, order, proof upload
7. Measure time → target <1 jam

---

## 6. Lampiran

### 6.1 Troubleshooting

#### Firebase Import Gagal

| Masalah                     | Solusi                                                            |
| --------------------------- | ----------------------------------------------------------------- |
| `JSON tidak valid`          | Cek format JSON di `storage/app/firebase-export.json`             |
| `Duplicate phone_number`    | Cek `normalizePhone()` sudah benar, atau hapus duplikat           |
| `Initiator tidak ditemukan` | Cek mapping uid → phone di Firebase users                         |
| `Oversell detected`         | Cek data orders, mungkin ada order yang tidak valid               |
| `Memory exhausted`          | Jalankan dengan `php artisan firebase:import --memory-limit=512M` |

#### Excel Import Gagal

| Masalah                    | Solusi                                                |
| -------------------------- | ----------------------------------------------------- |
| `File tidak ditemukan`     | Pastikan path file benar                              |
| `Campaign tidak ditemukan` | Cek ID campaign dengan `Campaign::pluck('id','name')` |
| `Varian tidak ditemukan`   | Cek variant size di campaign                          |
| `Duplicate phone`          | User sudah ada, akan di-skip (firstOrCreate)          |

#### S3 Migration Gagal

| Masalah                   | Solusi                                   |
| ------------------------- | ---------------------------------------- |
| `Koneksi S3 gagal`        | Cek AWS credentials, endpoint, region    |
| `Permission denied`       | Cek IAM policy untuk bucket              |
| `File tidak ditemukan`    | Pastikan file di `storage/app/public/`   |
| `TempUrl tidak berfungsi` | Cek bucket policy, IAM, dan waktu expiry |

### 6.2 Perintah Penting

| Keperluan          | Command                                                        |
| ------------------ | -------------------------------------------------------------- |
| Buat migration     | `php artisan make:migration nama_migration --table=table_name` |
| Jalankan migration | `php artisan migrate`                                          |
| Cek status         | `php artisan migrate:status`                                   |
| Rollback 1 step    | `php artisan migrate:rollback --step=1`                        |
| Refresh (DEV)      | `php artisan migrate:fresh --seed`                             |
| Buat factory       | `php artisan make:factory NamaFactory`                         |
| Buat seeder        | `php artisan make:seeder NamaSeeder`                           |
| Jalankan seeder    | `php artisan db:seed --class=NamaSeeder`                       |
| Import Firebase    | `php artisan firebase:import --file=... --cluster=PGH-RT03`    |
| Migrasi S3         | `php artisan storage:s3-migrate`                               |
| Backup DB          | `php artisan backup:run --only-db`                             |
| Restore DB         | `php artisan backup:restore`                                   |

---

**Dokumen Database & Migrasi Data V3.1 Production Ready - Desain Lengkap, Rencana Migrasi, Panduan Migrasi, Backup & DR!** 🚀
