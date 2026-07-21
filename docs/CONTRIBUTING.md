# PANDUAN KONTRIBUSI - Grosirun V3.1

**Proyek:** Grosirun Laravel 11 + Flutter  
**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Selamat Datang
2. Branching & Monorepo
3. Cara Kontribusi
4. Standar Kode
5. Checklist Review Enterprise
6. Testing Wajib
7. Dokumentasi Wajib
8. Keamanan & Secrets
9. Budget APK
10. Kode Etik & Komunikasi
11. Proses Rilis
12. Setup Development Singkat

---

## 1. Selamat Datang

### 1.1 Tentang Grosirun

Grosirun adalah platform patungan belanja sembako berbasis RT/RW yang dibangun dengan **Laravel 11** sebagai backend dan **Flutter 3.22+** sebagai aplikasi mobile. Tujuan utama adalah membantu warga mendapatkan harga grosir 14-21% lebih murah dibandingkan eceran melalui sistem gotong royong yang transparan dan akuntabel.

### 1.2 Fokus Utama Pengembangan

| Fokus                 | Keterangan                                                          |
| --------------------- | ------------------------------------------------------------------- |
| **Ringan**            | APK <10MB, RAM <180MB untuk perangkat low-end                       |
| **Zero Oversell**     | Menggunakan `lockForUpdate` untuk mencegah penjualan melebihi kuota |
| **Offline-First**     | Aplikasi tetap berfungsi saat tidak ada koneksi internet            |
| **UU PDP Compliance** | Consent, retensi data 90 hari, hak hapus akun                       |
| **Cluster Scope**     | Setiap user hanya melihat data di cluster RT-nya masing-masing      |
| **S3 Primary**        | Penyimpanan bukti di S3 private dengan tempUrl 1 jam                |
| **FCM Fallback**      | Notifikasi tetap terkirim melalui polling DB jika FCM down          |

### 1.3 Model Bisnis (Referensi BUSINESS_ANALYSIS.md)

| Komponen              | Nilai                             |
| --------------------- | --------------------------------- |
| Platform Fee          | 1% GMV + PPN 11%                  |
| Tagihan per PO AT_70  | Rp93.240 (Rp84.000 + PPN Rp9.240) |
| Laba Initiator per PO | Rp956.760                         |
| Target Adopsi         | 70% (35 dari 50 KK)               |
| Target GMV per PO     | Rp8.400.000 (700Kg × Rp12.000)    |

### 1.4 Status CI/CD

**CI Gate sudah real (bukan future):**

- Setiap Pull Request ke `develop` wajib melewati `test.yml`
- `backend-test` + `frontend-test` + `k6-smoke` harus hijau
- Minimal 1 CODEOWNER approve
- Deploy ke produksi menggunakan **Blue-Green zero-downtime**

---

## 2. Branching & Monorepo

### 2.1 Struktur Branch

```
main (protected)
  └── develop (integration - CI gate wajib)
      ├── feature/cluster-scope
      ├── feature/idempotency-key
      ├── feature/fcm-fallback
      ├── fix/oversell-lock
      ├── fix/s3-tempurl-expiry
      ├── docs/adr-007
      └── hotfix/crash-proof-upload (dari main)
```

### 2.2 Aturan Branch

| Branch      | Aturan                                                                                                     |
| ----------- | ---------------------------------------------------------------------------------------------------------- |
| `main`      | **Protected** - Hanya menerima PR dari `develop` setelah CI green + CODEOWNERS approve. Tag rilis di sini. |
| `develop`   | **Integrasi** - Semua feature branch merge ke sini. CI `test.yml` wajib hijau.                             |
| `feature/*` | Fitur baru - Branch dari `develop`, merge ke `develop` via PR.                                             |
| `fix/*`     | Perbaikan bug - Branch dari `develop`, merge ke `develop` via PR.                                          |
| `hotfix/*`  | Perbaikan darurat - Branch dari `main`, merge ke `main` dan `develop`.                                     |
| `docs/*`    | Perubahan dokumentasi - Branch dari `develop`.                                                             |

### 2.3 Monorepo Structure

