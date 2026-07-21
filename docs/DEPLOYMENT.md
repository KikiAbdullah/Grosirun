# PANDUAN DEPLOYMENT - Grosirun V3.1

**Stack:** Laravel 11 + Docker + Nginx + PHP-FPM + S3 + Redis + Supervisor + Blue-Green Zero-Downtime  
**Mobile:** Flutter APK <10MB + Firebase App Distribution + Play Internal  
**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Arsitektur Deployment
2. Prasyarat Production
3. Build Backend Production
4. Docker Deployment Production
5. Deployment VPS Native (Nginx, PHP-FPM, Supervisor, Cron)
6. Blue-Green Zero-Downtime Strategy
7. Canary Release 10%
8. Rollback Automation & SSL Monitoring
9. Build APK Flutter <10MB
10. Distribusi APK Pilot
11. Checklist Pra-Rilis
12. Post-Launch Monitoring & Alerting
13. Disaster Recovery Plan
14. Rollback Plan Manual
15. Cheat Sheet

---

## 1. Pendahuluan & Arsitektur Deployment

### 1.1 Artefak Deployment

| Artefak         | Lokasi                    | Deskripsi                                         |
| --------------- | ------------------------- | ------------------------------------------------- |
| **Backend API** | `https://api.grosirun.id` | Laravel 11 dengan S3 primary, MySQL, Redis, Queue |
| **Mobile APK**  | Firebase App Distribution | Flutter arm64 <10MB                               |

### 1.2 Arsitektur Production V3.1

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              NGINX (443 SSL)                               │
│                         Let's Encrypt Auto-Renew                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PHP-FPM 8.3 (30 children)                        │
│                         pm.max_children = 30                               │
│                         pm.start_servers = 10                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              LARAVEL 11                                    │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────────────────┐  │
│  │     MySQL 8     │  │     Redis 7     │  │      S3 Private Bucket    │  │
│  │   Primary DB    │  │  Queue + Cache  │  │  campaigns/, order_proofs/ │  │
│  │   Read Replica  │  │                 │  │      tempUrl 1h           │  │
│  └─────────────────┘  └─────────────────┘  └───────────────────────────┘  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     Supervisor (Queue Worker)                        │   │
│  │   2 procs: php artisan queue:work redis --tries=3 --max-jobs=1000  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     Cron (Scheduler)                                 │   │
│  │   * * * * * php artisan schedule:run                                │   │
│  │   0 2 * * * php artisan backup:run --only-db                       │   │
│  │   0 3 * * * php artisan proofs:clean-old                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      OBSERVABILITY & MONITORING                             │
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐  │
│  │   Pulse     │  │   Sentry    │  │  Prometheus │  │  Grafana         │  │
│  │ Slow Queries│  │   Errors    │  │   Metrics   │  │  Dashboard       │  │
│  │ Slow Req    │  │  Crashlytics│  │             │  │  Alerts          │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └──────────────────┘  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    Slack Alerts                                     │   │
│  │   #grosirun-ci, #grosirun-alerts                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Zero-Downtime Strategy

Grosirun V3.1 menggunakan **Blue-Green Deployment** untuk memastikan zero-downtime:

| Komponen | Blue (Live)                        | Green (Idle)                        |
| -------- | ---------------------------------- | ----------------------------------- |
| Folder   | `/var/www/grosirun/blue`           | `/var/www/grosirun/green`           |
| Symlink  | `/var/www/grosirun/current → blue` | `/var/www/grosirun/current → green` |
| Status   | Menerima traffic                   | Siap deploy                         |

---

## 2. Prasyarat Production

### 2.1 Infrastruktur

| Komponen   | Spesifikasi                | Keterangan                           |
| ---------- | -------------------------- | ------------------------------------ |
| **VPS**    | 2vCPU 4GB Ubuntu 22.04     | IDCloudHost / AWS EC2 / DigitalOcean |
| **Domain** | `api.grosirun.id`          | A record → IP VPS                    |
| **SSL**    | Let's Encrypt              | Auto-renew via Certbot               |
| **MySQL**  | 8.0 Managed atau localhost | max_connections=100                  |
| **Redis**  | 7.2 Managed atau localhost | maxclients=10000                     |
| **S3**     | `grosirun-prod-private`    | ap-southeast-1, versioning ON        |

### 2.2 Software Requirements

