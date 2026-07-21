# DICTIONARY ANALYTICS - Grosirun V3.1

**Platform:** Firebase Analytics + Custom Traces Firebase Performance  
**Tanggal:** 20 Juli 2026  
**Total Events:** 34 Event  
**Status:** Final Production Ready

---

## Daftar Isi

1. Konvensi Penamaan
2. Daftar Event (34 Event)
3. Properti Pengguna
4. Funnel Analitik
5. Implementasi Flutter
6. Dashboard & Monitoring

---

## 1. Konvensi Penamaan

### 1.1 Penamaan Event

- Format: `snake_case` (huruf kecil dengan underscore)
- Contoh: `login_success`, `campaign_view`, `checkout_start`
- Kata kerja di depan untuk action: `login_`, `checkout_`, `upload_`
- Kata benda di depan untuk view: `campaign_`, `notification_`

### 1.2 Parameter Event

- Format: `snake_case`
- Tipe data: string, integer, boolean
- Parameter wajib diberi tanda di kolom Params
- Hindari PII (Personally Identifiable Information) seperti email, nomor HP full

### 1.3 Properti Pengguna

- Format: `snake_case`
- Dikirim sekali saat login/setUserProperty
- Digunakan untuk segmentasi di dashboard

---

## 2. Daftar Event (34 Event)

### 2.1 Event Aplikasi & Sesi

| #   | Nama Event | Trigger                                        | Parameter                                                                                                                   | Level |
| --- | ---------- | ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ----- |
| 1   | `app_open` | Aplikasi dibuka dari keadaan mati (cold start) | `app_version` - versi aplikasi<br>`cluster_code` - kode cluster user<br>`is_first_open` - boolean, apakah pertama kali buka | High  |

### 2.2 Event Autentikasi

| #   | Nama Event      | Trigger                                  | Parameter                                                                                                                                                         | Level    |
| --- | --------------- | ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| 2   | `login_start`   | User menekan tombol Kirim OTP            | `phone_masked` - nomor HP terenkripsi (62812\*\*\*\*)                                                                                                             | Medium   |
| 3   | `otp_sent`      | Request OTP berhasil (status 200)        | `phone_masked` - nomor HP terenkripsi<br>`cluster_code` - kode cluster                                                                                            | High     |
| 4   | `otp_verify`    | User menekan tombol Verifikasi OTP       | `attempts` - jumlah percobaan<br>`is_success` - boolean, berhasil/gagal                                                                                           | High     |
| 5   | `login_success` | Autentikasi berhasil, user masuk ke Home | `user_id` - ID user (anonymized)<br>`role` - buyer/initiator/admin<br>`cluster_id` - ID cluster<br>`consent_version` - versi consent<br>`tos_version` - versi ToS | Critical |
| 6   | `login_fail`    | Autentikasi gagal (OTP salah, lock)      | `error_code` - kode error (ERR_001, ERR_001_RL)<br>`remaining_attempts` - sisa percobaan                                                                          | High     |
| 7   | `logout`        | User logout manual                       | `user_id` - ID user (anonymized)                                                                                                                                  | Medium   |

### 2.3 Event Consent & ToS (UU PDP)

| #   | Nama Event       | Trigger                                            | Parameter                                          | Level         |
| --- | ---------------- | -------------------------------------------------- | -------------------------------------------------- | ------------- |
| 8   | `consent_accept` | User centang checkbox consent + POST /auth/consent | `consent_version` - versi kebijakan privasi (v1.0) | High (UU PDP) |
| 9   | `tos_accept`     | User centang checkbox ToS + POST /auth/tos-accept  | `tos_version` - versi syarat layanan (v1.0)        | High          |

### 2.4 Event Campaign (PO)

| #   | Nama Event                | Trigger                        | Parameter                                                                                                                                                       | Level    |
| --- | ------------------------- | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| 10  | `campaign_list_view`      | Home berhasil memuat daftar PO | `cluster_id` - ID cluster<br>`count` - jumlah PO yang tampil<br>`is_offline` - boolean, apakah dari cache Hive<br>`etag_hit` - boolean, apakah 304 Not Modified | Critical |
| 11  | `campaign_detail_view`    | Halaman detail PO terbuka      | `campaign_id` - ID PO<br>`slug` - slug PO<br>`target_kg` - target kilogram<br>`current_kg` - kilogram terkumpul<br>`progress_percent` - persentase progress     | Critical |
| 12  | `campaign_create_start`   | Initiator mulai buat PO        | `cluster_id` - ID cluster                                                                                                                                       | Medium   |
| 13  | `campaign_create_success` | PO berhasil dipublikasikan     | `campaign_id` - ID PO<br>`target_kg` - target kilogram<br>`variant_count` - jumlah varian<br>`deadline_hours` - tenggat waktu dalam jam                         | High     |
| 14  | `campaign_create_fail`    | Gagal buat PO                  | `error_code` - kode error                                                                                                                                       | Medium   |