```
grosirun/
├── backend/          # Laravel 11 API
│   ├── app/
│   ├── database/
│   ├── tests/
│   ├── load-test/    # k6 scripts
│   └── docker/
├── mobile/           # Flutter 3.22+
│   ├── lib/
│   ├── android/
│   └── test/
├── docs/             # Dokumentasi (27 file markdown)
├── .github/
│   └── workflows/
│       ├── test.yml
│       ├── deploy.yml
│       └── build-apk.yml
├── docker-compose.yml
└── README.md
```

### 2.4 Deploy Terpisah

| Komponen    | Deploy                    | Trigger        |
| ----------- | ------------------------- | -------------- |
| Backend     | Blue-Green ke VPS         | Push ke `main` |
| Mobile APK  | Firebase App Distribution | Tag `v*.*.*`   |
| Dokumentasi | GitHub Pages (opsional)   | Push ke `main` |

---

## 3. Cara Kontribusi

### 3.1 Bug Report

**Judul:** `[Bug] Deskripsi singkat`

**Body Template:**

```markdown
## Informasi Bug

- **Cluster:** PGH-RT03 / PGH-RT04
- **Idempotency-Key:** [uuid jika ada]
- **ETag / If-Match:** W/"..."
- **Trace ID:** [dari error response]

## Langkah Reproduksi

1. [Langkah 1]
2. [Langkah 2]
3. [Langkah 3]

## Ekspektasi

[Jelaskan yang seharusnya terjadi]

## Aktual

[Jelaskan yang terjadi]

## Device

- **Model:** Samsung A10
- **OS:** Android 9
- **Versi Aplikasi:** 1.0.0+1

## Logs
```

[Tempelkan log error]

```

## Screenshot
[Lampirkan screenshot jika ada]
```

**Label yang Tersedia:**

| Label         | Keterangan                                 |
| ------------- | ------------------------------------------ |
| `bug`         | Semua bug                                  |
| `critical`    | Bug mematikan (crash, oversell, data loss) |
| `major`       | Bug utama (fungsi tidak jalan)             |
| `minor`       | Bug kecil (UI, typo)                       |
| `backend`     | Bug di Laravel                             |
| `mobile`      | Bug di Flutter                             |
| `security`    | Masalah keamanan                           |
| `cluster`     | Masalah terkait cluster                    |
| `idempotency` | Masalah Idempotency-Key                    |

### 3.2 Feature Request

**Judul:** `[Feature] Deskripsi fitur`

**Body Template:**

```markdown
## Problem

[Jelaskan masalah yang ingin dipecahkan]

## Solusi yang Diusulkan

[Jelaskan solusi]

## RICE Score

- **Reach:** [Berapa user yang terdampak]
- **Impact:** [1/2/3]
- **Confidence:** [0.1-1.0]
- **Effort:** [Person-weeks]
- **RICE:** [Hasil perhitungan]

## MoSCoW

- **Must:** [Wajib ada]
- **Should:** [Seharusnya ada]
- **Could:** [Boleh ada]
- **Won't:** [Tidak untuk V1.0]

## Dampak Teknis

- [ ] Membutuhkan cluster_id FK baru?
- [ ] Membutuhkan S3 storage?
- [ ] Membutuhkan FCM fallback?
- [ ] Membutuhkan Idempotency-Key?
- [ ] Memengaruhi APK size? Jika ya, estimasi penambahan: \_\_\_ MB
- [ ] Membutuhkan ADR (Architecture Decision Record)?
- [ ] Nama Feature Flag: `___`
- [ ] Membutuhkan data migration (Firebase → MySQL)?
```

### 3.3 Pull Request Flow

#### Langkah 1: Fork & Clone

```bash
git clone https://github.com/[username]/grosirun.git
cd grosirun
git checkout develop
git checkout -b feature/nama-fitur
```

#### Langkah 2: Coding

Ikuti standar di **CODING_STANDARDS.md**:

**Backend Laravel 11:**

- PSR-12 via `pint`
- `$fillable` strict, bukan `$guarded=[]`
- FormRequest untuk validasi
- Service layer untuk business logic + `lockForUpdate`
- DTO readonly untuk transfer data
- Resource untuk response API
- Pennant untuk feature flags
- RateLimiter centralized Redis
- S3 tempUrl dengan Policy check
- Audit `transaction_logs` untuk semua aksi sensitif

