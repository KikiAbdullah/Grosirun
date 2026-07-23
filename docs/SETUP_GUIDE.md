# PANDUAN INSTALASI LENGKAP - Grosirun V3.1

**Backend:** Laravel 11.34+ + PHP 8.3 + MySQL 8.0 + Redis 7.2 + S3 + Composer 2.7  
**Mobile:** Flutter 3.22.3 + Dart 3.4.4 + Android SDK 34 + NDK 26.1 + Dio + Hive + FCM + DeepLink  
**Target:** `flutter run` sampai Home Beranda PO + `http://localhost:8000/api/v1/health` → `{"status":"ok","db":"connected","redis":"connected","s3":"connected"}`  
**Waktu:** Docker 15 menit (Recommended) | Native 60-90 menit  
**OS:** Windows 10/11, macOS 12+ (Intel/M1), Ubuntu 22.04  
**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Owner:** Engineering
**Review Cycle:** Setiap release
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)
**Status Dokumen:** Final
**Status Implementasi:** Flutter Ready for Integration | Backend Not Started

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Prasyarat Sistem
3. Struktur Monorepo
4. Metode Instalasi: Docker vs Native
5. Opsi A: Docker (15 Menit - Rekomendasi)
   - 5.1 Instalasi Docker
   - 5.2 Clone Repository
   - 5.3 docker-compose.yml
   - 5.4 backend/Dockerfile
   - 5.5 backend/docker/nginx.conf
   - 5.6 Environment .env
   - 5.7 Up & Running
6. Opsi B: Native Setup (60-90 Menit)
   - 6.1 Windows 10/11 (Laragon)
   - 6.2 macOS (Homebrew)
   - 6.3 Ubuntu 22.04 (apt)
7. Firebase FCM Setup
8. S3 Setup (MinIO & AWS)
9. WA Gateway Fonnte
10. Flutter Setup
    - 10.1 Install Flutter SDK
    - 10.2 Install Android Studio + SDK + Emulator
    - 10.3 Setup Project & Pub Get
    - 10.4 Firebase google-services.json
    - 10.5 Env API Base URL
    - 10.6 Struktur Folder
    - 10.7 Jalankan di Emulator & HP Fisik
    - 10.8 Build APK Release <10MB
11. End-to-End Test OTP
12. Troubleshooting Decision Tree
13. Checklist Pre-Development

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Tujuan Dokumentasi Ini

Panduan ini membantu developer menyiapkan lingkungan pengembangan Grosirun V3.1 dengan cepat dan konsisten. Ada dua opsi:

| Opsi                     | Waktu       | Kelebihan                                          | Kekurangan                                  |
| ------------------------ | ----------- | -------------------------------------------------- | ------------------------------------------- |
| **Docker (Rekomendasi)** | 15 menit    | Environment konsisten, semua dependency terisolasi | Butuh RAM 4GB untuk Docker                  |
| **Native**               | 60-90 menit | Performa lebih cepat, debug lebih mudah            | Setup lebih kompleks, environment beda-beda |

### 1.2 Konteks Bisnis (Referensi [BUSINESS_ANALYSIS.md](BUSINESS_ANALYSIS.md))

| Komponen              | Nilai                          |
| --------------------- | ------------------------------ |
| Platform Fee          | 1% GMV + PPN 11%               |
| GMV per PO AT_70      | Rp8.400.000 (700Kg × Rp12.000) |
| Laba Initiator per PO | Rp956.760                      |
| Target Adopsi         | 70% (35 dari 50 KK)            |

**Aplikasi ini menangani transaksi uang riil dan data pribadi warga. Setup yang benar dan konsisten sangat penting untuk menghindari bug di produksi.**

---

## 2. Prasyarat Sistem

| Komponen             | Minimum   | Rekomendasi             | Perintah Cek                                   |
| -------------------- | --------- | ----------------------- | ---------------------------------------------- |
| **Docker + Compose** | 20.10+    | Latest                  | `docker --version`<br>`docker compose version` |
| **PHP**              | 8.3       | 8.3.9                   | `php -v`                                       |
| **Composer**         | 2.7+      | Latest                  | `composer -v`                                  |
| **Flutter**          | 3.22.0    | 3.22.3                  | `flutter --version`                            |
| **Android SDK**      | 34        | 34 + NDK 26             | -                                              |
| **Git**              | 2.40+     | Latest                  | `git --version`                                |
| **RAM**              | 8GB       | 16GB (Docker butuh 4GB) | Task Manager / `free -h`                       |
| **Disk**             | 20GB free | 50GB SSD                | `df -h`                                        |
| **Node**             | 18+       | Latest                  | `node -v`                                      |

---

## 3. Struktur Monorepo

```
grosirun/
├── backend/                     # Laravel 11 API
│   ├── Dockerfile
│   ├── Dockerfile.prod
│   ├── docker/
│   │   ├── nginx.conf
│   │   ├── nginx.prod.conf
│   │   ├── php.ini
│   │   └── supervisord.conf
│   ├── load-test/               # k6 scripts
│   │   ├── k6-deadline-rush.js
│   │   ├── k6-orders-race.js
│   │   └── k6-recap-heavy.js
│   ├── .env.example
│   └── ...
├── mobile/                      # Flutter 3.22+
│   ├── lib/
│   ├── android/
│   ├── test/
│   └── pubspec.yaml
├── docs/                        # Dokumentasi (27 file markdown)
├── docker-compose.yml           # Development
├── docker-compose.prod.yml      # Production override
├── .github/
│   └── workflows/
│       ├── test.yml
│       ├── deploy.yml
│       └── build-apk.yml
└── README.md
```

