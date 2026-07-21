# PIPA CI/CD - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Ikhtisar & CI Gate
2. Workflow: test.yml (Gate Wajib)
3. Workflow: deploy.yml (Blue-Green Zero-Downtime)
4. Workflow: build-apk.yml (Build & Distribusi APK)
5. Branch Protection & CODEOWNERS
6. Blue-Green Deployment
7. Canary 10% & Rollback Otomatis
8. Manajemen Secrets
9. Notifikasi Slack
10. Tabel Ringkasan Workflow

---

## 1. Ikhtisar & CI Gate

### 1.1 Latar Belakang

Sebelum V3.1, proses CI/CD masih bersifat manual. Pengembang menjalankan test secara lokal sebelum Pull Request, kemudian melakukan deploy manual ke server produksi. Hal ini menimbulkan risiko human error seperti:

- Test tidak dijalankan sama sekali
- Coverage kode menurun tanpa disadari
- Deploy menyebabkan downtime karena tidak ada strategi zero-downtime
- Rollback memakan waktu karena harus manual

**V3.1 memperkenalkan pipeline CI/CD otomatis penuh dengan GitHub Actions.**

### 1.2 Alur Pipeline Lengkap

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PULL REQUEST ke develop                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  test.yml (WAJIB)                                                          │
│  ├── backend-test:                                                         │
│  │   ├── PHP 8.3 + MySQL 8 + Redis 7                                      │
│  │   ├── composer install                                                 │
│  │   ├── php artisan migrate --env=testing                               │
│  │   ├── ./vendor/bin/pint --test                                        │
│  │   ├── php artisan test --parallel --coverage --min=80                │
│  │   └── php artisan test --filter=RaceCondition                        │
│  ├── frontend-test:                                                       │
│  │   ├── Flutter 3.22.3                                                  │
│  │   ├── flutter pub get                                                 │
│  │   ├── flutter analyze (0 issues)                                      │
│  │   ├── flutter test --coverage                                         │
│  │   └── dart format --set-exit-if-changed                              │
│  ├── apk-size-check:                                                      │
│  │   ├── flutter build apk --release --split-per-abi                    │
│  │   └── Check arm64 APK < 10MB                                          │
│  └── k6-smoke:                                                            │
│      └── k6 run k6-deadline-rush.js --vus 10 --duration 10s             │
│                                                                             │
│  Syarat Merge: ✅ backend-test ✅ frontend-test ✅ CODEOWNERS approve       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MERGE ke develop                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        RELEASE ke main (Tag vX.Y.Z)                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  deploy.yml (Blue-Green)                                                   │
│  ├── SSH ke VPS                                                            │
│  ├── Jalankan deploy-blue-green.sh                                        │
│  │   ├── Deteksi current color (blue/green)                              │
│  │   ├── Deploy ke next color                                             │
│  │   ├── composer install --no-dev                                       │
│  │   ├── php artisan migrate --force (additive only)                    │
│  │   ├── php artisan config:cache route:cache view:cache                │
│  │   ├── Health check temp port 8001                                     │
│  │   ├── Switch symlink current                                          │
│  │   ├── Reload PHP-FPM + Nginx (zero-downtime)                         │
│  │   └── Restart queue workers                                           │
│  ├── Health check prod (5x retry)                                        │
│  │   ├── ✅ Success → Slack notify                                       │
│  │   └── ❌ Failed → Auto rollback (rollback.sh)                         │
│  └── Notifikasi Slack                                                    │
│                                                                             │
│  build-apk.yml (Trigger Tag)                                              │
│  ├── Flutter build APK split-per-abi + obfuscate                         │
│  ├── Flutter build AAB                                                    │
│  ├── Check size <10MB                                                     │
│  ├── Upload artifact                                                      │
│  ├── Firebase App Distribution:                                           │
│  │   ├── 10% ke grup pilot-canary                                        │
│  │   └── Monitor Crashlytics 1 jam                                       │
│  └── Slack notify APK size + link                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Tabel Trigger Workflow

