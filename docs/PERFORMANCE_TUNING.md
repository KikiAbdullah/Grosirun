# PANDUAN PERFORMANCE TUNING - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Performance Budget
3. Laravel Tuning
4. Database Tuning
5. S3 Tuning
6. Queue Tuning (Horizon)
7. Flutter Tuning
8. Load Testing & Benchmark
9. Monitoring & Alerting
10. Ringkasan & Rekomendasi

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Mengapa Performance Tuning Penting?

Grosirun adalah platform patungan yang menangani transaksi uang riil. Performa aplikasi yang lambat dapat berdampak langsung pada bisnis:

| Dampak                | Potensi Kerugian               |
| --------------------- | ------------------------------ |
| GET /campaigns >300ms | Warga malas membuka aplikasi   |
| POST /orders >500ms   | Checkout batal, warga pergi    |
| Upload proof >3 detik | Warga frustrasi upload ulang   |
| Downtime 1 jam        | Hilang 2 PO = Rp16.800.000 GMV |

**Tujuan tuning:** Memastikan aplikasi tetap responsif bahkan saat 100 warga checkout bersamaan (thundering herd).

### 1.2 Referensi BUSINESS_ANALYSIS.md

| Komponen              | Nilai               |
| --------------------- | ------------------- |
| Platform Fee          | 1% GMV + PPN 11%    |
| GMV per PO AT_70      | Rp8.400.000         |
| Laba Initiator per PO | Rp956.760           |
| Target Adopsi         | 70% (35 dari 50 KK) |

**Performance tuning harus mendukung skala:**

- 1 cluster = 50 KK (35 aktif)
- 100 concurrent checkout di H-1 deadline
- 100 cluster = 5.000 KK di V2

---

## 2. Performance Budget

### 2.1 Target Performa

| Layer      | Metrik                       | Budget | Current V3.1 | Alat Ukur            |
| ---------- | ---------------------------- | ------ | ------------ | -------------------- |
| **API**    | GET /campaigns P95 cache hit | <150ms | 120ms        | Pulse + k6           |
| **API**    | POST /orders P95 lock        | <300ms | 220ms        | k6                   |
| **API**    | Upload proof 2MB avg         | <2s    | 1.6s         | Postman              |
| **API**    | Recap PDF 200 orders         | <3s    | 2.4s         | Manual               |
| **Mobile** | Cold Start                   | <2s    | 1.4s         | Firebase Performance |
| **Mobile** | RAM PSS low-end 2GB          | <180MB | 145MB        | Android Profiler     |
| **Mobile** | APK arm64                    | <10MB  | 7.8MB        | `ls -lh`             |
| **Mobile** | Frame Rate                   | 60 FPS | 60 FPS       | Flutter DevTools     |
| **Mobile** | Crash-free                   | >99.5% | 99.8%        | Crashlytics          |

### 2.2 Tindakan Jika Budget Terlampaui

| Langkah | Action                           |
| ------- | -------------------------------- |
| 1       | Investigasi root cause           |
| 2       | Optimasi (lihat section terkait) |
| 3       | Jalankan ulang benchmark         |
| 4       | Update PERFORMANCE_BENCHMARK.md  |

---

## 3. Laravel Tuning

### 3.1 OPcache Configuration

**File:** `docker/php.ini` (produksi)

```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=32
opcache.max_accelerated_files=20000
opcache.validate_timestamps=0     # Produksi: tidak cek mtime file
opcache.save_comments=0
opcache.enable_file_override=1
```

**Perbedaan Dev vs Prod:**

| Environment | `validate_timestamps` | Keterangan                                   |
| ----------- | --------------------- | -------------------------------------------- |
| Dev         | `1`                   | Hot reload, perubahan kode langsung terlihat |
| Prod        | `0`                   | Performa optimal, reload FPM setelah deploy  |

**Cek Status OPcache:**

```bash
php -i | grep opcache

# Atau via tinker
php artisan tinker
>>> opcache_get_status();
```

**Clear OPcache (setelah deploy):**

```bash
# Reload FPM
sudo systemctl reload php8.3-fpm

# Atau via artisan (jika package tersedia)
php artisan opcache:clear
```

### 3.2 Redis Cache Strategy

**Campaigns List (60 detik):**

```php
// app/Services/CampaignService.php
public function getActiveCampaigns(int $clusterId, int $page = 1): Collection
{
    $cacheKey = "campaigns:active:cluster:{$clusterId}:page:{$page}";

    return Cache::remember($cacheKey, 60, function () use ($clusterId, $page) {
        return Campaign::where('cluster_id', $clusterId)
            ->where('status', 'active')
            ->where('deadline', '>', now())
            ->orderBy('deadline')
            ->paginate(15);
    });
}
```