---

## 4. Metode Instalasi: Docker vs Native

| Metode                             | Kelebihan                                                                                                  | Kekurangan                                                      | Cocok Untuk                 |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------- |
| **A. Docker**                      | Env sama semua dev (PHP 8.3 + MySQL 8 + Redis 7 + Nginx + MinIO S3), setup 15 menit, tidak kotorin OS host | Butuh Docker Desktop RAM 4GB, sedikit lebih lambat di Windows   | Tim, onboarding baru, pilot |
| **B. Native Laragon/Homebrew/apt** | Lebih cepat di local, native debug, PHPStorm/Xdebug mudah                                                  | Env beda-beda, setup 60 menit, MySQL/Redis harus install manual | Solo dev, sudah ada PHP     |

**Rekomendasi Grosirun V3.1:** Pakai **Docker Metode A** untuk 15 menit jadi. Jika kamu sudah punya Laragon/XAMPP, lanjut Metode B.

---

## 5. Opsi A: Docker (15 Menit - Rekomendasi)

### 5.1 Instalasi Docker

**Windows:**

1. Download Docker Desktop https://www.docker.com/products/docker-desktop/
2. Install + centang WSL2 backend
3. Restart PC, buka Docker Desktop tunggu Running
4. Buka PowerShell cek:

```powershell
docker --version
docker compose version
```

**macOS:**

```bash
brew install --cask docker
# Buka Docker dari Applications, tunggu Running
docker --version
```

**Ubuntu:**

```bash
sudo apt update
sudo apt install docker.io docker-compose-v2 -y
sudo usermod -aG docker $USER
newgrp docker
docker --version
```

### 5.2 Clone Repository

```bash
git clone https://github.com/username/grosirun.git
cd grosirun
ls -1
# Harus ada docker-compose.yml, backend/, mobile/, docs/
```

### 5.3 docker-compose.yml

**File:** `docker-compose.yml` (sudah ada di root)

```yaml
version: "3.8"

services:
  # ============ BACKEND APP ============
  app:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: grosirun_app
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./backend:/var/www/html
      - ./backend/storage/logs:/var/www/html/storage/logs
    networks:
      - grosirun
    depends_on:
      - mysql
      - redis
    environment:
      - DB_HOST=mysql
      - REDIS_HOST=redis
      - FILESYSTEM_DISK=public
    ports:
      - "8000:9000"
    command: sh -c "php artisan serve --host=0.0.0.0 --port=9000"

  # ============ NGINX ============
  nginx:
    image: nginx:1.24-alpine
    container_name: grosirun_nginx
    restart: unless-stopped
    volumes:
      - ./backend:/var/www/html
      - ./backend/docker/nginx.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "8000:80"
    depends_on:
      - app
    networks:
      - grosirun

  # ============ MYSQL 8 ============
  mysql:
    image: mysql:8.0
    container_name: grosirun_mysql
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: grosirun
      MYSQL_ROOT_PASSWORD: root
      MYSQL_PASSWORD: secret
      MYSQL_USER: grosirun
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - grosirun
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

  # ============ REDIS 7 ============
  redis:
    image: redis:7.2-alpine
    container_name: grosirun_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - grosirun

  # ============ QUEUE WORKER ============
  queue:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: grosirun_queue
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./backend:/var/www/html
    depends_on:
      - mysql
      - redis
    command: php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
    networks:
      - grosirun

  # ============ SCHEDULER ============
  scheduler:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: grosirun_scheduler
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./backend:/var/www/html
    depends_on:
      - mysql
      - redis
    command: sh -c "while true; do php artisan schedule:run --no-interaction; sleep 60; done"
    networks:
      - grosirun

  # ============ MINIO (S3 Local) ============
  minio:
    image: minio/minio:latest
    container_name: grosirun_minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    networks:
      - grosirun

volumes:
  mysql_data:
  redis_data:
  minio_data:

networks:
  grosirun:
    driver: bridge
```

### 5.4 backend/Dockerfile

**File:** `backend/Dockerfile`

```dockerfile
FROM php:8.3-fpm-alpine

# ============ SYSTEM DEPENDENCIES ============
RUN apk add --no-cache \
    nginx supervisor \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev icu-dev mysql-client oniguruma-dev libxml2-dev \
    imagemagick-dev

# ============ PHP EXTENSIONS ============
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd pdo_mysql mbstring zip exif pcntl bcmath opcache

# ============ PECL EXTENSIONS ============
RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis

# ============ COMPOSER ============
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction \
    || composer install --optimize-autoloader

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000 80

CMD ["php-fpm"]
```

### 5.5 backend/docker/nginx.conf

**File:** `backend/docker/nginx.conf`

```nginx
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php;

    client_max_body_size 10M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 60s;
    }

    # Deny .env files
    location ~ /\.env {
        deny all;
    }

    # Deny .htaccess
    location ~ /\.ht {
        deny all;
    }
}
```