| Workflow        | Trigger                     | Tujuan                          |
| --------------- | --------------------------- | ------------------------------- |
| `test.yml`      | PR ke `develop` atau `main` | Validasi kode sebelum merge     |
| `test.yml`      | Push ke `develop`           | Test ulang setelah merge        |
| `deploy.yml`    | Push ke `main`              | Deploy ke produksi (blue-green) |
| `deploy.yml`    | `workflow_dispatch`         | Deploy manual via GitHub UI     |
| `build-apk.yml` | Tag `v*.*.*`                | Build APK untuk rilis           |
| `build-apk.yml` | `workflow_dispatch`         | Build APK manual                |

---

## 2. Workflow: test.yml (Gate Wajib)

### 2.1 Tujuan

Memastikan setiap Pull Request ke `develop` atau `main` lolos seluruh test sebelum di-merge. Workflow ini adalah **gate wajib** yang tidak bisa dilewati.

### 2.2 File: `.github/workflows/test.yml`

```yaml
name: Test Gate

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop]

jobs:
  # ==================== BACKEND TEST ====================
  backend-test:
    runs-on: ubuntu-22.04
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: grosirun_testing
          MYSQL_ROOT_PASSWORD: root
          MYSQL_USER: grosirun
          MYSQL_PASSWORD: secret
        ports: ["3306:3306"]
        options: --health-cmd="mysqladmin ping" --health-interval=10s
      redis:
        image: redis:7.2-alpine
        ports: ["6379:6379"]

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP 8.3
        uses: shivammathur/setup-php@v2
        with:
          php-version: "8.3"
          extensions: mbstring, pdo_mysql, redis, gd, imagick, zip, bcmath

      - name: Install Composer dependencies
        run: composer install --no-interaction --prefer-dist --optimize-autoloader
        working-directory: backend

      - name: Setup environment
        run: cp .env.example .env.testing
        working-directory: backend

      - name: Generate application key
        run: php artisan key:generate
        working-directory: backend

      - name: Run database migrations
        run: php artisan migrate --env=testing --force
        working-directory: backend

      - name: Check coding style (Pint)
        run: ./vendor/bin/pint --test
        working-directory: backend

      - name: Run PHPUnit/Pest tests with coverage
        run: php artisan test --parallel --coverage --min=80
        working-directory: backend

      - name: Run Race Condition tests
        run: php artisan test --filter=RaceCondition --parallel
        working-directory: backend

  # ==================== FRONTEND TEST ====================
  frontend-test:
    runs-on: ubuntu-22.04

    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.22.3"
          channel: "stable"

      - name: Install dependencies
        run: flutter pub get
        working-directory: mobile

      - name: Static analysis
        run: flutter analyze
        working-directory: mobile

      - name: Run unit tests
        run: flutter test --coverage
        working-directory: mobile

      - name: Check code formatting
        run: dart format --set-exit-if-changed lib/
        working-directory: mobile

      - name: Check APK size (arm64)
        run: |
          flutter build apk --release --split-per-abi --obfuscate \
            --split-debug-info=./build/debug-info \
            --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

          ls -lh build/app/outputs/apk/release/*.apk

          SIZE=$(stat -c%s build/app/outputs/apk/release/app-arm64-v8a-release.apk)
          MAX=10485760  # 10MB

          if [ $SIZE -gt $MAX ]; then
            echo "❌ APK too large: $SIZE bytes > $MAX bytes"
            exit 1
          else
            echo "✅ APK size: $SIZE bytes (under 10MB)"
          fi
        working-directory: mobile

  # ==================== K6 SMOKE TEST ====================
  k6-smoke:
    runs-on: ubuntu-22.04
    needs: backend-test

    steps:
      - uses: actions/checkout@v4

      - name: Setup k6
        uses: grafana/setup-k6-action@v1

      - name: Run smoke test (10 VU, 10s)
        run: |
          k6 run backend/load-test/k6-deadline-rush.js \
            --vus 10 \
            --duration 10s \
            --env API_URL=http://127.0.0.1:8000/api/v1 \
            --env TOKEN=test-token
```

### 2.3 Step-by-Step Penjelasan Job

#### backend-test