**Mobile Flutter:**

- `dart format` + `flutter analyze` 0 issues
- Equatable untuk semua State
- SecureStorage untuk token (bukan Hive)
- IdempotencyInterceptor untuk UUID per POST
- ETag If-None-Match untuk caching
- Hive persistence offline-first
- AppLinksService untuk deep link
- FcmService background handler + fallback polling
- ErrorBoundary + Sentry Crashlytics

#### Langkah 3: Test Lokal

**Wajib dijalankan sebelum PR:**

```bash
# Backend (Docker preferred)
docker compose exec app ./vendor/bin/pint
docker compose exec app php artisan test --parallel --coverage --min=80
docker compose exec app php artisan test --filter=RaceCondition

# Mobile
flutter analyze
flutter test
flutter test integration_test
flutter build apk --split-per-abi --obfuscate --analyze-size

# k6 smoke (jika OrderService berubah)
k6 run backend/load-test/k6-deadline-rush.js --vus 10 --duration 10s
```

#### Langkah 4: Commit

**Format:** `type(scope): subject`

| Type       | Penggunaan    | Contoh                                            |
| ---------- | ------------- | ------------------------------------------------- |
| `feat`     | Fitur baru    | `feat(backend): add cluster_id FK + ClusterScope` |
| `fix`      | Perbaikan bug | `fix(mobile): add offline proof queue`            |
| `docs`     | Dokumentasi   | `docs(adr): add ADR-003 S3 primary decision`      |
| `test`     | Testing       | `test(k6): add deadline-rush 100 VU`              |
| `chore`    | Maintenance   | `chore: update dependencies`                      |
| `refactor` | Refactor      | `refactor(order): extract validation logic`       |
| `perf`     | Performance   | `perf(campaign): add Redis cache 60s`             |
| `ci`       | CI/CD         | `ci: add blue-green deploy script`                |

**Scope yang Valid:** `backend`, `mobile`, `api`, `docs`, `ci`, `infra`, `security`, `test`

**Contoh Commit:**

```
feat(backend): add cluster_id FK + ClusterScope + cluster mismatch 403 ERR_040
feat(mobile): add deep link app_links + state persistence appStateBox
feat(api): add Idempotency-Key middleware + Redis cache 24h
feat(backend): add S3 primary disk + tempUrl 1h + lifecycle 90d job
feat(backend): add notifications fallback table + FCM fallback polling endpoint
feat(api): add batch-validate 207 multi-status
feat(backend): add Pennant feature flags qris-upload + canary
feat(infra): add docker-compose.yml + Dockerfile prod + blue-green deploy script
feat(ci): add test.yml gate Pest + flutter analyze required
fix(backend): prevent double validation admin race with lockForUpdate
fix(mobile): add offline proof upload queue type upload_proof
docs(adr): add ADR-003 S3 primary decision
test(k6): add deadline-rush 100 VU thundering herd
chore: update dependencies
```

#### Langkah 5: Push & PR

```bash
git push origin feature/nama-fitur
```

Buka Pull Request ke `develop` (bukan `main`).

#### Langkah 6: PR Template Checklist

```markdown
## Deskripsi

[Jelaskan perubahan yang dilakukan]

## Backend Checklist

- [ ] `php artisan test` pass coverage >80%
- [ ] `docker compose exec app php artisan test` pass
- [ ] Migration baru? Test rollback: `migrate:rollback --step=1` lalu `migrate`
- [ ] Race condition handled? `lockForUpdate` buyer checkout & admin validate
- [ ] RBAC + ClusterScope + Policy check owner/initiator own cluster
- [ ] Idempotency-Key added for POST/PATCH? Redis cache 24h
- [ ] ETag If-None-Match 304 + If-Match 412 handled
- [ ] Rate limit centralized per-route override tested 429
- [ ] Consent + ToS + DELETE account anonymize + retensi 90d proof
- [ ] S3 tempUrl private 1h generation with Policy check
- [ ] FCM fallback notifications table + polling 60s
- [ ] Batch operations 207 multi-status
- [ ] Feature flag Pennant check

## Mobile Checklist

- [ ] `flutter analyze` 0 issues
- [ ] `flutter test` pass
- [ ] APK size <10MB `ls -lh` + `--analyze-size`
- [ ] Deep link `grosirun://campaign/{id}` handled + pending when not auth
- [ ] FCM background handler + error boundary + state persistence when killed
- [ ] Offline proof queue `upload_proof` + file cleanup after sync
- [ ] Consent + ToS checkbox UI required

