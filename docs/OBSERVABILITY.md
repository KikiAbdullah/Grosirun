# OBSERVABILITY, PERFORMANCE & ANALYTICS - Grosirun V3.1

**Tanggal:** 20 Juli 2026
**Versi:** 3.1
**Owner:** Backend, Platform & Product Analytics
**Review Cycle:** Setiap release
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)
**Status Dokumen:** Final
**Status Implementasi:** Belum Dimulai

---

## Daftar Isi

1. Telemetry Governance
2. Technical Telemetry
3. Performance Engineering
4. Product Analytics
5. Privacy dan Data Minimization
6. Referensi Observability Terperinci
7. Referensi Performance Terperinci
8. Dictionary Analytics Terperinci

---

## 1. Telemetry Governance

Telemetry terbagi menjadi technical telemetry dan product telemetry dengan taxonomy, owner, retention, access control, environment, version, dan privacy review. Tidak boleh merekam OTP, token, nomor HP, tax ID, proof path, temporary URL, atau payload dokumen.

## 2. Technical Telemetry

Technical telemetry mencakup log, error, trace, metric, queue, database, S3, API latency, lifecycle, reservation invariant, dan security events. Alert harus actionable dan terhubung ke runbook.

## 3. Performance Engineering

Performance mencakup budget, OPcache, PHP-FPM, Nginx, Redis, MySQL, S3, Flutter, capacity test, benchmark plan, regression policy, dan artifact. Seluruh hasil aktual tetap belum diukur sampai aplikasi tersedia.

## 4. Product Analytics

Product telemetry menggunakan 59 event canonical untuk funnel Buyer, Initiator, Seller, dan Admin. Analytics mencatat active role, bukan single role, dan tidak mengirim PII.

## 5. Privacy dan Data Minimization

User ID dianonimkan, parameter dibatasi allowlist, retention mengikuti PRIVACY_POLICY, akses dashboard least privilege, serta BigQuery export hanya setelah privacy review.

## 6. Referensi Observability Terperinci

### 1. Pendahuluan & Konteks Bisnis

#### 1.1 Mengapa Observability Penting untuk Grosirun?

Grosirun adalah platform patungan yang menangani transaksi uang riil (Rp8.400.000 GMV per PO). Setiap gangguan sistem dapat berdampak langsung pada:

| Dampak                  | Potensi Kerugian                 |
| ----------------------- | -------------------------------- |
| API down 1 jam          | Hilang 2 PO = Rp16.800.000 GMV   |
| Oversell bug            | Kehilangan kepercayaan warga     |
| FCM down tanpa fallback | Warga tidak tahu status pesanan  |
| S3 down                 | Bukti QRIS hilang, mediasi sulit |

**Observability memastikan kita bisa mendeteksi dan merespons masalah sebelum berdampak besar pada bisnis.**

#### 1.2 Referensi [BUSINESS_ANALYSIS.md](BUSINESS_ANALYSIS.md)

| Komponen              | Nilai               |
| --------------------- | ------------------- |
| Platform Fee          | 1% GMV + PPN 11%    |
| GMV per PO AT_70      | Rp8.400.000         |
| Laba Initiator per PO | Rp956.760           |
| Target Adopsi         | 70% (35 dari 50 KK) |

**Observability harus melindungi nilai bisnis ini.**

---

### 2. Filosofi Observability

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

### 3. Logging vs Sentry Decision Matrix

#### 3.1 Matriks Keputusan

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

#### 3.2 Konfigurasi .env.prod

```ini
LOG_CHANNEL=daily
LOG_LEVEL=warning  # Produksi: warning+ untuk mengurangi noise
LOG_DAILY_DAYS=7

SENTRY_LARAVEL_DSN=https://...@sentry.io/...
SENTRY_TRACES_SAMPLE_RATE=0.1

PULSE_ENABLED=true
TELESCOPE_ENABLED=false  # Hanya untuk development
```

#### 3.3 Sentry Breadcrumb untuk Business Flow

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
    data: ['campaign_id' => $campaign->id, 'target_quantity' => $campaign->target_quantity]
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

### 4. Laravel Logging

#### 4.1 Log Channel Daily

- **Lokasi:** `storage/logs/laravel-2026-07-20.log`
- **Rotasi:** 7 hari (`LOG_DAILY_DAYS=7`)
- **Format:** Plain text (opsional JSON untuk ELK future)

#### 4.2 Log Masking (UU PDP)

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

#### 4.3 Telescope (Development Only)

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

### 5. Laravel Pulse + Prometheus + Grafana

#### 5.1 Laravel Pulse

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

#### 5.2 Prometheus Exporter

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

#### 5.3 Grafana Dashboard

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

#### 5.4 Grafana Alerts

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

### 6. S3 + Redis + Queue + Horizon Metrics

#### 6.1 S3 Metrics

| Metrik             | Sumber                      | Action jika buruk        |
| ------------------ | --------------------------- | ------------------------ |
| Upload latency     | Custom trace `proof_upload` | Check S3 region, network |
| Error rate 5xx     | CloudWatch / MinIO          | Check IAM, bucket policy |
| TempUrl generation | Custom log                  | Check Policy, IAM        |

#### 6.2 Redis Metrics

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

#### 6.3 Queue & Horizon

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

### 7. Flutter Crashlytics + Firebase Performance + Custom Traces

#### 7.1 Firebase Crashlytics

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

#### 7.2 Firebase Performance

**Instalasi:**

```yaml
dependencies:
  firebase_performance: ^0.9.3+8
```

**Custom Traces:**

##### Trace 1: Campaign List Load