| Langkah | Perintah                                          | Keterangan                                       |
| ------- | ------------------------------------------------- | ------------------------------------------------ |
| 1       | Setup PHP 8.3                                     | Menginstall PHP beserta ekstensi yang dibutuhkan |
| 2       | `composer install`                                | Install dependency Laravel (tanpa dev di CI)     |
| 3       | `cp .env.example .env.testing`                    | Setup environment untuk testing                  |
| 4       | `php artisan key:generate`                        | Generate APP_KEY                                 |
| 5       | `php artisan migrate`                             | Migrasi database testing                         |
| 6       | `pint --test`                                     | Cek coding style PSR-12                          |
| 7       | `php artisan test --parallel --coverage --min=80` | Jalankan semua test, coverage minimal 80%        |
| 8       | `--filter=RaceCondition`                          | Test race condition (kritis untuk zero oversell) |

#### frontend-test

| Langkah | Perintah                            | Keterangan                      |
| ------- | ----------------------------------- | ------------------------------- |
| 1       | Setup Flutter 3.22.3                | Install Flutter SDK             |
| 2       | `flutter pub get`                   | Install dependency Dart/Flutter |
| 3       | `flutter analyze`                   | Static analysis, 0 issues wajib |
| 4       | `flutter test --coverage`           | Jalankan unit test              |
| 5       | `dart format --set-exit-if-changed` | Cek format kode                 |
| 6       | Build APK arm64                     | Cek ukuran APK <10MB            |

#### k6-smoke

| Langkah | Perintah                             | Keterangan                                        |
| ------- | ------------------------------------ | ------------------------------------------------- |
| 1       | Setup k6                             | Install k6 load testing tool                      |
| 2       | `k6 run ... --vus 10 --duration 10s` | Smoke test dengan 10 virtual user selama 10 detik |

### 2.4 Syarat Merge

| Syarat             | Keterangan                              |
| ------------------ | --------------------------------------- |
| `backend-test` ✅  | Semua test backend lulus, coverage >80% |
| `frontend-test` ✅ | Flutter analyze 0 issues, APK <10MB     |
| `k6-smoke` ✅      | Smoke test tidak error                  |
| CODEOWNERS ✅      | Minimal 1 approval dari CODEOWNERS      |

---

## 3. Workflow: deploy.yml (Blue-Green Zero-Downtime)

### 3.1 Tujuan

Melakukan deploy ke produksi dengan strategi **Blue-Green** (zero-downtime). Jika health check gagal, otomatis melakukan rollback ke versi sebelumnya.

### 3.2 File: `.github/workflows/deploy.yml`

```yaml
name: Deploy Blue-Green

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-22.04

    steps:
      - uses: actions/checkout@v4

      # ============ SSH SETUP ============
      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      # ============ DEPLOY BLUE-GREEN ============
      - name: Deploy via Blue-Green script
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.VPS_USER }}@${{ secrets.VPS_HOST }} << 'EOF'
          cd /var/www/grosirun
          ./deploy-blue-green.sh
          EOF

      # ============ HEALTH CHECK ============
      - name: Health check (5 retries)
        run: |
          for i in {1..5}; do
            echo "Health check attempt $i/5"
            if curl -f https://api.grosirun.id/api/v1/health; then
              echo "✅ Health check passed"
              break
            else
              echo "❌ Health check failed (attempt $i)"
              sleep 5
              if [ $i -eq 5 ]; then
                echo "🚨 Health check failed 5 times, triggering rollback"
                ssh ${{ secrets.VPS_USER }}@${{ secrets.VPS_HOST }} \
                  "cd /var/www/grosirun && ./rollback.sh"
                exit 1
              fi
            fi
          done

      # ============ NOTIFICATION ============
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          fields: repo,message,commit,author,action,eventName,ref,workflow
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
        if: always()
```

### 3.3 Step-by-Step Penjelasan

| Langkah | Keterangan                                         |
| ------- | -------------------------------------------------- |
| 1       | Setup SSH key untuk akses ke VPS                   |
| 2       | Jalankan `deploy-blue-green.sh` di VPS             |
| 3       | Health check 5 kali dengan interval 5 detik        |
| 4       | Jika semua gagal → jalankan `rollback.sh` otomatis |
| 5       | Kirim notifikasi Slack (sukses/gagal)              |