```bash
# PHP 8.3 + Extensions
sudo apt install -y php8.3 php8.3-cli php8.3-fpm \
  php8.3-mysql php8.3-redis php8.3-gd php8.3-imagick \
  php8.3-mbstring php8.3-zip php8.3-bcmath php8.3-exif \
  php8.3-curl php8.3-xml php8.3-intl

# Nginx, Supervisor, Certbot, Composer
sudo apt install -y nginx supervisor certbot python3-certbot-nginx composer

# Node.js (untuk asset build)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### 2.3 Environment Variables

**File:** `/var/www/grosirun/backend/.env.prod` (disimpan di VPS + 1Password Vault)

```ini
APP_NAME=Grosirun
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.grosirun.id
APP_KEY=base64:...  # Dari php artisan key:generate

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=grosirun
DB_USERNAME=grosirun
DB_PASSWORD=secret

REDIS_HOST=localhost
REDIS_PASSWORD=null
REDIS_PORT=6379

QUEUE_CONNECTION=redis
CACHE_STORE=redis
SESSION_DRIVER=redis

FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=ap-southeast-1
AWS_BUCKET=grosirun-prod-private
AWS_USE_PATH_STYLE_ENDPOINT=false

S3_TEMP_URL_EXPIRY=60

FONNTE_API_KEY=...
FONNTE_SENDER=6281234567890

FIREBASE_CREDENTIALS=storage/app/firebase/firebase_credentials.json

SENTRY_LARAVEL_DSN=https://...
SLACK_WEBHOOK=https://hooks.slack.com/...

PULSE_ENABLED=true
TELESCOPE_ENABLED=false

FEATURE_QRIS_UPLOAD=true
FEATURE_EXTEND_DEADLINE=true
FEATURE_BATCH_VALIDATE=true
```

### 2.4 S3 Bucket Setup

```bash
# 1. Buat bucket private
aws s3api create-bucket \
  --bucket grosirun-prod-private \
  --region ap-southeast-1 \
  --create-bucket-configuration LocationConstraint=ap-southeast-1

# 2. Block public access
aws s3api put-public-access-block \
  --bucket grosirun-prod-private \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# 3. Enable versioning
aws s3api put-bucket-versioning \
  --bucket grosirun-prod-private \
  --versioning-configuration Status=Enabled

# 4. Lifecycle rule 90 days (order_proofs/)
aws s3api put-bucket-lifecycle-configuration \
  --bucket grosirun-prod-private \
  --lifecycle-configuration file://s3-lifecycle.json
```

**s3-lifecycle.json:**

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

---

## 3. Build Backend Production

### 3.1 Persiapan Kode

```bash
cd /var/www/grosirun/backend

# Install dependencies (tanpa dev)
composer install --no-dev --optimize-autoloader --no-interaction

# Generate key
php artisan key:generate --force

# Storage link (masih dibutuhkan untuk fallback local)
php artisan storage:link

# Jalankan migrasi (additive only!)
php artisan migrate --force

# Cache konfigurasi, route, view
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Optimasi penuh
php artisan optimize

# Cek feature flags
php artisan pennant:feature list

# Test backup ke S3
php artisan backup:run --only-db
```

### 3.2 Permission

```bash
# Set permission
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
sudo chmod -R 775 storage/logs
```

### 3.3 PHP-FPM Pool Tuning

**File:** `/etc/php/8.3/fpm/pool.d/www.conf`

```ini
pm = dynamic
pm.max_children = 30
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500
request_terminate_timeout = 60s
```

### 3.4 OPcache Tuning

**File:** `/etc/php/8.3/cli/conf.d/10-opcache.ini`

```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=32
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=0
opcache.save_comments=0
opcache.enable_file_override=1
```

---

## 4. Docker Deployment Production

### 4.1 docker-compose.prod.yml

**File:** `docker-compose.prod.yml` (override untuk production)

```yaml
version: "3.8"