```dart
final trace = FirebasePerformance.instance.newTrace('campaign_list_load');
await trace.start();
trace.putAttribute('cluster_id', clusterId.toString());
trace.putAttribute('is_offline', isOffline.toString());
trace.putAttribute('etag_hit', etagHit.toString());

await campaignRepo.getActiveCampaigns();

await trace.stop();
```

##### Trace 2: Checkout Flow

```dart
final trace = FirebasePerformance.instance.newTrace('checkout_flow');
await trace.start();
trace.putAttribute('payment_method', paymentMethod);
trace.putAttribute('is_offline', isOffline.toString());
trace.putMetric('quantity', quantity);

// ... checkout process

await trace.stop();
```

##### Trace 3: Proof Upload

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

#### 7.3 Analytics Events

Lihat **[Observability — Product Analytics](OBSERVABILITY.md#4-product-analytics)** untuk 30+ event:

| Event                | Trigger           |
| -------------------- | ----------------- |
| `login_success`      | Login berhasil    |
| `campaign_view`      | Detail PO dibuka  |
| `checkout_start`     | Mulai checkout    |
| `checkout_success`   | Order berhasil    |
| `validation_success` | Validasi berhasil |
| `notification_open`  | Notifikasi dibuka |

---

### 8. Slow Query & Pulse Slow Requests

#### 8.1 Slow Query Detection

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

#### 8.2 Slow Request Detection

**Pulse Otomatis:** Request >500ms muncul di dashboard `/pulse`

**Optimasi jika slow:**

| Penyebab      | Solusi                                                 |
| ------------- | ------------------------------------------------------ |
| Missing index | Tambah index `(cluster_id, status, deadline)`          |
| N+1 queries   | Eager loading `with(['variant','user'])`               |
| No cache      | `Cache::remember('campaigns:active', 60, fn() => ...)` |
| Heavy recap   | Gunakan read replica `on('mysql_read')`                |

#### 8.3 Slow Query Alert

**Grafana Alert:** Slow queries >5 dalam 10 menit → Slack

**Runbook:**

1. Buka Pulse `/pulse` lihat query lambat
2. Copy SQL
3. Jalankan `EXPLAIN [SQL]`
4. Tambah indeks jika perlu
5. Atau cache query

---

### 9. Alerting Slack + UptimeRobot + SSL Monitoring

#### 9.1 Slack Integration

**Webhook URL:** `$SLACK_WEBHOOK` di .env.prod

**Channel:** `#grosirun-alerts`

**Format Alert:**

```json
{
  "text": "🚨 [ALERT_NAME]\n- Severity: [CRITICAL/HIGH/MEDIUM]\n- Time: [timestamp]\n- Details: [detail]\n- Action: [runbook]"
}
```

#### 9.2 UptimeRobot / BetterStack

**Endpoint:** `https://api.grosirun.id/api/v1/health`

**Check:** Setiap 1 menit

**Alert:** Jika 503 status code 3 kali berturut-turut

**SSL Monitoring:** UptimeRobot juga monitor SSL expiry

#### 9.3 SSL Monitoring Script

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

#### 9.4 Health Endpoint

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

### 10. Dashboard & Runbook

#### 10.1 Dashboard Ringkasan

| Dashboard                | URL                           | Fungsi                                         |
| ------------------------ | ----------------------------- | ---------------------------------------------- |
| **Laravel Pulse**        | `/pulse`                      | Slow requests, slow queries, exceptions, queue |
| **Horizon**              | `/horizon`                    | Queue jobs (pending, failed, processes)        |
| **Grafana**              | `https://grafana.grosirun.id` | Metrics P95, DB, Redis, S3, SSL                |
| **Firebase Crashlytics** | Firebase Console              | Crash-free rate, non-fatal errors              |
| **Firebase Performance** | Firebase Console              | Network traces, custom traces P95              |
| **Firebase Analytics**   | Firebase Console              | User behavior, funnel conversion               |
| **S3 CloudWatch**        | AWS Console                   | S3 latency, error rate                         |

#### 10.2 Runbook (Jika Alert Menyala)

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

#### 10.6 Dashboard dan Alert Supply Domain

Metrik: jumlah supplier pending verification, offer active/expired, offer-to-campaign conversion, PO acceptance rate, seller response P95, shipment on-time rate, discrepancy rate, invalid transition count, reservation conflict, dan invariant kapasitas. Dashboard memisahkan campaign `target_reached`, `po_submitted`, `fulfillment`, `distribution`, dan `completed`.

Alert dikirim jika PO `submitted` tidak direspons 12 jam, shipment melewati SLA, discrepancy >2%, `reserved_quantity + committed_quantity > available_quantity`, reservation release gagal, Admin override tanpa ticket, atau akses Seller ke data Buyer terdeteksi. Log menggunakan ID/UUID dan base-unit quantity; tax ID, nomor HP, alamat lengkap, proof path, dan temporary URL tidak dicatat.

### 11. Ringkasan & Rekomendasi

#### 11.1 Ringkasan

| Komponen                 | Status              | Keterangan                    |
| ------------------------ | ------------------- | ----------------------------- |
| **Logging**              | Dokumen final; belum diimplementasikan | Daily channel, masking PII    |
| **Sentry**               | Dokumen final; belum diimplementasikan | Capture exception, breadcrumb |
| **Pulse**                | Dokumen final; belum diimplementasikan | Slow query, slow request      |
| **Prometheus + Grafana** | Dokumen final; belum diimplementasikan | Metrics, alerting             |
| **Horizon**              | Dokumen final; belum diimplementasikan | Queue monitoring              |
| **Crashlytics**          | Dokumen final; belum diimplementasikan | Crash-free monitoring         |
| **Firebase Performance** | Dokumen final; belum diimplementasikan | Custom traces                 |
| **Alerting**             | Dokumen final; belum diimplementasikan | Slack, UptimeRobot, SSL       |
| **Runbook**              | Dokumen final; belum diimplementasikan | Actionable per alert          |

#### 11.2 Rekomendasi V1.1

| #   | Rekomendasi                                                        | Priority |
| --- | ------------------------------------------------------------------ | -------- |
| 1   | Elasticsearch + Kibana untuk log aggregation                       | Medium   |
| 2   | APM (Application Performance Monitoring) untuk distributed tracing | Low      |
| 3   | Synthetic monitoring (selain UptimeRobot)                          | Low      |
| 4   | Custom dashboard Grosirun Business Metrics (GMV, adoption)         | High     |
| 5   | Anomaly detection untuk GMV drop                                   | Medium   |

#### 11.3 Business Metrics Dashboard (Future)

**Dashboard untuk Product Owner:**

| Metric                    | Target       | Sumber       |
| ------------------------- | ------------ | ------------ |
| GMV per cluster per bulan | Rp16.800.000 | Orders       |
| Adoption rate             | 70%          | Users        |
| Campaign completion rate  | 80%          | Campaigns    |
| Initiator churn           | <20%         | Users        |
| Platform fee collection   | 95%          | Transactions |

---

## 7. Referensi Performance Terperinci

### 1. Pendahuluan & Konteks Bisnis

#### 1.1 Mengapa Performance Tuning Penting?

Grosirun adalah platform patungan yang menangani transaksi uang riil. Performa aplikasi yang lambat dapat berdampak langsung pada bisnis:

| Dampak                | Potensi Kerugian               |
| --------------------- | ------------------------------ |
| GET /campaigns >300ms | Warga malas membuka aplikasi   |
| POST /orders >500ms   | Checkout batal, warga pergi    |
| Upload proof >3 detik | Warga frustrasi upload ulang   |
| Downtime 1 jam        | Hilang 2 PO = Rp16.800.000 GMV |

**Tujuan tuning:** Memastikan aplikasi tetap responsif bahkan saat 100 warga checkout bersamaan (thundering herd).

#### 1.2 Referensi [BUSINESS_ANALYSIS.md](BUSINESS_ANALYSIS.md)

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

### 2. Performance Budget

#### 2.1 Target Performa

| Layer | Metrik | Budget | Hasil aktual | Alat ukur |
| --- | --- | --- | --- | --- |
| API | GET /campaigns P95 cache hit | <150ms | Belum diukur | Pulse + k6 |
| API | POST /orders P95 lock | <300ms | Belum diukur | k6 |
| API | GET /offers P95 | <200ms | Belum diukur | k6 |
| API | POST /campaigns dari offer P95 | <350ms | Belum diukur | k6 |
| API | Transisi purchase order P95 | <300ms | Belum diukur | k6 |
| API | Upload proof 2MB average | <2s | Belum diukur | k6/Postman |
| Mobile | Cold start | <2s | Belum diukur | Firebase Performance |
| Mobile | RAM PSS low-end | <180MB | Belum diukur | Android Profiler |
| Mobile | APK arm64 | <10MB | Belum diukur | CI artifact |
| Mobile | Crash-free | >99.5% | Belum diukur | Crashlytics |

Tidak ada baseline aktual sebelum aplikasi, environment pengujian, commit, dan artefak hasil tersedia.

#### 2.2 Tindakan Jika Budget Terlampaui

| Langkah | Action                           |
| ------- | -------------------------------- |
| 1       | Investigasi root cause           |
| 2       | Optimasi (lihat section terkait) |
| 3       | Jalankan ulang benchmark         |
| 4       | Update [Observability — Performance & Benchmark](OBSERVABILITY.md#3-performance-engineering)  |

---

### 3. Laravel Tuning

#### 3.1 OPcache Configuration

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

#### 3.2 Redis Cache Strategy

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

#### 3.3 Nginx Tuning

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

#### 3.4 PHP-FPM Pool Tuning

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

### 4. Database Tuning

#### 4.1 Index Strategy

**Indeks Wajib (dari [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)):**

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

#### 4.2 EXPLAIN Usage

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

#### 4.3 Partitioning (Future V2)

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

#### 4.4 Read Replica

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

#### 4.5 Connection Pooling

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

### 5. S3 Tuning

#### 5.1 Konfigurasi S3

| Aspek          | Konfigurasi                             | Keterangan                 |
| -------------- | --------------------------------------- | -------------------------- |
| **Bucket**     | Private Block Public Access ON          | Keamanan                   |
| **TempUrl**    | `temporaryUrl($path, now()->addHour())` | 1 jam expiry               |
| **Lifecycle**  | `order_proofs/*` 90 hari                | UU PDP                     |
| **Versioning** | ON                                      | Recovery accidental delete |
| **Region**     | ap-southeast-1                          | Dekat dengan Indonesia     |

#### 5.2 CloudFront CDN (Opsional V1.1)

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

#### 5.3 Transfer Acceleration (Opsional)

Untuk upload proof dari Indonesia ke S3 Singapore:

```bash
aws s3api put-bucket-accelerate-configuration \
  --bucket grosirun-prod-private \
  --accelerate-configuration Status=Enabled
```

**URL:** `s3-accelerate.amazonaws.com`

---

### 6. Queue Tuning (Horizon)

#### 6.1 Horizon Configuration

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

#### 6.2 Supervisor Configuration

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

#### 6.3 Monitoring

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

### 7. Flutter Tuning

#### 7.1 ListView Optimization

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

#### 7.2 Image Caching

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

#### 7.3 Memory Leak Prevention

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

#### 7.4 Frame 60 FPS

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

#### 7.5 APK Size <10MB

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

### 8. Load Testing & Benchmark

**Status:** Belum dijalankan. Seluruh angka pada bagian ini adalah target, bukan hasil aktual.

#### 8.1 Environment Wajib Dicatat

Setiap run menyimpan commit SHA nyata, tanggal Asia/Jakarta, CPU/RAM, versi PHP/MySQL/Redis, dataset, network profile, k6 command, raw JSON, summary, dan link CI artifact. Hasil tanpa metadata tersebut tidak boleh disebut baseline.

#### 8.2 Skenario Backend

| Skenario | Beban | Target |
| --- | --- | --- |
| Daftar campaign | 100 VU/30s | P95 <150ms, 5xx <0.1% |
| Checkout sisa kapasitas | 100 VU/30s | P95 <300ms, tidak oversell |
| Reserve offer bersama | 100 Inisiator | invariant capacity selalu benar |
| Create campaign snapshot | 50 VU | P95 <350ms, satu reservation/idempotency key |
| Seller decision PO | 50 VU | P95 <300ms, state log tidak ganda |
| Recap 200 order | 10 VU/60s | P95 <3s |
| Upload proof 2MB | 10 VU/30s | average <2s |

#### 8.3 Skenario Mobile

Ukur cold/warm start, RAM PSS, frame rendering, APK per ABI, offline queue, offer list, Seller workspace, role switching, dan crash-free. Perangkat minimum Android 7 RAM 2GB; hasil tetap `Belum diukur` sampai perangkat dan build aktual tersedia.

#### 8.4 Prosedur Baseline

1. Deploy commit kandidat ke environment terisolasi.
2. Seed dataset deterministik tanpa PII.
3. Warm-up, jalankan minimal tiga kali, simpan raw output.
4. Gunakan median run sebagai baseline dan catat variasi.
5. Verifikasi correctness: quota, capacity, idempotency, state log, dan data privacy.
6. Review hasil; baru isi tabel baseline history.

#### 8.5 Template Hasil

| Versi | Tanggal | Commit SHA | Skenario | P50 | P95 | P99 | Error rate | Correctness | Artifact |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Belum tersedia | — | — | — | — | — | — | — | — | — |

#### 8.6 Regression Policy

Investigasi jika P95 memburuk >20% dari baseline terverifikasi atau melewati budget, error rate meningkat, atau correctness gagal. Baseline hanya diperbarui setelah perubahan diterima dan alasan dicatat; jangan mengubah baseline untuk menyembunyikan regresi.

---

### 9. Integrasi dengan Telemetry Canonical

Performance engineering menerbitkan metric dan trace ke dashboard, alert, dan runbook yang didefinisikan satu kali pada bagian 6. Jangan membuat threshold alert kedua di bagian performance. Budget dan benchmark pada bagian ini menjadi input bagi rules technical telemetry.

---

## 8. Dictionary Analytics Terperinci

### 1. Konvensi Penamaan

#### 1.1 Penamaan Event

- Format: `snake_case` (huruf kecil dengan underscore)
- Contoh: `login_success`, `campaign_view`, `checkout_start`
- Kata kerja di depan untuk action: `login_`, `checkout_`, `upload_`
- Kata benda di depan untuk view: `campaign_`, `notification_`

#### 1.2 Parameter Event

- Format: `snake_case`
- Tipe data: string, integer, boolean
- Parameter wajib diberi tanda di kolom Params
- Hindari PII (Personally Identifiable Information) seperti email, nomor HP full

#### 1.3 Properti Pengguna

- Format: `snake_case`
- Dikirim sekali saat login/setUserProperty
- Digunakan untuk segmentasi di dashboard

---

### 2. Daftar Event (59 Event)

#### 2.1 Event Aplikasi & Sesi

| #   | Nama Event | Trigger                                        | Parameter                                                                                                                   | Level |
| --- | ---------- | ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ----- |
| 1   | `app_open` | Aplikasi dibuka dari keadaan mati (cold start) | `app_version` - versi aplikasi<br>`cluster_code` - kode cluster user<br>`is_first_open` - boolean, apakah pertama kali buka | High  |

#### 2.2 Event Autentikasi

| #   | Nama Event      | Trigger                                  | Parameter                                                                                                                                                         | Level    |
| --- | --------------- | ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| 2   | `login_start`   | User menekan tombol Kirim OTP            | `phone_masked` - nomor HP terenkripsi (62812\*\*\*\*)                                                                                                             | Medium   |
| 3   | `otp_sent`      | Request OTP berhasil (status 200)        | `phone_masked` - nomor HP terenkripsi<br>`cluster_code` - kode cluster                                                                                            | High     |
| 4   | `otp_verify`    | User menekan tombol Verifikasi OTP       | `attempts` - jumlah percobaan<br>`is_success` - boolean, berhasil/gagal                                                                                           | High     |
| 5   | `login_success` | Autentikasi berhasil, user masuk ke Home | `user_id` - ID user (anonymized)<br>`active_role` - buyer/initiator/seller/admin<br>`cluster_id` - ID cluster<br>`consent_version` - versi consent<br>`tos_version` - versi ToS | Critical |
| 6   | `login_fail`    | Autentikasi gagal (OTP salah, lock)      | `error_code` - kode error (ERR_001, ERR_001_RL)<br>`remaining_attempts` - sisa percobaan                                                                          | High     |
| 7   | `logout`        | User logout manual                       | `user_id` - ID user (anonymized)                                                                                                                                  | Medium   |

#### 2.3 Event Consent & ToS (UU PDP)

| #   | Nama Event       | Trigger                                            | Parameter                                          | Level         |
| --- | ---------------- | -------------------------------------------------- | -------------------------------------------------- | ------------- |
| 8   | `consent_accept` | User centang checkbox consent + POST /auth/consent | `consent_version` - versi kebijakan privasi (v1.0) | High (UU PDP) |
| 9   | `tos_accept`     | User centang checkbox ToS + POST /auth/tos-accept  | `tos_version` - versi syarat layanan (v1.0)        | High          |

#### 2.4 Event Campaign (PO)

| #   | Nama Event                | Trigger                        | Parameter                                                                                                                                                       | Level    |
| --- | ------------------------- | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| 10  | `campaign_list_view`      | Home berhasil memuat daftar PO | `cluster_id` - ID cluster<br>`count` - jumlah PO yang tampil<br>`is_offline` - boolean, apakah dari cache Hive<br>`etag_hit` - boolean, apakah 304 Not Modified | Critical |
| 11  | `campaign_detail_view`    | Halaman detail PO terbuka      | `campaign_id` - ID PO<br>`slug` - slug PO<br>`target_quantity` - target kilogram<br>`current_quantity` - kilogram terkumpul<br>`progress_percent` - persentase progress     | Critical |
| 12  | `campaign_create_start`   | Inisiator memilih offer untuk PO | `cluster_id` - ID cluster<br>`offer_id` - penawaran terpilih                                                                                                                                       | Medium   |
| 13  | `campaign_create_success` | Snapshot offer tersimpan dan PO dipublikasikan | `campaign_id` - ID PO<br>`offer_id` - penawaran sumber<br>`offer_version` - versi snapshot<br>`target_quantity` - target kilogram<br>`variant_count` - jumlah varian<br>`deadline_hours` - tenggat waktu dalam jam                         | High     |
| 14  | `campaign_create_fail`    | Gagal buat PO                  | `error_code` - kode error                                                                                                                                       | Medium   |

#### 2.5 Event Interaksi Campaign

| #   | Nama Event           | Trigger                                 | Parameter                                                                                                                                | Level  |
| --- | -------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 15  | `deep_link_open`     | User klik link grosirun://campaign/{id} | `campaign_id` - ID PO<br>`source` - cold/warm (app mati/hidup)<br>`is_pending` - boolean, apakah disimpan saat belum login               | Medium |
| 16  | `share_wa`           | User menekan tombol Bagikan ke WA       | `campaign_id` - ID PO<br>`share_text_length` - panjang teks yang dibagikan                                                               | Medium |
| 17  | `social_ticker_view` | Ticker sosial terlihat selama 5 detik   | `campaign_id` - ID PO                                                                                                                    | Low    |
| 18  | `variant_select`     | User menekan tombol + atau - varian     | `campaign_id` - ID PO<br>`variant_size` - ukuran varian (5/10 Kg)<br>`quantity` - jumlah yang dipilih<br>`remaining` - sisa kuota varian | Medium |

#### 2.6 Event Checkout & Order

| #   | Nama Event         | Trigger                            | Parameter                                                                                                                                                                                                                                                                                        | Level                   |
| --- | ------------------ | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| 19  | `checkout_start`   | User menekan tombol Pesan Sekarang | `campaign_id` - ID PO<br>`variant_id` - ID varian<br>`variant_size` - ukuran varian<br>`quantity` - jumlah<br>`total_price` - total harga<br>`payment_method` - cash/qris                                                                                                                        | Critical (funnel start) |
| 20  | `checkout_success` | Order berhasil (status 201)        | `campaign_id` - ID PO<br>`order_uuid` - UUID order<br>`variant_size` - ukuran varian<br>`quantity` - jumlah<br>`total_quantity` - total kilogram<br>`total_price` - total harga<br>`payment_method` - cash/qris<br>`is_offline` - boolean, apakah order offline<br>`idempotency_key` - key idempotensi | Critical (funnel)       |
| 21  | `checkout_fail`    | Order gagal                        | `campaign_id` - ID PO<br>`error_code` - ERR_024 OUT_OF_STOCK, ERR_040 CLUSTER_MISMATCH<br>`remaining` - sisa stok (jika out of stock)                                                                                                                                                            | High                    |
| 22  | `order_cancel`     | Buyer membatalkan order pending    | `order_uuid` - UUID order<br>`campaign_id` - ID PO                                                                                                                                                                                                                                               | Medium                  |

#### 2.7 Event Upload Proof (QRIS)

| #   | Nama Event          | Trigger                                      | Parameter                                                                                                                                                                                                                     | Level  |
| --- | ------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 23  | `proof_pick`        | User memilih gambar bukti dari galeri/kamera | `campaign_id` - ID PO<br>`order_uuid` - UUID order<br>`source` - camera/gallery<br>`original_size_mb` - ukuran file asli (MB)                                                                                                 | Medium |
| 24  | `proof_upload`      | Upload bukti berhasil (status 200)           | `order_uuid` - UUID order<br>`original_size_mb` - ukuran asli<br>`compressed_size_mb` - ukuran setelah kompres<br>`is_offline_queued` - boolean, apakah disimpan antrian offline<br>`duration_ms` - durasi upload (milidetik) | High   |
| 25  | `proof_upload_fail` | Upload bukti gagal                           | `error_code` - ERR_050 UPLOAD_TOO_LARGE, network error<br>`size_mb` - ukuran file                                                                                                                                             | Medium |

#### 2.8 Event Admin & Validasi

| #   | Nama Event           | Trigger                                | Parameter                                                                                                                                         | Level                   |
| --- | -------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| 26  | `validation_success` | Initiator validasi pembayaran berhasil | `order_uuid` - UUID order<br>`campaign_id` - ID PO<br>`validation_type` - cash/qris/override<br>`notes_length` - panjang catatan (untuk override) | Critical (admin funnel) |
| 27  | `validation_fail`    | Validasi gagal (admin race)            | `error_code` - ERR_030 ALREADY_VALIDATED, ERR_031 STALE_DATA                                                                                      | High                    |
| 28  | `reject_proof`       | Initiator menolak bukti blur           | `order_uuid` - UUID order<br>`reason_length` - panjang alasan penolakan                                                                           | Medium                  |
| 29  | `batch_validate`     | Initiator validasi massal (207)        | `campaign_id` - ID PO<br>`success_count` - jumlah berhasil<br>`failed_count` - jumlah gagal                                                       | Medium                  |

#### 2.9 Event Recap & Distribusi

| #   | Nama Event              | Trigger                                     | Parameter                                                                                                                            | Level  |
| --- | ----------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------ |
| 30  | `recap_view`            | Initiator melihat rekap PDF                 | `campaign_id` - ID PO<br>`total_quantity` - total kilogram<br>`total_revenue` - total pendapatan<br>`is_pdf` - boolean, apakah membuka PDF | Medium |
| 31  | `distribution_check`    | Initiator menandai buyer sudah ambil barang | `order_uuid` - UUID order<br>`campaign_id` - ID PO<br>`taken_count` - jumlah yang sudah ambil<br>`remaining` - sisa yang belum ambil | Medium |
| 32  | `distribution_complete` | Initiator menyelesaikan distribusi          | `campaign_id` - ID PO<br>`total_taken` - total yang sudah ambil                                                                      | High   |

#### 2.10 Event Notifikasi

| #   | Nama Event             | Trigger                                    | Parameter                                                                                                                               | Level  |
| --- | ---------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 33  | `notification_receive` | FCM diterima (foreground/background)       | `type` - NEW_ORDER, DEADLINE_WARNING, CANCELLED, COMPLETED<br>`campaign_id` - ID PO<br>`is_foreground` - boolean, apakah app terbuka    | High   |
| 34  | `notification_open`    | User menekan notifikasi                    | `type` - jenis notifikasi<br>`campaign_id` - ID PO<br>`is_fallback` - boolean, apakah dari polling fallback<br>`read_at` - waktu dibaca | High   |
| 35  | `fcm_fallback_poll`    | Polling GET /notifications setiap 60 detik | `unread_count` - jumlah notifikasi belum dibaca<br>`is_fcm_down` - boolean, apakah FCM bermasalah                                       | Medium |

#### 2.11 Event Privasi & Akun

| #   | Nama Event                | Trigger                                    | Parameter                                                            | Level         |
| --- | ------------------------- | ------------------------------------------ | -------------------------------------------------------------------- | ------------- |
| 36  | `account_delete`          | User menghapus akun (DELETE /auth/account) | `reason` - alasan (opsional)<br>`cluster_id` - ID cluster            | High (UU PDP) |
| 37  | `account_delete_complete` | Proses anonimisasi selesai (<24 jam)       | `user_id` - ID user (anonymized)<br>`duration_hours` - durasi proses | High          |

#### 2.12 Event Error & Offline

| #   | Nama Event       | Trigger                           | Parameter                                                                                          | Level    |
| --- | ---------------- | --------------------------------- | -------------------------------------------------------------------------------------------------- | -------- |
| 38  | `error_boundary` | Error tidak tertangani di Flutter | `error` - pesan error<br>`stack` - stack trace (dihash)<br>`screen` - halaman tempat error terjadi | Critical |
| 39  | `offline_banner` | Banner offline muncul             | `is_offline` - true<br>`screen` - home/detail/checkout                                             | Low      |

---


#### 2.13 Event Seller, Offer, dan Purchase Order

| No | Event | Trigger | Parameter utama |
| --- | --- | --- | --- |
| 40 | `role_switch` | User mengganti role aktif | `from_role`, `to_role` |
| 41 | `supplier_registration_submit` | Seller mengirim profil | `supplier_id` |
| 42 | `supplier_verification_result` | Admin memberi keputusan | `supplier_id`, `decision` |
| 43 | `offer_submit` | Seller mengirim offer | `offer_id`, `supplier_id`, `tier_count` |
| 44 | `offer_moderation_result` | Admin memoderasi offer | `offer_id`, `decision` |
| 45 | `campaign_create_from_offer` | Inisiator membuat campaign | `offer_id`, `campaign_id`, `offer_version` |
| 46 | `purchase_order_submit` | Inisiator submit PO | `purchase_order_id`, `supplier_id`, `total` |
| 47 | `purchase_order_decision` | Seller accept/reject | `purchase_order_id`, `decision`, `response_seconds` |
| 48 | `purchase_order_status_change` | Fulfillment berubah | `from_status`, `to_status` |
| 49 | `fulfillment_discrepancy` | Barang diterima tidak sesuai | `purchase_order_id`, `quantity_delta` |

| 50 | `offer_variant_select` | Inisiator memilih packaging | `offer_id`, `offer_variant_id`, `package_quantity`, `base_unit` |
| 51 | `offer_capacity_reserve` | Campaign mereservasi kapasitas | `offer_id`, `quantity`, `result` |
| 52 | `campaign_status_change` | Lifecycle campaign berubah | `from_status`, `to_status`, `reason_code` |
| 53 | `purchase_order_timeout` | PO melewati SLA | `purchase_order_id`, `age_hours` |
| 54 | `supplier_member_invite` | Owner mengundang member | `supplier_id`, `member_role` |
| 55 | `fulfillment_dispute_open` | Inisiator membuka dispute | `purchase_order_id`, `reason_code` |
| 56 | `fulfillment_dispute_resolve` | Admin menyelesaikan dispute | `resolution`, `duration_hours` |
| 57 | `admin_supplier_verification` | Keputusan verifikasi | `decision`, `duration_hours` |
| 58 | `admin_offer_moderation` | Keputusan moderasi | `decision`, `duration_hours` |
| 59 | `admin_emergency_override` | Override insiden | `resource_type`, `reason_code` |

Analytics tidak mengirim nama supplier legal, tax ID, nama Pembeli, nomor HP, alamat lengkap, atau path dokumen.

### 3. Properti Pengguna (User Properties)

Properti ini dikirim sekali saat login atau berubah, digunakan untuk segmentasi di dashboard.

| Properti       | Nilai                           | Keterangan                   |
| -------------- | ------------------------------- | ---------------------------- |
| `active_role`  | `buyer` / `initiator` / `seller` / `admin` | Role aktif pada sesi         |
| `role_count`   | `1`, `2`, ... | Jumlah role yang dimiliki tanpa mengirim daftar sensitif |
| `cluster_code` | `PGH-RT03`, `PGH-RT04`          | Kode cluster RT              |
| `app_version`  | `1.0.0+1`                       | Versi aplikasi (versionCode) |
| `has_consent`  | `true` / `false`                | Apakah sudah setuju UU PDP   |
| `has_tos`      | `true` / `false`                | Apakah sudah setuju ToS      |
| `platform`     | `android` / `ios`               | Platform perangkat           |
| `device_model` | `Samsung A10`, `Redmi 4A`       | Model perangkat              |
| `os_version`   | `Android 9`, `Android 11`       | Versi OS                     |

**Implementasi:**

```dart
await analytics.setUserProperty(
  name: 'active_role',
  value: user.activeRole,
);
await analytics.setUserProperty(
  name: 'cluster_code',
  value: user.clusterCode,
);
```

---

### 4. Funnel Analitik

#### 4.1 Funnel Buyer (End-to-End)

```
app_open
  → login_success
    → campaign_list_view
      → campaign_detail_view
        → checkout_start
          → checkout_success
            → validation_success (admin)
              → distribution_check
```

**Target Funnel (dari PRD):**

- `campaign_detail_view` → `checkout_success`: **>60%**
- `checkout_start` → `checkout_success`: **>80%**
- `validation_success` → `distribution_check`: **>90%**

**Cara Monitor di Firebase:**

1. Firebase Console → Analytics → Funnel
2. Buat Funnel baru dengan urutan event di atas
3. Set date range 30 hari
4. Bandingkan conversion rate antar cluster

#### 4.2 Funnel Admin (Initiator)

```
login_success (active_role=initiator)
  → campaign_list_view
    → campaign_detail_view
      → validation_success
        → recap_view
          → distribution_complete
```

**Target Funnel:**

- `campaign_detail_view` → `validation_success`: **>90%**
- `validation_success` → `distribution_complete`: **>85%**

#### 4.3 Funnel A/B Test (Tombol 56dp vs 48dp)

```
campaign_detail_view
  → checkout_start (variant A: tombol 56dp)
  → checkout_success
```

Bandakan conversion rate antar 2 grup dengan Remote Config.

---

### 5. Implementasi Flutter

#### 5.1 Setup Analytics Service

`lib/core/analytics/analytics_service.dart`:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;

  // Log event dengan Sentry breadcrumb
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters?.map(
          (key, value) => MapEntry(key, value as Object),
        ),
      );

      // Tambahkan ke Sentry untuk debugging
      await Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'analytics: $name',
          data: parameters,
          category: 'analytics',
        ),
      );
    } catch (e) {
      // Jangan gagalkan app jika analytics error
      debugPrint('Analytics error: $e');
    }
  }

  // Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Set user ID (anonymized)
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Custom Performance Trace
  PerformanceTrace startTrace(String name) {
    return _performance.newTrace(name);
  }
}

