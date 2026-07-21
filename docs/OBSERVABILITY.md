# OBSERVABILITY - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Filosofi Observability
3. Logging vs Sentry Decision Matrix
4. Laravel Logging
5. Laravel Pulse + Prometheus + Grafana
6. S3 + Redis + Queue + Horizon Metrics
7. Flutter Crashlytics + Firebase Performance + Custom Traces
8. Slow Query & Pulse Slow Requests
9. Alerting Slack + UptimeRobot + SSL Monitoring
10. Dashboard & Runbook
11. Ringkasan & Rekomendasi

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Mengapa Observability Penting untuk Grosirun?

Grosirun adalah platform patungan yang menangani transaksi uang riil (Rp8.400.000 GMV per PO). Setiap gangguan sistem dapat berdampak langsung pada:

| Dampak                  | Potensi Kerugian                 |
| ----------------------- | -------------------------------- |
| API down 1 jam          | Hilang 2 PO = Rp16.800.000 GMV   |
| Oversell bug            | Kehilangan kepercayaan warga     |
| FCM down tanpa fallback | Warga tidak tahu status pesanan  |
| S3 down                 | Bukti QRIS hilang, mediasi sulit |

**Observability memastikan kita bisa mendeteksi dan merespons masalah sebelum berdampak besar pada bisnis.**

### 1.2 Referensi BUSINESS_ANALYSIS.md

| Komponen              | Nilai               |
| --------------------- | ------------------- |
| Platform Fee          | 1% GMV + PPN 11%    |
| GMV per PO AT_70      | Rp8.400.000         |
| Laba Initiator per PO | Rp956.760           |
| Target Adopsi         | 70% (35 dari 50 KK) |

**Observability harus melindungi nilai bisnis ini.**

---

## 2. Filosofi Observability

Observability terdiri dari 3 pilar:

| Pilar       | Fungsi               | Tools                                    |
| ----------- | -------------------- | ---------------------------------------- |
| **Logs**    | Merekam kejadian     | Laravel daily log, Sentry                |
| **Metrics** | Mengukur performa    | Pulse, Prometheus, Grafana               |
| **Traces**  | Melacak alur request | Sentry Performance, Firebase Performance |

**Prinsip:**

1. **Proaktif:** Deteksi masalah sebelum user komplain
2. **Akurat:** Data observability harus bisa diandalkan untuk decision making
3. **Actionable:** Setiap alert harus punya runbook yang jelas
4. **Efisien:** Tidak over-alerting (hanya alert untuk hal yang penting)

---

## 3. Logging vs Sentry Decision Matrix

### 3.1 Matriks Keputusan

| Tipe Event                    | Level      | Destinasi                                     | Contoh                                                    | Alert?                 |
| ----------------------------- | ---------- | --------------------------------------------- | --------------------------------------------------------- | ---------------------- |
| **Info bisnis**               | `info`     | Log daily                                     | OTP terkirim ke 62812\*\*\*\* (masked) + cluster PGH-RT03 | ❌ No                  |
| **Warning bisnis**            | `warning`  | Log + Sentry breadcrumb                       | Kuota varian <10%                                         | ❌ No                  |
| **Error bisnis (user fault)** | `error`    | Log daily ONLY (not Sentry)                   | Oversell attempt 409, validation already 409              | ❌ No (to avoid noise) |
| **Exception unexpected 5xx**  | `error`    | Log::error + Sentry::captureException + Slack | DB connection lost, S3 timeout, Redis down                | ✅ Yes (Slack urgent)  |
| **Security critical**         | `critical` | Log::critical + Sentry + Slack                | 10x OTP fail same IP (brute force), IDOR attempt 403      | ✅ Yes (Slack urgent)  |
| **Performance warning**       | `warning`  | Log + Pulse + Slack                           | P95 GET /campaigns >300ms selama 5 menit                  | ✅ Yes (Slack)         |
| **Queue failed job**          | `error`    | failed_jobs table + Sentry + Slack            | FCM job fail 3 tries, CleanOldProofsJob fail              | ✅ Yes (Slack)         |
| **GDPR deletion**             | `info`     | Log + transaction_logs                        | User DELETE /auth/account                                 | ❌ No                  |

### 3.2 Konfigurasi .env.prod

```ini
LOG_CHANNEL=daily
LOG_LEVEL=warning  # Produksi: warning+ untuk mengurangi noise
LOG_DAILY_DAYS=7

SENTRY_LARAVEL_DSN=https://...@sentry.io/...
SENTRY_TRACES_SAMPLE_RATE=0.1

PULSE_ENABLED=true
TELESCOPE_ENABLED=false  # Hanya untuk development
```