### 3.4 Isi Script deploy-blue-green.sh

Script ini berada di VPS di `/var/www/grosirun/deploy-blue-green.sh`.

```bash
#!/bin/bash
set -e

echo "🚀 Starting Blue-Green deployment..."

# Deteksi current color
CURRENT=$(readlink /var/www/grosirun/current | xargs basename)
if [ "$CURRENT" = "blue" ]; then
  NEXT="green"
else
  NEXT="blue"
fi

echo "📦 Current: $CURRENT, Deploying to: $NEXT"

# Pindah ke folder target
cd /var/www/grosirun/$NEXT

# Pull kode terbaru
git pull origin main

# Install composer (tanpa dev)
composer install --no-dev --optimize-autoloader --no-interaction

# Jalankan migrasi (additive only!)
php artisan migrate --force --no-interaction

# Cache konfigurasi
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Warm up aplikasi
php artisan optimize

# Health check via temporary port
echo "🔍 Health check on temp port 8001..."
php artisan serve --host=127.0.0.1 --port=8001 &
PID=$!
sleep 5

if curl -f http://127.0.0.1:8001/api/v1/health; then
  echo "✅ Health check passed"
else
  echo "❌ Health check failed"
  kill $PID
  exit 1
fi
kill $PID

# Switch symlink (zero-downtime)
echo "🔄 Switching symlink to $NEXT..."
ln -nfs /var/www/grosirun/$NEXT /var/www/grosirun/current

# Reload PHP-FPM dan Nginx (zero-downtime, bukan restart)
echo "🔄 Reloading PHP-FPM and Nginx..."
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx

# Restart queue workers (gunakan kode baru)
echo "🔄 Restarting queue workers..."
sudo supervisorctl restart grosirun-worker:*

# Post-deploy health check
echo "🔍 Post-deploy health check..."
if curl -f https://api.grosirun.id/api/v1/health; then
  echo "✅ Deployment successful to $NEXT!"
  echo "📦 Old $CURRENT remains as rollback target"
else
  echo "❌ Post-deploy health check failed! Rolling back..."
  ./rollback.sh
  exit 1
fi
```

### 3.5 Catatan Penting tentang Migrasi

**Prinsip Blue-Green:** Migrasi harus **additive only** (hanya menambah) dalam satu deploy.

| Jenis Perubahan   | Boleh di Blue-Green? | Keterangan                            |
| ----------------- | -------------------- | ------------------------------------- |
| Tambah kolom baru | ✅                   | Old code tetap jalan (kolom nullable) |
| Tambah tabel baru | ✅                   | Old code tidak akses tabel baru       |
| Tambah indeks     | ✅                   | Tidak mempengaruhi old code           |
| Hapus kolom       | ❌                   | Harus 2-phase (expand-contract)       |
| Rename kolom      | ❌                   | Harus 2-phase (expand-contract)       |
| Ubah tipe data    | ❌                   | Harus 2-phase (expand-contract)       |

**2-Phase Expand-Contract Pattern:**

1. **Phase 1 (Expand):** Tambah kolom baru, dual-write (tulis ke old + new)
2. **Phase 2 (Migrate):** Backfill data, switch read ke new
3. **Phase 3 (Contract):** Hapus kolom old (deploy terpisah)

---

## 4. Workflow: build-apk.yml (Build & Distribusi APK)

### 4.1 Tujuan

Membangun APK untuk rilis, melakukan obfuscate, mengecek ukuran, mengupload ke Firebase App Distribution (canary 10%), dan notifikasi Slack.

### 4.2 File: `.github/workflows/build-apk.yml`