// Singleton instance
final analytics = AnalyticsService();
```

#### 5.2 Event Logger Helper

`lib/core/analytics/event_logger.dart`:

```dart
class EventLogger {
  // Auth Events
  static Future<void> loginSuccess({
    required String userId,
    required String activeRole,
    required int clusterId,
  }) async {
    await analytics.logEvent(
      name: 'login_success',
      parameters: {
        'user_id': userId.hashCode.toString(), // Anonymized
        'active_role': activeRole,
        'cluster_id': clusterId,
        'consent_version': 'v1.0',
        'tos_version': 'v1.0',
      },
    );
    await analytics.setUserId(userId);
    await analytics.setUserProperty(name: 'active_role', value: activeRole);
    await analytics.setUserProperty(
      name: 'cluster_id',
      value: clusterId.toString(),
    );
  }

  // Campaign Events
  static Future<void> campaignListView({
    required int clusterId,
    required int count,
    required bool isOffline,
    required bool etagHit,
  }) async {
    await analytics.logEvent(
      name: 'campaign_list_view',
      parameters: {
        'cluster_id': clusterId,
        'count': count,
        'is_offline': isOffline,
        'etag_hit': etagHit,
      },
    );
  }

  // Checkout Events
  static Future<void> checkoutSuccess({
    required int campaignId,
    required String orderUuid,
    required int variantSize,
    required int quantity,
    required int totalKg,
    required int totalPrice,
    required String paymentMethod,
    required bool isOffline,
    required String idempotencyKey,
  }) async {
    // Performance trace
    final trace = analytics.startTrace('checkout_flow');
    await trace.start();
    trace.putAttribute('payment_method', paymentMethod);
    trace.putAttribute('is_offline', isOffline.toString());
    trace.putMetric('quantity', quantity);

    await analytics.logEvent(
      name: 'checkout_success',
      parameters: {
        'campaign_id': campaignId,
        'order_uuid': orderUuid,
        'variant_size': variantSize,
        'quantity': quantity,
        'total_quantity': totalKg,
        'total_price': totalPrice,
        'payment_method': paymentMethod,
        'is_offline': isOffline,
        'idempotency_key': idempotencyKey,
      },
    );

    await trace.stop();
  }