### 3.3 Sentry Breadcrumb untuk Business Flow

Tambahkan `Sentry::addBreadcrumb()` untuk trace bisnis:

```php
// OTP flow
Sentry::addBreadcrumb(new Breadcrumb(
    level: Breadcrumb::INFO,
    category: 'auth',
    message: 'OTP requested',
    data: ['phone_masked' => substr($phone, 0, 4) . '****']
));

// Campaign created
Sentry::addBreadcrumb(new Breadcrumb(
    level: Breadcrumb::INFO,
    category: 'campaign',
    message: 'Campaign created',
    data: ['campaign_id' => $campaign->id, 'target_kg' => $campaign->target_kg]
));

// Order created
Sentry::addBreadcrumb(new Breadcrumb(
    level: Breadcrumb::INFO,
    category: 'order',
    message: 'Order created',
    data: ['order_uuid' => $order->uuid, 'total_price' => $order->total_price]
));
```

---

## 4. Laravel Logging

### 4.1 Log Channel Daily

- **Lokasi:** `storage/logs/laravel-2026-07-20.log`
- **Rotasi:** 7 hari (`LOG_DAILY_DAYS=7`)
- **Format:** Plain text (opsional JSON untuk ELK future)

### 4.2 Log Masking (UU PDP)

**Wajib masking PII (Personal Identifiable Information):**

```php
// ✅ Benar
Log::info('OTP sent', [
    'phone_masked' => substr($phone, 0, 4) . '****',
    'cluster_code' => $clusterCode,
]);

// ❌ Salah - tidak boleh log OTP plain di produksi
Log::info('OTP sent', ['phone' => $phone, 'otp' => $otp]);
```

**Local Development:** OTP plain di `storage/logs/otp.log` untuk testing (hanya di local, tidak di produksi).

### 4.3 Telescope (Development Only)

**Instalasi:**

```bash
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate
```

**Konfigurasi .env:**

```ini
TELESCOPE_ENABLED=true  # Hanya dev, false di prod
```

**Dashboard:** `/telescope`

**Fitur:**

- Lihat semua request
- Query log (deteksi N+1)
- Jobs & Queue
- Exceptions
- Logs

**Check N+1 Queries:** Target <5 query per request (dengan eager loading).

---

## 5. Laravel Pulse + Prometheus + Grafana

### 5.1 Laravel Pulse

**Instalasi:**

```bash
composer require laravel/pulse
php artisan pulse:install
php artisan migrate
```

**Konfigurasi .env:**

```ini
PULSE_ENABLED=true
```

**Dashboard:** `/pulse` (hanya admin via middleware `role:admin` + Gate `can:viewPulse`)

**Metrik yang Ditampilkan:**

| Metrik         | Keterangan                   |
| -------------- | ---------------------------- |
| Slow requests  | P95, P99 per endpoint        |
| Slow queries   | Query >1s dengan SQL lengkap |
| Exceptions     | Error rate per endpoint      |
| Queue jobs     | Pending, failed, processed   |
| Cache hit/miss | Cache::remember hit rate     |
| Server         | CPU, Memory, Disk            |

### 5.2 Prometheus Exporter

**Instalasi:**

```bash
composer require promphp/prometheus_client_php
```

**Route `/metrics`:**

```php
// routes/web.php
Route::get('/metrics', [MetricsController::class, 'index'])->middleware('auth:api');
```

**Metrik yang Dikirim:**

```prometheus
# HELP http_request_duration_seconds P95
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds{route="/api/v1/campaigns",method="GET",status="200"} 0.12

# HELP db_query_duration_seconds Slow query
# TYPE db_query_duration_seconds histogram
db_query_duration_seconds{query="SELECT * FROM campaigns WHERE..."} 1.5

# HELP queue_failed_jobs_total Failed jobs counter
# TYPE queue_failed_jobs_total counter
queue_failed_jobs_total 0

# HELP s3_upload_duration_seconds S3 upload latency
# TYPE s3_upload_duration_seconds histogram
s3_upload_duration_seconds 1.6
```

### 5.3 Grafana Dashboard

**Data Source:** Prometheus (scrape `/metrics` setiap 15 detik)

**Dashboard Panels:**