### 5.6 Environment .env

**File:** `backend/.env`

```bash
# Buat dari .env.example
cp backend/.env.example backend/.env

# Edit backend/.env
nano backend/.env
```

**Isi minimal untuk Docker:**

```ini
APP_NAME=Grosirun
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=grosirun
DB_USERNAME=grosirun
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

QUEUE_CONNECTION=redis
CACHE_STORE=redis
SESSION_DRIVER=redis

FILESYSTEM_DISK=public

FONNTE_API_KEY=your_fonnte_token_local
FIREBASE_CREDENTIALS=storage/app/firebase/firebase_credentials.json

TELESCOPE_ENABLED=true
PULSE_ENABLED=false
```

### 5.7 Up & Running

```bash
# 1. Build dan jalankan containers
docker compose up -d --build

# 2. Cek status
docker compose ps
# Harusnya 7 containers: app, nginx, mysql, redis, queue, scheduler, minio

# 3. Install Composer dependencies
docker compose exec app composer install

# 4. Generate APP_KEY
docker compose exec app php artisan key:generate

# 5. Migrasi + Seed (buat cluster default PGH-RT03)
docker compose exec app php artisan migrate --seed

# 6. Storage link
docker compose exec app php artisan storage:link

# 7. Cache config (opsional)
docker compose exec app php artisan config:cache

# 8. Health check
curl http://localhost:8000/api/v1/health

# Expected:
# {"status":"ok","db":"connected","redis":"connected","s3":"connected","version":"v1.0.0"}
```

**Keuntungan Docker:** Semua developer punya environment yang sama (MySQL 8 + Redis 7 + PHP 8.3 + Nginx + MinIO). Setup 15 menit.

**Jika error `port 8000 already in use`:** Matikan XAMPP/Laragon atau ganti port di `docker-compose.yml` `8000:80` jadi `8001:80`.

---

## 6. Opsi B: Native Setup (60-90 Menit)

### 6.1 Windows 10/11 (Laragon)

**Kenapa Laragon?** 1-klik PHP 8.3 + MySQL 8 + Redis + Nginx + Composer, tidak perlu XAMPP config ribet.

**Langkah 1: Install Laragon**

1. Download Laragon Full https://laragon.org/download/ → Laragon Full 6.0
2. Install di `C:\laragon`, centang Auto virtual hosts
3. Buka Laragon → klik **Start All** (Nginx, MySQL, Redis, PHP)
4. Klik Menu → PHP → Version → pilih **php-8.3** (jika belum ada, Menu → Tools → Quick Add → php-8.3)
5. Klik Menu → Tools → Quick Add → Redis, MySQL 8
6. Cek:

```powershell
php -v
# PHP 8.3.x
composer -v
# 2.7+
mysql --version
redis-cli ping
# PONG
```

**Langkah 2: Setup Database**

Buka HeidiSQL via Laragon → Menu → Database → Open HeidiSQL → New Session root no password → Buat DB:

```sql
CREATE DATABASE grosirun CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'grosirun'@'localhost' IDENTIFIED BY 'secret';
GRANT ALL PRIVILEGES ON grosirun.* TO 'grosirun'@'localhost';
FLUSH PRIVILEGES;
```

Atau via terminal Laragon Terminal:

```bash
mysql -u root -e "CREATE DATABASE grosirun CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER 'grosirun'@'localhost' IDENTIFIED BY 'secret'; GRANT ALL ON grosirun.* TO 'grosirun'@'localhost'; FLUSH PRIVILEGES;"
```

**Langkah 3: Clone & Env**

```powershell
cd C:\laragon\www
git clone https://github.com/username/grosirun.git
cd grosirun\backend
copy .env.example .env
notepad .env
```

Isi untuk Laragon Native:

```
APP_URL=http://localhost:8000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=grosirun
DB_USERNAME=grosirun
DB_PASSWORD=secret
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
QUEUE_CONNECTION=redis
CACHE_STORE=redis
FILESYSTEM_DISK=public
```

**Langkah 4: Install & Migrate**

Buka Laragon Terminal di folder backend:

```bash
composer install
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```

Buka http://localhost:8000/api/v1/health → ok

**Terminal kedua untuk queue:**

```bash
cd C:\laragon\www\grosirun\backend
php artisan queue:work redis --sleep=3 --tries=3
```

**Terminal ketiga scheduler:**

```bash
php artisan schedule:work
```

### 6.2 macOS (Homebrew)

**Langkah 1: Install Brew + PHP 8.3 + MySQL + Redis**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew install php@8.3 composer mysql@8.0 redis node

brew services start php@8.3
brew services start mysql@8.0
brew services start redis

php -v
# 8.3
composer -v
mysql --version
redis-cli ping
# PONG
```

**Langkah 2: Buat DB**

```bash
mysql -u root
CREATE DATABASE grosirun CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'grosirun'@'localhost' IDENTIFIED BY 'secret';
GRANT ALL PRIVILEGES ON grosirun.* TO 'grosirun'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Langkah 3: Clone & Setup**

```bash
cd ~/development
git clone https://github.com/username/grosirun.git
cd grosirun/backend
cp .env.example .env
nano .env
# Isi DB_HOST=127.0.0.1 DB_DATABASE=grosirun DB_USERNAME=grosirun DB_PASSWORD=secret REDIS_HOST=127.0.0.1

composer install
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 2 queue:
php artisan queue:work redis

# Terminal 3 scheduler:
php artisan schedule:work
```