  // Error Events
  static Future<void> errorBoundary({
    required dynamic error,
    required StackTrace stack,
    required String screen,
  }) async {
    await analytics.logEvent(
      name: 'error_boundary',
      parameters: {
        'error': error.toString(),
        'screen': screen,
        // Stack trace dihash untuk privacy
      },
    );
  }
}
```

#### 5.3 Penggunaan di Cubit

`lib/logic/cubits/order/order_cubit.dart`:

```dart
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  Future<void> createOrder({
    required int campaignId,
    required int variantId,
    required int quantity,
    required String paymentMethod,
  }) async {
    emit(OrderLoading());
    final startTime = DateTime.now();

    try {
      final order = await _repository.createOrder(...);

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      await EventLogger.checkoutSuccess(
        campaignId: campaignId,
        orderUuid: order.uuid,
        variantSize: order.variantSize,
        quantity: quantity,
        totalKg: order.totalKg,
        totalPrice: order.totalPrice,
        paymentMethod: paymentMethod,
        isOffline: false,
        idempotencyKey: order.idempotencyKey,
      );

      emit(OrderSuccess(order));
    } catch (e) {
      await EventLogger.checkoutFail(
        campaignId: campaignId,
        errorCode: _getErrorCode(e),
      );
      emit(OrderError(e.toString()));
    }
  }
}
```

#### 5.4 Performance Traces

**Trace 1: Campaign List Load**

```dart
final trace = analytics.startTrace('campaign_list_load');
await trace.start();
trace.putAttribute('cluster_id', clusterId.toString());
trace.putAttribute('is_offline', isOffline.toString());