**Campaign Detail (15 detik + ETag):**

```php
public function getCampaignDetail(int $id): Campaign
{
    $cacheKey = "campaign:{$id}";

    return Cache::remember($cacheKey, 15, function () use ($id) {
        return Campaign::with(['variants', 'initiator', 'cluster'])
            ->findOrFail($id);
    });
}
```

**Recap PDF (5 menit - berat):**

```php
public function generateRecap(int $campaignId): string
{
    $cacheKey = "recap:{$campaignId}";

    return Cache::remember($cacheKey, 300, function () use ($campaignId) {
        // Generate PDF berat
        return $this->pdfService->generate($campaignId);
    });
}
```

**Cache Invalidation (saat campaign berubah):**

```php
// Saat campaign dibuat, diupdate, atau dihapus
Cache::tags(['campaigns'])->flush();

// Atau manual
Cache::forget("campaigns:active:cluster:{$clusterId}:page:{$page}");
Cache::forget("campaign:{$campaignId}");
Cache::forget("recap:{$campaignId}");
```

**Cache Stampede Prevention:**

Untuk cache yang heavy (recap), gunakan `Cache::lock()`:

```php
$lockKey = "recap:lock:{$campaignId}";
$lock = Cache::lock($lockKey, 10);

if ($lock->get()) {
    try {
        $pdf = $this->generatePdf($campaignId);
        Cache::put("recap:{$campaignId}", $pdf, 300);
    } finally {
        $lock->release();
    }
}
```

### 3.3 Nginx Tuning

**File:** `docker/nginx.prod.conf`

```nginx
worker_processes auto;
worker_connections 1024;
client_max_body_size 10M;
keepalive_timeout 65;

# Gzip compression (reduce bandwidth 70%)
gzip on;
gzip_types text/plain application/json application/javascript text/css image/svg+xml;
gzip_min_length 1024;
gzip_comp_level 6;

# FastCGI cache (opsional)
fastcgi_cache_path /var/cache/nginx levels=1:2 keys_zone=laravel:100m inactive=60m;
fastcgi_cache_key "$scheme$request_method$host$request_uri";

location ~ \.php$ {
    fastcgi_pass app:9000;
    fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    include fastcgi_params;
    fastcgi_read_timeout 60s;

    # FastCGI cache (untuk GET yang tidak sering berubah)
    fastcgi_cache laravel;
    fastcgi_cache_valid 200 60s;
    fastcgi_cache_bypass $http_cache_control;
    fastcgi_no_cache $http_cache_control;
}
```

### 3.4 PHP-FPM Pool Tuning

**File:** `/etc/php/8.3/fpm/pool.d/www.conf`

```ini
pm = dynamic
pm.max_children = 30
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500          # Recycle worker untuk prevent memory leak
pm.process_idle_timeout = 10s
request_terminate_timeout = 60s

# Monitoring
pm.status_path = /status
```

**Menghitung `pm.max_children`:**

```
RAM Total = 4 GB
OS = 1 GB
MySQL = 512 MB
Redis = 512 MB
Sisa untuk PHP = ~2 GB = 2048 MB

Rata-rata memory per PHP process = 80 MB
Max Children = 2048 / 80 = ~25-30
```

**Monitoring PHP-FPM:**

```bash
# Status
curl http://127.0.0.1/status?plain

# Active processes
curl http://127.0.0.1/status?plain | grep "active processes"
```

---

## 4. Database Tuning

### 4.1 Index Strategy

**Indeks Wajib (dari DATABASE_DESIGN.md):**

```sql
-- Campaigns list per cluster + status + deadline
CREATE INDEX idx_campaigns_cluster_status_deadline
    ON campaigns (cluster_id, status, deadline);

-- Orders dashboard admin (pending orders)
CREATE INDEX idx_orders_campaign_status
    ON orders (campaign_id, payment_status);

-- My orders (user_id + created_at DESC)
CREATE INDEX idx_orders_user_created
    ON orders (user_id, created_at DESC);

-- OTP lookup
CREATE INDEX idx_otp_phone_expires
    ON otp_codes (phone_number, expires_at);

-- Notifications unread
CREATE INDEX idx_notifications_user_read
    ON notifications (user_id, read_at);
```

### 4.2 EXPLAIN Usage

**Cek Query di Tinker:**

```bash
php artisan tinker
```

```php
// Cek query campaigns
DB::table('campaigns')
    ->where('cluster_id', 1)
    ->where('status', 'active')
    ->where('deadline', '>', now())
    ->orderBy('deadline')
    ->explain();
```