## Dokumentasi Checklist

- [ ] Update API_SPEC.md + TECHNICAL_SPEC.md + DATABASE_DESIGN.md
- [ ] Update ERROR_CATALOG.md + CHANGELOG.md + VERSIONING_STRATEGY.md
- [ ] Added ADR if architecture decision
- [ ] Update ONBOARDING_PILOT.md / FAQ_END_USER.md if user flow change

## Infra & Security Checklist

- [ ] No hardcoded secrets .env, dart-define only
- [ ] Tested blue-green deploy health check + rollback automation
- [ ] Added k6 script if performance critical
- [ ] CODEOWNERS approve required + test.yml green

## Issue Terkait

Closes #123
```

#### Langkah 7: Code Review

**CODEOWNERS (`.github/CODEOWNERS`):**

```
* @backend-lead @mobile-lead
/backend/ @backend-lead
/mobile/ @mobile-lead
/docs/ @product-owner @backend-lead @mobile-lead
*.md @product-owner
docker-compose.yml @backend-lead @infra
.github/workflows/ @infra @backend-lead
load-test/ @backend-lead
```

**Syarat Merge:**

- Minimal 1 CODEOWNER approve
- CI `test.yml` hijau
- Semua checklist tercentang

#### Langkah 8: Merge

Gunakan **Squash & Merge** ke `develop`, lalu hapus branch.

---

## 4. Standar Kode

### 4.1 Backend Laravel 11

**Wajib:**

- PSR-12 via `pint`
- `$fillable` strict (jangan `$guarded=[]`)
- FormRequest untuk validasi input
- Service layer untuk business logic
- `lockForUpdate()` di transaction untuk mencegah race condition
- DTO readonly untuk transfer data internal
- Resource untuk response API (bukan array manual)
- Pennant untuk feature flags
- RateLimiter centralized Redis
- S3 tempUrl dengan Policy check
- Audit `transaction_logs` untuk semua aksi sensitif
- ClusterScope global untuk filter data per cluster

**Controller yang Baik:**

```php
class OrderController extends Controller
{
    public function store(StoreOrderRequest $request, Campaign $campaign)
    {
        $order = $this->orderService->create(
            $campaign,
            $request->toDTO(),
            $request->user()
        );

        return new OrderResource($order);
    }
}
```

**Controller yang Buruk (Jangan):**

```php
class OrderController extends Controller
{
    public function store(Request $request, $campaignId)
    {
        // ❌ Logic panjang di controller
        // ❌ Tidak ada FormRequest
        // ❌ Tidak ada lockForUpdate
        // ❌ Tidak ada cluster check
        $variant = CampaignVariant::find($request->variant_id);
        $order = Order::create([...]); // ❌ Direct create
        return response()->json([...]);
    }
}
```

### 4.2 Mobile Flutter

**Wajib:**

- `dart format` + `flutter analyze` 0 issues
- `flutter_lints` aktif
- Equatable untuk semua State
- Token di `flutter_secure_storage` (bukan Hive)
- Hive boxes: `campaignsBox`, `ordersBox`, `pendingQueueBox`, `notificationsBox`, `appStateBox`, `etagBox`, `idempotencyBox`
- Dio interceptors: Auth, Idempotency, ETag, Retry
- `ListView.builder` untuk daftar panjang (bukan `ListView(children:)`)
- `cached_network_image` disk cache 7 hari
- `flutter_image_compress` sebelum upload
- Barrel export: `lib/logic/cubits/cubits.dart`

**Cubit yang Baik:**

```dart
class OrderCubit extends Cubit<OrderState> {
  Future<void> createOrder({...}) async {
    emit(OrderLoading());
    try {
      final order = await _repository.createOrder(...);
      emit(OrderSuccess(order));
    } catch (e) {
      emit(OrderError(_mapError(e)));
    }
  }
}
```

---

## 5. Checklist Review Enterprise

Reviewer wajib memeriksa semua item di bawah ini. Jika ada yang gagal → Request Changes.

### 5.1 Backend & API

- [ ] **Race Condition Buyer:** `lockForUpdate` variant quota, sold atomic, 409 OUT_OF_STOCK di k6 100 VU
- [ ] **Admin Race:** `lockForUpdate` orders on validate, 409 ALREADY_VALIDATED
- [ ] **Cluster Scope:** ClusterScope global, Policy check cluster_id match, 403 ERR_040
- [ ] **Idempotency-Key:** Redis cache 24h, replay same key return same response, header mandatory untuk POST/PATCH kritisk
- [ ] **ETag:** Generation `W/"updated_at-current_kg"`, If-None-Match 304, If-Match 412 stale handling
- [ ] **S3 Primary + tempUrl:** S3 private bucket, tempUrl 1h dengan Policy, lifecycle 90d + CleanOldProofsJob
- [ ] **Consent + ToS + PDP:** `consent_at`, `tos_accepted_at` logged, checkbox UI, DELETE /auth/account anonymize <24h
- [ ] **FCM Fallback:** notifications table fallback, GET /notifications polling 60s, mark read
- [ ] **Batch Validate:** 207 multi-status success+failed, transaction per order, FCM batch
- [ ] **Feature Flags:** Pennant check, enable/disable tanpa deploy, GET /features
- [ ] **Rate Limit Centralized:** Redis per-route: 60/min global, 5/min OTP, 10/min override, test 429
- [ ] **Security:** $fillable strict, FormRequest, Policy, S3 mime check random UUID, no SQL injection, XSS escape, audit logs, no hardcoded secrets

### 5.2 Mobile

- [ ] **Deep Link:** `grosirun://campaign/{id}` AppLinks handler + pending deep link when not auth
- [ ] **FCM Background Handler:** `_firebaseMessagingBackgroundHandler` entry-point, save Hive notificationsBox
- [ ] **Error Boundary:** `FlutterError.onError` + `PlatformDispatcher.onError` Sentry Crashlytics
- [ ] **State Persistence:** `appStateBox` lastRoute, lastCampaignId restored after kill
- [ ] **Offline Proof Queue:** pendingQueue type `upload_proof`, file path in app docs, sync online, delete local temp after success
- [ ] **APK Size:** <10MB arm64, `--analyze-size`, no heavy libs unless justified, WebP assets, Lottie <100KB