### 6.3 Ubuntu 22.04 (apt)

**Langkah 1: Add PPA + Install**

```bash
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php8.3 php8.3-cli php8.3-common php8.3-mysql php8.3-zip php8.3-gd php8.3-mbstring php8.3-curl php8.3-xml php8.3-bcmath php8.3-redis php8.3-imagick mysql-server redis-server composer nodejs npm -y

sudo systemctl start mysql redis-server
sudo systemctl enable mysql redis-server

php -v
composer -v
mysql --version
redis-cli ping
```

**Langkah 2: Secure MySQL + Buat DB**

```bash
sudo mysql
CREATE DATABASE grosirun CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'grosirun'@'localhost' IDENTIFIED BY 'secret';
GRANT ALL PRIVILEGES ON grosirun.* TO 'grosirun'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Langkah 3: Clone & Setup**

```bash
cd ~/grosirun
cd backend
cp .env.example .env
nano .env
composer install
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
php artisan queue:work redis --sleep=3 --tries=3
php artisan schedule:work
```

### 6.4 Queue & Scheduler (Native)

```bash
# Terminal 2: Queue worker
php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600

# Terminal 3: Scheduler
php artisan schedule:work
```

---

## 7. Firebase FCM Setup

### 7.1 Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Buat project `grosirun-dev` (atau gunakan existing)
3. Tambahkan Android app:
   - Package name: `com.grosirun.app`
   - App nickname: `Grosirun Dev`
   - SHA-1: skip (FCM tetap berjalan)
4. Download `google-services.json` → simpan di `mobile/android/app/google-services.json`
5. Project Settings → Service Accounts → Generate new private key
6. Download JSON → simpan di `backend/storage/app/firebase/firebase_credentials.json`

### 7.2 Verifikasi

```bash
# Cek file ada
ls -la mobile/android/app/google-services.json
ls -la backend/storage/app/firebase/firebase_credentials.json

# Test FCM token di Flutter (nanti)
```

---

## 8. S3 Setup (MinIO & AWS)

### 8.1 Development: MinIO (Docker)

**Sudah termasuk di docker-compose.yml** (service minio).

```bash
# Up MinIO
docker compose up -d minio

# Akses Console
# http://localhost:9001 (minioadmin/minioadmin)

# Buat bucket: grosirun-local (private)
```

**Update .env untuk test S3:**

```ini
FILESYSTEM_DISK=s3
AWS_ENDPOINT=http://minio:9000
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_BUCKET=grosirun-local
AWS_USE_PATH_STYLE_ENDPOINT=true
AWS_DEFAULT_REGION=ap-southeast-1
```

**Test Upload:**

```bash
docker compose exec app php artisan tinker
```

```php
Storage::disk('s3')->put('test.txt', 'Hello S3');
Storage::disk('s3')->exists('test.txt'); // true
Storage::disk('s3')->temporaryUrl('test.txt', now()->addHour());
// Copy URL → buka browser → file terdownload
```

### 8.2 Production: AWS S3

**1. Buat bucket:**

```bash
aws s3api create-bucket \
  --bucket grosirun-prod-private \
  --region ap-southeast-1 \
  --create-bucket-configuration LocationConstraint=ap-southeast-1
```

**2. Block public access:**

```bash
aws s3api put-public-access-block \
  --bucket grosirun-prod-private \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

**3. Enable versioning:**

```bash
aws s3api put-bucket-versioning \
  --bucket grosirun-prod-private \
  --versioning-configuration Status=Enabled
```

**4. Lifecycle rule (90 days):**

```json
{
  "Rules": [
    {
      "ID": "delete-old-proofs-90d",
      "Filter": { "Prefix": "order_proofs/" },
      "Status": "Enabled",
      "Expiration": { "Days": 90 },
      "NoncurrentVersionExpiration": { "NoncurrentDays": 7 }
    }
  ]
}
```

```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket grosirun-prod-private \
  --lifecycle-configuration file://s3-lifecycle.json
```

**5. Update .env.prod:**

```ini
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=ap-southeast-1
AWS_BUCKET=grosirun-prod-private
AWS_USE_PATH_STYLE_ENDPOINT=false
```

---

## 9. WA Gateway Fonnte

### 9.1 Setup