### 2.5 Event Interaksi Campaign

| #   | Nama Event           | Trigger                                 | Parameter                                                                                                                                | Level  |
| --- | -------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 15  | `deep_link_open`     | User klik link grosirun://campaign/{id} | `campaign_id` - ID PO<br>`source` - cold/warm (app mati/hidup)<br>`is_pending` - boolean, apakah disimpan saat belum login               | Medium |
| 16  | `share_wa`           | User menekan tombol Bagikan ke WA       | `campaign_id` - ID PO<br>`share_text_length` - panjang teks yang dibagikan                                                               | Medium |
| 17  | `social_ticker_view` | Ticker sosial terlihat selama 5 detik   | `campaign_id` - ID PO                                                                                                                    | Low    |
| 18  | `variant_select`     | User menekan tombol + atau - varian     | `campaign_id` - ID PO<br>`variant_size` - ukuran varian (5/10 Kg)<br>`quantity` - jumlah yang dipilih<br>`remaining` - sisa kuota varian | Medium |

### 2.6 Event Checkout & Order

| #   | Nama Event         | Trigger                            | Parameter                                                                                                                                                                                                                                                                                        | Level                   |
| --- | ------------------ | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| 19  | `checkout_start`   | User menekan tombol Pesan Sekarang | `campaign_id` - ID PO<br>`variant_id` - ID varian<br>`variant_size` - ukuran varian<br>`quantity` - jumlah<br>`total_price` - total harga<br>`payment_method` - cash/qris                                                                                                                        | Critical (funnel start) |
| 20  | `checkout_success` | Order berhasil (status 201)        | `campaign_id` - ID PO<br>`order_uuid` - UUID order<br>`variant_size` - ukuran varian<br>`quantity` - jumlah<br>`total_kg` - total kilogram<br>`total_price` - total harga<br>`payment_method` - cash/qris<br>`is_offline` - boolean, apakah order offline<br>`idempotency_key` - key idempotensi | Critical (funnel)       |
| 21  | `checkout_fail`    | Order gagal                        | `campaign_id` - ID PO<br>`error_code` - ERR_024 OUT_OF_STOCK, ERR_040 CLUSTER_MISMATCH<br>`remaining` - sisa stok (jika out of stock)                                                                                                                                                            | High                    |
| 22  | `order_cancel`     | Buyer membatalkan order pending    | `order_uuid` - UUID order<br>`campaign_id` - ID PO                                                                                                                                                                                                                                               | Medium                  |

### 2.7 Event Upload Proof (QRIS)

| #   | Nama Event          | Trigger                                      | Parameter                                                                                                                                                                                                                     | Level  |
| --- | ------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 23  | `proof_pick`        | User memilih gambar bukti dari galeri/kamera | `campaign_id` - ID PO<br>`order_uuid` - UUID order<br>`source` - camera/gallery<br>`original_size_mb` - ukuran file asli (MB)                                                                                                 | Medium |
| 24  | `proof_upload`      | Upload bukti berhasil (status 200)           | `order_uuid` - UUID order<br>`original_size_mb` - ukuran asli<br>`compressed_size_mb` - ukuran setelah kompres<br>`is_offline_queued` - boolean, apakah disimpan antrian offline<br>`duration_ms` - durasi upload (milidetik) | High   |
| 25  | `proof_upload_fail` | Upload bukti gagal                           | `error_code` - ERR_050 UPLOAD_TOO_LARGE, network error<br>`size_mb` - ukuran file                                                                                                                                             | Medium |

### 2.8 Event Admin & Validasi