```yaml
name: Build APK

on:
  push:
    tags: ["v*.*.*"]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-22.04

    steps:
      - uses: actions/checkout@v4

      # ============ SETUP FLUTTER ============
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.22.3"

      # ============ INSTALL DEPENDENCIES ============
      - name: Install dependencies
        run: flutter pub get
        working-directory: mobile

      # ============ BUILD APK ============
      - name: Build APK (split-per-abi + obfuscate)
        run: |
          flutter build apk --release --split-per-abi --obfuscate \
            --split-debug-info=./build/debug-info \
            --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1 \
            --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }}
        working-directory: mobile

      # ============ BUILD AAB ============
      - name: Build AAB
        run: |
          flutter build appbundle --release --obfuscate \
            --split-debug-info=./build/debug-info \
            --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1
        working-directory: mobile

      # ============ CHECK SIZE ============
      - name: Check APK size
        run: |
          echo "📦 APK sizes:"
          ls -lh build/app/outputs/apk/release/*.apk
        working-directory: mobile

      # ============ UPLOAD ARTIFACT ============
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: apk-arm64
          path: mobile/build/app/outputs/apk/release/app-arm64-v8a-release.apk

      # ============ FIREBASE APP DISTRIBUTION (Canary 10%) ============
      - name: Upload to Firebase App Distribution (Canary)
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: pilot-canary
          file: mobile/build/app/outputs/apk/release/app-arm64-v8a-release.apk

      # ============ NOTIFY SLACK ============
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          fields: repo,message,commit,author,action,eventName,ref,workflow
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
        if: always()
```

### 4.3 Step-by-Step Penjelasan

| Langkah | Perintah                            | Keterangan                                 |
| ------- | ----------------------------------- | ------------------------------------------ |
| 1       | Setup Flutter                       | Install Flutter 3.22.3                     |
| 2       | `flutter pub get`                   | Install dependency                         |
| 3       | `flutter build apk --split-per-abi` | Build APK untuk arm64, armeabi-v7a, x86_64 |
| 4       | `--obfuscate`                       | Obfuscate kode untuk keamanan              |
| 5       | `--split-debug-info`                | Simpan debug info untuk Sentry             |
| 6       | `flutter build appbundle`           | Build AAB untuk Play Store                 |
| 7       | Check size                          | Verifikasi APK <10MB                       |
| 8       | Upload artifact                     | Simpan APK di GitHub Actions               |
| 9       | Firebase Distribution               | Kirim ke grup pilot-canary (10%)           |
| 10      | Slack notify                        | Informasikan hasil build                   |

### 4.4 Canary 10% Strategy

| Langkah | Waktu      | Aktivitas                                              |
| ------- | ---------- | ------------------------------------------------------ |
| 1       | 0 menit    | Upload APK ke grup `pilot-canary` (Pak Agus + 3 buyer) |
| 2       | 0-60 menit | Monitor Crashlytics crash-free rate                    |
| 3       | 60 menit   | Jika crash-free >99.5% → deploy ke semua `pilot-rt03`  |
| 4       | 60+ menit  | Jika crash rate >0.5% → rollback APK, fix bug          |

---

## 5. Branch Protection & CODEOWNERS

### 5.1 File: `.github/CODEOWNERS`

```txt
# Default owner untuk semua file
* @backend-lead @mobile-lead

# Backend-specific
/backend/ @backend-lead

# Mobile-specific
/mobile/ @mobile-lead

# Documentation
/docs/ @product-owner @backend-lead @mobile-lead
*.md @product-owner

# Infrastructure
docker-compose.yml @backend-lead @infra
.github/workflows/ @infra @backend-lead

# Load testing
backend/load-test/ @backend-lead
```

### 5.2 Branch Protection Rules (GitHub Settings)

**Untuk branch `develop` dan `main`:**

| Pengaturan                  | Nilai | Keterangan                                  |
| --------------------------- | ----- | ------------------------------------------- |
| Require pull request        | ✅    | Tidak bisa push langsung ke branch          |
| Require approvals           | 1     | Minimal 1 approval dari CODEOWNERS          |
| Dismiss stale reviews       | ✅    | Review otomatis di-reset jika ada push baru |
| Require status checks       | ✅    | `backend-test`, `frontend-test` harus hijau |
| Require branches up-to-date | ✅    | PR harus sync dengan base branch            |
| Include administrators      | ✅    | Aturan berlaku untuk semua, termasuk admin  |

---

## 6. Blue-Green Deployment

### 6.1 Konsep Blue-Green