services:
  app:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      - APP_ENV=production
      - FILESYSTEM_DISK=s3
    env_file:
      - ./backend/.env.prod
    restart: always
    networks:
      - grosirun
    depends_on:
      - redis
    volumes:
      - ./backend/storage:/var/www/html/storage

  nginx:
    image: nginx:1.24-alpine
    container_name: grosirun_nginx
    restart: always
    volumes:
      - ./backend:/var/www/html
      - ./backend/docker/nginx.prod.conf:/etc/nginx/conf.d/default.conf
      - /etc/letsencrypt:/etc/letsencrypt:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - app
    networks:
      - grosirun

  redis:
    image: redis:7.2-alpine
    container_name: grosirun_redis
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - grosirun

  queue:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    container_name: grosirun_queue
    restart: always
    working_dir: /var/www/html
    volumes:
      - ./backend:/var/www/html
    depends_on:
      - redis
      - app
    command: php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600 --max-jobs=1000
    networks:
      - grosirun

  scheduler:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    container_name: grosirun_scheduler
    restart: always
    working_dir: /var/www/html
    volumes:
      - ./backend:/var/www/html
    depends_on:
      - redis
      - app
    command: sh -c "while true; do php artisan schedule:run --no-interaction; sleep 60; done"
    networks:
      - grosirun

volumes:
  redis_data:

networks:
  grosirun:
    driver: bridge
```

### 4.2 Dockerfile.prod

**File:** `backend/Dockerfile.prod`

```dockerfile
FROM php:8.3-fpm-alpine

# System dependencies
RUN apk add --no-cache \
    nginx supervisor \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev icu-dev mysql-client oniguruma-dev libxml2-dev \
    imagemagick-dev

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd pdo_mysql mbstring zip exif pcntl bcmath opcache

# Imagick & Redis via PECL
RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis

# Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
```

### 4.3 Menjalankan Docker Production

```bash
# Build dan up
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Migrasi
docker compose exec app php artisan migrate --force

# Config cache
docker compose exec app php artisan config:cache

# Health check
curl https://api.grosirun.id/api/v1/health
```

### 4.4 Blue-Green dengan Docker

Untuk blue-green dengan Docker, buat dua stack:

```bash
# Blue stack (live)
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  -p grosirun_blue up -d

# Green stack (deploy)
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  -p grosirun_green up -d

# Nginx switch upstream (lihat section 6)
```

---

## 5. Deployment VPS Native (Nginx, PHP-FPM, Supervisor, Cron)

### 5.1 Nginx Configuration

**File:** `/etc/nginx/sites-available/api.grosirun.id`

```nginx
server {
    listen 80;
    server_name api.grosirun.id;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.grosirun.id;

    ssl_certificate /etc/letsencrypt/live/api.grosirun.id/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.grosirun.id/privkey.pem;

    # Blue-Green root
    root /var/www/grosirun/current/public;

    index index.php;

    client_max_body_size 10M;

    # Gzip compression
    gzip on;
    gzip_types text/plain application/json application/javascript text/css;
    gzip_min_length 1024;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
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

    # Health check (no cache)
    location /health {
        try_files $uri /index.php?$query_string;
        expires -1;
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }
}
```

### 5.2 Supervisor Configuration

**File:** `/etc/supervisor/conf.d/grosirun-worker.conf`

```ini
[program:grosirun-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/grosirun/current/backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600 --max-jobs=1000
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/grosirun/current/backend/storage/logs/worker.log
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=3
stopwaitsecs=3600
```

### 5.3 Cron Jobs

```bash
# Edit crontab
sudo crontab -e -u www-data

# Tambahkan:
* * * * * cd /var/www/grosirun/current/backend && php artisan schedule:run >> /dev/null 2>&1
0 2 * * * cd /var/www/grosirun/current/backend && php artisan backup:run --only-db >> /dev/null 2>&1
0 3 * * * cd /var/www/grosirun/current/backend && php artisan proofs:clean-old >> /dev/null 2>&1
0 * * * * certbot renew --quiet --post-hook "systemctl reload nginx"
```

### 5.4 Enable Services

```bash
# Nginx
sudo ln -s /etc/nginx/sites-available/api.grosirun.id /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# PHP-FPM
sudo systemctl enable php8.3-fpm
sudo systemctl restart php8.3-fpm

# Supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start grosirun-worker:*

# Cron
sudo systemctl enable cron
sudo systemctl restart cron
```

---

## 6. Blue-Green Zero-Downtime Strategy

### 6.1 Folder Structure

```
/var/www/grosirun/
├── blue/
│   ├── backend/
│   ├── .env.prod
│   └── storage/
├── green/
│   ├── backend/
│   ├── .env.prod
│   └── storage/
├── current -> blue/          # Symlink ke versi live
├── deploy-blue-green.sh
└── rollback.sh
```

### 6.2 Deploy Script

**File:** `/var/www/grosirun/deploy-blue-green.sh`

```bash
#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Blue-Green Deployment - Grosirun V3.1"
echo "=========================================="
echo ""

# 1. Deteksi current color
CURRENT=$(readlink /var/www/grosirun/current | xargs basename)
if [ "$CURRENT" = "blue" ]; then
    NEXT="green"
else
    NEXT="blue"
fi

echo "📦 Current: $CURRENT"
echo "📦 Deploy to: $NEXT"
echo ""

# 2. Pindah ke folder target
cd /var/www/grosirun/$NEXT

echo "🔄 Pull latest code..."
git pull origin main

echo "📦 Install Composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

echo "🗄️ Run migrations (additive only!)..."
php artisan migrate --force --no-interaction

echo "🔧 Cache config, routes, views..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan optimize

echo "🔍 Health check (temp port 8001)..."
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

echo "🔀 Switching symlink to $NEXT..."
ln -nfs /var/www/grosirun/$NEXT /var/www/grosirun/current

echo "🔄 Reloading PHP-FPM and Nginx (zero-downtime)..."
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx

echo "🔄 Restarting queue workers..."
sudo supervisorctl restart grosirun-worker:*

echo "🔍 Post-deploy health check..."
if curl -f https://api.grosirun.id/api/v1/health; then
    echo "=========================================="
    echo "✅ Deployment successful to $NEXT!"
    echo "📦 Old $CURRENT remains as rollback target"
    echo "=========================================="

    # Notify Slack
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"✅ Deploy Blue-Green sukses! Current: '$CURRENT' → '$NEXT'"}' \
        $SLACK_WEBHOOK