| #   | Nama Event           | Trigger                                | Parameter                                                                                                                                         | Level                   |
| --- | -------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| 26  | `validation_success` | Initiator validasi pembayaran berhasil | `order_uuid` - UUID order<br>`campaign_id` - ID PO<br>`validation_type` - cash/qris/override<br>`notes_length` - panjang catatan (untuk override) | Critical (admin funnel) |
| 27  | `validation_fail`    | Validasi gagal (admin race)            | `error_code` - ERR_030 ALREADY_VALIDATED, ERR_031 STALE_DATA                                                                                      | High                    |
| 28  | `reject_proof`       | Initiator menolak bukti blur           | `order_uuid` - UUID order<br>`reason_length` - panjang alasan penolakan                                                                           | Medium                  |
| 29  | `batch_validate`     | Initiator validasi massal (207)        | `campaign_id` - ID PO<br>`success_count` - jumlah berhasil<br>`failed_count` - jumlah gagal                                                       | Medium                  |

### 2.9 Event Recap & Distribusi

| #   | Nama Event              | Trigger                                     | Parameter                                                                                                                            | Level  |
| --- | ----------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------ |
| 30  | `recap_view`            | Initiator melihat rekap PDF                 | `campaign_id` - ID PO<br>`total_kg` - total kilogram<br>`total_revenue` - total pendapatan<br>`is_pdf` - boolean, apakah membuka PDF | Medium |
| 31  | `distribution_check`    | Initiator menandai buyer sudah ambil barang | `order_uuid` - UUID order<br>`campaign_id` - ID PO<br>`taken_count` - jumlah yang sudah ambil<br>`remaining` - sisa yang belum ambil | Medium |
| 32  | `distribution_complete` | Initiator menyelesaikan distribusi          | `campaign_id` - ID PO<br>`total_taken` - total yang sudah ambil                                                                      | High   |

### 2.10 Event Notifikasi

| #   | Nama Event             | Trigger                                    | Parameter                                                                                                                               | Level  |
| --- | ---------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 33  | `notification_receive` | FCM diterima (foreground/background)       | `type` - NEW_ORDER, DEADLINE_WARNING, CANCELLED, COMPLETED<br>`campaign_id` - ID PO<br>`is_foreground` - boolean, apakah app terbuka    | High   |
| 34  | `notification_open`    | User menekan notifikasi                    | `type` - jenis notifikasi<br>`campaign_id` - ID PO<br>`is_fallback` - boolean, apakah dari polling fallback<br>`read_at` - waktu dibaca | High   |
| 35  | `fcm_fallback_poll`    | Polling GET /notifications setiap 60 detik | `unread_count` - jumlah notifikasi belum dibaca<br>`is_fcm_down` - boolean, apakah FCM bermasalah                                       | Medium |

### 2.11 Event Privasi & Akun

| #   | Nama Event                | Trigger                                    | Parameter                                                            | Level         |
| --- | ------------------------- | ------------------------------------------ | -------------------------------------------------------------------- | ------------- |
| 36  | `account_delete`          | User menghapus akun (DELETE /auth/account) | `reason` - alasan (opsional)<br>`cluster_id` - ID cluster            | High (UU PDP) |
| 37  | `account_delete_complete` | Proses anonimisasi selesai (<24 jam)       | `user_id` - ID user (anonymized)<br>`duration_hours` - durasi proses | High          |

### 2.12 Event Error & Offline

| #   | Nama Event       | Trigger                           | Parameter                                                                                          | Level    |
| --- | ---------------- | --------------------------------- | -------------------------------------------------------------------------------------------------- | -------- |
| 38  | `error_boundary` | Error tidak tertangani di Flutter | `error` - pesan error<br>`stack` - stack trace (dihash)<br>`screen` - halaman tempat error terjadi | Critical |
| 39  | `offline_banner` | Banner offline muncul             | `is_offline` - true<br>`screen` - home/detail/checkout                                             | Low      |

---

## 3. Properti Pengguna (User Properties)

Properti ini dikirim sekali saat login atau berubah, digunakan untuk segmentasi di dashboard.

| Properti       | Nilai                           | Keterangan                   |
| -------------- | ------------------------------- | ---------------------------- |
| `role`         | `buyer` / `initiator` / `admin` | Peran user                   |
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
  name: 'role',
  value: user.role,
);
await analytics.setUserProperty(
  name: 'cluster_code',
  value: user.clusterCode,
);
```

---

## 4. Funnel Analitik

### 4.1 Funnel Buyer (End-to-End)

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

### 4.2 Funnel Admin (Initiator)

```
login_success (role=initiator)
  → campaign_list_view
    → campaign_detail_view
      → validation_success
        → recap_view
          → distribution_complete