```
┌─────────────────────────────────────────────────────────────────┐
│                    Nginx (Load Balancer)                        │
│                    root: /var/www/grosirun/current              │
└─────────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┴─────────────────┐
            ▼                                   ▼
┌──────────────────────┐           ┌──────────────────────┐
│   BLUE (live)        │           │   GREEN (idle)       │
│   /var/www/blue      │           │   /var/www/green     │
│   v1.0.0             │           │   v1.1.0 (deploy)    │
└──────────────────────┘           └──────────────────────┘
```

### 6.2 Folder Structure di VPS

```
/var/www/grosirun/
├── blue/                    # Versi saat ini (live)
│   ├── backend/
│   ├── .env.prod
│   └── storage/
├── green/                   # Versi baru (idle)
│   ├── backend/
│   ├── .env.prod
│   └── storage/
├── current -> blue/         # Symlink ke versi live
├── deploy-blue-green.sh    # Script deploy
└── rollback.sh             # Script rollback
```

### 6.3 Keunggulan Blue-Green

| Keunggulan           | Keterangan                                           |
| -------------------- | ---------------------------------------------------- |
| **Zero-downtime**    | Switch symlink <1 detik, tidak ada restart Nginx/FPM |
| **Rollback instan**  | Switch symlink kembali ke warna sebelumnya           |
| **Testing di green** | Bisa test versi baru di port 8001 sebelum live       |
| **Minimal risk**     | Jika health check gagal, tidak jadi switch           |

---

## 7. Canary 10% & Rollback Otomatis

### 7.1 Canary 10% via Firebase App Distribution

**Grouping:**

| Group          | Jumlah Tester | Keterangan                    |
| -------------- | ------------- | ----------------------------- |
| `pilot-canary` | 3-5 orang     | Pak Agus + 3 buyer terpercaya |
| `pilot-rt03`   | 35 orang      | Semua buyer di RT03           |

**Proses Manual (Setelah Canary OK):**

```bash
# Setelah 1 jam monitor Crashlytics
firebase appdistribution:distribute \
  --app $FIREBASE_APP_ID \
  --groups pilot-rt03 \
  mobile/build/app/outputs/apk/release/app-arm64-v8a-release.apk
```

### 7.2 Rollback Automation

**File: `/var/www/grosirun/rollback.sh`**

```bash
#!/bin/bash
set -e

echo "⏪ Rolling back..."

CURRENT=$(readlink /var/www/grosirun/current | xargs basename)
if [ "$CURRENT" = "blue" ]; then
  ROLLBACK="green"
else
  ROLLBACK="blue"
fi

echo "🔄 Rolling back from $CURRENT to $ROLLBACK"

# Health check rollback version via temp port
cd /var/www/grosirun/$ROLLBACK

php artisan config:cache

php artisan serve --host=127.0.0.1 --port=8001 &
PID=$!
sleep 5

if ! curl -f http://127.0.0.1:8001/api/v1/health; then
  echo "❌ Rollback health check failed! Manual intervention needed."
  kill $PID
  exit 1
fi
kill $PID

# Switch symlink ke rollback version
ln -nfs /var/www/grosirun/$ROLLBACK /var/www/grosirun/current

# Reload services
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx
sudo supervisorctl restart grosirun-worker:*

# Notify Slack
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"🚨 Grosirun rollback to '$ROLLBACK' automated"}' \
  $SLACK_WEBHOOK

echo "✅ Rollback to $ROLLBACK completed"
```

### 7.3 Trigger Rollback Otomatis

**Di `deploy.yml`:**

```yaml
- name: Health check (5 retries)
  run: |
    for i in {1..5}; do
      if curl -f https://api.grosirun.id/api/v1/health; then
        break
      else
        sleep 5
        if [ $i -eq 5 ]; then
          # ❌ Gagal 5 kali → rollback
          ssh $VPS_HOST "cd /var/www/grosirun && ./rollback.sh"
          exit 1
        fi
      fi
    done
```

---

## 8. Manajemen Secrets

### 8.1 GitHub Secrets yang Dibutuhkan