| Panel             | Query                                                                      | Alert                |
| ----------------- | -------------------------------------------------------------------------- | -------------------- |
| API P95 per route | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` | >300ms 5min          |
| Slow queries      | `rate(db_query_duration_seconds_count[5m])`                                | >5 in 10min          |
| Queue failed jobs | `rate(queue_failed_jobs_total[10m])`                                       | >5 in 10min          |
| MySQL connections | `mysql_threads_connected`                                                  | >80% max_connections |
| Redis memory      | `redis_memory_used_bytes`                                                  | >80% maxmemory       |
| SSL expiry        | `ssl_expiry_days`                                                          | <7 days              |

### 5.4 Grafana Alerts

| Alert          | Threshold             | Channel                         | Action                          |
| -------------- | --------------------- | ------------------------------- | ------------------------------- |
| API P95 tinggi | >300ms selama 5 menit | Slack #grosirun-alerts          | Cek Pulse slow queries          |
| Slow queries   | >5 dalam 10 menit     | Slack #grosirun-alerts          | EXPLAIN query, tambah index     |
| Failed jobs    | >5 dalam 10 menit     | Slack #grosirun-alerts          | `php artisan queue:retry --all` |
| DB connections | >80% max_connections  | Slack #grosirun-alerts          | Scale FPM, kill long query      |
| Redis memory   | >80%                  | Slack #grosirun-alerts          | Clear cache, upgrade memory     |
| SSL expiry     | <7 hari               | Slack #grosirun-alerts (urgent) | `certbot renew --force-renewal` |
| Disk VPS       | >80%                  | Slack #grosirun-alerts          | Clean logs, upgrade disk        |
| FCM job fail   | 3 kali tries          | Slack #grosirun-alerts          | Check Firebase credentials      |

---

## 6. S3 + Redis + Queue + Horizon Metrics

### 6.1 S3 Metrics

| Metrik             | Sumber                      | Action jika buruk        |
| ------------------ | --------------------------- | ------------------------ |
| Upload latency     | Custom trace `proof_upload` | Check S3 region, network |
| Error rate 5xx     | CloudWatch / MinIO          | Check IAM, bucket policy |
| TempUrl generation | Custom log                  | Check Policy, IAM        |

### 6.2 Redis Metrics

**Perintah:**

```bash
redis-cli INFO
```

**Metrik Penting:**

| Metrik              | Target          | Action                      |
| ------------------- | --------------- | --------------------------- |
| `used_memory`       | <80% maxmemory  | Clear cache, upgrade        |
| `connected_clients` | <80% maxclients | Check connection leak       |
| `hit_rate` (cache)  | >80%            | Periksa TTL, cache strategy |

### 6.3 Queue & Horizon

**Horizon Dashboard:** `/horizon`

**Metrik:**

| Metrik        | Target            | Action                          |
| ------------- | ----------------- | ------------------------------- |
| Pending jobs  | <100              | Scale worker `numprocs=2→4`     |
| Failed jobs   | <5 dalam 10 menit | `php artisan queue:retry --all` |
| Throughput    | >10 jobs/min      | Scale worker                    |
| Worker status | RUNNING           | `supervisorctl status`          |

**Perintah Monitoring:**

```bash
# Cek status worker
supervisorctl status grosirun-worker:*

# Cek failed jobs
php artisan queue:failed

# Retry all failed
php artisan queue:retry --all
```

---

## 7. Flutter Crashlytics + Firebase Performance + Custom Traces

### 7.1 Firebase Crashlytics

**Instalasi:**

```yaml
dependencies:
  firebase_crashlytics: ^3.5.0
  firebase_core: ^2.31.0
```

**Konfigurasi di main.dart:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Error handler
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    Sentry.captureException(error, stackTrace: stack);
    return true;
  };

  runApp(MyApp());
}
```

**Log Breadcrumb:**

```dart
FirebaseCrashlytics.instance.log('Campaign loaded id $campaignId');
FirebaseCrashlytics.instance.log('Order created uuid $orderUuid');
```

**Target:** Crash-free sessions >99.5%

### 7.2 Firebase Performance

**Instalasi:**

```yaml
dependencies:
  firebase_performance: ^0.9.3+8
```

**Custom Traces:**

#### Trace 1: Campaign List Load

```dart
final trace = FirebasePerformance.instance.newTrace('campaign_list_load');
await trace.start();
trace.putAttribute('cluster_id', clusterId.toString());
trace.putAttribute('is_offline', isOffline.toString());
trace.putAttribute('etag_hit', etagHit.toString());

await campaignRepo.getActiveCampaigns();

await trace.stop();
```

#### Trace 2: Checkout Flow

```dart
final trace = FirebasePerformance.instance.newTrace('checkout_flow');
await trace.start();
trace.putAttribute('payment_method', paymentMethod);
trace.putAttribute('is_offline', isOffline.toString());
trace.putMetric('quantity', quantity);

// ... checkout process

await trace.stop();
```