### 5.3 Observability & Infra

- [ ] **Docs Updated:** API_SPEC, TECHNICAL_SPEC, DATABASE_DESIGN, ERROR_CATALOG, CHANGELOG, VERSIONING, ADR, ONBOARDING_PILOT, FAQ
- [ ] **CI/CD:** test.yml gate green, deploy blue-green zero-downtime, rollback automation, SSL expiry monitoring, canary 10%
- [ ] **Observability:** Log vs Sentry matrix, Pulse slow queries, Firebase Performance traces
- [ ] **Disaster Recovery:** Backup S3 daily + restore drill <1h RTO documented

---

## 6. Testing Wajib

### 6.1 Backend Testing

| Jenis Test       | Tools     | Coverage Target       |
| ---------------- | --------- | --------------------- |
| Unit Service     | Pest      | >80%                  |
| Feature API      | Pest      | Semua endpoint        |
| Race Condition   | Pest + k6 | 100 VU deadline rush  |
| Admin Race       | Pest      | 2 concurrent validate |
| Cluster Mismatch | Pest      | 403 ERR_040           |
| Idempotency      | Pest      | Redis cache 24h       |
| ETag             | Pest      | 304 + 412             |
| S3               | Pest mock | tempUrl 1h            |
| Notifications    | Pest      | FCM + fallback DB     |
| Deletion         | Pest      | Anonymize <24h        |
| Rate Limit       | Pest      | 429                   |

### 6.2 Mobile Testing