1. Daftar di [Fonnte](https://fonnte.com/)
2. Scan QR Code dengan WhatsApp
3. Dapatkan token

### 9.2 Update .env

```ini
FONNTE_API_KEY=your_token_here
FONNTE_SENDER=6281234567890  # Nomor WA yang sudah terdaftar
```

### 9.3 Test

```bash
curl -X POST https://api.fonnte.com/send \
  -H "Authorization: YOUR_TOKEN" \
  -d "target=6281234567890" \
  -d "message=Test OTP Grosirun: 1234"
```

### 9.4 Local Dev (Tanpa Kuota)

Di `OtpService`, log OTP ke file saat local:

```php
if (app()->environment('local')) {
    Log::channel('otp')->info("OTP for {$phone}: {$otp}");
}
```

**File:** `storage/logs/otp.log`

---

## 10. Flutter Setup

### 10.1 Install Flutter SDK

**Official:** https://docs.flutter.dev/get-started/install

**Windows:**

1. Download Flutter ZIP stable 3.22.3 https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.3-stable.zip
2. Ekstrak ke `C:\src\flutter` (buat folder `C:\src` dulu, jangan di `C:\Program Files` ada spasi)

**macOS Intel:**

```bash
mkdir -p ~/development
cd ~/development
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.22.3-stable.zip
unzip flutter_macos_3.22.3-stable.zip
```

**macOS M1/Apple Silicon:**

```bash
mkdir -p ~/development
cd ~/development
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.22.3-stable.zip
unzip flutter_macos_arm64_3.22.3-stable.zip
```

**Linux Ubuntu:**

```bash
mkdir -p ~/development
cd ~/development
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz
tar xf flutter_linux_3.22.3-stable.tar.xz
```

### 10.2 Tambah Flutter ke PATH

**Windows:**

1. Buka System Properties → Environment Variables → User Variables Path → Edit → New → `C:\src\flutter\bin`
2. OK, OK, restart PowerShell/CMD

**macOS/Linux:**

Buka `~/.zshrc` (atau `~/.bashrc`):

```bash
nano ~/.zshrc
# Tambah baris:
export PATH="$PATH:$HOME/development/flutter/bin"
# Save, lalu:
source ~/.zshrc
```

### 10.3 Verifikasi Flutter Doctor

Buka terminal baru (agar PATH reload):

```bash
flutter --version
# Flutter 3.22.3 • channel stable • ...

flutter doctor
# Akan cek Android toolchain, Android Studio, VS Code, Connected device
# Ikuti petunjuk [✓] hijau semua minimal 3: Flutter, Android toolchain, Android Studio
```

### 10.4 Install Android Studio + Android SDK + Emulator

**Download Android Studio:** https://developer.android.com/studio → Download Android Studio Iguana+ latest.

**Install:** Next Next, centang Android SDK, Android SDK Platform, Android Virtual Device.

**SDK Manager:**

- Tab SDK Platforms: centang **Android 14.0 (API 34)** + **Android 7.0 (API 24)** (minSdk Grosirun 24)
- Tab SDK Tools: centang **Android SDK Build-Tools 34**, **Android SDK Command-line Tools**, **Android Emulator**, **Android SDK Platform-Tools**, **NDK 26.1.10909125** (untuk obfuscate + build)

**Set Android SDK Command-line Tools Path (Untuk flutter doctor):**

**Windows:** Tambah env `ANDROID_HOME` = `C:\Users\%USERNAME%\AppData\Local\Android\Sdk`, add to PATH `%ANDROID_HOME%\platform-tools` + `%ANDROID_HOME%\emulator`

**macOS/Linux:** Tambah di `~/.zshrc`:

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk # macOS
export ANDROID_HOME=$HOME/Android/Sdk # Linux
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
source ~/.zshrc
```

**Buat Emulator AVD:**

Android Studio → More Actions → Virtual Device Manager → Create Device:

- Pilih **Pixel 7** + System Image **Tiramisu API 34 Google APIs** → Download → Next → Finish
- Start emulator, tunggu booting Android.

```bash
flutter emulators
flutter emulators --launch Pixel_7_API_34
flutter devices
# Harus ada emulator Pixel 7
```

**Accept Android Licenses:**

```bash
flutter doctor --android-licenses
# Tekan y semua sampai selesai

flutter doctor
# Harus semua centang hijau minimal 3
```

### 10.5 Setup Project Grosirun Mobile

**Clone Repo Monorepo:**

```bash
cd ~/development # atau C:\src\projects
git clone https://github.com/username/grosirun.git
cd grosirun/mobile
```

**pubspec.yaml Grosirun V3.1:**

```yaml
name: grosirun_app
environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  dio: ^5.4.3
  retrofit: ^4.1.0
  json_annotation: ^4.9.0
  flutter_secure_storage: ^9.0.0
  hive_flutter: ^1.1.0
  sqflite: ^2.3.3
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.3.0
  lottie: ^3.1.2
  share_plus: ^8.0.2
  firebase_core: ^2.31.0
  firebase_messaging: ^14.9.0
  firebase_analytics: ^10.10.0
  firebase_crashlytics: ^3.5.0
  firebase_performance: ^0.9.3+8
  connectivity_plus: ^6.0.3
  app_links: ^5.0.1
  intl: ^0.19.0
  uuid: ^4.3.3
  flutter_local_notifications: ^17.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0
```

**Install:**

```bash
flutter pub get

# Jika error version solving
flutter pub upgrade

# Build runner for json_serializable + retrofit
flutter pub run build_runner build --delete-conflicting-outputs
```

### 10.6 Firebase google-services.json

1. Download `google-services.json` dari Firebase Console
2. Letakkan di `mobile/android/app/google-services.json`
3. Firebase credentials JSON di `backend/storage/app/firebase/firebase_credentials.json`

### 10.7 Env API Base URL

**File:** `mobile/lib/core/constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1', // emulator Android ke host
  );
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
```

**Kenapa 10.0.2.2?** Emulator Android punya host loopback sendiri, `localhost` di emulator = emulator itu sendiri, bukan laptop. `10.0.2.2` adalah alias host laptop dari emulator.

- **Emulator**: `http://10.0.2.2:8000/api/v1`
- **Real device + laptop same WiFi**: cari IP laptop `ipconfig` atau `ifconfig`, misal `192.168.1.5`, baseUrl `http://192.168.1.5:8000/api/v1`
- **Prod**: `https://api.grosirun.id/api/v1`