| Nama Secret                | Keterangan                             | Diperlukan di Workflow    |
| -------------------------- | -------------------------------------- | ------------------------- |
| `VPS_SSH_KEY`              | Private key SSH ke VPS                 | deploy.yml                |
| `VPS_HOST`                 | IP/Domain VPS (contoh: 123.45.67.89)   | deploy.yml                |
| `VPS_USER`                 | Username SSH (contoh: ubuntu)          | deploy.yml                |
| `FIREBASE_APP_ID`          | Firebase App ID untuk App Distribution | build-apk.yml             |
| `FIREBASE_SERVICE_ACCOUNT` | JSON Service Account Firebase          | build-apk.yml             |
| `SENTRY_DSN`               | Sentry DSN untuk error tracking        | build-apk.yml             |
| `SLACK_WEBHOOK`            | Slack Incoming Webhook URL             | deploy.yml, build-apk.yml |

### 8.2 Cara Setup Secrets

1. Buka repository GitHub
2. Settings → Secrets and variables → Actions
3. Klik "New repository secret"
4. Masukkan Nama dan Nilai

### 8.3 Environment Variables di VPS (Tidak di GitHub)

File `.env.prod` disimpan langsung di VPS di `/var/www/grosirun/blue/.env.prod` dan `/var/www/grosirun/green/.env.prod` (salin dari vault 1Password).

```bash
# .env.prod (contoh)
APP_ENV=production
APP_DEBUG=false

DB_HOST=localhost
DB_DATABASE=grosirun
DB_USERNAME=grosirun
DB_PASSWORD=secret

REDIS_HOST=localhost
REDIS_PORT=6379

FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=ap-southeast-1
AWS_BUCKET=grosirun-prod-private

SENTRY_LARAVEL_DSN=https://...
SLACK_WEBHOOK=https://hooks.slack.com/...
```

---

## 9. Notifikasi Slack

### 9.1 Konfigurasi Webhook

1. Buat Slack App → Incoming Webhooks
2. Tambahkan ke channel `#grosirun-ci` dan `#grosirun-alerts`
3. Copy Webhook URL → simpan sebagai `SLACK_WEBHOOK` di GitHub Secrets

### 9.2 Format Notifikasi

**Notifikasi Sukses:**

```json
{
  "text": "✅ Deploy Blue-Green sukses!\nRepo: grosirun\nCommit: abc123\nAuthor: @dev\nRef: main\nWorkflow: Deploy Blue-Green\nStatus: success"
}
```

**Notifikasi Gagal:**

```json
{
  "text": "❌ Deploy Blue-Green gagal!\nRepo: grosirun\nCommit: abc123\nAuthor: @dev\nRef: main\nWorkflow: Deploy Blue-Green\nStatus: failure\nAction: ./rollback.sh telah dijalankan otomatis"
}
```

**Notifikasi Rollback:**

```json
{
  "text": "🚨 Rollback otomatis triggered!\nDari: blue\nKe: green\nAlasan: Health check gagal 5x\nTim: @backend-lead @infra"
}
```

### 9.3 Channel Tujuan

| Channel            | Tujuan Notifikasi                    |
| ------------------ | ------------------------------------ |
| `#grosirun-ci`     | Semua workflow (test, deploy, build) |
| `#grosirun-alerts` | Hanya gagal/rollback/urgent          |
| `@backend-lead`    | Mention jika rollback terjadi        |

---

## 10. Tabel Ringkasan Workflow

| Workflow        | Trigger         | Durasi Estimasi | Output                          |
| --------------- | --------------- | --------------- | ------------------------------- |
| `test.yml`      | PR ke develop   | 5-8 menit       | Status test, coverage, APK size |
| `test.yml`      | Push ke develop | 5-8 menit       | Status test                     |
| `deploy.yml`    | Push ke main    | 3-5 menit       | Deploy ke VPS (blue-green)      |
| `build-apk.yml` | Tag v*.*.\*     | 5-7 menit       | APK + Firebase Distribution     |

### 10.1 Status Check yang Wajib

```
✅ backend-test       # PHPUnit/Pest lulus, coverage >80%
✅ frontend-test      # Flutter analyze 0, test lulus, APK <10MB
✅ k6-smoke           # Smoke test 10 VU lulus
✅ CODEOWNERS         # Minimal 1 approval
```

---

**CI/CD V3.1 Production Ready - Semua gate otomatis, zero-downtime, rollback otomatis, canary 10%!** 🚀