| Jenis Test        | Tools            | Coverage                   |
| ----------------- | ---------------- | -------------------------- |
| Cubit             | bloc_test        | All states                 |
| Widget            | flutter_test     | UI components              |
| Integration       | integration_test | Full E2E flow              |
| Deep Link         | integration_test | `grosirun://campaign/{id}` |
| FCM Fallback      | integration_test | Polling 60s                |
| Proof Queue       | integration_test | Offline upload sync        |
| State Persistence | integration_test | Restore after kill         |

### 6.3 k6 Load Testing

| Script                | VUs | Duration     | Threshold         |
| --------------------- | --- | ------------ | ----------------- |
| `k6-deadline-rush.js` | 100 | 30s          | P95 <300ms, 0 5xx |
| `k6-orders-race.js`   | 2   | 2 iterations | 1 success, 1 409  |
| `k6-recap-heavy.js`   | 10  | 60s          | P95 <3s           |

**Run Locally:**

```bash
k6 run backend/load-test/k6-deadline-rush.js --vus 10 --duration 10s
```

### 6.4 Smoke Test (5 Menit per Release)

**Backend Smoke:**

- [ ] GET /health 200 (db, redis, s3 connected)
- [ ] POST request-otp + verify-otp consent+tos → token 200
- [ ] POST /campaigns with image S3 → 201 + image_url
- [ ] POST /orders with Idempotency-Key → 201 + sold++
- [ ] POST /orders same key replay → same response (no duplicate)
- [ ] PATCH validate → 200 paid + log + notifications fallback
- [ ] DELETE /auth/account → 202
- [ ] k6 small 10 VU 10s → 0 5xx

**Mobile Smoke:**

- [ ] Install APK arm64 <10MB
- [ ] Consent + ToS checkboxes required
- [ ] Login OTP → Home list own cluster
- [ ] DeepLink opens detail
- [ ] Checkout cash + Idempotency header
- [ ] Offline checkout → SuccessLocal + pendingQueue
- [ ] Online sync → success
- [ ] Proof upload offline → UploadLocalQueued → sync success
- [ ] Admin dashboard + batch validate 2 orders
- [ ] Recap PDF + share WA
- [ ] Distribusi checklist markTaken + complete
- [ ] Notifications polling 60s
- [ ] Error boundary → ErrorView not crash
- [ ] State persistence kill app → restore lastRoute

---

## 7. Dokumentasi Wajib

### 7.1 Update Berdasarkan Perubahan

| Perubahan             | Dokumen yang Harus Diupdate                         |
| --------------------- | --------------------------------------------------- |
| Endpoint baru/berubah | API_SPEC.md, TECHNICAL_SPEC.md, OpenAPI Scribe      |
| Schema DB             | DATABASE_DESIGN.md, DATABASE_MIGRATION_GUIDE.md     |
| Error code baru       | ERROR_CATALOG.md + mapper Flutter                   |
| Feature flag baru     | TECHNICAL_SPEC.md, API_SPEC.md, CODING_STANDARDS.md |
| User flow berubah     | ONBOARDING_PILOT.md, FAQ_END_USER.md, UI_SPEC.md    |
| Architecture decision | ARCHITECTURE_DECISION_RECORDS.md                    |
| Breaking change       | CHANGELOG.md, VERSIONING_STRATEGY.md                |
| Deploy/infra          | DEPLOYMENT.md, CI_CD.md                             |
| Security              | SECURITY.md, SECURITY_REVIEW.md                     |
| Performance           | PERFORMANCE_TUNING.md, PERFORMANCE_BENCHMARK.md     |
| Observability         | OBSERVABILITY.md                                    |

### 7.2 Generate OpenAPI

```bash
php artisan scribe:generate
# Output: storage/docs/v1/openapi.yaml
# Akses: https://api.grosirun.id/docs
```

### 7.3 Update CHANGELOG

Setiap PR wajib menambahkan entry di `CHANGELOG.md` bagian `[Unreleased]`:

```markdown
## [Unreleased]

### Added

- `feat(backend): add cluster_id FK + ClusterScope`

### Changed

- `refactor(order): extract validation logic to service`

### Fixed

- `fix(mobile): offline proof queue file cleanup`

### Deprecated

- `GET /campaigns/{id}/old-recap` - use `recap`, Sunset 31 Dec 2026
```

Jika breaking change → tambah `### Upgrade Guide`.

---