### 10.8 Jalankan di Emulator & HP Fisik

**Emulator:**

```bash
flutter emulators --launch Pixel_7_API_34
flutter devices
# Harus ada emulator

flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

**HP Fisik Android:**

1. HP → Pengaturan → Tentang Ponsel → Tap **Nomor Bentukan** 7x → Developer
2. Kembali → Pengaturan → Opsi Developer → Aktifkan **USB Debugging**
3. Colok HP ke laptop via USB, Allow debugging
4. Cek:

```bash
adb devices
# Harus ada device ID

flutter devices
# Harus ada HP model

# Cari IP laptop
# Windows: ipconfig → IPv4 192.168.1.5
# macOS/Linux: ifconfig → en0 192.168.1.5

# Pastikan HP & laptop satu WiFi

flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000/api/v1
```

### 10.9 Struktur Folder + Hive Init

```
mobile/lib/
├── core/
│   ├── network/dio_client.dart (Bearer + Idempotency + ETag + Retry)
│   ├── storage/hive_service.dart
│   ├── deeplink/app_links_service.dart
│   ├── fcm/fcm_service.dart
│   ├── error/error_boundary.dart
│   └── constants.dart
├── data/
│   ├── models/
│   ├── datasources/remote/
│   ├── datasources/local/
│   └── repositories/
├── logic/cubits/
└── presentation/screens/
```

**Main init Hive:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('campaignsBox');
  await Hive.openBox('ordersBox');
  await Hive.openBox('pendingQueueBox');
  await Hive.openBox('notificationsBox');
  await Hive.openBox('appStateBox');
  await Hive.openBox('etagBox');
  await Hive.openBox('idempotencyBox');

  Bloc.observer = AppBlocObserver();

  runApp(MultiBlocProvider(... child: GrosirunApp()));
}
```

### 10.10 Build APK Release <10MB

**Build Split ABI:**

```bash
cd mobile
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Prod S3 primary API
flutter build apk --release --split-per-abi --obfuscate \
  --split-debug-info=./build/debug-info \
  --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1 \
  --dart-define=SENTRY_DSN=https://...@sentry.io/...

# Output:
# app-arm64-v8a-release.apk <10MB # target; belum diukur
# app-armeabi-v7a-release.apk ~7.2MB
# app-x86_64-release.apk ~8.5MB

ls -lh build/app/outputs/apk/release/*.apk
# Harus <10MB each

# Analyze size detail
flutter build apk --release --analyze-size --split-per-abi --obfuscate
```

**Tips size <10MB:**

- Split ABI `--split-per-abi` (wajib)
- Obfuscate `--obfuscate --split-debug-info`
- shrinkResources true minifyEnabled true di build.gradle
- WebP assets not PNG
- No google_maps, no camera full
- Lottie JSON trim <100KB

**Build AAB untuk Play Store:**

```bash
flutter build appbundle --release --obfuscate \
  --split-debug-info=./build/debug-info \
  --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1
```

---

## 11. End-to-End Test OTP

### 11.1 Health Check

```bash
curl http://localhost:8000/api/v1/health
# {"status":"ok","db":"connected","redis":"connected","s3":"connected"}
```

### 11.2 Request OTP

```bash
curl -X POST http://localhost:8000/api/v1/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"081234567890","cluster_code":"PGH-RT03"}'
# {"message":"OTP dikirim"}
```

### 11.3 Cek OTP di Log

```bash
# Docker
docker compose exec app cat storage/logs/laravel.log | grep OTP

# Native
tail -f storage/logs/laravel.log | grep OTP
# OTP for 6281234567890: 1234
```

### 11.4 Verify OTP

```bash
curl -X POST http://localhost:8000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number":"081234567890",
    "otp":"1234",
    "consent":true,
    "tos":true,
    "cluster_code":"PGH-RT03",
    "consent_version":"v1.0",
    "tos_version":"v1.0"
  }'
# {"data":{"token":"1|...","user":{...}}}
```

---

## 12. Troubleshooting Decision Tree