await _repository.getActiveCampaigns();

await trace.stop();
```

**Trace 2: Proof Upload**

```dart
final trace = analytics.startTrace('proof_upload');
await trace.start();
trace.putAttribute('is_offline', isOffline.toString());
trace.putMetric('original_size_mb', originalSize);

await _repository.uploadProof(...);

await trace.stop();
```

---

### 6. Dashboard & Monitoring

#### 6.1 Firebase Analytics Dashboard

| Komponen            | Lokasi                      | Kegunaan                                   |
| ------------------- | --------------------------- | ------------------------------------------ |
| **Events**          | Analytics → Events          | Lihat semua 59 event, jumlah, parameter    |
| **Funnels**         | Analytics → Funnels         | Monitoring conversion rate buyer & admin   |
| **User Properties** | Analytics → User Properties | Segmentasi berdasarkan active role dan cluster       |
| **Cohorts**         | Analytics → Cohorts         | Retention W2, W4 per cluster               |
| **DebugView**       | Analytics → DebugView       | Debug real-time event (aktifkan di device) |

#### 6.2 Query SQL untuk BigQuery (Opsional V1.1)

**Query Funnel Conversion:**

```sql
-- Conversion campaign_detail_view → checkout_success per cluster
WITH detail_view AS (
  SELECT DISTINCT user_id, campaign_id, DATE(event_timestamp) AS view_date
  FROM `grosirun.analytics.events`
  WHERE event_name = 'campaign_detail_view'
),
checkout_success AS (
  SELECT DISTINCT user_id, campaign_id, DATE(event_timestamp) AS checkout_date
  FROM `grosirun.analytics.events`
  WHERE event_name = 'checkout_success'
)
SELECT
  d.cluster_id,
  COUNT(DISTINCT d.user_id) AS viewers,
  COUNT(DISTINCT c.user_id) AS converters,
  ROUND(SAFE_DIVIDE(COUNT(DISTINCT c.user_id), COUNT(DISTINCT d.user_id)) * 100, 2) AS conversion_rate