## 8. Keamanan & Secrets

### 8.1 Jangan Commit

| File                               | Keterangan                       |
| ---------------------------------- | -------------------------------- |
| `.env.prod`                        | Environment production           |
| `storage/app/firebase/*.json`      | Firebase credentials             |
| `android/app/google-services.json` | Google Services (prod)           |
| `*.jks`                            | Keystore Android                 |
| `*.p12`, `*.pem`                   | Sertifikat                       |
| `FONNTE_TOKEN`                     | Token WA Gateway                 |
| `AWS_*`                            | S3 credentials                   |
| `SENTRY_DSN`                       | Sentry DSN (gunakan dart-define) |

### 8.2 Cara Aman

| Environment     | Metode                                                       |
| --------------- | ------------------------------------------------------------ |
| Backend .env    | `.env.example` di repo, `.env.prod` di VPS + 1Password vault |
| Flutter secrets | `--dart-define` saat build, bukan `constants.dart`           |
| Google Services | `google-services.json` dev di repo, prod di VPS              |
| S3              | Private bucket, tempUrl 1h, lifecycle 90d                    |
| Firebase        | Service Account JSON di `storage/app/firebase/` (gitignore)  |

### 8.3 Key Rotation

| Key                  | Prosedur                                              |
| -------------------- | ----------------------------------------------------- |
| APP_KEY              | `php artisan key:generate` + update .env.prod         |
| S3 Keys              | Rotasi IAM, update .env.prod                          |
| Firebase Credentials | Generate new Service Account, update JSON, revoke old |
| FONNTE Token         | Regenerate di dashboard Fonnte                        |

### 8.4 Vulnerability Disclosure

**Email:** `security@grosirun.id`

**Kebijakan:**

- Jangan buka issue publik untuk keamanan
- Kami akan respons dalam 24 jam
- Perbaikan critical dalam 7 hari
- Credit di SECURITY.md Hall of Fame (opsional)

---

## 9. Budget APK

### 9.1 Target

| Arsitektur  | Target |
| ----------- | ------ |
| arm64-v8a   | <10MB  |
| armeabi-v7a | <9MB   |
| x86_64      | <11MB  |

### 9.2 Perintah Cek

```bash
flutter build apk --release --split-per-abi --obfuscate --analyze-size
ls -lh build/app/outputs/apk/release/*.apk
```

### 9.3 Aturan Tambahan

| Aturan     | Keterangan                                                          |
| ---------- | ------------------------------------------------------------------- |
| +0.5MB     | Wajib justification + alternatif lebih ringan                       |
| Heavy libs | Hindari `google_maps_flutter` (~5MB), `camera` full (kecuali perlu) |
| Assets     | Gunakan WebP (bukan PNG), Lottie <100KB                             |
| Font       | Gunakan system font (bukan custom) jika memungkinkan                |

---

## 10. Kode Etik & Komunikasi

### 10.1 Kode Etik

1. **Hormat & Profesional** - Fokus pada solusi, bukan ego teknologi
2. **Fokus Warga RT** - Setiap keputusan harus mengutamakan kemudahan ibu-ibu RT
3. **Bahasa Indonesia** untuk diskusi GitHub Issue
4. **Commit message** English (Conventional Commits)
5. **On-Call** untuk critical bug di pilot:
   - Oversell → hotfix <24 jam
   - Money mismatch → hotfix <24 jam
   - S3 down → fallback + hotfix <24 jam
   - FCM down → fallback polling sudah ada

### 10.2 Komunikasi

| Channel                | Tujuan                                               |
| ---------------------- | ---------------------------------------------------- |
| GitHub Issues          | Bug report, feature request                          |
| GitHub PR              | Code review                                          |
| Slack #grosirun-alerts | Pulse slow query >300ms, failed jobs >5, SSL <7 days |
| WA Grup Dev            | Darurat (opsional)                                   |

---

## 11. Proses Rilis

### 11.1 Langkah Rilis