```
[App tidak bisa jalan?]
  │
  ├─ Backend 500?
  │   ├─ docker compose logs app → cek .env DB_HOST=mysql (bukan 127.0.0.1)
  │   ├─ php artisan migrate → SQLSTATE access denied → cek DB_PASSWORD=secret
  │   ├─ Storage link 404 image → php artisan storage:link + chmod 775 storage
  │   └─ S3 error → cek AWS credentials + endpoint + bucket exists
  │
  ├─ OTP tidak masuk?
  │   ├─ Local dev? Cek storage/logs/laravel.log OTP plain ada?
  │   ├─ Fonnte token salah? Test curl manual
  │   ├─ Rate limit 429? Cek redis-cli KEYS "rl:otp:*"
  │   └─ Phone format? Harus 08xxx, normalisasi jadi 628
  │
  ├─ Flutter Dio Connection refused?
  │   ├─ Emulator? baseUrl harus 10.0.2.2:8000
  │   ├─ Real device? baseUrl IP laptop (192.168.1.x), same WiFi
  │   ├─ Docker? curl http://localhost:8000/api/v1/health harus 200
  │   └─ Cleartext HTTP? AndroidManifest usesCleartextTraffic true
  │
  ├─ S3 Upload 413?
  │   ├─ PHP upload_max_filesize 10M di docker/php.ini
  │   └─ Nginx client_max_body_size 10M
  │
  ├─ Race condition oversell?
  │   ├─ Cek OrderService lockForUpdate ada?
  │   ├─ Test k6: backend/load-test/k6-deadline-rush.js
  │   └─ Check DB variant.sold after test
  │
  ├─ FCM tidak masuk?
  │   ├─ google-services.json ada?
  │   ├─ Firebase credentials JSON ada?
  │   ├─ FCM fallback? Cek notifications table
  │   └─ Token null? POST /auth/fcm-token setelah login
  │
  └─ APK >10MB?
      ├─ flutter build apk --analyze-size
      ├─ Cek pubspec ada google_maps? Hapus
      └─ PNG → WebP, Lottie trim
```

### 12.1 Masalah Spesifik Flutter

| Masalah                                              | Penyebab                                       | Solusi                                                                                                                       |
| ---------------------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `flutter doctor` Android toolchain [!]               | SDK belum install                              | Android Studio SDK Manager centang API 34 + Build-Tools + Command-line Tools + NDK 26, `flutter doctor --android-licenses` y |
| `Android license status unknown`                     | Licenses belum accept                          | `flutter doctor --android-licenses`                                                                                          |
| `Dio Connection refused` emulator                    | baseUrl localhost bukan 10.0.2.2               | Emulator harus 10.0.2.2, real device IP laptop 192.168.1.x same WiFi                                                         |
| `Cleartext HTTP not permitted`                       | Android 9+ block http                          | Tambah `android:usesCleartextTraffic="true"` di AndroidManifest application                                                  |
| `google-services.json missing`                       | Belum download Firebase                        | Download dari Firebase Console, taruh `mobile/android/app/`                                                                  |
| `NDK version mismatch`                               | NDK not installed or version wrong             | `flutter clean`, update `android/app/build.gradle` `ndkVersion "26.1.10909125"`, SDK Manager install NDK 26                  |
| `APK build fails OutOfMemory Java heap`              | Gradle heap                                    | `android/gradle.properties` `org.gradle.jvmargs=-Xmx4G`                                                                      |
| `APK >10MB`                                          | Include heavy lib                              | `flutter build apk --analyze-size`, cek lib google_maps? Remove, WebP assets, Lottie trim                                    |
| `OTP tidak masuk`                                    | Backend Fonnte token salah / device disconnect | Cek backend `storage/logs/laravel.log` OTP plain local mode, test curl Fonnte manual                                         |
| `FCM token null`                                     | google-services.json prod vs dev mismatch      | Check package com.grosirun.app same, FirebaseMessaging.instance.getToken() log, POST /auth/fcm-token                         |
| `Deep link tidak buka detail`                        | intent-filter missing                          | AndroidManifest add `<intent-filter>` grosirun scheme + AppLinksService init navigatorKey                                    |
| `State persistence kill app lastRoute tidak restore` | appStateBox not saved                          | NavigatorObserver save lastRoute on push, main cold start check appStateBox lastRoute within 30min navigate                  |
| `Offline proof queue tidak sync`                     | SyncService not init / Connectivity not listen | main.dart `SyncService().init()` + `Connectivity().onConnectivityChanged.listen` + periodic 5min Timer                       |
| `Crash di HP RAM 2GB saat upload 5MB`                | Tidak compress                                 | `flutter_image_compress` compress 800x800 70% before upload                                                                  |
| `flutter run stuck Installing APK`                   | ADB device offline                             | `adb kill-server && adb start-server`, `adb devices`, cabut colok USB, allow debugging lagi                                  |

### 12.2 Masalah Spesifik Backend

| Masalah                                    | Penyebab                                                        | Solusi                                                                                                                |
| ------------------------------------------ | --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `composer install` out of memory           | RAM kecil                                                       | `COMPOSER_MEMORY_LIMIT=-1 composer install`                                                                           |
| `SQLSTATE Access denied`                   | .env DB salah / DB belum buat                                   | Cek DB_HOST mysql vs 127.0.0.1, buat DB manual, `php artisan config:clear`                                            |
| `Storage link public does not exist`       | Filesystem config                                               | `php artisan storage:link` + chmod 775 storage bootstrap/cache                                                        |
| `Firebase credentials not found`           | Path salah                                                      | Pastikan file `storage/app/firebase/firebase_credentials.json` ada 644                                                |
| `Fonnte WA tidak kirim`                    | Token salah / device disconnect                                 | Cek dashboard Fonnte, test curl manual, local mode log file                                                           |
| `Redis connection refused`                 | Redis belum jalan                                               | `redis-cli ping` harus PONG, `brew services start redis`, `sudo systemctl start redis`, `docker compose up -d redis`  |
| `Queue job tidak jalan FCM tidak terkirim` | Worker mati                                                     | Jalankan `queue:work`, cek QUEUE_CONNECTION=redis, `supervisorctl status`                                             |
| `Image upload 413 Payload Too Large`       | Nginx/PHP limit                                                 | php.ini `upload_max_filesize=10M post_max_size=10M`, nginx `client_max_body_size 10M;`                                |
| `S3 error Access Denied`                   | Bucket policy / creds salah / endpoint                          | Cek AWS keys, bucket private Block public ON, MinIO endpoint http://minio:9000 vs localhost:9000                      |
| `OTP rate limit 429 padahal baru 1x`       | IP kena throttle Redis rl:otp:\*                                | `redis-cli KEYS "rl:otp:*"` + `DEL`, `php artisan cache:clear`, cek otp_codes locked_until DB                         |
| `k6 100 VU P95 >300ms`                     | MySQL slow, no index, Redis not cache, PHP-FPM max_children low | EXPLAIN query, add index, Cache::remember 60s, increase FPM max_children 30, OPcache enable, check Pulse slow queries |
| `docker compose port 8000 already in use`  | Laragon/XAMPP pakai 8000                                        | Matikan XAMPP atau ganti docker-compose port 8000→8001, api jadi http://localhost:8001/api/v1/health                  |