FROM detail_view d
LEFT JOIN checkout_success c
  ON d.user_id = c.user_id
  AND d.campaign_id = c.campaign_id
GROUP BY d.cluster_id
ORDER BY conversion_rate DESC;
```

---

### 7. Troubleshooting & Debug

#### 7.1 Debug Mode di Firebase

```dart
// Aktifkan DebugView di Firebase
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Di terminal
adb shell setprop debug.firebase.analytics.app com.grosirun.app
```

#### 7.2 Cek Event Terkirim

1. Buka aplikasi
2. Buka Firebase Console → Analytics → DebugView
3. Lakukan action di app
4. Lihat event muncul dalam 5 detik

#### 7.3 Event Tidak Muncul

| Masalah                      | Solusi                                                 |
| ---------------------------- | ------------------------------------------------------ |
| DebugView kosong             | Set `setAnalyticsCollectionEnabled(true)`, restart app |
| Parameter tidak muncul       | Cek tipe data (Object tidak boleh, gunakan String/Int) |
| Event tidak terkirim offline | Firebase SDK cache event, kirim saat online            |

---

### 8. Checklist Finalisasi

- [ ] Semua 59 event terdefinisi
- [ ] User Properties terkirim saat login
- [ ] Funnel Buyer dibuat di Firebase
- [ ] Funnel Admin dibuat di Firebase
- [ ] Performance Traces: `campaign_list_load`, `checkout_flow`, `proof_upload`
- [ ] Error Boundary mengirim `error_boundary` event
- [ ] DebugView berfungsi di device test
- [ ] Crashlytics terintegrasi
- [ ] Sentry breadcrumb terkirim untuk setiap event
- [ ] Dokumentasi update di [CHANGELOG.md](CHANGELOG.md)

---
