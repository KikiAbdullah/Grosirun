# PRODUCT REQUIREMENTS DOCUMENT (PRD) - Grosirun V3.1 Enterprise GAP Closed

**Nama:** Grosirun  
**Stack:** Backend Laravel 11 (REST API) + Frontend Flutter 3.22+ + Web Admin V1.1 (Livewire/Inertia)  
**Target:** APK `<10 MB` arm64, Coverage >75%, Crash-free >99.5%  
**Fase:** MVP V1.0 + Enterprise Readiness  
**Tanggal:** 20 Juli 2026  
**Versi:** 3.1 GAP Closed  
**Status:** Final Draft

---

## Daftar Isi
1. Ringkasan Eksekutif + Stakeholder Matrix
2. Metrik + MoSCoW + RICE Scoring
3. Persona + UU PDP Consent
4. Ruang Lingkup Fitur + Cluster + Non-Escrow + ToS
5. Alur Pengguna + Flowchart Bisnis BPMN
6. NFR + Storage Strategy S3 Primary + Versioning V2
7. Fase Rilis + Roadmap Visual
8. Mitigasi Risiko + Dispute SOP Ref
9. Daftar Tugas + Dependency Graph
10. Glosarium + Keputusan Final Inkonsistensi

---

## 1. Ringkasan Eksekutif + Stakeholder Matrix

**Visi:** Otak digital ekonomi mikro RT/RW, hilangkan 100% admin manual patungan, taat UU PDP No.27/2022, non-escrow legal.

**Problem Validasi Lapangan 2026:** Harga eceran Rp14k vs grosir Rp11.5k, rekap manual salah 30%, uang titipan Rp5-10jt tercecer, ketua RT burnout 60% berhenti 2 siklus.