else
    echo "❌ Post-deploy health check failed! Rolling back..."
    ./rollback.sh
    exit 1
fi
```

### 6.3 Migrasi Additive Only

**Prinsip Blue-Green:** Database schema harus backward compatible.

| Jenis Perubahan         | Boleh di Blue-Green? | Keterangan                      |
| ----------------------- | -------------------- | ------------------------------- |
| Tambah kolom (nullable) | ✅                   | Old code ignore new kolom       |
| Tambah tabel            | ✅                   | Old code tidak akses tabel baru |
| Tambah indeks           | ✅                   | Tidak mempengaruhi old code     |
| Hapus kolom             | ❌                   | Harus 2-phase (expand-contract) |
| Rename kolom            | ❌                   | Harus 2-phase (expand-contract) |
| Ubah tipe data          | ❌                   | Harus 2-phase (expand-contract) |

---

## 7. Canary Release 10%

### 7.1 Pennant Feature Flag

Untuk high-risk changes (OrderService lock change, query optimization), gunakan canary rollout.

```php
// app/Providers/AppServiceProvider.php
Feature::define('canary-new-order-service', function (User $user) {
    // 10% random, sticky per user via hash
    return crc32($user->id) % 100 < 10;
});
```

**OrderService:**

```php
if (Feature::active('canary-new-order-service')) {
    // New logic (optimized)
    return $this->createOrderV2($campaign, $dto);
} else {
    // Old logic (stable)
    return $this->createOrderV1($campaign, $dto);
}
```

### 7.2 Rollout Step-by-Step

| Langkah | Command                                                                 | Monitoring              |
| ------- | ----------------------------------------------------------------------- | ----------------------- |
| 1       | `php artisan pennant:activate canary-new-order-service --percentage=10` | Error rate, Pulse 1 jam |
| 2       | Jika error <2% → `--percentage=50`                                      | Error rate, Pulse 1 jam |
| 3       | Jika error <2% → `--percentage=100`                                     | Error rate, Pulse 1 jam |
| 4       | Jika error >5% → `php artisan pennant:deactivate`                       | Rollback flag           |

### 7.3 Nginx Weighted Canary (Alternatif)

```nginx
upstream backend {
    server 127.0.0.1:8000 weight=90;  # Old version
    server 127.0.0.1:8001 weight=10;  # New version (canary)
}
```

---

## 8. Rollback Automation & SSL Monitoring

### 8.1 Rollback Script

**File:** `/var/www/grosirun/rollback.sh`

```bash
#!/bin/bash
set -e