---

### 12.3 Seed dan Verifikasi Alur Penawaran-ke-Campaign

Jalankan `php artisan db:seed --class=OfferCampaignSeeder`. Seeder development wajib deterministik dan membuat:

- Empat role, Buyer, Buyer+Initiator multi-role, Seller owner/sales/warehouse, dan Admin.
- Supplier `pending_verification`, `verified`, dan `suspended` beserta membership lengkap.
- Product dengan base unit kg/liter/piece, offer area, dua tier harga, dan `supplier_offer_variants`.
- Offer `draft`, `pending_review`, `active`, `paused`, `expired`, serta kapasitas available/reserved/committed yang memenuhi invariant.
- Campaign pada seluruh lifecycle: draft, active, target_reached, po_submitted, fulfillment, distribution, completed, expired, cancelled.
- Purchase order pada seluruh state, item snapshot, invoice, surat jalan, payment proof, delivery evidence, dan append-only status log.
- Fulfillment dispute open/responded/resolved serta queue verifikasi/moderasi Admin.
- Dataset race test untuk reservation dan checkout tanpa PII nyata.

Verifikasi `/auth/me` memuat `roles` dan `active_role`; Seller hanya melihat supplier membership sendiri dan selalu mendapat 403 saat meminta identitas atau proof Buyer. Seeder harus idempotent pada database development/testing dan dilarang dijalankan di production.

## 13. Checklist Pre-Development

### 13.1 Backend Checklist

- [ ] Docker: `docker compose ps` 7 containers Running + `curl /api/v1/health` 200 db redis s3 connected **atau** Native: `php artisan serve` + `queue:work` + `schedule:work` Running
- [ ] `php artisan migrate --seed` tables 9: clusters, users, otp_codes, campaigns, variants, orders, transaction_logs, notifications, personal_access_tokens
- [ ] `storage:link` + folders campaigns, order_proofs, recaps, firebase ada
- [ ] Firebase credentials JSON ada di `storage/app/firebase/`
- [ ] S3 MinIO test `Storage::disk('s3')->put('test.txt')` success tempUrl works (atau AWS S3 prod bucket private + lifecycle 90d)
- [ ] WA Gateway Fonnte token set + test curl OR local log OTP di `storage/logs/laravel.log` muncul OTP plain
- [ ] Queue worker Running `supervisorctl status` or `docker logs queue` no error + Redis PONG
- [ ] OTP flow curl request-otp + verify-otp + GET campaigns token Bearer success
- [ ] `php artisan test --parallel` coverage >80% (atau Pest tests green)
- [ ] `.env.example` updated with S3, Fonnte, Firebase, Sentry vars
- [ ] `php artisan optimize:clear` before dev, `config:cache route:cache` for prod

### 13.2 Flutter Checklist

- [ ] `flutter doctor` 3 centang hijau (Flutter, Android toolchain, Android Studio)
- [ ] `mobile/android/app/google-services.json` ada
- [ ] `flutter pub get` success + `build_runner build`
- [ ] `lib/core/constants.dart` baseUrl correct
- [ ] `flutter run --dart-define=API_BASE_URL=...` sampai Home list campaign cluster PGH-RT03 (dari seed)
- [ ] Consent checkbox + ToS checkbox UI required, POST /auth/consent + /tos-accept logs consent_at
- [ ] DeepLink test: `adb shell am start -W -a android.intent.action.VIEW -d "grosirun://campaign/12" com.grosirun.app`
- [ ] FCM background handler `_firebaseMessagingBackgroundHandler` registered
- [ ] Error boundary: `FlutterError.onError` + `PlatformDispatcher.onError`
- [ ] Offline proof queue: `pendingQueueBox` type `upload_proof`
- [ ] Idempotency-Key interceptor UUID per POST
- [ ] ETag If-None-Match 304 handling
- [ ] `flutter build apk --release --split-per-abi --obfuscate` arm64 <10MB `ls -lh`
- [ ] AAB build for Play Store
- [ ] Test install APK 3 devices Redmi 4A Android 7, Samsung A10 Android 9, Oppo A3s Android 8 login + checkout + admin validate

---