#### Trace 3: Proof Upload

```dart
final trace = FirebasePerformance.instance.newTrace('proof_upload');
await trace.start();
trace.putMetric('original_size_mb', originalSize);
trace.putAttribute('is_offline', isOffline.toString());

await uploadProof();

await trace.stop();
```

**Dashboard Firebase Performance:**

| Metrik                         | Target     |
| ------------------------------ | ---------- |
| Cold start                     | <2 detik   |
| Home screen render             | <1.5 detik |
| GET /campaigns P95             | <300ms     |
| POST /orders P95               | <300ms     |
| Upload proof P95               | <2 detik   |
| `campaign_list_load` trace P95 | <1.2 detik |
| `checkout_flow` trace P95      | <2 menit   |

### 7.3 Analytics Events

Lihat **ANALYTICS_EVENT_DICTIONARY.md** untuk 30+ event:

| Event                | Trigger           |
| -------------------- | ----------------- |
| `login_success`      | Login berhasil    |
| `campaign_view`      | Detail PO dibuka  |
| `checkout_start`     | Mulai checkout    |
| `checkout_success`   | Order berhasil    |
| `validation_success` | Validasi berhasil |
| `notification_open`  | Notifikasi dibuka |

---

## 8. Slow Query & Pulse Slow Requests

### 8.1 Slow Query Detection

**Pulse Otomatis:** Query >1s muncul di dashboard `/pulse`

**Manual Check:**

```bash
php artisan tinker
```

```php
// Cek slow query log
DB::enableQueryLog();
Campaign::where('cluster_id', 1)
    ->where('status', 'active')
    ->orderBy('deadline')
    ->get();
dd(DB::getQueryLog());

// EXPLAIN
DB::select('EXPLAIN SELECT * FROM campaigns WHERE cluster_id=1 AND status="active" ORDER BY deadline');
```

### 8.2 Slow Request Detection

**Pulse Otomatis:** Request >500ms muncul di dashboard `/pulse`

**Optimasi jika slow:**

| Penyebab      | Solusi                                                 |
| ------------- | ------------------------------------------------------ |
| Missing index | Tambah index `(cluster_id, status, deadline)`          |
| N+1 queries   | Eager loading `with(['variant','user'])`               |
| No cache      | `Cache::remember('campaigns:active', 60, fn() => ...)` |
| Heavy recap   | Gunakan read replica `on('mysql_read')`                |

### 8.3 Slow Query Alert

**Grafana Alert:** Slow queries >5 dalam 10 menit → Slack

**Runbook:**

1. Buka Pulse `/pulse` lihat query lambat
2. Copy SQL
3. Jalankan `EXPLAIN [SQL]`
4. Tambah indeks jika perlu
5. Atau cache query

---

## 9. Alerting Slack + UptimeRobot + SSL Monitoring

### 9.1 Slack Integration

**Webhook URL:** `$SLACK_WEBHOOK` di .env.prod

**Channel:** `#grosirun-alerts`

**Format Alert:**

```json
{
  "text": "🚨 [ALERT_NAME]\n- Severity: [CRITICAL/HIGH/MEDIUM]\n- Time: [timestamp]\n- Details: [detail]\n- Action: [runbook]"
}
```

### 9.2 UptimeRobot / BetterStack

**Endpoint:** `https://api.grosirun.id/api/v1/health`

**Check:** Setiap 1 menit

**Alert:** Jika 503 status code 3 kali berturut-turut

**SSL Monitoring:** UptimeRobot juga monitor SSL expiry

### 9.3 SSL Monitoring Script

**File:** `/var/www/grosirun/check-ssl.sh`

```bash
#!/bin/bash
DOMAIN="api.grosirun.id"
EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt 7 ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"⚠️ SSL Certificate for '$DOMAIN' expires in '$DAYS_LEFT' days!"}' \
        $SLACK_WEBHOOK
fi
```

**Cron:** `0 0 * * * /var/www/grosirun/check-ssl.sh`

### 9.4 Health Endpoint

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

## 10. Dashboard & Runbook

### 10.1 Dashboard Ringkasan

| Dashboard                | URL                           | Fungsi                                         |
| ------------------------ | ----------------------------- | ---------------------------------------------- |
| **Laravel Pulse**        | `/pulse`                      | Slow requests, slow queries, exceptions, queue |
| **Horizon**              | `/horizon`                    | Queue jobs (pending, failed, processes)        |
| **Grafana**              | `https://grafana.grosirun.id` | Metrics P95, DB, Redis, S3, SSL                |
| **Firebase Crashlytics** | Firebase Console              | Crash-free rate, non-fatal errors              |
| **Firebase Performance** | Firebase Console              | Network traces, custom traces P95              |
| **Firebase Analytics**   | Firebase Console              | User behavior, funnel conversion               |
| **S3 CloudWatch**        | AWS Console                   | S3 latency, error rate                         |