echo "=========================================="
echo "⏪ ROLLBACK - Grosirun V3.1"
echo "=========================================="
echo ""

# 1. Deteksi current color
CURRENT=$(readlink /var/www/grosirun/current | xargs basename)
if [ "$CURRENT" = "blue" ]; then
    ROLLBACK="green"
else
    ROLLBACK="blue"
fi

echo "⏪ Rolling back from $CURRENT to $ROLLBACK"
echo ""

# 2. Check rollback version health
cd /var/www/grosirun/$ROLLBACK

echo "🔍 Health check rollback version..."
php artisan config:cache
php artisan serve --host=127.0.0.1 --port=8001 &
PID=$!
sleep 5

if ! curl -f http://127.0.0.1:8001/api/v1/health; then
    echo "❌ Rollback health check failed!"
    echo "🚨 Manual intervention required"
    kill $PID
    exit 1
fi
kill $PID

# 3. Switch symlink
echo "🔀 Switching symlink to $ROLLBACK..."
ln -nfs /var/www/grosirun/$ROLLBACK /var/www/grosirun/current

# 4. Reload services
echo "🔄 Reloading PHP-FPM and Nginx..."
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx

# 5. Restart queue workers
echo "🔄 Restarting queue workers..."
sudo supervisorctl restart grosirun-worker:*

# 6. Notify Slack
echo "📢 Notifying Slack..."
curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"🚨 Rollback otomatis! Current: '$CURRENT' → '$ROLLBACK'"}' \
    $SLACK_WEBHOOK

echo "=========================================="
echo "✅ Rollback to $ROLLBACK completed!"
echo "=========================================="
```

### 8.2 SSL Monitoring Script

**File:** `/var/www/grosirun/check-ssl.sh`

```bash
#!/bin/bash

DOMAIN="api.grosirun.id"
EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

echo "SSL expires in $DAYS_LEFT days"

if [ $DAYS_LEFT -lt 7 ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"⚠️ SSL Certificate for '$DOMAIN' expires in '$DAYS_LEFT' days!"}' \
        $SLACK_WEBHOOK
    exit 1
fi

exit 0
```

**Tambahkan ke cron:**

```bash
0 0 * * * /var/www/grosirun/check-ssl.sh
```

### 8.3 Health Check Response

**GET /api/v1/health:**

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

---

## 9. Build APK Flutter <10MB

### 9.1 pubspec.yaml Versioning

```yaml
name: grosirun_app
version: 1.0.0+1 # versionName + versionCode
```

### 9.2 Build Command Production

```bash
cd mobile

# Build APK split-per-abi dengan obfuscate
flutter build apk --release --split-per-abi --obfuscate \
    --split-debug-info=./build/debug-info \
    --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1 \
    --dart-define=SENTRY_DSN=https://...@sentry.io/...

# Build AAB untuk Play Store
flutter build appbundle --release --obfuscate \
    --split-debug-info=./build/debug-info \
    --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1 \
    --dart-define=SENTRY_DSN=https://...@sentry.io/...