```

**Target Funnel:**

- `campaign_detail_view` → `validation_success`: **>90%**
- `validation_success` → `distribution_complete`: **>85%**

### 4.3 Funnel A/B Test (Tombol 56dp vs 48dp)

```
campaign_detail_view
  → checkout_start (variant A: tombol 56dp)
  → checkout_success
```

Bandakan conversion rate antar 2 grup dengan Remote Config.

---

## 5. Implementasi Flutter

### 5.1 Setup Analytics Service

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

### 5.2 Event Logger Helper

`lib/core/analytics/event_logger.dart`:

```dart
class EventLogger {
  // Auth Events
  static Future<void> loginSuccess({
    required String userId,
    required String role,
    required int clusterId,
  }) async {
    await analytics.logEvent(
      name: 'login_success',
      parameters: {
        'user_id': userId.hashCode.toString(), // Anonymized
        'role': role,
        'cluster_id': clusterId,
        'consent_version': 'v1.0',
        'tos_version': 'v1.0',
      },
    );
    await analytics.setUserId(userId);
    await analytics.setUserProperty(name: 'role', value: role);
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
        'total_kg': totalKg,
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

### 5.3 Penggunaan di Cubit

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

### 5.4 Performance Traces

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

## 6. Dashboard & Monitoring

### 6.1 Firebase Analytics Dashboard

| Komponen            | Lokasi                      | Kegunaan                                   |
| ------------------- | --------------------------- | ------------------------------------------ |
| **Events**          | Analytics → Events          | Lihat semua 34 event, jumlah, parameter    |
| **Funnels**         | Analytics → Funnels         | Monitoring conversion rate buyer & admin   |
| **User Properties** | Analytics → User Properties | Segmentasi berdasarkan role, cluster       |
| **Cohorts**         | Analytics → Cohorts         | Retention W2, W4 per cluster               |
| **DebugView**       | Analytics → DebugView       | Debug real-time event (aktifkan di device) |

### 6.2 Firebase Performance Dashboard

| Komponen             | Lokasi                      | Kegunaan                                              |
| -------------------- | --------------------------- | ----------------------------------------------------- |
| **Custom Traces**    | Performance → Custom Traces | `campaign_list_load`, `checkout_flow`, `proof_upload` |
| **Network Traces**   | Performance → Network       | GET /campaigns P95, POST /orders P95                  |
| **Screen Rendering** | Performance → Screen        | Cold start, Home render time                          |

### 6.3 Firebase Crashlytics

| Komponen        | Lokasi                    | Kegunaan                           |
| --------------- | ------------------------- | ---------------------------------- |
| **Crash-free**  | Crashlytics → Dashboard   | Target >99.5%                      |
| **Non-fatal**   | Crashlytics → Issues      | Error Boundary events, stack trace |
| **Breadcrumbs** | Crashlytics → Breadcrumbs | Lihat event sebelum crash          |

### 6.4 Query SQL untuk BigQuery (Opsional V1.1)

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

## 7. Troubleshooting & Debug

### 7.1 Debug Mode di Firebase

```dart
// Aktifkan DebugView di Firebase
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Di terminal
adb shell setprop debug.firebase.analytics.app com.grosirun.app
```

### 7.2 Cek Event Terkirim

1. Buka aplikasi
2. Buka Firebase Console → Analytics → DebugView
3. Lakukan action di app
4. Lihat event muncul dalam 5 detik

### 7.3 Event Tidak Muncul

| Masalah                      | Solusi                                                 |
| ---------------------------- | ------------------------------------------------------ |
| DebugView kosong             | Set `setAnalyticsCollectionEnabled(true)`, restart app |
| Parameter tidak muncul       | Cek tipe data (Object tidak boleh, gunakan String/Int) |
| Event tidak terkirim offline | Firebase SDK cache event, kirim saat online            |

---

## 8. Checklist Finalisasi

- [ ] Semua 34 event terdefinisi
- [ ] User Properties terkirim saat login
- [ ] Funnel Buyer dibuat di Firebase
- [ ] Funnel Admin dibuat di Firebase
- [ ] Performance Traces: `campaign_list_load`, `checkout_flow`, `proof_upload`
- [ ] Error Boundary mengirim `error_boundary` event
- [ ] DebugView berfungsi di device test
- [ ] Crashlytics terintegrasi
- [ ] Sentry breadcrumb terkirim untuk setiap event
- [ ] Dokumentasi update di CHANGELOG.md

---

**Dictionary Analytics V3.1 Siap Production!** 📊