### 10.2 Runbook (Jika Alert Menyala)

| Alert                            | Tindakan                                                                                            | Perintah                                                                                                              |
| -------------------------------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| **P95 GET /campaigns >300ms 5m** | 1. Buka Pulse lihat slow queries<br>2. EXPLAIN query<br>3. Cek index<br>4. Cek Redis cache hit rate | `php artisan pulse:check`<br>`EXPLAIN SELECT ...`<br>`redis-cli INFO stats`                                           |
| **Failed jobs >5 10m**           | 1. Lihat daftar failed<br>2. Retry semua<br>3. Cek Redis status<br>4. Restart worker                | `php artisan queue:failed`<br>`php artisan queue:retry --all`<br>`systemctl restart redis`<br>`supervisorctl restart` |
| **SSL expiry <7d**               | 1. Renew certificate<br>2. Reload nginx<br>3. Verifikasi                                            | `certbot renew --force-renewal`<br>`systemctl reload nginx`<br>`curl /health`                                         |
| **Disk >80%**                    | 1. Cek ukuran folder<br>2. Clean logs<br>3. Clean backup<br>4. Upgrade disk                         | `df -h`<br>`php artisan backup:clean`<br>`find storage/logs -name "*.log" -mtime +30 -delete`                         |
| **DB connections >80%**          | 1. Cek processlist<br>2. Kill long query<br>3. Scale FPM                                            | `SHOW PROCESSLIST;`<br>`KILL [id];`<br>`sudo systemctl reload php8.3-fpm`                                             |
| **FCM job fail**                 | 1. Cek Firebase credentials<br>2. Cek FCM token<br>3. Fallback notifications table                  | `ls -la storage/app/firebase/`<br>`php artisan tinker`<br>`SELECT * FROM notifications`                               |
| **Crash-free <99.5%**            | 1. Buka Crashlytics<br>2. Lihat top crash<br>3. Fix hotfix<br>4. Build APK patch                    | `firebase crashlytics:list`<br>Fix di code<br>`flutter build apk`<br>`firebase appdistribution:distribute`            |

---

## 11. Ringkasan & Rekomendasi

### 11.1 Ringkasan

| Komponen                 | Status              | Keterangan                    |
| ------------------------ | ------------------- | ----------------------------- |
| **Logging**              | ✅ Production Ready | Daily channel, masking PII    |
| **Sentry**               | ✅ Production Ready | Capture exception, breadcrumb |
| **Pulse**                | ✅ Production Ready | Slow query, slow request      |
| **Prometheus + Grafana** | ✅ Production Ready | Metrics, alerting             |
| **Horizon**              | ✅ Production Ready | Queue monitoring              |
| **Crashlytics**          | ✅ Production Ready | Crash-free monitoring         |
| **Firebase Performance** | ✅ Production Ready | Custom traces                 |
| **Alerting**             | ✅ Production Ready | Slack, UptimeRobot, SSL       |
| **Runbook**              | ✅ Production Ready | Actionable per alert          |

### 11.2 Rekomendasi V1.1

| #   | Rekomendasi                                                        | Priority |
| --- | ------------------------------------------------------------------ | -------- |
| 1   | Elasticsearch + Kibana untuk log aggregation                       | Medium   |
| 2   | APM (Application Performance Monitoring) untuk distributed tracing | Low      |
| 3   | Synthetic monitoring (selain UptimeRobot)                          | Low      |
| 4   | Custom dashboard Grosirun Business Metrics (GMV, adoption)         | High     |
| 5   | Anomaly detection untuk GMV drop                                   | Medium   |

### 11.3 Business Metrics Dashboard (Future)

**Dashboard untuk Product Owner:**

| Metric                    | Target       | Sumber       |
| ------------------------- | ------------ | ------------ |
| GMV per cluster per bulan | Rp16.800.000 | Orders       |
| Adoption rate             | 70%          | Users        |
| Campaign completion rate  | 80%          | Campaigns    |
| Initiator churn           | <20%         | Users        |
| Platform fee collection   | 95%          | Transactions |

---

**Observability V3.1 Production Ready - Log vs Sentry Matrix, Pulse, Prometheus, Grafana, Crashlytics, Performance Traces, Alerting, Runbook!** 📊🚀