**Hasil yang Diinginkan:**

```
+----+-------------+----------+------------+-------+--------------------------------------+---------+---------+------+------+----------+-----------------------+
| id | select_type | table    | partitions | type  | possible_keys                        | key     | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+----------+------------+-------+--------------------------------------+---------+---------+------+------+----------+-----------------------+
|  1 | SIMPLE      | campaigns| NULL       | range | idx_campaigns_cluster_status_deadline | idx_... | 3       | NULL |   15 |   100.00 | Using index condition |
+----+-------------+----------+------------+-------+--------------------------------------+---------+---------+------+------+----------+-----------------------+
```

**Jika muncul `Using filesort` atau `Using temporary` → tambah indeks.**

### 4.3 Partitioning (Future V2)

**Saat orders mencapai >1 juta row:**

```sql
ALTER TABLE orders PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION p2028 VALUES LESS THAN (2029),
    PARTITION pFuture VALUES LESS THAN MAXVALUE
);
```

**Prerequisite:** Primary Key harus include partition key.

```sql
-- V2 Migration
ALTER TABLE orders DROP PRIMARY KEY;
ALTER TABLE orders ADD PRIMARY KEY (id, created_at);
```

### 4.4 Read Replica

**Konfigurasi** `config/database.php`:

```php
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

**Penggunaan di Recap:**

```php
// CampaignService@recap
$orders = Order::on('mysql_read')
    ->where('campaign_id', $campaign->id)
    ->where('payment_status', 'paid')
    ->with(['variant', 'user:id,name'])
    ->get();
```

### 4.5 Connection Pooling

| Komponen    | Konfigurasi       | Nilai |
| ----------- | ----------------- | ----- |
| **MySQL**   | `max_connections` | 100   |
| **MySQL**   | `wait_timeout`    | 300   |
| **PHP-FPM** | `pm.max_children` | 30    |
| **Redis**   | `maxclients`      | 10000 |
| **Redis**   | `timeout`         | 0     |

**Monitor Connections:**

```sql
-- MySQL
SHOW STATUS LIKE 'Threads_connected';
SHOW PROCESSLIST;

