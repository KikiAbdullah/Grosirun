# CHANGELOG & STRATEGI VERSIONING - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Owner:** Product & Engineering
**Review Cycle:** Setiap release
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)
**Status Dokumen:** Final
**Status Implementasi:** Flutter Ready for Integration | Backend Not Started

---

## Daftar Isi

1. Strategi Versioning
   - 1.1 Pendahuluan & Konteks Bisnis
   - 1.2 Semantic Versioning (SemVer)
   - 1.3 API Versioning
   - 1.4 Database Migration Versioning
   - 1.5 Flutter Versioning (versionCode + versionName)
   - 1.6 Deprecation Policy & Sunset
   - 1.7 Upgrade Guide Template
   - 1.8 Feature Flag vs Versioning
   - 1.9 Ringkasan & Checklist
2. Changelog
   - 2.1 [Unreleased] - V1.1 Nice-to-Have Backlog
   - 2.2 [v1.0.0] - 20 Juli 2026
   - 2.3 Release Notes Template

---


## Decision Log

| Tanggal | Decision | ADR | Dampak dokumen | Status |
| --- | --- | --- | --- | --- |
| 20 Juli 2026 | Laravel 11 backend | [ADR-001](ARCHITECTURE_DECISION_RECORDS.md#adr-001-laravel-11-vs-nodejsnestjs-vs-golang) | Technical, API, Deployment | Accepted |
| 20 Juli 2026 | MySQL 8 primary database | [ADR-002](ARCHITECTURE_DECISION_RECORDS.md#adr-002-mysql-8-vs-postgresql-15) | Technical, Test | Accepted |
| 20 Juli 2026 | S3 private primary storage | [ADR-003](ARCHITECTURE_DECISION_RECORDS.md#adr-003-s3-primary-vs-local-storage) | Technical, Security, Privacy, Deployment | Accepted |
| 20 Juli 2026 | Cubit state management | [ADR-004](ARCHITECTURE_DECISION_RECORDS.md#adr-004-cubit-vs-riverpod-vs-bloc-vs-provider) | Mobile, Test | Accepted |
| 20 Juli 2026 | Hive dan SQLite offline storage | [ADR-005](ARCHITECTURE_DECISION_RECORDS.md#adr-005-hive--sqlite-vs-drift-vs-isar) | Mobile, Security | Accepted |
| 20 Juli 2026 | Sanctum API authentication | [ADR-006](ARCHITECTURE_DECISION_RECORDS.md#adr-006-sanctum-vs-jwt-vs-passport) | API, Security | Accepted |
| 20 Juli 2026 | Dio HTTP client | [ADR-007](ARCHITECTURE_DECISION_RECORDS.md#adr-007-dio-vs-http-package) | Mobile, Observability | Accepted |
| 21 Juli 2026 | Seller membuat penawaran; Inisiator membuat campaign; empat role multi-role | [ADR-008](ARCHITECTURE_DECISION_RECORDS.md#adr-008-penawaran-supplier-campaign-inisiator-dan-multi-role) | PRD, Technical, API, Mobile, Security, Test, User Guide | Accepted |

Untuk perubahan besar berikutnya, tambahkan satu baris berisi tanggal, keputusan, ADR, dokumen terdampak, dan status. Release entry wajib mereferensikan Decision Log atau ADR terkait.

---

# Bagian 1: Strategi Versioning

## 1.1 Pendahuluan & Konteks Bisnis

### Mengapa Versioning Penting?

Versioning adalah fondasi untuk menjaga **stabilitas** dan **backward compatibility** aplikasi Grosirun. Dengan versioning yang jelas, kita dapat:

| Manfaat         | Keterangan                                         |
| --------------- | -------------------------------------------------- |
| **Keamanan**    | Aplikasi lama tetap berjalan saat rilis baru       |
| **Rollback**    | Mudah kembali ke versi sebelumnya jika ada masalah |
| **Komunikasi**  | Pengguna dan developer tahu apa yang berubah       |
| **Deprecation** | Memberikan waktu transisi untuk perubahan breaking |

### Konteks Bisnis (Referensi [BUSINESS_ANALYSIS.md](BUSINESS_ANALYSIS.md))

| Komponen              | Nilai               |
| --------------------- | ------------------- |
| Platform Fee          | 1% GMV + PPN 11%    |
| GMV per PO AT_70      | Rp8.400.000         |
| Laba Initiator per PO | Rp956.760           |
| Target Adopsi         | 70% (35 dari 50 KK) |

**Versioning yang buruk dapat menyebabkan:**

- Aplikasi lama crash karena API berubah → warga tidak bisa pesan → kehilangan GMV
- Migrasi database gagal → data transaksi hilang → sengketa dana
- Breaking change tanpa pemberitahuan → kehilangan kepercayaan warga

---

## 1.2 Semantic Versioning (SemVer)

### Format

Grosirun menggunakan **Semantic Versioning (SemVer)** dengan format:

```
MAJOR.MINOR.PATCH
Contoh: 1.0.0, 1.1.0, 2.0.0
```

### Definisi

| Level     | Kapan Digunakan                                                                            | Contoh                                                                                                                               | Dampak                                           |
| --------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------ |
| **MAJOR** | Breaking change API, perubahan schema yang tidak backward compatible, penghapusan endpoint | Menghapus `GET /campaigns/{id}/old-recap`, mengubah struktur response orders, mengubah flow autentikasi                              | Wajib upgrade manual, deprecation period 6 bulan |
| **MINOR** | Fitur baru additive (non-breaking), endpoint baru, field optional baru, feature flag baru  | Menambahkan `POST /campaigns/{id}/orders/batch-validate`, menambahkan `cluster_id` FK (nullable), menambahkan notifications fallback | Upgrade otomatis (backward compatible)           |
| **PATCH** | Bugfix, perbaikan keamanan, optimasi performa, tidak mengubah API contract                 | Memperbaiki oversell lock, kompres image 70%, memperbaiki rate limit bypass                                                          | Upgrade otomatis (backward compatible)           |

### Contoh di Grosirun

| Versi  | Perubahan                                             | Kategori |
| ------ | ----------------------------------------------------- | -------- |
| v1.0.0 | Initial release MVP                                   | -        |
| v1.0.1 | Fix oversell lock race condition                      | PATCH    |
| v1.1.0 | Add batch-validate endpoint                           | MINOR    |
| v1.1.1 | Fix S3 tempUrl expiry handling                        | PATCH    |
| v2.0.0 | Remove `/old-recap`, change orders response structure | MAJOR    |

### Git Tag

```bash
# Buat tag
git tag -a v1.0.0 -m "MVP V1.0 Laravel 11 + S3 + Cluster + Final"

# Push tag ke remote
git push origin v1.0.0

# Lihat semua tag
git tag -l

# Lihat detail tag
git show v1.0.0
```

**[CHANGELOG.md](CHANGELOG.md)** harus diperbarui setiap release.

---

## 1.3 API Versioning

### URL Versioning (Primary)

**Current:**

```
/api/v1/
```

**Future:**

```
/api/v2/
```

**Implementasi di Laravel:**

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    require __DIR__.'/api/v1.php';
});

Route::prefix('v2')->group(function () {
    require __DIR__.'/api/v2.php';
});
```

**Contoh Endpoint:**

| Version | Endpoint                | Keterangan                            |
| ------- | ----------------------- | ------------------------------------- |
| v1      | `GET /api/v1/campaigns` | Response awal                         |
| v2      | `GET /api/v2/campaigns` | Response dengan field baru (breaking) |

### Header Versioning (Secondary)

**Accept Header:**

```
Accept: application/vnd.grosirun.v1+json
Accept: application/vnd.grosirun.v2+json
```

**X-App-Version:**
Flutter mengirim `X-App-Version: 1.0.0+1` agar backend bisa:

- Log deprecated client version
- Check `min_supported_flutter_version`

**Middleware ApiVersion:**

```php
// app/Http/Middleware/ApiVersion.php
class ApiVersion
{
    public function handle(Request $request, Closure $next)
    {
        $accept = $request->header('Accept');
        $version = 'v1'; // default

        if (str_contains($accept, 'v2')) {
            $version = 'v2';
        }

        $request->attributes->set('api_version', $version);
        return $next($request);
    }
}
```

### Deprecation Headers

Ketika endpoint di V1 sudah deprecated tetapi masih aktif untuk backward compatibility:

```
HTTP/1.1 200 OK
Deprecation: true
Sunset: Sat, 31 Dec 2026 23:59:59 GMT
X-API-Deprecation-Notice: Use GET /campaigns/{id}/recap instead of /old-recap
```

**Implementasi di Controller:**

```php
public function oldRecap(Campaign $campaign)
{
    // Log deprecated usage
    Log::warning('Deprecated endpoint called', [
        'user_id' => auth()->id(),
        'campaign_id' => $campaign->id,
    ]);

    return response()->json([...])
        ->header('Deprecation', 'true')
        ->header('Sunset', 'Sat, 31 Dec 2026 23:59:59 GMT')
        ->header('X-API-Deprecation-Notice', 'Use GET /campaigns/{id}/recap');
}
```

### Contoh Deprecation Flow

| Fase  | Versi           | Action                                        | Status Endpoint Lama                          |
| ----- | --------------- | --------------------------------------------- | --------------------------------------------- |
| **1** | v1.0.0          | Endpoint baru `recap` ditambahkan             | Aktif (deprecation: false)                    |
| **2** | v1.1.0          | Endpoint lama `old-recap` ditandai deprecated | Deprecation: true, Sunset: 6 bulan            |
| **3** | v1.2.0 - v1.9.x | Endpoint lama masih aktif                     | Deprecation tetap true, log warning di Sentry |
| **4** | v2.0.0          | Endpoint lama dihapus                         | 410 Gone + message gunakan yang baru          |

### OpenAPI Docs Per Version

```bash
# Generate V1
php artisan scribe:generate --config=scribe.v1.config

# Generate V2 (future)
php artisan scribe:generate --config=scribe.v2.config
```

**Output:**

- `storage/docs/v1/openapi.yaml`
- `storage/docs/v2/openapi.yaml`

**Akses:**

- `https://api.grosirun.id/docs/v1`
- `https://api.grosirun.id/docs/v2`

---

## 1.4 Database Migration Versioning

### Prinsip

| Prinsip                        | Keterangan                                                                     |
| ------------------------------ | ------------------------------------------------------------------------------ |
| **Additive Only (Blue-Green)** | Migration di produksi hanya menambah, tidak menghapus/rename dalam satu deploy |
| **Timestamp Order**            | `2026_07_20_000001_create_clusters_table.php` → clusters sebelum users         |
| **Never Edit Old**             | Jangan edit migration yang sudah merge ke main/develop                         |
| **Expand-Contract**            | Untuk breaking schema, gunakan 3-phase: Expand → Migrate → Contract            |

### Expand-Contract Pattern

**Historical Migration Example (Legacy Only): `price_total_supplier` → `supplier_total_price`**

**Phase 1 - Expand (Deploy 1):**

```php
// Migration: add_supplier_total_price_to_campaigns.php
Schema::table('campaigns', function (Blueprint $table) {
    $table->bigInteger('supplier_total_price')->nullable()->after('price_total_supplier');
});
```

**Phase 2 - Migrate (Deploy 2):**

```php
// Migration: backfill_supplier_total_price.php
DB::table('campaigns')
    ->whereNull('supplier_total_price')
    ->update(['supplier_total_price' => DB::raw('price_total_supplier')]);
```

**Phase 3 - Contract (Deploy 3):**

```php
// Migration: drop_price_total_supplier.php
Schema::table('campaigns', function (Blueprint $table) {
    $table->dropColumn('price_total_supplier');
});
```

### Version Association

| Version | Migration yang Termasuk                          |
| ------- | ------------------------------------------------ |
| v1.0.0  | Semua migration sampai 2026-07-20                |
| v1.1.0  | Migration baru setelah v1.0.0 (additive)         |
| v2.0.0  | Migration yang menjalankan Phase 3 (drop column) |

### Rollback Safe

```bash
# Rollback 1 step (safe jika additive)
php artisan migrate:rollback --step=1

# Rollback dengan restore backup (jika data loss)
php artisan backup:restore
```

**Lihat [Technical Specification §19](TECHNICAL_SPEC.md#19-panduan-migrasi-database) untuk detail.**

---

## 1.5 Flutter Versioning (versionCode + versionName)

### pubspec.yaml

```yaml
name: grosirun_app
version: 1.0.0+1
# versionName: 1.0.0
# versionCode: 1 (Android) / build number (iOS)
```

### versionName vs versionCode

| Komponen        | Format              | Keterangan                                              |
| --------------- | ------------------- | ------------------------------------------------------- |
| **versionName** | `MAJOR.MINOR.PATCH` | SemVer, untuk user                                      |
| **versionCode** | Integer             | Harus increment setiap release (Play Store requirement) |

**Contoh:**

| Release | versionName | versionCode |
| ------- | ----------- | ----------- |
| v1.0.0  | 1.0.0       | 1           |
| v1.0.1  | 1.0.1       | 2           |
| v1.1.0  | 1.1.0       | 3           |
| v2.0.0  | 2.0.0       | 4           |

### CI/CD BUILD_NUMBER

**GitHub Actions build-apk.yml:**

```yaml
- name: Build APK
  run: |
    flutter build apk --release --split-per-abi --obfuscate \
      --build-number=${{ github.run_number }} \
      --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1
```

**pubspec.yaml dengan env:**

```yaml
version: 1.0.0+${BUILD_NUMBER}
```

### Force Update Check

**Endpoint:** `GET /version`

**Response:**

```json
{
  "api_version": "v1",
  "app_version": "1.0.0",
  "deprecation": null,
  "min_supported_flutter_version": "1.0.0+1",
  "min_supported_flutter_version_name": "1.0.0"
}
```

**Flutter Check:**

```dart
Future<void> checkForceUpdate() async {
  final version = await api.getVersion();
  final currentVersionCode = await getCurrentVersionCode();

  final minSupported = int.parse(version.minSupportedFlutterVersion.split('+')[1]);
  if (currentVersionCode < minSupported) {
    // Tampilkan dialog force update (blocking)
    await showDialog(
      barrierDismissible: false,
      builder: (_) => ForceUpdateDialog(
        minVersion: version.minSupportedFlutterVersionName,
      ),
    );
    // Open Play Store
    await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.grosirun.app'));
  }
}
```

---

## 1.6 Deprecation Policy & Sunset

### Kebijakan

| Aspek                     | Detail                                                        |
| ------------------------- | ------------------------------------------------------------- |
| **Non-breaking additive** | Tetap di major yang sama, tidak perlu deprecation             |
| **Breaking change**       | Wajib major bump + deprecation period minimal **6 bulan**     |
| **Sunset header**         | Harus mencantumkan tanggal 6 bulan setelah deprecation notice |
| **Komunikasi**            | [CHANGELOG.md](CHANGELOG.md) + Slack #release + in-app banner + email         |

### Timeline Deprecation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEPRECATION TIMELINE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Bulan 0: V1.1.0 rilis                                                     │
│  ├─ Endpoint lama ditandai Deprecation: true, Sunset: 6 bulan             │
│  ├─ CHANGELOG.md Deprecated section                                       │
│  └─ Sentry breadcrumb untuk tracking usage                                │
│                                                                             │
│  Bulan 1-5: V1.2.0, V1.3.0, ...                                          │
│  ├─ Endpoint lama masih aktif                                              │
│  ├─ Monitor usage via Pulse + Sentry                                      │
│  └─ Jika usage <5%, pertimbangkan early removal                           │
│                                                                             │
│  Bulan 6: V2.0.0 rilis                                                     │
│  ├─ Endpoint lama dihapus (410 Gone)                                      │
│  ├─ Upgrade Guide di CHANGELOG.md                                         │
│  └─ Force update dialog untuk APK lama                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Monitoring Deprecated Endpoint

**Pulse + Sentry:**

```php
// app/Http/Controllers/Api/V1/CampaignController.php
public function oldRecap(Campaign $campaign)
{
    // Log ke Sentry
    Sentry::addBreadcrumb(new Breadcrumb(
        level: Breadcrumb::WARNING,
        category: 'deprecation',
        message: 'old-recap called',
        data: ['user_id' => auth()->id(), 'campaign_id' => $campaign->id]
    ));

    // Log ke Pulse untuk monitoring
    Log::warning('Deprecated endpoint called', [
        'user_id' => auth()->id(),
        'campaign_id' => $campaign->id,
    ]);

    // ...
}
```

**Grafana Alert:** Jika usage deprecated endpoint >5% selama 1 minggu → Slack notifikasi.

---

## 1.7 Upgrade Guide Template

### Template [CHANGELOG.md](CHANGELOG.md)

```markdown
## [vX.Y.Z] - DD MMM YYYY - [Breaking / Minor / Patch]

### Added

- Fitur baru

### Changed

- Perubahan fitur existing

### Deprecated

- Endpoint yang akan dihapus, Sunset date

### Removed

- Fitur yang dihapus

### Fixed

- Bugfix

### Security

- Security advisory

### Upgrade Guide from vPrevious to vX.Y.Z

**Backend:**

1. Backup DB `php artisan backup:run --only-db`
2. Run migrations `php artisan migrate --force`
3. Update .env.prod dengan variable baru
4. Run data migration `php artisan [command]`
5. Clear cache `php artisan optimize:clear && php artisan config:cache`
6. Deploy blue-green `./deploy-blue-green.sh`
7. Test health `curl /api/v1/health`

**Mobile:**

1. Update pubspec.yaml version `X.Y.Z+BUILD`
2. Update model handling field baru
3. Re-generate json_serializable `flutter pub run build_runner build`
4. Test `flutter test` + integration_test
5. Build APK `flutter build apk --split-per-abi --obfuscate`
6. Distribute canary 10% first

**Breaking Changes Impact:**

- Old Flutter APK vPrevious calling deprecated endpoint → 410 Gone
- Force update via min_supported_version

**Performance Benchmark vs Baseline:**

- GET /campaigns P95 before: XXXms, after: XXXms
- POST /orders P95 before: XXXms, after: XXXms
```

### Contoh Upgrade Guide: v1.0.0 → v2.0.0

```markdown
## [v2.0.0] - 01 Dec 2026 - Breaking

### Deprecated Removed

- Removed GET /campaigns/{id}/old-recap (Sunset 31 Dec 2026)
- Removed field `price_total_supplier` from campaigns (use `supplier_total_price`)

### Upgrade Guide from v1.0.0 to v2.0.0

**Backend:**

1. Backup DB `php artisan backup:run --only-db`
2. Run migrations `php artisan migrate --force`
3. Run data migration `php artisan campaigns:backfill-supplier-price`
4. Clear cache `php artisan optimize:clear && php artisan config:cache`
5. Deploy blue-green `./deploy-blue-green.sh`
6. Test health `curl /api/v1/health` and `/api/v2/health`

**Mobile:**

1. Update pubspec.yaml version `2.0.0+2`
2. Add `supplier_total_price` to CampaignModel.fromJson
3. Remove `price_total_supplier` usage
4. Re-generate json_serializable
5. Build APK with `API_BASE_URL=https://api.grosirun.id/api/v2`

**Breaking Changes Impact:**

- Old Flutter APK v1.0.0 calling /old-recap → 410 Gone
- Force update dialog via min_supported_version = 2.0.0+2
```

---

## 1.8 Feature Flag vs Versioning

### Kapan Menggunakan Apa?

| Skenario                                                                | Gunakan Feature Flag?                                     | Gunakan Version Bump?                    |
| ----------------------------------------------------------------------- | --------------------------------------------------------- | ---------------------------------------- |
| Enable/disable QRIS upload sementara (bug)                              | ✅ Ya, flag `qris-upload` off tanpa deploy                | ❌ Tidak                                 |
| New endpoint batch-validate (non-breaking additive)                     | ✅ Flag opsional `batch-validate` untuk canary 10% → 100% | ✅ Minor version 1.1.0                   |
| Rename field `price_total_supplier` → `supplier_total_price` (breaking) | ❌ Tidak                                                  | ✅ Major version 2.0.0 + expand-contract |
| Dark Mode UI (tidak ada API change)                                     | ✅ Flag `dark-mode` Remote Config                         | ✅ Minor 1.1.0                           |
| New `cluster_id` FK (additive non-breaking)                             | ❌ Tidak perlu (migration sudah backward compat)          | ✅ Minor 1.1.0                           |

### Decision Tree

```
Apakah ada breaking change di API contract?
│
├── YA ──► Major version + Deprecation 6 bulan
│          + Expand-Contract (jika schema)
│          + Upgrade Guide
│          + Sunset header
│
└── TIDAK
    │
    Apakah ada fitur baru additive?
    │
    ├── YA ──► Minor version
    │          + Feature Flag (opsional untuk canary)
    │          + CHANGELOG.md Added
    │
    └── TIDAK ──► Patch version
                   + Bugfix atau perbaikan performa
                   + CHANGELOG.md Fixed
```

### Contoh Implementasi Feature Flag + Version

**Skenario:** New OrderService V2 dengan optimasi lock (canary 10%)

```php
// app/Providers/AppServiceProvider.php
Feature::define('canary-new-order-service', function (User $user) {
    return crc32((string) $user->id) % 100 < 10; // 10% canary
});

// app/Services/OrderService.php
public function create(Campaign $campaign, CreateOrderDTO $dto, User $buyer): Order
{
    if (Feature::active('canary-new-order-service')) {
        return $this->createV2($campaign, $dto, $buyer); // New logic
    }

    return $this->createV1($campaign, $dto, $buyer); // Old logic
}
```

**Rollout:**

```bash
# Step 1: 10% canary
php artisan pennant:activate canary-new-order-service --percentage=10
# Monitor 1 jam → error rate <2%

# Step 2: 50%
php artisan pennant:activate canary-new-order-service --percentage=50
# Monitor 1 jam → error rate <2%

# Step 3: 100%
php artisan pennant:activate canary-new-order-service --all

# Jika error >5% → rollback
php artisan pennant:deactivate canary-new-order-service
```

---

## 1.9 Ringkasan & Checklist

### Ringkasan

| Aspek              | Strategi                                                    |
| ------------------ | ----------------------------------------------------------- |
| **Version Format** | MAJOR.MINOR.PATCH (SemVer)                                  |
| **API Versioning** | URL `/api/v1/` + Accept header                              |
| **Deprecation**    | 6 bulan minimum, Sunset header                              |
| **Database**       | Additive only di Blue-Green, Expand-Contract untuk breaking |
| **Flutter**        | versionName (SemVer) + versionCode (integer)                |
| **Feature Flag**   | Pennant untuk canary rollout                                |
| **Documentation**  | [CHANGELOG.md](CHANGELOG.md) + Upgrade Guide                                |

### Checklist Release

| Item                                                                          | Status |
| ----------------------------------------------------------------------------- | ------ |
| [ ] [CHANGELOG.md](CHANGELOG.md) updated with Added/Changed/Deprecated/Removed/Fixed/Security | ☐      |
| [ ] Version bump di composer.json (backend)                                   | ☐      |
| [ ] Version bump di pubspec.yaml (mobile)                                     | ☐      |
| [ ] Git tag `vX.Y.Z` created and pushed                                       | ☐      |
| [ ] Upgrade Guide written (jika breaking)                                     | ☐      |
| [ ] Deprecation header added (jika deprecated)                                | ☐      |
| [ ] Sunset date set (6 bulan dari deprecation)                                | ☐      |
| [ ] OpenAPI docs generated for new version                                    | ☐      |
| [ ] Performance benchmark updated                                             | ☐      |
| [ ] Notifikasi Slack #release                                                 | ☐      |
| [ ] In-app banner for deprecation (jika perlu)                                | ☐      |

### Perintah Penting

| Keperluan                   | Command                                                     |
| --------------------------- | ----------------------------------------------------------- |
| **Tag version**             | `git tag -a v1.0.0 -m "message"` + `git push origin v1.0.0` |
| **Generate OpenAPI V1**     | `php artisan scribe:generate --config=scribe.v1.config`     |
| **Buat migration**          | `php artisan make:migration add_column_to_table`            |
| **Rollback migration**      | `php artisan migrate:rollback --step=1`                     |
| **Activate feature flag**   | `php artisan pennant:activate flag --percentage=50`         |
| **Deactivate feature flag** | `php artisan pennant:deactivate flag`                       |

---

# Bagian 2: Changelog

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), SemVer, Asia/Jakarta.

---

## [Unreleased] - V1.1 Nice-to-Have Backlog

### Added

- Web Dashboard Admin Livewire/Inertia (Nice #1) - desktop rekap Pak Agus
- iOS TestFlight build + Podfile (Nice #2)
- Analytics Event Dictionary 59 events + notification_open tracking (Nice #3 + #8)
- A/B Remote Config Firebase tombol 56dp vs 48dp (Nice #4)
- i18n flutter_localizations + intl multi-language ID/EN (Nice #5)
- Dark Mode ThemeMode (Nice #6)
- Role `seller` serta multi-role melalui `roles` dan `user_roles`.
- Supplier organization, membership, product, offer, tier harga, area layanan, purchase order, dokumen, dan status log.
- Alur Seller offer → Inisiator campaign snapshot → purchase order → fulfillment.
- Verifikasi Supplier dan moderasi offer oleh Admin aplikasi.
- Policy yang mencegah Seller mengakses data dan bukti pembayaran Pembeli.
- Brand Guidelines (`docs/BRAND_GUIDELINES.md`) — panduan lengkap brand: filosofi (asal-usul nama "Grosir" + "Run", kepribadian "tetangga yang bisa dipercaya"), tagline (rekomendasi: "Yuk, Grosirun Bareng!"), arah visual, identitas, palet warna, tipografi, ikonografi, nada suara, komponen UI, aplikasi brand, dan do's/don'ts.
- Mobile User Flow (`docs/MOBILE_USER_FLOW.md`) — alur lengkap 4 role (Buyer, Initiator, Seller, Admin) dengan detail screen-by-screen navigation, ASCII diagrams untuk visualisasi UI, contoh persona (Bu Siti, Pak Agus, Andi), alur lengkap 6 phase PO cycle, matrix fitur 15+ items per role, dan troubleshooting & eskalasi.
- Flutter Mobile Project (`mobile/`) — implementasi lengkap Flutter 3.22+ dengan 40+ dependencies: architecture BLoC/Cubit pattern, 4 models (User, Campaign, Order, Notification), 4 repositories (Auth, Campaign, Order, Notification), 4 cubits, authentication flow (OTP, consent, ToS), home screen dengan 4 tabs, campaign detail, profile, workspace screens untuk setiap role, widgets (BigButton, OfflineBanner), Android configuration (Kotlin, Gradle), dan mock data untuk testing.

### Changed

- Campaign wajib dibuat Inisiator dari penawaran aktif.
- `users.role` digantikan relasi multi-role melalui `user_roles` dan `active_role`.
- Supplier menjadi organisasi yang diwakili Seller melalui `supplier_members`.

### Deprecated

- `GET /campaigns/{id}/old-recap` text only - use `GET /campaigns/{id}/recap` with PDF S3 tempUrl, Sunset 31 Dec 2026

### Removed

- -

### Fixed

- -

### Security

- -

---

## [v1.0.0] - 20 Juli 2026 (Final MVP V1.0 + Enterprise Ready)

**BREAKING from v0.5.0 Firebase era - total rewrite Laravel 11 + S3 + Cluster + Final**

### Added - Backend Laravel 11 Enterprise

- **Framework:** Laravel 11.34.2 PHP 8.3, Sanctum 4 expiry 30d
- **Clusters Table:** `clusters` id, name, code unique PGH-RT03, rw, kelurahan. FK `users.cluster_id`, `campaigns.cluster_id`, `orders.cluster_id` denormalized. Global Scope ClusterScope auto filter auth user cluster. Seed default cluster PGH-RT03 pilot. Ready multi-cluster V2 without big migration.
- **S3 Primary Storage:** `FILESYSTEM_DISK=s3` prod private bucket `grosirun-prod-private` versioning ON, lifecycle delete `order_proofs/*` after 90d. Local only dev. Campaign images `campaigns/{uuid}.jpg` public via CloudFront or S3 public, proof private tempUrl 1h via `temporaryUrl()`. Intervention second compress 600x600 80%. Controller Policy check before generate tempUrl.
- **Database Design:** 8 tables: clusters, users, otp_codes, campaigns, campaign_variants, orders (uuid external, cluster_id), transaction_logs, notifications fallback, idempotency_keys Redis. ERD mermaid + cardinality + FK diagram + index strategy `(cluster_id,status,deadline)`, `(campaign_id,payment_status)`, `(user_id,created_at)`, partitioning orders by YEAR future V2, read replica for recap heavy.
- **Idempotency-Key:** Middleware `IdempotencyMiddleware` Redis `idempotency:{user_id}:{key}` cache response 24h, mandatory for POST /orders, POST proof, PATCH validate, batch-validate. Prevents duplicate on Dio retry + offline queue replay.
- **ETag + Cache-Control + If-Match:** GET /campaigns `Cache-Control: public, max-age=60` Redis 60s + ETag `W/"updated_at-current_quantity"`. GET detail ETag, If-None-Match → 304 Not Modified. PATCH validate optional If-Match → 412 STALE if mismatch. Saves battery + bandwidth.
- **Consent UU PDP + ToS + Deletion:** users fields `consent_at`, `consent_version`, `tos_accepted_at`, `tos_version`. Endpoints POST /auth/consent, POST /auth/tos-accept, DELETE /auth/account anonymize job AnonymizeUserJob SLA <24h: name Deleted User {id}, phone DELETED\_{id}, fcm null, tokens revoked, S3 proofs deleted, orders anonymized retain Kg for audit. Retensi proof 90d via S3 lifecycle + CleanOldProofsJob daily. Privacy Policy doc.
- **Notifications Fallback:** Table `notifications` id, user_id FK, title, body, data json, read_at. Flow: SendFcmJob try Kreait FCM, even if success also insert DB fallback, if FCM fails catch still insert DB. Flutter polling GET /notifications?unread=true every 60s on resume + FCM foreground handler. PATCH read, POST read-all. Not dependent 100% Firebase.
- **Batch Operations:** POST /campaigns/{id}/orders/batch-validate {order_uuids[], notes} → 207 multi-status success+failed, transaction per order, FCM batch. For initiator checkbox validate 10 orders at once reduce N+1.
- **Feature Flags:** Laravel Pennant `qris-upload`, `extend-deadline`, `batch-validate`, `canary-new-order-service`. Flags via DB + env, toggle without deploy `php artisan pennant:activate --percentage=10`. GET /features return active flags for Flutter hide/show UI.
- **Rate Limit Centralized:** AppServiceProvider RateLimiter custom Redis: global 60/min per user, 100/min per IP, otp 5/min per phone+IP, override 10/min per initiator, validate 30/min. Middleware throttle:otp, throttle:global-api, throttle:override-validate. 429 with `locked_until`, `retry_after`, `code ERR_001_RL`.
- **Webhooks Placeholder:** POST /webhooks/supplier-erp/order-status signed HMAC future V2 supplier integration, feature flag supplier-erp-webhook false, table webhooks prepared.
- **Error Catalog (Dokumentasi baru):** 50 codes ERR_001 OTP_EXPIRED 401 action request ulang, ERR_024 OUT_OF_STOCK 409, ERR_030 ALREADY_VALIDATED 409 admin race, ERR_031 STALE_DATA 412, ERR_040 CLUSTER_MISMATCH 403, ERR_050 UPLOAD_TOO_LARGE 413, etc. Frontend mapper human message + trace_id Sentry.
- **Versioning Strategy V2:** URL /api/v1/ current, future /api/v2/ backward compat, Deprecation header, Sunset, 6 months maintenance V1 after V2 launch, Accept header `application/vnd.grosirun.v1+json`, X-App-Version check min_supported. Doc [Changelog — Strategi Versioning](CHANGELOG.md#bagian-1-strategi-versioning) + OpenAPI Scribe v1/v2.
- **Clusters + Auth + OTP:** request-otp now cluster_code optional invite, verify-otp consent+tos true required 422 if false, cluster assignment firstOrCreate, token creation.
- **Proof Upload S3:** Multipart 2MB max mime jpg/png random UUID S3 private, tempUrl 1h, overwrite old log, Idempotency-Key mandatory.
- **Validation + Admin Race Fixed:** OrderService validate now lockForUpdate orders row, throw 409 ALREADY_VALIDATED if already paid, audit logs. Test pest concurrency 2 initiators same order same second.
- **Recap + Distribution + Extend/Cancel:** Read replica mysql_read for recap heavy, cluster scoped, extend feature flag check, FCM + fallback notifications broadcast.
- **Observability:** Laravel Pulse dashboard /pulse slow queries, slow requests, exceptions, queue. Prometheus exporter /metrics for Grafana. Sentry DSN prod, decision matrix Log vs Sentry: info→log daily, warning→log breadcrumb, error business recoverable 409→log only, 5xx→log+ Sentry capture + Slack alert, security critical→log critical + Sentry + Slack urgent. Telescope dev only.
- **Docker Local Environment:** docker-compose.yml root app MySQL Redis Nginx queue scheduler, Dockerfile prod, docker/nginx.conf, php.ini prod, supervisord.conf, Dev Container optional, setup 15 min vs 90 min native.

### Added - Mobile Flutter 3.22+ Enterprise

- **Consent + ToS Screens:** Checkbox wajib "Saya setuju data WA disimpan untuk PO RT sesuai UU PDP No.27/2022 link Privacy Policy" + ToS non-escrow disclaimer "Grosirun hanya catat status, dana langsung ke Initiator". POST /auth/consent + /tos-accept, users consent_at logged, verify button disabled if not checked.
- **Cluster Scope:** Auth repo getCurrentUserClusterId, CampaignRepository filter cluster, error dialog ERR_040 cluster mismatch.
- **Idempotency Interceptor:** Dio interceptor generate UUID v4 per POST/PATCH, header Idempotency-Key, save Hive idempotencyBox mapping url payload.
- **ETag Handling:** CampaignRemote save ETag from header to Hive etagBox, next GET sends If-None-Match, 304 no rebuild saves battery, If-Match for PATCH validate 412 stale handling.
- **Deep Linking Handler:** AppLinks package, grosirun://campaign/{id} + https://grosirun.id/c/{slug}, getInitialAppLink + uriLinkStream, pendingDeepLink when not authenticated saved Hive appStateBox, navigate after login, AndroidManifest intent-filter autoVerify.
- **FCM Background Handler Full Detail (penyempurnaan):** \_firebaseMessagingBackgroundHandler entry-point save Hive notificationsBox, FcmService init foreground onMessage show snackbar + refresh cubits + save Hive, onMessageOpenedApp navigate campaign_id, fallback polling GET /notifications 60s on resume Timer periodic + AppLifecycleState.
- **Error Boundary Widget Tree (penyempurnaan):** ErrorBoundary StatefulWidget, FlutterError.onError + PlatformDispatcher.onError + Sentry + Crashlytics, ErrorView with retry.
- **State Persistence When Killed (penyempurnaan):** appStateBox lastRoute lastCampaignId lastActiveAt lastDeepLink pendingDeepLink notification count, NavigatorObserver save on push, main cold start restore lastRoute within 30 min.
- **Offline Proof Upload Queue:** pendingQueueBox type upload_proof {order_uuid, local_file_path in app docs dir, idempotency_key}, SyncService processes both create_order + upload_proof ordered created_at asc 3 tries backoff, if file deleted remove queue + local notif fail, after sync delete local temp file.
- **Batch Validate UI:** Dashboard admin checkbox multi-select 10 orders + batch validate button api 207 partial success dialog success+failed.
- **Feature Flags UI:** GET /features hide/show QRIS option if qris-upload false without APK update.
- **Analytics Event Dictionary (Nice #3):** 59 events login_success, campaign_view, checkout_start, checkout_success, validation, notification_open, deep_link_open, proof_upload, etc. FirebaseAnalytics debugView.
- **Performance Traces:** Firebase Performance custom traces campaign_list_load, checkout_flow, proof_upload.

### Added - Infra / CI/CD / Docs Enterprise

- **Docker:** `docker-compose.yml` (app, nginx, mysql, redis, queue, scheduler) + `docker-compose.prod.yml` override S3 + `backend/Dockerfile` + `backend/Dockerfile.prod` + `backend/docker/nginx.conf` + `php.ini` prod + `supervisord.conf`
- **CI/CD Pipeline:** `.github/workflows/test.yml` runs on PR to develop: `php artisan test --coverage`, `flutter analyze`, `flutter test`, k6 smoke 10 VU, required check CODEOWNERS approve. `deploy.yml` blue-green zero-downtime: build Docker, migrate, health check temp port 8001, switch symlink current, reload FPM Nginx, restart queue, post health, Slack notify, auto rollback.sh if health fails 3x. `build-apk.yml` manual dispatch: build APK split-per-abi obfuscate SENTRY_DSN dart-define, upload artifact + Firebase App Distribution canary 10% then all, size check <10MB fail if >.
- **Error Tracking Strategy Matrix:** Log vs Sentry decision matrix in TECHNICAL_SPEC + [OBSERVABILITY.md](OBSERVABILITY.md): info log daily, warning breadcrumb, recoverable 409 log only, 5xx log+ Sentry + Slack, security critical log+ Sentry + Slack urgent.
- **Migration Rollback Plan:** [Technical Specification §19](TECHNICAL_SPEC.md#19-panduan-migrasi-database) expand-contract strategy, safe rollback per migration `migrate:rollback --step=1`, restore from backup S3 if data loss, blue-green additive only migrations.
- **FCM Fallback:** notifications table + GET /notifications polling 60s + PATCH read.
- **Monitoring & Alerting Detail:** Laravel Pulse + Prometheus + Grafana dashboards slow queries, slow requests, queue failed, P95 >300ms 5m alert Slack, SSL expiry <7 days alert, disk >80%, DB connections >80%, Firebase Performance custom traces.
- **Disaster Recovery:** RTO 1h RPO 24h, backup daily S3 spatie, retention 7d, S3 versioning, restore drill procedure 1x before pilot documented in [DEPLOYMENT.md](DEPLOYMENT.md) bagian 13 — Disaster Recovery Plan.
- **UU PDP Compliance:** [PRIVACY_POLICY.md](PRIVACY_POLICY.md) UU PDP No.27/2022, dasar pengolahan consent, retensi 90d proof, hak hapus DELETE /auth/account anonymize SLA <24h, log consent_at.
- **Load Testing Script:** `backend/load-test/k6-deadline-rush.js` 100 VUs 30s 10 quota limited 10 success 90 409, `k6-orders-race.js` 2 VUs same variant 1 quota, `k6-recap-heavy.js` 10 VUs recap heavy, thresholds P95 <300ms, http_req_failed <0.1, baseline saved [Observability — Performance & Benchmark](OBSERVABILITY.md#3-performance-engineering).
- **Feature Flags:** Pennant flags.
- **Rate Limit Centralized:** Redis per-route override.
- **Documentation Baseline (15 consolidated documents):**
  1. `PRD.md` — product requirements dan lifecycle.
  2. `BUSINESS_ANALYSIS.md` — business, legal-finance assumptions, GTM.
  3. `TECHNICAL_SPEC.md` — architecture, ERD penawaran-ke-campaign, database, migration.
  4. `API_SPEC.md` — REST contract dan canonical error catalog.
  5. `MOBILE_SPEC.md` — UX, screen map, Cubit, offline, FCM.
  6. `SECURITY.md` — threat model, authorization, security review.
  7. `PRIVACY_POLICY.md` — legal privacy document dan consent version.
  8. `TEST_PLAN.md` — test strategy dan acceptance evidence.
  9. `DEPLOYMENT.md` — CI, build, deploy, rollback, DR.
  10. `DEVELOPMENT_GUIDE.md` — coding, Git, PR, contribution.
  11. `OBSERVABILITY.md` — telemetry, performance, 59 analytics events.
  12. `USER_GUIDE.md` — role guide, FAQ, refund dan dispute operations.
  13. `ARCHITECTURE_DECISION_RECORDS.md` — 8 ADR.
  14. `SETUP_GUIDE.md` — local development setup.
  15. `CHANGELOG.md` — version strategy dan release history.

### Changed

- **Storage Strategy:** Dari local `storage/app/public` primary → **S3 private primary prod**. Local only dev. TempUrl 1h private, lifecycle 90d. Update all docs consistent S3.
- **DB Schema:** Tambah `clusters` table + FK, tambah `notifications` fallback, tambah `cluster_id` di orders denormalized, tambah `consent_at`, `tos_accepted_at`. Index strategy `(cluster_id,status,deadline)` etc. Partitioning ready.
- **API:** Tambah Idempotency-Key, ETag, Cache-Control, RateLimit headers, Deprecation Sunset, Versioning Accept header, Batch validate 207, Notifications fallback, Features, Clusters, DELETE account, Consent ToS, Proof-url tempUrl, Webhook placeholder, OpenAPI Scribe.
- **Mobile:** Tambah consent+ToS checkboxes, cluster scope, Idempotency interceptor, ETag caching 304, deep link handler, FCM background full + fallback polling, error boundary, state persistence killed, offline proof queue, batch validate checkbox, feature flags UI, analytics dictionary.
- **Docs:** Dokumentasi dikonsolidasikan menjadi 15 sumber kebenaran dengan referensi silang yang diperbarui.

### Deprecated

- **GET /campaigns/{id}/old-recap** text only → use `GET /campaigns/{id}/recap` with PDF S3 tempUrl. Sunset 31 Dec 2026. Header `Deprecation: true`, `Sunset: Sat, 31 Dec 2026`. Doc in CHANGELOG Deprecated + CHANGELOG bagian Strategi Versioning.
- **Local storage primary** → deprecated, use S3 primary. Migration guide in TECHNICAL_SPEC bagian 18–19 (Migrasi Data dan Panduan Migrasi Database).
- **Firebase Realtime** → deprecated, use Laravel API + Redis cache + ETag polling.

### Removed

- Firebase Firestore collection `products` → replaced MySQL campaigns table. Data migration plan in [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) bagian 18 — Rencana Migrasi Data artisan command `firebase:import`.
- Old `uploads/` folder old docs Firebase era - deleted.

### Fixed

- **Critical Oversell Race:** Fixed via lockForUpdate + Idempotency-Key + k6 100 VU test, 0 negative quota.
- **Admin Race Double Validation:** Fixed lockForUpdate orders + 409 ALREADY_VALIDATED + 412 STALE.
- **Storage VPS Disk Full:** Fixed S3 primary private bucket, lifecycle 90d, not local.
- **DB tanpa cluster_id:** Fixed clusters table + FK + ClusterScope + 403 CLUSTER_MISMATCH.
- **CI Future vs Deploy Matang Inkonsistensi:** Fixed CI/CD real test.yml gate required, deploy blue-green zero-downtime, rollback automation, canary 10%, not manual git pull.
- **GET /campaigns auth policy ambiguous:** Fixed decision final Auth required for all, documented in PRD + API_SPEC + TECHNICAL_SPEC consistent.
- **FCM Down 100% dependency:** Fixed fallback notifications DB + polling 60s.
- **OTP Rate Limit Bypass:** Fixed per phone+IP + attempts + locked_until + Redis.
- **APK Size 12MB:** Target split-per-ABI <10MB; belum diukur.
- **Progress Bar Not Updating:** Fixed polling 15s + FCM trigger + ETag 304.

### Security

- **Non-Escrow + ToS + Dispute SOP:** ToS screen scroll + checkbox consent non-escrow, [User Guide §7–8](USER_GUIDE.md#7-komplain-refund-dan-dispute-operations) refund 2x24h eskalasi RW, audit logs.
- **UU PDP Compliance:** Consent checkbox + privacy policy + DELETE account anonymize SLA <24h + retensi 90d proof S3 lifecycle + CleanOldProofsJob.
- **S3 Security:** Private bucket, tempUrl 1h, Policy check owner or initiator own campaign cluster, random UUID filename, mime check, Intervention second compress, no path traversal.
- **IDOR + Mass Assignment + XSS + SQLi:** Policy + $fillable strict + Resource escape + FormRequest + Eloquent safe, OWASP Checklist in [Security — Review Checklist](SECURITY.md#15-owasp-api-top-10-2023-checklist) Pass.
- **Rate Limit Centralized:** Redis per-route override 60/min global user + 100/min per IP, 5/min otp, 10/min override sensitive, 429 + trace_id.
- **Secrets:** No hardcoded .env, dart-define SENTRY_DSN, google-services.json prod via env, keystore \*.jks gitignore, S3 keys via env, Firebase credentials via env.
- **Audit:** transaction_logs all sensitive actions with ip, initiator_id, notes, type.
- **Binary Protection:** Obfuscate --obfuscate + split-debug-info.

### Known Issues (Terkontrol V3.1)

- [Low] Detail PO open ~2.2s Redmi 4A (target <1.5) - optimasi thumbnail cache V1.1
- [Medium] Offline pending queue hilang if ganti HP (Hive local only) - V1.1 export/import queue planned
- [Medium] S3 tempUrl 1h expiry - Flutter regenerate via GET proof-url, but if offline cannot regenerate - fallback local file path? Doc in FAQ
- [Low] Canary 10% via Pennant random 10% not sticky, user could flip - future sticky via user_id hash
- [Low] Blue-green DB migrations must additive only, dropping column needs 2-phase expand-contract - doc in TECHNICAL_SPEC bagian 19 — Panduan Migrasi Database

---

## [v0.5.0] - 15 Juli 2026 (Alpha Firebase Era Deprecated)

...

---

## [v0.1.0] - 20 Juni 2026 (Initial Firebase)

...

---

## Release Notes Template

### Template untuk setiap release tag vX.Y.Z:

```markdown
## [vX.Y.Z] - DD MMM YYYY

### Added

- Fitur baru

### Changed

- Perubahan fitur existing, termasuk storage strategy jika ada

### Deprecated

- Endpoint / fitur yang akan dihapus, Sunset date, migration guide

### Removed

- Fitur yang dihapus

### Fixed

- Bugfix critical race etc

### Security

- Security advisory, CVE, OWASP fix

### Upgrade Guide (for Breaking Changes)

- Langkah migrate dari vPrevious ke vX.Y.Z: migration command, env change, S3 bucket change, Flutter dart-define new, etc.

### Performance Benchmark vs Baseline

- P95 GET /campaigns before X after Y
- k6 result link

### Disaster Recovery Drill

- RTO actual vs target, issues

### Known Issues

- List low/medium/high
```

### Migration Notes Example

```
From v0.5.0 Firebase to v1.0.0 Laravel 11:
- Must run `php artisan migrate --seed` clusters + notifications
- Set FILESYSTEM_DISK=s3 prod, create bucket private lifecycle 90d
- Run TECHNICAL_SPEC bagian 18 — Rencana Migrasi Data Firebase import `php artisan firebase:import`
- Flutter: add consent + ToS checkboxes, deep link intent-filter, FCM background handler, Idempotency interceptor, ETag handling
- Env: add AWS_*, SENTRY_DSN, SLACK_WEBHOOK, FEATURE_*, PULSE_ENABLED
- Docker: `docker compose up -d --build`
- CI: add .github/workflows/test.yml required
```

### Deprecation Section Example

```
Deprecated:
- GET /campaigns/{id}/old-recap text only → use GET /campaigns/{id}/recap PDF S3 tempUrl, Sunset 31 Dec 2026, Deprecation header true
- Local storage primary → use S3 primary, migration via TECHNICAL_SPEC bagian 18 — Rencana Migrasi Data
```

### Security Advisory Section Example

```
Security:
- Fix IDOR: Buyer cannot GET orders other buyer 403 Policy added (CVE-like internal SEC-001)
- Fix Rate Limit Bypass OTP 5/min per phone+IP Redis lock
- S3 private tempUrl 1h not public list
```

---