# Cek size
ls -lh build/app/outputs/apk/release/*.apk
# app-arm64-v8a-release.apk ~7.8MB <10MB ✅
```

### 9.3 CI/CD Build (GitHub Actions)

**File:** `.github/workflows/build-apk.yml`

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
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.22.3"
      - run: flutter pub get
        working-directory: mobile
      - run: |
          flutter build apk --release --split-per-abi --obfuscate \
            --split-debug-info=./build/debug-info \
            --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1 \
            --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }}
        working-directory: mobile
      - name: Check size
        run: |
          SIZE=$(stat -c%s build/app/outputs/apk/release/app-arm64-v8a-release.apk)
          MAX=10485760
          if [ $SIZE -gt $MAX ]; then exit 1; fi
        working-directory: mobile
      - uses: actions/upload-artifact@v4
        with:
          name: apk-arm64
          path: mobile/build/app/outputs/apk/release/app-arm64-v8a-release.apk
      - uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: pilot-canary
          file: mobile/build/app/outputs/apk/release/app-arm64-v8a-release.apk
```

---

## 10. Distribusi APK Pilot

### 10.1 3 Opsi Distribusi

| Opsi                          | Kelebihan                            | Kekurangan             | Rekomendasi        |
| ----------------------------- | ------------------------------------ | ---------------------- | ------------------ |
| **Firebase App Distribution** | Mudah, tracking install, grup canary | Butuh akun Firebase    | ✅ **Rekomendasi** |
| **Play Store Internal**       | Official, auto-update                | Butuh proses review    | Untuk V1.1         |
| **Google Drive / WA**         | Sederhana                            | Manual, susah tracking | Fallback           |

### 10.2 Firebase App Distribution

**Setup:**

1. Firebase Console → App Distribution
2. Buat grup: `pilot-canary` (3-5 orang), `pilot-rt03` (35 orang)
3. Tambahkan tester dengan email

**Distribute:**

```bash
# Canary 10% (Pak Agus + 3 buyer)
firebase appdistribution:distribute \
  --app 1:123456789:android:abcdef \
  --groups pilot-canary \
  app-arm64-v8a-release.apk

# Monitor Crashlytics 1 jam

# All pilot
firebase appdistribution:distribute \
  --app 1:123456789:android:abcdef \
  --groups pilot-rt03 \
  app-arm64-v8a-release.apk
```

### 10.3 Canary Strategy

| Langkah | Waktu      | Aktivitas                                           |
| ------- | ---------- | --------------------------------------------------- |
| 1       | 0 menit    | Distribusi ke `pilot-canary` (10%)                  |
| 2       | 0-60 menit | Monitor Crashlytics crash-free rate                 |
| 3       | 60 menit   | Jika crash-free >99.5% → distribusi ke `pilot-rt03` |
| 4       | 60+ menit  | Jika crash >0.5% → rollback APK, fix bug            |

---

## 11. Checklist Pra-Rilis V3.1

### 11.1 Backend Checklist

- [ ] `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d` build success
- [ ] S3 bucket `grosirun-prod-private` exists, lifecycle 90d, versioning ON
- [ ] Test S3 upload: `Storage::disk('s3')->put('test.txt','ok')` → file exists in S3 console
- [ ] Test S3 tempUrl: `Storage::disk('s3')->temporaryUrl('test.txt', now()->addHour())` returns 200
- [ ] `clusters` table seeded `PGH-RT03`, users & campaigns have cluster_id FK
- [ ] ClusterScope applied: buyer cluster mismatch returns 403 ERR_040
- [ ] `notifications` table exists, test FCM fallback: stop queue, POST order, check notifications row
- [ ] Idempotency Redis cache: POST /orders same Idempotency-Key twice → same response
- [ ] ETag: GET /campaigns returns ETag, If-None-Match returns 304
- [ ] RateLimiter Redis: `redis-cli KEYS "rl:*"` exists
- [ ] Feature Flags: `php artisan pennant:feature list` shows qris-upload, extend-deadline
- [ ] Blue-Green folders `/var/www/grosirun/blue` & `/green` + symlink `/current` exists
- [ ] `deploy-blue-green.sh` executable, health check temp port 8001 works
- [ ] `rollback.sh` tested, Slack notification sent
- [ ] SSL auto-renew cron + `check-ssl.sh` exists
- [ ] Backup daily S3 `backups/` retention 7 days
- [ ] RTO 1h RPO 24h documented, disaster drill checklist filled
- [ ] CI/CD `.github/workflows/test.yml` passes
- [ ] Sentry DSN prod set, test `Sentry::captureMessage('test')` appears
- [ ] Pulse enabled prod, `/pulse` dashboard accessible

### 11.2 Mobile Checklist

- [ ] Consent + ToS checkbox screens exist, POST /auth/consent + /tos-accept called
- [ ] DeepLink test: `adb shell am start -W -a android.intent.action.VIEW -d "grosirun://campaign/12"` opens detail
- [ ] FCM background handler saves Hive notificationsBox
- [ ] Fallback polling GET /notifications 60s works when FCM down
- [ ] Offline proof queue: airplane mode pick proof → pendingQueue type upload_proof → online sync success → temp file deleted
- [ ] Error boundary: `FlutterError.onError` + `PlatformDispatcher.onError` + Sentry works
- [ ] State persistence: appStateBox lastRoute, lastCampaignId restored after kill
- [ ] Idempotency-Key interceptor generates UUID per POST
- [ ] ETag If-None-Match sends, 304 no rebuild
- [ ] APK arm64 <10MB, versionCode from CI BUILD_NUMBER
- [ ] Onboarding pilot guide PDF SOP 1 lembar for Pak Agus tested

---

## 12. Post-Launch Monitoring & Alerting

### 12.1 Laravel Pulse

**Install:**

```bash
composer require laravel/pulse
php artisan pulse:install
php artisan migrate
```

**Dashboard:** `/pulse` (admin only)

**Metrics:**

- Slow queries >1s
- Slow requests >500ms
- Exceptions
- Queue jobs failed
- Cache hit/miss

### 12.2 Alert Rules

| Alert              | Threshold            | Channel       | Action                          |
| ------------------ | -------------------- | ------------- | ------------------------------- |
| P95 GET /campaigns | >300ms 5 min         | Slack #alerts | Investigate index, cache        |
| Failed jobs        | >5 in 10 min         | Slack #alerts | `php artisan queue:retry --all` |
| SSL expiry         | <7 days              | Slack #alerts | `certbot renew --force-renewal` |
| VPS disk           | >80%                 | Slack #alerts | Clean logs, upgrade disk        |
| DB connections     | >80% max_connections | Slack #alerts | Scale FPM, check slow queries   |
| FCM job fail       | 3 tries              | Slack #alerts | Check Firebase credentials      |
| Crash-free         | <99.5%               | Slack #alerts | Hotfix APK, redistribute        |

### 12.3 Uptime Monitoring

**UptimeRobot / BetterStack:**

- Monitor `https://api.grosirun.id/api/v1/health` setiap 1 menit
- Alert jika 503 3 kali berturut-turut
- Monitor SSL expiry

### 12.4 Slack Integration

**Webhook URL:** `$SLACK_WEBHOOK` di .env.prod

**Channel:** `#grosirun-ci` dan `#grosirun-alerts`

---

## 13. Disaster Recovery Plan

### 13.1 RTO/RPO Definition

| Metric                             | Target | Keterangan                                |
| ---------------------------------- | ------ | ----------------------------------------- |
| **RTO** (Recovery Time Objective)  | 1 jam  | Waktu dari deteksi down sampai service up |
| **RPO** (Recovery Point Objective) | 24 jam | Data loss maksimal (backup daily 02:00)   |

### 13.2 Backup Strategy

| Komponen        | Frekuensi     | Retention | Lokasi          |
| --------------- | ------------- | --------- | --------------- |
| **Database**    | Daily 02:00   | 7 hari    | S3 `backups/`   |
| **S3 Files**    | Versioning ON | Forever   | S3 bucket       |
| **Source Code** | Tag vX.Y.Z    | Forever   | GitHub          |
| **Secrets**     | Manual        | Forever   | 1Password Vault |

### 13.3 Disaster Scenarios

| Disaster              | Impact                 | Recovery Procedure                       | Est. Time |
| --------------------- | ---------------------- | ---------------------------------------- | --------- |
| **VPS total down**    | API 100% down          | Spin new VPS, restore DB from S3, deploy | 45 min    |
| **MySQL corrupted**   | Data lost              | Restore latest backup S3                 | 30 min    |
| **S3 bucket deleted** | Images/proofs lost     | Restore from versioning                  | 20 min    |
| **Redis down**        | Queue fail, cache miss | Restart redis, retry queue jobs          | 5 min     |
| **SSL expired**       | HTTPS fail             | Certbot renew `--force-renewal`          | 5 min     |

### 13.4 Disaster Recovery Drill

**Wajib dilakukan 1x sebelum Alpha Pilot.**

**Dokumentasi:** `docs/DISASTER_RECOVERY_DRILL_REPORT.md`

**Prosedur:**

1. Spin new VPS staging Ubuntu 22.04
2. Install Docker + docker-compose
3. Download latest backup from S3:

   ```bash
   aws s3 cp s3://grosirun-prod-private/backups/latest.zip ./latest.zip
   unzip latest.zip
   ```

4. Restore database:

   ```bash
   mysql -u root -p grosirun < db-dumps/mysql-grosirun.sql
   ```

5. Clone repo, set .env.prod (copy from 1Password)
6. `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d`
7. Health check: `curl /api/v1/health` → 200
8. Test login OTP, create campaign, order, proof upload S3 tempUrl
9. Measure time → target <1 jam
10. Document issues, update DEPLOYMENT.md
11. Destroy staging VPS

**Ulangi setiap 3 bulan.**

---

## 14. Rollback Plan Manual (Fallback)

### 14.1 Trigger Manual

Jika automation gagal, lakukan manual:

```bash
# 1. SSH ke VPS
ssh user@vps-ip

# 2. Cek status
cd /var/www/grosirun
ls -la current
# current -> blue/ (atau green/)

# 3. Rollback ke color lain
./rollback.sh

# 4. Jika rollback script gagal, manual:
CURRENT=$(readlink current | xargs basename)
if [ "$CURRENT" = "blue" ]; then ROLLBACK="green"; else ROLLBACK="blue"; fi
ln -nfs /var/www/grosirun/$ROLLBACK /var/www/grosirun/current
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx
sudo supervisorctl restart grosirun-worker:*
```

### 14.2 Database Rollback

Jika migration menyebabkan data loss:

```bash
# 1. Restore dari backup S3
aws s3 cp s3://grosirun-prod-private/backups/latest.sql.gz .
gunzip latest.sql.gz
mysql -u grosirun -p grosirun < latest.sql

# 2. Rollback migration (jika perlu)
php artisan migrate:rollback --step=1

# 3. Switch symlink ke previous version
./rollback.sh
```

---

## 15. Cheat Sheet V3.1

### 15.1 Perintah Penting

| Keperluan               | Command                                                                                                                                                                                |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Docker up dev**       | `docker compose up -d --build`                                                                                                                                                         |
| **Docker prod up**      | `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d`                                                                                                                |
| **Health check**        | `curl https://api.grosirun.id/api/v1/health`                                                                                                                                           |
| **Backup DB S3**        | `php artisan backup:run --only-db`                                                                                                                                                     |
| **Restore drill**       | `aws s3 cp s3://.../latest.zip ./ && unzip && mysql ...`                                                                                                                               |
| **Blue-Green deploy**   | `./deploy-blue-green.sh`                                                                                                                                                               |
| **Rollback auto**       | `./rollback.sh`                                                                                                                                                                        |
| **Canary flag 10%**     | `php artisan pennant:activate canary-new-order-service --percentage=10`                                                                                                                |
| **Check SSL expiry**    | `./check-ssl.sh`                                                                                                                                                                       |
| **K6 load test 100 VU** | `k6 run backend/load-test/k6-deadline-rush.js`                                                                                                                                         |
| **K6 race test**        | `k6 run backend/load-test/k6-orders-race.js`                                                                                                                                           |
| **Flutter build prod**  | `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./build/debug-info --dart-define=API_BASE_URL=https://api.grosirun.id/api/v1 --dart-define=SENTRY_DSN=...` |

### 15.2 File Locations

| File                  | Lokasi                                                                   |
| --------------------- | ------------------------------------------------------------------------ |
| **.env.prod**         | `/var/www/grosirun/blue/.env.prod` & `/var/www/grosirun/green/.env.prod` |
| **Deploy script**     | `/var/www/grosirun/deploy-blue-green.sh`                                 |
| **Rollback script**   | `/var/www/grosirun/rollback.sh`                                          |
| **SSL check**         | `/var/www/grosirun/check-ssl.sh`                                         |
| **Nginx config**      | `/etc/nginx/sites-available/api.grosirun.id`                             |
| **PHP-FPM config**    | `/etc/php/8.3/fpm/pool.d/www.conf`                                       |
| **Supervisor config** | `/etc/supervisor/conf.d/grosirun-worker.conf`                            |
| **Logs**              | `/var/www/grosirun/current/backend/storage/logs/`                        |

### 15.3 Rollback Checklist

| Urutan | Action            | Command                                               |
| ------ | ----------------- | ----------------------------------------------------- |
| 1      | SSH ke VPS        | `ssh user@vps-ip`                                     |
| 2      | Cek current       | `cd /var/www/grosirun && ls -la current`              |
| 3      | Backup DB         | `php artisan backup:run --only-db` (sebelum rollback) |
| 4      | Jalankan rollback | `./rollback.sh`                                       |
| 5      | Health check      | `curl https://api.grosirun.id/api/v1/health`          |
| 6      | Notify Slack      | Manual jika script gagal                              |

---

**Panduan Deployment V3.1 Production Ready - Blue-Green, Canary, Rollback, Monitoring, Disaster Recovery!** 🚀