-- Redis
redis-cli INFO clients
```

---

## 5. S3 Tuning

### 5.1 Konfigurasi S3

| Aspek          | Konfigurasi                             | Keterangan                 |
| -------------- | --------------------------------------- | -------------------------- |
| **Bucket**     | Private Block Public Access ON          | Keamanan                   |
| **TempUrl**    | `temporaryUrl($path, now()->addHour())` | 1 jam expiry               |
| **Lifecycle**  | `order_proofs/*` 90 hari                | UU PDP                     |
| **Versioning** | ON                                      | Recovery accidental delete |
| **Region**     | ap-southeast-1                          | Dekat dengan Indonesia     |

### 5.2 CloudFront CDN (Opsional V1.1)

Untuk campaign images yang bersifat public, gunakan CloudFront:

```bash
# Setup CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name grosirun-prod-private.s3.amazonaws.com \
  --default-cache-behavior "{
    'MinTTL': 86400,
    'MaxTTL': 31536000,
    'DefaultTTL': 86400,
    'Compress': true,
    'ViewerProtocolPolicy': 'redirect-to-https'
  }"
```

**URL:** `https://cdn.grosirun.id/campaigns/{uuid}.jpg`

### 5.3 Transfer Acceleration (Opsional)

Untuk upload proof dari Indonesia ke S3 Singapore:

```bash
aws s3api put-bucket-accelerate-configuration \
  --bucket grosirun-prod-private \
  --accelerate-configuration Status=Enabled
```

**URL:** `s3-accelerate.amazonaws.com`

---

## 6. Queue Tuning (Horizon)

### 6.1 Horizon Configuration

**File:** `config/horizon.php`

```php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['default'],
            'balance' => 'auto',
            'processes' => 2,
            'tries' => 3,
            'timeout' => 60,
            'memory' => 128,
        ],
    ],
],
```

### 6.2 Supervisor Configuration

**File:** `/etc/supervisor/conf.d/grosirun-worker.conf`

```ini
[program:grosirun-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/grosirun/current/backend/artisan queue:work redis \
    --sleep=3 \
    --tries=3 \
    --max-time=3600 \
    --max-jobs=1000 \
    --memory=128
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

### 6.3 Monitoring

```bash
# Cek status worker
supervisorctl status grosirun-worker:*

# Cek failed jobs
php artisan queue:failed

# Retry semua failed
php artisan queue:retry --all

# Retry spesifik
php artisan queue:retry 123

# Clear failed
php artisan queue:flush
```

**Alert:** Failed jobs >5 dalam 10 menit → Slack

---

## 7. Flutter Tuning

### 7.1 ListView Optimization

**✅ Gunakan ListView.builder:**

```dart
ListView.builder(
  itemCount: campaigns.length,
  itemBuilder: (context, index) {
    return CampaignCard(campaign: campaigns[index]);
  },
)
```

**❌ Jangan gunakan ListView(children:) untuk daftar panjang:**

```dart
// ❌ BURUK - akan me-rebuild semua widget
ListView(
  children: campaigns.map((c) => CampaignCard(campaign: c)).toList(),
)
```

**Optimasi Tambahan:**

```dart
ListView.builder(
  itemCount: campaigns.length,
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: CampaignCard(campaign: campaigns[index]),
    );
  },
  // Nonaktifkan keep-alive untuk menghemat memory
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: true,
)
```

### 7.2 Image Caching

**cached_network_image Configuration:**

```dart
CachedNetworkImage(
  imageUrl: campaign.imageUrl,
  cacheManager: DefaultCacheManager(),
  // Cache 7 hari
  cacheKey: campaign.imageUrl,
  // Memory cache max 100 images
  memCacheWidth: 400,
  memCacheHeight: 400,
  placeholder: (context, url) => Shimmer(
    child: Container(color: Colors.grey[300]),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**Clear Cache on Memory Pressure:**

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    // Clear image cache saat memory pressure
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
```

### 7.3 Memory Leak Prevention

**✅ Cancel Timer di dispose():**

```dart
class CampaignCubit extends Cubit<CampaignState> {
  Timer? _pollingTimer;

  void startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 15), (_) {
      loadActive();
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
```

**✅ Cancel StreamSubscription:**

```dart
class AppLinksService {
  StreamSubscription? _subscription;

  void init() {
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
```

**✅ Avoid Large List in State:**

```dart
// ❌ BURUK - menyimpan 1000 item di memory
class CampaignState extends Equatable {
  final List<Campaign> campaigns; // 1000 item
}

// ✅ BAIK - pagination
class CampaignState extends Equatable {
  final List<Campaign> campaigns; // 15 item per page
  final int currentPage;
  final bool hasMore;
}
```

### 7.4 Frame 60 FPS

**Flutter DevTools Performance View:**

```bash
flutter run --profile
# Buka Chrome: http://localhost:9100
```

**Tips 60 FPS:**

| Tips                     | Keterangan                                      |
| ------------------------ | ----------------------------------------------- |
| `const` widgets          | Gunakan `const` untuk widget statis             |
| `RepaintBoundary`        | Isolasi bagian yang sering repaint (Lottie)     |
| Jangan build heavy       | Pindahkan logic ke Cubit, bukan di build method |
| `flutter_image_compress` | Compress di isolate (native)                    |
| Lottie                   | `<100KB`, `frameRate: FrameRate.max`            |

### 7.5 APK Size <10MB

```bash
flutter build apk --release --split-per-abi --obfuscate --analyze-size
```

**Optimasi APK Size:**

| Tips                 | Keterangan                        |
| -------------------- | --------------------------------- |
| **Split ABI**        | `--split-per-abi` (wajib)         |
| **Obfuscate**        | `--obfuscate`                     |
| **Shrink Resources** | `android:shrinkResources=true`    |
| **WebP Assets**      | PNG → WebP (hemat 30-50%)         |
| **Lottie Trim**      | Hapus frame tidak perlu, <100KB   |
| **No google_maps**   | Tambah ~5MB, hindari              |
| **Font Subset**      | Hanya Latin, bukan semua karakter |

---

## 8. Load Testing & Benchmark

### 8.1 k6 Scripts

**File:** `backend/load-test/k6-deadline-rush.js`

```javascript
import http from "k6/http";
import { check, sleep } from "k6";
import { Rate } from "k6/metrics";

const outOfStockRate = new Rate("out_of_stock_rate");

export const options = {
  vus: 100,
  duration: "30s",
  thresholds: {
    http_req_duration: ["p(95)<300"],
    http_req_failed: ["rate<0.1"],
    out_of_stock_rate: ["value<0.95"],
  },
};

export default function () {
  const url = `${__ENV.API_URL}/campaigns/${__ENV.CAMPAIGN_ID}/orders`;
  const payload = JSON.stringify({
    variant_id: parseInt(__ENV.VARIANT_ID),
    quantity: 1,
    payment_method: "cash",
  });
  const params = {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${__ENV.TOKEN}`,
      "Idempotency-Key": `key-${__VU}-${Date.now()}`,
    },
  };

  const res = http.post(url, payload, params);

  check(res, {
    "status is 201 or 409": (r) => r.status === 201 || r.status === 409,
  });

  if (res.status === 409) {
    outOfStockRate.add(1);
  }

  sleep(1);
}
```

**Jalankan:**

```bash
k6 run backend/load-test/k6-deadline-rush.js \
  --out json=result.json \
  --env API_URL=https://api.grosirun.id/api/v1 \
  --env TOKEN=YOUR_TOKEN \
  --env CAMPAIGN_ID=12 \
  --env VARIANT_ID=20
```

### 8.2 Baseline

**File:** `PERFORMANCE_BENCHMARK.md`

| Endpoint       | VUs | P95   | P99   | 5xx Rate | Tanggal    | Commit |
| -------------- | --- | ----- | ----- | -------- | ---------- | ------ |
| GET /campaigns | 100 | 120ms | 180ms | 0%       | 2026-07-20 | abc123 |
| POST /orders   | 100 | 220ms | 350ms | 0%       | 2026-07-20 | abc123 |
| GET /recap     | 10  | 2.4s  | 2.9s  | 0%       | 2026-07-20 | abc123 |
| POST /proof    | 10  | 1.6s  | 2.0s  | 0%       | 2026-07-20 | abc123 |

**Threshold Peringatan:** Jika P95 >120% baseline → investigasi.

### 8.3 Apache Bench (Quick Test)

```bash
ab -n 100 -c 20 -H "Authorization: Bearer TOKEN" \
  https://api.grosirun.id/api/v1/campaigns
```

---

## 9. Monitoring & Alerting

### 9.1 Laravel Pulse

**Dashboard:** `/pulse`

| Metrik        | Threshold       |
| ------------- | --------------- |
| Slow queries  | >1s             |
| Slow requests | >500ms          |
| Exceptions    | >5/min          |
| Queue jobs    | Failed >5/10min |

### 9.2 Alert Rules

| Alert              | Threshold            | Channel        | Action                     |
| ------------------ | -------------------- | -------------- | -------------------------- |
| P95 GET /campaigns | >300ms 5 menit       | Slack          | Cek index, cache, FPM      |
| Failed jobs        | >5 dalam 10 menit    | Slack          | `queue:retry --all`        |
| SSL expiry         | <7 hari              | Slack (urgent) | `certbot renew`            |
| Disk VPS           | >80%                 | Slack          | Clean logs, upgrade        |
| DB connections     | >80% max_connections | Slack          | Scale FPM, kill long query |
| Crash-free         | <99.5%               | Slack          | Hotfix APK                 |

### 9.3 Firebase Performance

**Custom Traces:**

| Trace                | Target P95 |
| -------------------- | ---------- |
| `campaign_list_load` | <1.5 detik |
| `checkout_flow`      | <3 detik   |
| `proof_upload`       | <2 detik   |

---

## 10. Ringkasan & Rekomendasi

### 10.1 Ringkasan Tuning

| Komponen         | Konfigurasi                                  | Status |
| ---------------- | -------------------------------------------- | ------ |
| **OPcache**      | memory=256, validate_timestamps=0            | ✅     |
| **Redis Cache**  | 60s TTL, tags flush                          | ✅     |
| **Nginx**        | gzip on, FastCGI cache                       | ✅     |
| **PHP-FPM**      | max_children=30, max_requests=500            | ✅     |
| **Index**        | cluster_status_deadline, campaign_status     | ✅     |
| **Read Replica** | mysql_read untuk recap                       | ✅     |
| **S3**           | Private bucket, tempUrl 1h, lifecycle 90d    | ✅     |
| **Horizon**      | processes=2, tries=3                         | ✅     |
| **Flutter**      | ListView.builder, cached_image, cancel timer | ✅     |

### 10.2 Rekomendasi V1.1

| #   | Rekomendasi                              | Priority             |
| --- | ---------------------------------------- | -------------------- |
| 1   | CloudFront CDN untuk campaign images     | Medium               |
| 2   | S3 Transfer Acceleration                 | Low                  |
| 3   | Partitioning orders by year              | High (jika >1M rows) |
| 4   | ELK Stack untuk log aggregation          | Medium               |
| 5   | APM (Application Performance Monitoring) | Low                  |

---

**Performance Tuning V3.1 Production Ready - OPcache, Redis Cache, Nginx Gzip, PHP-FPM, Index, Read Replica, Flutter Optimization, Load Testing, Monitoring!** 🚀📊