**Solusi V3.1:**
- Laravel 11 API ACID + `lockForUpdate()` zero oversell, `clusters` table untuk multi-RT future (gap #2 fixed)
- S3 primary storage prod (gap storage inkonsistensi fixed): VPS tidak penuh, backup + lifecycle 90 hari
- Flutter offline-first Hive + pendingQueue, onboarding Pak Agus + FAQ ibu-ibu
- CI/CD GitHub Actions gate test (gap CI future fixed)

**Stakeholder Matrix:**

| Stakeholder | Role | Kepentingan | Power | Strategi |
| :--- | :--- | :--- | :--- | :--- |
| Bu Siti (Buyer) | End User | Hemat 15-20%, checkout <2 menit | High interest, Low power | Fokus UX tombol 56dp, tutorial 60s, FAQ |
| Pak Agus (Initiator) | Admin | Hemat 80% waktu admin | High interest, High power | Libatkan di dogfooding, SOP onboarding, ToS |
| Ketua RW | Sponsor | Transparansi dana RT | Medium interest, High power | Laporan PDF rekap, observability dashboard |
| Dev Team | Builder | Code coverage, no oversell | High interest, Medium power | CI/CD, ADR, security review |
| Kominfo/UU PDP | Regulator | Data pribadi warga | Low interest, High power | Privacy policy, DELETE account, retensi |
| Supplier (Makmur Jaya) | External | Pesanan akurat | Medium interest, Low power | Rekap PDF teks auto via WA, webhook V2 optional |

---

## 2. Metrik + MoSCoW + RICE Scoring

### Success Metrics (sama + tambahan PDP compliance)

| Metrik | Target | Sumber | Freq | Action Gagal |
| :--- | :--- | :--- | :--- | :--- |
| Adoption | 70% 1 RT 35/50 KK | users count cluster_id | Harian | Tutorial video + door-to-door |
| Friction checkout | 80% <2 menit | analytics event checkout_success | Per PO | Perbesar tombol |
| Zero-discrepancy | 100% uang==barang | Audit orders paid vs fisik | Akhir PO | Wajib checklist + foto |
| Retention W2 | 40% PO2 | distinct user second campaign | Mingguan | FCM promo |
| Admin time saved | 80% 4j→45m | Survey WA | Akhir pilot | Optimasi PDF 1-klik |
| Crash-free | >99.5% | Crashlytics | Harian | Hotfix 24h |
| API Error Rate | <2% 5xx | Telescope/Sentry | Harian | Scale FPM Redis |
| Oversell Rate | 0% | Check variant quota<0 | Per order | Pessimistic lock |
| APK Size | <10MB arm64 | ls -lh | Per build | Tree shaking WebP |
| **UU PDP Consent** | 100% consent checkbox logged | users consent_at | Per user | Block login jika belum consent |
| **Data Deletion SLA** | <24h setelah DELETE /auth/account | logs | Per request | Alert Slack |

### MoSCoW Priority V1.0 (GAP Fixed)

| Must Have | Should Have | Could Have V1.1 | Won't Have |
| :--- | :--- | :--- | :--- |
| Auth OTP WA + lock 15m + consent UU PDP checkbox + ToS non-escrow | Extend + Cancel + broadcast FCM + fallback /notifications | Web Dashboard Livewire (admin web) | Escrow payment gateway |
| Campaign CRUD + cluster_id FK + target multiple rule | Transfer pesanan on_behalf | iOS TestFlight | ML recommendation |
| Varian Paten +/- no manual input | Social proof ticker polling 15s + share WA | Dark Mode + i18n | Multi-currency |
| Order lockForUpdate + quota check atomic + 409 oversell | Backup daily + restore drill RTO 1h RPO 24h | Analytics Dictionary + notification_open event | Google Maps |
| Upload bukti compress 70% + S3 primary + 90d lifecycle | Rate limit per-route Redis: auth 60/min, override 10/min | A/B Remote Config tombol |  |
| Validate/Reject/Override with notes + undo 5min + audit transaction_logs | Feature Flags laravel-feature-flags | Offline proof upload queue |  |
| Rekap PDF + teks WA | Observability Pulse + Prometheus Grafana |  |  |
| Checklist distribusi is_taken + complete | CI/CD test gate |  |  |
| FCM + fallback /notifications poll |  |  |  |

### RICE Scoring untuk Fitur Nice-to-Have

| Fitur | Reach | Impact | Confidence | Effort | RICE Score | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Web Dashboard Admin | 10 initiators | 8 (hemat waktu rekap desktop) | 90% | 5d | (10*8*0.9)/5=14.4 | V1.1 High |
| iOS TestFlight | 50 iPhone users per cluster (20%) | 6 | 70% | 7d | (50*6*0.7)/7=30 | V1.1 Medium |
| Dark Mode | 200 buyers malam hari | 3 | 80% | 2d | (200*3*0.8)/2=240 | V1.1 Low effort high |
| Analytics Dictionary | Dev team | 9 | 100% | 3d | 270 | V1.0 Should |
| Offline proof queue | 30 buyers sinyal jelek | 7 | 85% | 4d | (30*7*0.85)/4=44.6 | V1.1 |

---

## 3. Persona + UU PDP Consent

### Bu Siti Rahayu (Buyer) - Sama + tambahan PDP concern

| Atribut | Detail |
| :--- | :--- |
| Usia 45th IRT, Samsung A10 RAM 2GB Android 9, storage 64GB sisa 14GB | Takut data pribadi dijual, butuh jelas privasi |
| Butuh consent checkbox: "Saya setuju data WA disimpan untuk PO RT saja, sesuai UU PDP No.27/2022" + link Privacy Policy |  |
| Hak hapus data: Menu Profil → Hapus Akun → anonimize |

### Pak Agus (Initiator)

Butuh SOP sengketa jika buyer bilang sudah transfer tapi proof blur: lihat DISPUTE_SOP.md tanggung jawab initiator validasi 2x24 jam.

### Sistem Persona Laravel

Harus tahan 50-100 concurrent deadline rush (GAP thundering herd), bukan cuma 20.

---

## 4. Ruang Lingkup Fitur + Cluster + Non-Escrow + ToS

### 4.1. Cluster Multi-RT (Fix Gap Inkonsistensi DB tanpa cluster_id)

**Sebelumnya:** PRD bilang 1 Cluster=500 user tapi DB tidak punya cluster_id → migration besar nanti.

**Sekarang V3.1 Fix:** Tambah table `clusters`:

| Field | Type |
| :--- | :--- |
| id PK | bigint |
| name | varchar: "Permata Hijau RT03" |
| code | varchar unique: "PGH-RT03" |
| rw, kelurahan, kota | varchar |
| created_at | timestamp |

Update `users` add `cluster_id FK nullable`, `campaigns` add `cluster_id FK`. Seed default cluster PGH-RT03 untuk pilot. Semua query `GET /campaigns` filter `where cluster_id = auth user cluster_id` (scope global). Untuk MVP 1 cluster, tapi schema siap multi-cluster tanpa migration besar (GAP fixed).

### 4.2. Auth + UU PDP Compliance (GAP Kritis 1.1)

**Flow Consent:**
1. User login OTP screen tambah checkbox wajib: "Saya menyetujui Penyimpanan data WA & transaksi untuk keperluan PO RT sesuai Kebijakan Privasi (link)"
2. Jika tidak centang → tombol Verifikasi disabled.
3. Saat verify OTP success Laravel simpan `users.consent_at = now(), consent_version = "v1.0"`, `privacy_policy_accepted = true`
4. Jika user tidak setuju → tidak bisa login.
5. Endpoint baru: `DELETE /api/v1/auth/account` → soft delete anonimize: name = "Deleted User {id}", phone_number = "DELETED_{id}", fcm_token null, personal_access_tokens revoked, orders retained anonymized (user_id null? atau keep but name masked), proof images deleted S3, transaction_logs keep initiator_id but buyer anonymized. SLA <24h, job queue.
6. Retensi: proof images S3 lifecycle 90 hari setelah campaign completed, lalu auto delete (S3 lifecycle rule + Laravel scheduler `CleanOldProofsJob` daily)
7. Privacy Policy screen di Flutter: `PRIVACY_POLICY.md` content.

Tambah di SETUP_GUIDE & API_SPEC.

### 4.3. Non-Escrow + ToS + Dispute SOP (GAP Kritis 1.2)

**Disclaimer ToS Screen Onboarding (wajib scroll + checkbox):**
"Grosirun hanya mencatat status pembayaran (pending/paid). Dana tunai fisik atau transfer QRIS langsung ke rekening pribadi Initiator. Grosirun bukan penjamin dana, bukan escrow, tidak memegang dana. Jika ada sengketa dana, tanggung jawab pertama Initiator untuk refund manual 2x24 jam, eskalasi ke Ketua RT/RW. Baca DISPUTE_SOP."

- Flutter: first launch setelah login jika `tos_accepted_at null` → tampilkan modal ToS + checkbox → POST `/auth/tos-accept`
- Laravel: `users.tos_accepted_at`, `tos_version`
- Buyer agree ToS logged di `transaction_logs` type `tos_accept`
- Jika tidak agree → logout.

**Dispute SOP** detail ada di `docs/DISPUTE_SOP.md` (GAP fixed): timeline, tanggung jawab, bukti, eskalasi.

### 4.4. Fitur Sebelumnya Tetap + Tambahan Baru GAP

Semua fitur lama (login OTP, beranda, varian paten, progress, ticker, checkout cash/qris, share WA, buat PO, dashboard 3 tab, rekap PDF, extend, cancel, checklist distribusi) tetap.

**Tambahan baru V3.1 dari GAP:**

- **FCM Fallback (GAP Kritis #6):** Jika FCM gagal (Firebase down), simpan notifikasi ke table `notifications` Laravel. Flutter fallback polling `GET /api/v1/notifications?unread=true` setiap 60s atau saat app resume. Notif ditandai read setelah dibaca. Jadi tidak bergantung 100% FCM. Lihat API_SPEC + OBSERVABILITY.

- **Feature Flags (GAP Penting #5):** Package `laravel- Pennant` atau `laravel-feature-flags` (internal). Flags: `qris_upload`, `extend_deadline`, `dark_mode` (for remote config). Enable/disable via env + DB + Horizon tanpa deploy. Contoh: jika QRIS bermasalah, matikan via flag tanpa upload APK baru. Lihat TECHNICAL_SPEC + PERFORMANCE_TUNING.

- **API Gateway Rate Limit Centralized (GAP Penting #6):** Bukan hanya throttle middleware per controller. Buat `RateLimiter` custom di `AppServiceProvider`: global 60/min per user, per IP 100/min, per-route override: `request-otp 5/min per phone + IP`, `validate 30/min initiator`, `override-validate 10/min initiator` (sensitif). Gunakan Redis limiter. Lihat SECURITY.md.

- **Offline Proof Upload Queue (Nice #7 + GAP):** Sebelumnya hanya order queue offline. Sekarang tambah proof upload queue juga: jika buyer QRIS offline saat mau upload bukti, simpan file path lokal di pending queue type `upload_proof`, sync saat online (mirip order). Lihat STATE_MANAGEMENT_FLOW + PERFORMANCE_TUNING.

- **Batch Operations (Nice + API_SPEC Gap):** Endpoint `POST /api/v1/campaigns/{id}/orders/batch-validate` untuk validasi 10 orders sekaligus (checkbox di dashboard). Kurangi N+1 request admin saat distribusi 100 buyer.

- **Web Dashboard Admin V1.1 (Nice #1):** Doc `UI_SPEC.md` mention web admin Livewire/Inertia optional V1.1 untuk rekap desktop Pak Agus. Tidak scope V1.0 tapi design siap.

---

## 5. Alur Pengguna + Flowchart Bisnis BPMN

### 5.1. Flowchart Bisnis Utama (New)

```mermaid
flowchart TD
    A[Initiator Buat Campaign PO] --> B{Target & Varian valid?}
    B -- Yes --> C[Status Active, Cache Redis clear]
    B -- No --> A
    C --> D[Buyer Lihat Home List Active]
    D --> E[Buyer Detail + Polling 15s + Ticker]
    E --> F[Buyer Pilih Varian Qty Checkout Cash/QRIS]
    F --> G{Quota cukup? lockForUpdate}
    G -- No --> H[409 OUT_OF_STOCK, Flutter dialog stok habis]
    G -- Yes --> I[Order Created pending/waiting_qris, sold++, current_kg++]
    I --> J{Payment Method?}
    J -- Cash --> K[Buyer Bayar Tunai ke Initiator Offline]
    J -- QRIS --> L[Buyer Upload Proof compress 70% S3 + 90d lifecycle]
    L --> M{Proof valid?}
    K --> N[Initiator Dashboard Tab Pending]
    N --> O[Initiator Validate Cash -> paid + log validation + FCM + fallback notif DB]
    M --> P[Initiator Dashboard Tab QRIS Waiting]
    P --> Q{Valid?}
    Q -- Yes --> O
    Q -- No Blur --> R[Reject + reason + FCM + fallback notif]
    R --> L
    O --> S{current_kg >= target_kg?}
    S -- Yes --> T[Status Completed auto, FCM broadcast completed]
    S -- No --> E
    T --> U[Initiator Recap PDF + Text Share WA Supplier]
    U --> V[Supplier Kirim Barang Truk]
    V --> W[Initiator Distribution Checklist markTaken is_taken]
    W --> X[Complete Distribution distribution_completed_at]
    X --> Y[90 Hari, CleanOldProofsJob delete S3 proof]
```

Sequence Diagram detail ada di `DATABASE_DESIGN.md` + `TECHNICAL_SPEC.md` tambahan.

### 5.2. Skenario Thundering Herd (GAP Penting 2.1)

Jam H-1 deadline, 50-100 buyer buka app bersamaan checkout sisa 10 paket.

- Laravel harus handle 100 concurrent dengan `lockForUpdate()` + Redis queue FCM after commit.
- Flutter Dio retry 503 dengan backoff jika server 503 maintenance deploy.
- Load test k6 `k6-deadline-rush.js` simulasi 100 VUs.

### 5.3. Skenario Admin Race (GAP Penting 2.2)

2 admin device (Pak Agus HP + istri login akun sama? atau 2 initiator satu cluster) validate order sama bersamaan.

- Solution: `orders` row `lockForUpdate()` juga saat validate, transaction_logs audit. Second request dapat 409 "Order sudah divalidasi".
- Test di `OrderServiceTest` concurrency.

---

## 6. NFR + Storage S3 Primary + Versioning V2

### Update Storage Strategy (Fix Inkonsistensi Dokumen #1)

**Keputusan Final V3.1:**

- Primary storage prod: **S3 compatible** (AWS S3 atau MinIO atau IDCloud S3) — bukan local. Alasan: VPS 4GB disk penuh jika 500 user upload proof 2MB x 200 orders x N campaigns.
- Local disk hanya untuk dev + cache.
- Laravel `FILESYSTEM_DISK=s3` prod, `public` dev.
- URL: `Storage::disk('s3')->temporaryUrl()` 1 jam untuk proof (private bucket) — lebih aman dari public URL random.
- Lifecycle S3: rule delete `order_proofs/*` after 90 days after campaign completed (via S3 lifecycle + Laravel scheduler CleanOldProofsJob double safety)
- Backup: proof images tidak backup (karena lifecycle), tapi DB backup daily S3.

Update di semua dokumen: TECHNICAL_SPEC, API_SPEC, DEPLOYMENT, SECURITY konsisten S3 primary.

### Versioning Strategy V2 (GAP Kritis #5)

- API versioning: prefix `/api/v1/` now. Future `/api/v2/` backward compatible.
- Strategy: V1 maintain min 6 bulan setelah V2 launch. Deprecation header `X-API-Deprecation: 2026-12-31` + Sunset.
- Breaking changes: need major version bump. Add guide in VERSIONING_STRATEGY.md
- Flutter: send `Accept: application/vnd.grosirun.v1+json` header optional, plus `X-App-Version`
- Docs: OpenAPI/Swagger per version via Scribe generate `storage/docs/v1/openapi.yaml`

### Performance Budget (Add dari GAP)

Lihat README + PERFORMANCE_TUNING.md:

- GET /campaigns P95 <150ms cache hit Redis 60s
- POST /orders P95 <300ms include lock
- Upload 2MB <2s
- Flutter cold start <2s
- RAM <180MB
- APK <10MB
- Frame 60 FPS

### Database Index + Partitioning (Gap TECHNICAL_SPEC)

- Index: `campaigns (cluster_id, status, deadline)`, `campaign_variants (campaign_id)`, `orders (campaign_id, payment_status, user_id)`, `otp_codes (phone_number, expires_at)`, `notifications (user_id, read_at)`
- Partitioning: `orders` partition by year `PARTITION BY RANGE (YEAR(created_at))` jika >1M rows V2 (Mvp single partition but ready doc)
- Read Replica: Recap PDF heavy query via read replica (Doc TECHNICAL_SPEC add config `DB_CONNECTION=mysql_read` for reporting)
- Connection pooling: PHP-FPM pm.max_children 30, MySQL max_connections 100, Redis pooling.

### Cluster_id Add

Semua endpoint filter by `auth()->user()->cluster_id` scope.

---

## 7. Fase Rilis + Roadmap Visual

### Sprint Update (Docker + CI/CD + Security Review)

| Fase | Timeline | Backend | Mobile | Infra/Security | Output |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Sprint 1 Foundation | 20 Jul - 3 Ags 2026 | Laravel 11 + Docker compose MySQL Redis Nginx + cluster table + OtpService + UU PDP consent fields | Flutter Dio Hive SecureStorage + AuthCubit + consent checkbox | CI test.yml gate Pest + flutter analyze + Docker ready | Auth E2E + cluster |
| Sprint 2 Core | 4 Ags - 18 Ags | Campaign CRUD cluster scope + variant + cache Redis + S3 primary | Home Detail progress ticker polling + share WA + deep link | ADR docs + DATABASE_DESIGN + SECURITY.md | PO listing live |
| Sprint 3 Transaction | 19 Ags - 2 Sep | OrderService lockForUpdate + proof S3 tempUrl + batch validate + notifications fallback table | Checkout + proof queue offline + upload compress | k6 load test deadline rush 100 concurrent + ERROR_CATALOG | Checkout live |
| Sprint 4 Admin & Obs | 3 Sep - 10 Sep | Recap PDF + distribution + FCM + fallback /notifications + feature flags + rate limit centralized | Admin dashboard 3 tabs + recap viewer + checklist + FCM background handler | OBSERVABILITY.md Pulse Prometheus Grafana + PERFORMANCE_TUNING | Admin full |
| Dogfooding + Security Review | 11 Sep - 17 Sep | Load test thundering herd + admin race test + restore drill RTO 1h | Test 3 device low-end + APK <10MB + error boundary | SECURITY_REVIEW OWASP Top 10 API+Mobile checklist | RC + sec review |
| Alpha Pilot 1 RT | 18 Sep - 25 Sep | Deploy blue-green zero-downtime + backup daily S3 + canary 10% | Firebase App Distribution + onboarding pilot guide Pak Agus + FAQ | Monitoring alert Slack P95>300ms | Pilot 1 RT |
| Go-Live V1.0 | 26 Sep - 30 Sep | Go-live if adoption>70% crash-free>99.5% | Feedback form analytics dictionary | Post-launch hotfix plan | Prod V1.0 |

Gantt visual di README.md.

---

## 8. Mitigasi Risiko + Dispute SOP Ref

### Dispute SOP Non-Escrow (Gap Kritis Fixed - Detail di DISPUTE_SOP.md)

| Skenario | Tanggung Jawab | Timeline | Bukti | Eskalasi |
| :--- | :--- | :--- | :--- | :--- |
| Buyer transfer QRIS tapi proof blur rejected | Initiator harus cek mutasi bank 2x24 jam, jika ada mutasi validasi paksa override dengan notes "cek mutasi BCA jam..." | 2x24h | Mutasi screenshot + log override | Jika tidak kooperatif → Ketua RW → mediasi RT → refund manual |
| Buyer bayar tunai tapi initiator lupa centang validate | Buyer simpan bukti kwitansi manual, initiator wajib undo/override dalam 5m-24h. Checklist distribusi final jadi bukti ambil | 1x24h | Log validation, transaksi tunai fisik | Ketua RT saksi |
| PO batal target gagal, buyer sudah bayar | Initiator wajib refund manual 100% dalam 2x24h, FCM broadcast + WA grup. Grosirun hanya notif, bukan penahan dana | 2x24h | List paid orders di recap | Jika tidak refund → laporkan RW + blacklist initiator |
| Initiator kabur bawa uang | Risiko non-escrow. Mitigasi: pilih initiator terpercaya Ketua RT, audit log transparan, proof S3, ToS consent | - | transaction_logs + orders paid | Jalur hukum perdata, Grosirun provide data audit untuk mediasi (bukan penjamin) |

ToS consent screen wajib di onboarding: user centang setuju non-escrow + UU PDP.

### Risiko Lain (A,B,C) sebelumnya tetap + tambahan

| Risiko | Plan A | Plan B | Plan C |
| :--- | :--- | :--- | :--- |
| FCM Down Firebase | Fallback /notifications DB poll 60s (GAP fixed) | Retry queue 3x exponential | Buyer cek manual di app My Orders tanpa push |
| Storage S3 Down | Retry 3x, fallback local temp + queue upload S3 later | Alert admin, bukti simpan lokal HP dulu | Manual WA bukti ke initiator |
| Disaster VPS down | Restore dari backup S3, RTO 1h RPO 24h, disaster drill 1x sebelum pilot | Blue-green standby | Manual Excel sementara |
| UU PDP violation | Privacy policy + consent + DELETE account + retensi 90d | Anonimisasi | Lapor DPO |

---

## 9. Daftar Tugas + Dependency Graph

### Dependency Graph

```
clusters table → users.cluster_id → campaigns.cluster_id → variants → orders → logs
     |
     → notifications fallback
     |
     → feature_flags
```

Order tidak bisa dibuat jika cluster mismatch: buyer cluster harus sama dengan campaign cluster (scope).

### Checklist Developer Update (Tambahan GAP)

**Backend:**
- [ ] Migration `clusters` + add FK `users.cluster_id`, `campaigns.cluster_id`
- [ ] Migration `notifications` fallback FCM
- [ ] Change filesystem disk S3 primary prod, local dev (consistency fix)
- [ ] RateLimiter centralized Redis per-route (auth 5/min, override 10/min)
- [ ] Feature Flags package + flags: qris_upload, extend_deadline
- [ ] Endpoint `DELETE /auth/account` + `POST /auth/tos-accept` + `POST /auth/consent`
- [ ] Batch validate endpoint
- [ ] Error Catalog constants + response `code` like ERR_024
- [ ] Versioning strategy header deprecation
- [ ] K6 load test scripts in `backend/load-test/`
- [ ] Docker compose + Dockerfile prod Nginx
- [ ] CI/CD workflows test.yml, deploy.yml blue-green, build-apk.yml
- [ ] Observability Pulse + Scribe OpenAPI v1
- [ ] Privacy policy retensi 90d job `CleanOldProofsJob`

**Mobile:**
- [ ] Consent + ToS checkbox screens + API calls
- [ ] Deep linking `grosirun://campaign/{slug}` handler + AppLinks Android
- [ ] FCM background handler + fallback poll notifications 60s
- [ ] Offline proof upload queue pendingQueue type upload_proof
- [ ] Error boundary `FlutterError.onError` + `PlatformDispatcher.onError` Sentry
- [ ] State persistence Hive when killed (Auth state, campaign detail)
- [ ] Analytics Dictionary 30 events
- [ ] FAQ + Onboarding pilot screens

Total estimasi tambah 7 hari untuk GAP fixes → masih dalam 5 minggu + 1 minggu buffer.

---

## 10. Glosarium + Keputusan Final Inkonsistensi

### Keputusan Final Fix Inkonsistensi Antar Dokumen (Gap #4)

| # | Isu Sebelum | Keputusan Final V3.1 |
| :--- | :--- | :--- |
| 1 | Storage lokal vs S3 inkonsisten | **S3 primary prod** (private bucket tempUrl 1h), local hanya dev. Update semua docs: TECHNICAL_SPEC, API_SPEC, DEPLOYMENT, SECURITY konsisten S3. |
| 2 | DB tanpa cluster_id padahal PRD 1 cluster=500 user | **Tambah clusters table + FK** di users & campaigns. Semua query scoped cluster_id. Siap multi-cluster V2 tanpa migration besar. |
| 3 | CI Future vs deploy matang inkonsisten | **CI/CD real** now: `.github/workflows/test.yml` gate Pest + flutter analyze required before merge develop (GAP fixed). Deploy blue-green zero-downtime, bukan manual git pull di prod langsung. |
| 4 | GET /campaigns public vs auth required | **Final: Auth required untuk semua** (keputusan produk). Public read hanya untuk health. PRD update eksplisit, bukan hanya API_SPEC. |

### Glosarium Baru

| Istilah | Definisi V3.1 |
| :--- | :--- |
| Cluster | Entitas RT/RW/Perumahan, 1 cluster max 500 active users MVP, FK di users & campaigns |
| S3 Primary | Penyimpanan utama proof & campaign image di S3/MinIO private bucket tempUrl, lifecycle 90d |
| FCM Fallback | Jika FCM gagal, simpan notifikasi ke table notifications + Flutter poll GET /notifications |
| Feature Flag | Fitur bisa on/off via env/DB tanpa deploy APK baru (Pennant) |
| Blue-Green Deploy | 2 env prod blue/green, deploy ke green, health check, switch Nginx zero-downtime |
| RTO/RPO | Recovery Time Objective 1 jam, Recovery Point Objective 24 jam (backup daily) |
| UU PDP | UU Pelindungan Data Pribadi No.27/2022, consent, retensi, hak hapus |
| ToS Non-Escrow | Terms of Service bahwa Grosirun tidak pegang dana, hanya catat status |
| Dispute SOP | Prosedur sengketa dana tunai/QRIS manual refund 2x24 jam + eskalasi RW |
| Thundering Herd | Lonjakan 50-100 buyer checkout sisa stok di H-1 deadline |

---

**Penutup V3.1 Enterprise:** PRD ini sekarang menutup semua GAP Kritis (UU PDP, Dispute SOP, CI/CD, Storage S3, Cluster_id, FCM fallback) + Penting (Thundering herd load test, admin race, zero-downtime, disaster drill) + menambahkan MoSCoW RICE stakeholder matrix untuk keputusan produk transparan.

**Next Action:** Update semua dokumen lain sesuai keputusan Final di Section 10 ini (single source of truth).

**Signed:** Product Team Grosirun, 20 Juli 2026, V3.1 GAP Closed.