| Langkah | Aktivitas                                                | PIC           |
| ------- | -------------------------------------------------------- | ------------- |
| 1       | Merge semua feature PR ke `develop` (CI green)           | Developer     |
| 2       | Buat PR `develop` → `main` dengan judul `Release vX.Y.Z` | Tech Lead     |
| 3       | Update CHANGELOG.md: date, version, upgrade guide        | Tech Lead     |
| 4       | Update PERFORMANCE_BENCHMARK.md baseline                 | Backend Lead  |
| 5       | Tag: `git tag -a v1.0.0 -m "MVP V1.0"` + push tag        | Tech Lead     |
| 6       | CI/CD `deploy.yml` auto blue-green deploy ke VPS         | Otomatis      |
| 7       | Canary flag 10% via Pennant, monitor 1 jam               | Backend Lead  |
| 8       | Jika error rate <2% → naik 50% → 100%                    | Backend Lead  |
| 9       | Build APK + Firebase Distribution canary 10% → all       | Mobile Lead   |
| 10      | Notifikasi Slack + WA tester                             | Product Owner |

### 11.2 Blue-Green Deploy

Script `deploy-blue-green.sh` di VPS:

```bash
#!/bin/bash
CURRENT=$(readlink /var/www/grosirun/current | xargs basename)
if [ "$CURRENT" = "blue" ]; then NEXT="green"; else NEXT="blue"; fi

cd /var/www/grosirun/$NEXT
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force  # ADDITIVE ONLY!
php artisan config:cache && php artisan route:cache && php artisan view:cache
php artisan optimize

# Health check temp port 8001
php artisan serve --host=127.0.0.1 --port=8001 &
sleep 5
curl -f http://127.0.0.1:8001/api/v1/health || exit 1

# Switch symlink (zero-downtime)
ln -nfs /var/www/grosirun/$NEXT /var/www/grosirun/current
systemctl reload php8.3-fpm
systemctl reload nginx
supervisorctl restart grosirun-worker:*

curl -f https://api.grosirun.id/api/v1/health || ./rollback.sh
```

### 11.3 Rollback Otomatis

Jika health check gagal 5x di `deploy.yml`, otomatis jalankan `rollback.sh`:

```bash
#!/bin/bash
CURRENT=$(readlink /var/www/grosirun/current | xargs basename)
if [ "$CURRENT" = "blue" ]; then ROLLBACK="green"; else ROLLBACK="blue"; fi

ln -nfs /var/www/grosirun/$ROLLBACK /var/www/grosirun/current
systemctl reload php8.3-fpm
systemctl reload nginx
supervisorctl restart grosirun-worker:*

curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"🚨 Rollback to '$ROLLBACK' automated"}' $SLACK_WEBHOOK
```

---

## 12. Setup Development Singkat

### 12.1 Docker (15 Menit - Recommended)

```bash
git clone https://github.com/username/grosirun.git
cd grosirun

cp backend/.env.example backend/.env
# Edit DB_HOST=mysql, REDIS_HOST=redis

docker compose up -d --build
docker compose exec app composer install
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --seed
docker compose exec app php artisan storage:link

curl http://localhost:8000/api/v1/health
# {"status":"ok","db":"connected","redis":"connected","s3":"connected"}
```

### 12.2 Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

### 12.3 Troubleshooting Decision Tree

```
[App tidak bisa jalan?]
  |
  ├─ Backend 500?
  │   ├─ docker compose logs app → cek .env DB_HOST=mysql
  │   ├─ php artisan migrate → SQLSTATE access denied → cek DB_PASSWORD
  │   └─ Storage link 404 → php artisan storage:link + chmod 775
  │
  ├─ OTP tidak masuk?
  │   ├─ Local? Cek storage/logs/laravel.log OTP plain
  │   ├─ Fonnte token salah? Test curl manual
  │   └─ Rate limit 429? Cek redis-cli KEYS "rl:otp:*"
  │
  ├─ Flutter Connection refused?
  │   ├─ Emulator? baseUrl 10.0.2.2:8000
  │   ├─ Real device? IP laptop 192.168.1.x, same WiFi
  │   └─ Cleartext HTTP? AndroidManifest usesCleartextTraffic true
  │
  └─ APK >10MB?
      ├─ flutter build apk --analyze-size
      ├─ Cek pubspec ada google_maps? Hapus
      └─ PNG → WebP, Lottie trim
```

---

**Terima kasih sudah berkontribusi! 🙌**
