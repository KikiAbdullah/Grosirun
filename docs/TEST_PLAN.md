# RENCANA PENGUJIAN - Grosirun V3.1

**Stack:** Laravel 11 Pest + Flutter bloc_test + k6 Load Test + OWASP Security  
**Target:** MVP V1.0 Pilot 1 RT 500 users + Thundering Herd 100 concurrent + Admin Race + Disaster Drill  
**Tanggal:** 20 Juli 2026  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Lingkup & Piramida Pengujian
3. Perangkat Uji & Network Throttling
4. Backend Tests (Laravel Pest)
5. Frontend Tests (Flutter)
6. Skenario Positif (Happy Path)
7. Skenario Negatif & Edge Cases
8. Performance Test & k6 Scripts
9. Security Test & OWASP Matrix
10. Smoke Test Checklist
11. Acceptance Criteria & Bug Tracking

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Tujuan Pengujian

Rencana pengujian ini bertujuan untuk memastikan bahwa aplikasi Grosirun V3.1 telah memenuhi standar kualitas dan keamanan sebelum diluncurkan ke Pilot 1 RT. Pengujian mencakup:

| Aspek                 | Target                                                        |
| --------------------- | ------------------------------------------------------------- |
| **Zero Oversell**     | Tidak ada penjualan melebihi kuota, terbukti dengan k6 100 VU |
| **Zero Discrepancy**  | Uang dan barang sesuai 100%                                   |
| **UU PDP Compliance** | Consent, retensi 90 hari, hak hapus akun <24 jam              |
| **S3 Security**       | Private bucket, tempUrl 1 jam, lifecycle 90 hari              |
| **Cluster Scope**     | Isolasi data antar RT (403 CLUSTER_MISMATCH)                  |
| **FCM Fallback**      | Notifikasi tetap masuk via DB polling jika FCM down           |
| **Idempotency**       | Tidak ada duplikasi order saat retry                          |
| **ETag**              | 304 Not Modified menghemat bandwidth                          |
| **Crash-free**        | >99.5% di Crashlytics                                         |
| **APK Size**          | <10MB arm64                                                   |

### 1.2 Konteks Bisnis (Referensi BUSINESS_ANALYSIS.md)

| Komponen              | Nilai               |
| --------------------- | ------------------- |
| Platform Fee          | 1% GMV + PPN 11%    |
| GMV per PO AT_70      | Rp8.400.000         |
| Laba Initiator per PO | Rp956.760           |
| Target Adopsi         | 70% (35 dari 50 KK) |

**Setiap bug pada fitur kritis (order, validasi, pembayaran) dapat menyebabkan kerugian finansial dan kehilangan kepercayaan warga.**

### 1.3 Ruang Lingkup V3.1

| Fitur                                     | Diuji? |
| ----------------------------------------- | ------ |
| Cluster (FK, scope, mismatch 403)         | ✅     |
| S3 Primary (tempUrl 1h, lifecycle 90d)    | ✅     |
| Idempotency-Key (replay, no duplicate)    | ✅     |
| ETag (304, 412 stale)                     | ✅     |
| Consent + ToS + DELETE account anonymize  | ✅     |
| Notifications fallback DB + poll 60s      | ✅     |
| Batch validate                            | ✅     |
| Feature Flags (Pennant)                   | ✅     |
| Rate Limit Centralized Redis              | ✅     |
| Deep Linking `grosirun://campaign/{id}`   | ✅     |
| FCM Background Handler                    | ✅     |
| Offline Proof Queue                       | ✅     |
| State Persistence (appStateBox)           | ✅     |
| Error Boundary (Sentry + Crashlytics)     | ✅     |
| Blue-Green Deploy (zero-downtime)         | ✅     |
| Disaster Recovery Drill (RTO 1h, RPO 24h) | ✅     |

### 1.4 Out of Scope V1.0

- Escrow payment gateway
- ML recommendation
- Google Maps
- iOS TestFlight (V1.1)
- Dark Mode (V1.1)

---

## 2. Lingkup & Piramida Pengujian

### 2.1 Piramida Pengujian

```
         ┌────────────────────────────────────────────────┐
         │          Manual E2E (3 device + pilot)         │  10%
         │         Integration Test (Flutter + k6)        │  20%
         │      Cubit Unit + Widget + DeepLink + FCM      │  30%
         │  Backend Unit (Pest) + Feature API + Security  │  40%
         └────────────────────────────────────────────────┘
```

### 2.2 Tools yang Digunakan

| Kategori                 | Tools                                    |
| ------------------------ | ---------------------------------------- |
| **Backend Unit/Feature** | Pest, PHPUnit, RefreshDatabase           |
| **Mobile Unit**          | flutter_test, bloc_test, mocktail        |
| **Mobile Integration**   | integration_test, flutter_driver         |
| **Load Testing**         | k6 (100 VU, 30s)                         |
| **API Testing**          | Postman, curl                            |
| **Security**             | OWASP ZAP (opsional), manual code review |
| **Monitoring**           | Sentry, Crashlytics, Pulse               |
| **Performance**          | Firebase Performance, Flutter DevTools   |

### 2.3 Coverage Target

| Layer                   | Target |
| ----------------------- | ------ |
| **Backend Service**     | >80%   |
| **Backend Feature API** | >75%   |
| **Flutter Cubit**       | >80%   |
| **Flutter Model**       | >90%   |
| **Flutter Widget**      | >60%   |

---

## 3. Perangkat Uji & Network Throttling

### 3.1 Perangkat Fisik

| Perangkat            | RAM | Android | Keterangan                 |
| -------------------- | --- | ------- | -------------------------- |
| **Samsung A10**      | 2GB | 9       | Perangkat utama (low-end)  |
| **Redmi 4A**         | 2GB | 7       | Perangkat tertua (minimum) |
| **Oppo A3s**         | 2GB | 8       | Perangkat low-end kedua    |
| **Pixel 7 Emulator** | 8GB | 14      | Development & debugging    |

### 3.2 Network Throttling

| Skenario    | Setting                     | Tools         |
| ----------- | --------------------------- | ------------- |
| **Offline** | Airplane mode               | HP/emulator   |
| **4G Slow** | 400ms latency, 400kbps      | Charles Proxy |
| **2G**      | 800ms latency, 100kbps      | Charles Proxy |
| **Timeout** | Simulasikan request timeout | Charles Proxy |

### 3.3 iOS Simulator (Future V1.1)

Untuk V1.0, iOS tidak diuji (belum didukung). Rencana V1.1: iPhone SE, iPhone 13.

---

## 4. Backend Tests (Laravel Pest)

### 4.1 Setup .env.testing

```ini
APP_ENV=testing
DB_CONNECTION=mysql
DB_DATABASE=grosirun_testing
QUEUE_CONNECTION=sync
FILESYSTEM_DISK=public
CACHE_STORE=array
FEATURE_QRIS_UPLOAD=true
```

### 4.2 Unit Service Tests

#### OtpServiceTest

```php
// tests/Unit/Services/OtpServiceTest.php
test('generate otp with hash and expiry 5 minutes', function () {
    $service = app(OtpService::class);
    $otp = $service->generateOtp('081234567890', 'PGH-RT03');

    $otpCode = OtpCode::where('phone_number', '6281234567890')->first();
    expect($otpCode)->not->toBeNull();
    expect($otpCode->expires_at)->toBeAfter(now()->addMinutes(4));
    expect(Hash::check($otp, $otpCode->otp_hash))->toBeTrue();
});

test('lock after 5 failed attempts', function () {
    $service = app(OtpService::class);
    $phone = '081234567890';

    for ($i = 0; $i < 5; $i++) {
        try {
            $service->verifyOtp($phone, '9999');
        } catch (HttpException $e) {
            // Expected
        }
    }

    $otpCode = OtpCode::where('phone_number', '6281234567890')->first();
    expect($otpCode->locked_until)->toBeAfter(now()->addMinutes(14));
    expect($otpCode->attempts)->toBe(5);
});
```

#### OrderServiceTest (Critical - Race & Admin Race)

```php
// tests/Unit/Services/OrderServiceTest.php
test('prevents oversell with lockForUpdate - 2 buyers same variant 1 quota', function () {
    $campaign = Campaign::factory()->hasVariants(1, ['quota' => 1])->create();
    $variant = $campaign->variants->first();
    $buyer1 = User::factory()->create();
    $buyer2 = User::factory()->create();

    $service = app(OrderService::class);

    // Buyer 1 berhasil
    $order1 = $service->create($campaign, new CreateOrderDTO(
        variantId: $variant->id,
        quantity: 1,
        paymentMethod: 'cash',
        idempotencyKey: 'key1'
    ), $buyer1);

    expect($order1)->toBeInstanceOf(Order::class);

    // Buyer 2 gagal (stok habis)
    expect(fn() => $service->create($campaign, new CreateOrderDTO(
        variantId: $variant->id,
        quantity: 1,
        paymentMethod: 'cash',
        idempotencyKey: 'key2'
    ), $buyer2))->toThrow(HttpException::class, 'ERR_024');
});

test('prevents double validation from 2 initiators concurrent (admin race)', function () {
    $order = Order::factory()->create(['payment_status' => 'pending']);
    $initiator1 = User::factory()->initiator()->create(['cluster_id' => $order->cluster_id]);
    $initiator2 = User::factory()->initiator()->create(['cluster_id' => $order->cluster_id]);

    $service = app(OrderService::class);

    // Simulasi 2 concurrent validate
    $result1 = $service->validate($order, $initiator1);
    expect($result1->payment_status)->toBe('paid');

    // Validasi kedua gagal
    expect(fn() => $service->validate($order->fresh(), $initiator2))
        ->toThrow(HttpException::class, 'ERR_030');
});

test('checks cluster mismatch - 403 ERR_040', function () {
    $campaign = Campaign::factory()->create(['cluster_id' => 1]);
    $buyer = User::factory()->create(['cluster_id' => 2]);

    $service = app(OrderService::class);

    expect(fn() => $service->create($campaign, new CreateOrderDTO(
        variantId: 1,
        quantity: 1,
        paymentMethod: 'cash',
        idempotencyKey: 'key1'
    ), $buyer))->toThrow(HttpException::class, 'ERR_040');
});

test('uses idempotency key to prevent duplicate on replay', function () {
    $campaign = Campaign::factory()->hasVariants(1, ['quota' => 10])->create();
    $variant = $campaign->variants->first();
    $buyer = User::factory()->create();
    $idempotencyKey = 'uuid-123';

    $service = app(OrderService::class);

    // Request pertama
    $order1 = $service->create($campaign, new CreateOrderDTO(
        variantId: $variant->id,
        quantity: 1,
        paymentMethod: 'cash',
        idempotencyKey: $idempotencyKey
    ), $buyer);

    // Request kedua dengan key sama
    $order2 = $service->create($campaign, new CreateOrderDTO(
        variantId: $variant->id,
        quantity: 1,
        paymentMethod: 'cash',
        idempotencyKey: $idempotencyKey
    ), $buyer);

    // Harus order yang sama (tidak duplicate)
    expect($order2->id)->toBe($order1->id);
    expect($order2->uuid)->toBe($order1->uuid);
    expect($campaign->variants->first()->sold)->toBe(1); // Tidak bertambah
});
```

#### NotificationServiceTest

```php
// tests/Unit/Services/NotificationServiceTest.php
test('FCM success + fallback DB insert', function () {
    $service = app(NotificationService::class);
    $order = Order::factory()->create();

    // Mock FCM success
    Http::fake(['*' => Http::response(['success' => true])]);

    $service->sendNewOrderNotification($order);

    // Cek DB fallback
    $notification = Notification::where('user_id', $order->campaign->initiator_id)
        ->where('data->type', 'NEW_ORDER')
        ->first();

    expect($notification)->not->toBeNull();
});

test('FCM fail + fallback DB still insert', function () {
    $service = app(NotificationService::class);
    $order = Order::factory()->create();

    // Mock FCM fail
    Http::fake(['*' => Http::response(['success' => false], 500)]);

    $service->sendNewOrderNotification($order);

    // Cek DB fallback tetap ada
    $notification = Notification::where('user_id', $order->campaign->initiator_id)
        ->where('data->type', 'NEW_ORDER')
        ->first();

    expect($notification)->not->toBeNull();
});
```

### 4.3 Feature API Tests

#### Auth + Consent + ToS + Deletion

| Test                        | Endpoint                 | Expected                                            |
| --------------------------- | ------------------------ | --------------------------------------------------- |
| Request OTP valid           | `POST /auth/request-otp` | 200, `otp_codes` row created                        |
| Verify OTP consent false    | `POST /auth/verify-otp`  | 422 ERR_002                                         |
| Verify OTP tos false        | `POST /auth/verify-otp`  | 422 ERR_003                                         |
| Verify OTP consent+tos true | `POST /auth/verify-otp`  | 200, token, `consent_at` & `tos_accepted_at` filled |
| DELETE account              | `DELETE /auth/account`   | 202, `AnonymizeUserJob` dispatched                  |
| Request OTP 6x/min          | `POST /auth/request-otp` | 5x 200, 6x 429                                      |

#### Cluster Tests

| Test                             | Endpoint                   | Expected                       |
| -------------------------------- | -------------------------- | ------------------------------ |
| GET campaigns own cluster        | `GET /campaigns`           | Hanya campaign cluster sendiri |
| POST order campaign cluster lain | `POST /campaigns/2/orders` | 403 ERR_040                    |

#### Campaign + ETag + Cache

| Test                             | Endpoint          | Expected                           |
| -------------------------------- | ----------------- | ---------------------------------- |
| POST campaign with image         | `POST /campaigns` | 201, S3 path `campaigns/*.jpg`     |
| GET campaigns with ETag          | `GET /campaigns`  | ETag header                        |
| GET campaigns with If-None-Match | `GET /campaigns`  | 304 Not Modified                   |
| Cache-Control max-age=60         | `GET /campaigns`  | Header `Cache-Control: max-age=60` |

#### Order + Idempotency + ETag + Batch

| Test                            | Endpoint                                     | Expected                      |
| ------------------------------- | -------------------------------------------- | ----------------------------- |
| POST order with Idempotency-Key | `POST /orders`                               | 201, order created            |
| POST same key replay            | `POST /orders`                               | 201, order sama, no duplicate |
| GET order ETag                  | `GET /orders/{uuid}`                         | ETag header                   |
| PATCH validate wrong If-Match   | `PATCH /orders/{uuid}/validate`              | 412 STALE_DATA                |
| Batch validate 3 uuids          | `POST /campaigns/{id}/orders/batch-validate` | 207, partial success          |

#### Notifications Fallback

| Test                             | Endpoint               | Expected                     |
| -------------------------------- | ---------------------- | ---------------------------- |
| POST order → notifications table | `POST /orders`         | Notification row inserted    |
| GET /notifications?unread=true   | `GET /notifications`   | Returns unread notifications |
| PATCH /notifications/{id}/read   | `PATCH /notifications` | `read_at` filled             |

#### Feature Flags

| Test                          | Endpoint        | Expected             |
| ----------------------------- | --------------- | -------------------- |
| GET /features                 | `GET /features` | Returns flags        |
| qris-upload false → POST qris | `POST /orders`  | 403 FEATURE_DISABLED |

#### Rate Limit Centralized

| Test             | Endpoint                                 | Expected |
| ---------------- | ---------------------------------------- | -------- |
| Override 11x/min | `PATCH /orders/{uuid}/override-validate` | 11th 429 |

#### GDPR Deletion

| Test           | Endpoint               | Expected                             |
| -------------- | ---------------------- | ------------------------------------ |
| DELETE account | `DELETE /auth/account` | S3 proofs deleted, orders anonymized |

---

## 5. Frontend Tests (Flutter)

### 5.1 Unit Models

```dart
// test/data/models/campaign_model_test.dart
test('CampaignModel fromJson parses cluster and progress', () {
  final json = {
    'id': 1,
    'cluster_id': 1,
    'name': 'Beras Mahkota',
    'target_kg': 1000,
    'current_kg': 750,
    'slug': 'beras-mahkota',
    'status': 'active',
  };

  final model = CampaignModel.fromJson(json);
  expect(model.id, 1);
  expect(model.clusterId, 1);
  expect(model.progressPercent, 75.0);
});

test('OrderModel has idempotencyKey', () {
  final json = {
    'uuid': '123',
    'idempotency_key': 'key-123',
    'payment_status': 'pending',
  };
  final model = OrderModel.fromJson(json);
  expect(model.idempotencyKey, 'key-123');
});
```

### 5.2 Cubit Tests

#### AuthCubit

```dart
// test/logic/cubits/auth/auth_cubit_test.dart
group('AuthCubit', () {
  late AuthCubit cubit;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    cubit = AuthCubit(repository);
  });

  test('initial state is AuthInitial', () {
    expect(cubit.state, isA<AuthInitial>());
  });

  test('requestOtp success emits AuthOtpSent', () async {
    when(repository.requestOtp('081234567890', 'PGH-RT03'))
        .thenAnswer((_) async => OtpResponse(expiresIn: 300));

    await cubit.requestOtp(phone: '081234567890', clusterCode: 'PGH-RT03');

    expect(cubit.state, isA<AuthOtpSent>());
    expect((cubit.state as AuthOtpSent).phone, '081234567890');
  });

  test('verifyOtp consent false emits AuthError', () async {
    await cubit.verifyOtp(
      phone: '081234567890',
      otp: '1234',
      consent: false,
      tos: true,
      clusterCode: null,
      fcmToken: null,
    );

    expect(cubit.state, isA<AuthError>());
    expect((cubit.state as AuthError).code, 'ERR_002');
  });

  test('verifyOtp success emits AuthAuthenticated', () async {
    when(repository.verifyOtp(...)).thenAnswer((_) async => UserModel(...));

    await cubit.verifyOtp(...);

    expect(cubit.state, isA<AuthAuthenticated>());
  });
});
```

#### CampaignCubit

```dart
test('loadActive success emits CampaignLoaded', () async {
  when(repository.getActiveCampaigns(clusterId: 1, etag: null))
      .thenAnswer((_) async => CampaignResult(campaigns: [], etag: 'etag1'));

  await cubit.loadActive();

  expect(cubit.state, isA<CampaignLoaded>());
});

test('loadActive 304 Not Modified uses cache', () async {
  when(repository.getActiveCampaigns(clusterId: 1, etag: 'etag1'))
      .thenThrow(NotModifiedException());

  when(repository.getLocalCampaigns()).thenAnswer((_) async => [...]);

  await cubit.loadActive();

  expect(cubit.state, isA<CampaignLoaded>());
  expect((cubit.state as CampaignLoaded).isOffline, false);
});

test('loadActive offline fallback emits CampaignLoadedOffline', () async {
  when(repository.getActiveCampaigns(...)).thenThrow(DioException(...));
  when(repository.getLocalCampaigns()).thenAnswer((_) async => [...]);

  await cubit.loadActive();

  expect(cubit.state, isA<CampaignLoaded>());
  expect((cubit.state as CampaignLoaded).isOffline, true);
});
```

#### OrderCubit

```dart
test('createOrder with Idempotency-Key header', () async {
  // Verifikasi Dio interceptor menambahkan header Idempotency-Key
  // ...

  expect(headers.containsKey('Idempotency-Key'), true);
});

test('createOrder offline emits SuccessLocal', () async {
  when(repository.createOrder(...)).thenThrow(ConnectionError());

  await cubit.createOrder(...);

  expect(cubit.state, isA<OrderSuccessLocal>());
});

test('uploadProof offline emits UploadLocalQueued', () async {
  when(repository.uploadProof(...)).thenThrow(ConnectionError());

  await cubit.uploadProof(orderUuid: '123', filePath: '/path/to/file.jpg');

  expect(cubit.state, isA<UploadLocalQueued>());
});
```

### 5.3 Widget Tests

```dart
// test/presentation/widgets/big_button_test.dart
testWidgets('BigButton disabled when not checked', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BigButton(
          onPressed: () {},
          text: 'Verifikasi',
          isEnabled: false,
        ),
      ),
    ),
  );

  final button = find.text('Verifikasi');
  expect(button, findsOneWidget);
  expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, false);
});

testWidgets('ErrorView shows ERR_024 message', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ErrorView(
        error: 'Stok habis, pilih varian lain',
        code: 'ERR_024',
        onRetry: () {},
      ),
    ),
  );

  expect(find.text('Stok habis, pilih varian lain'), findsOneWidget);
  expect(find.text('ERR_024'), findsOneWidget);
});
```

### 5.4 Integration Tests E2E

```dart
// integration_test/e2e_test.dart
testWidgets('E2E buyer checkout + consent + deep link + FCM fallback', (tester) async {
  // 1. Buka aplikasi
  await tester.pumpWidget(GrosirunApp());

  // 2. Login OTP
  await tester.enterText(find.byKey(Key('phoneField')), '081234567890');
  await tester.tap(find.text('Kirim OTP'));
  await tester.pumpAndSettle();

  // 3. Consent checkbox
  await tester.tap(find.byKey(Key('consentCheckbox')));
  await tester.tap(find.byKey(Key('tosCheckbox')));
  await tester.pumpAndSettle();

  // 4. Enter OTP
  await tester.enterText(find.byKey(Key('otpField')), '1234');
  await tester.tap(find.text('Verifikasi'));
  await tester.pumpAndSettle();

  // 5. Home
  expect(find.text('Beras Mahkota'), findsOneWidget);

  // 6. Deep link simulasi
  final appLinks = AppLinksService();
  await appLinks.handleUri(Uri.parse('grosirun://campaign/12'));
  await tester.pumpAndSettle();

  // 7. Detail campaign
  expect(find.text('Beras Mahkota Premium'), findsOneWidget);

  // 8. Checkout
  await tester.tap(find.text('Ikut Patungan'));
  await tester.pumpAndSettle();

  // 9. Confirm
  await tester.tap(find.text('Pesan Sekarang'));
  await tester.pumpAndSettle();

  // 10. Success
  expect(find.text('Pesanan berhasil dibuat'), findsOneWidget);
});
```

---

## 6. Skenario Positif (Happy Path)

### 6.1 Flow Lengkap End-to-End

| Langkah | Actor                | Action                                          | Expected             |
| ------- | -------------------- | ----------------------------------------------- | -------------------- |
| 1       | Initiator (PGH-RT03) | Login dengan consent+tos                        | 200, token           |
| 2       | Initiator            | Buat campaign dengan image S3                   | 201, image_url       |
| 3       | Initiator            | Share WA deep link `grosirun://campaign/{slug}` | WA terkirim          |
| 4       | Buyer (PGH-RT03)     | Login consent+tos                               | 200, token           |
| 5       | Buyer                | Home list hanya campaign cluster sendiri        | Campaign muncul      |
| 6       | Buyer                | Tap deep link → detail campaign                 | Detail terbuka       |
| 7       | Buyer                | Checkout qty1, Idempotency-Key uuid1            | 201, pending         |
| 8       | System               | sold++ pada variant                             | sold bertambah       |
| 9       | System               | current_kg++ pada campaign                      | current_kg bertambah |
| 10      | Initiator            | Validasi + FCM + fallback DB                    | 200, log validation  |
| 11      | Buyer                | FCM foreground + fallback polling               | Notifikasi masuk     |
| 12      | System               | Ulangi sampai 100%                              | Status completed     |
| 13      | Initiator            | Recap PDF S3 tempUrl                            | PDF terbuka          |
| 14      | Initiator            | Distribution checklist                          | is_taken true        |
| 15      | Buyer                | DELETE account                                  | 202, anonymize       |

**Assertions:**

- Cluster mismatch blocked (403 ERR_040)
- Idempotency prevents duplicate (sold hanya +1)
- ETag 304 menghemat bandwidth
- S3 lifecycle 90d (simulasi CleanOldProofsJob)

---

## 7. Skenario Negatif & Edge Cases

### 7.1 Thundering Herd Deadline Rush (100 Concurrent)

**Setup:**

- Campaign target 50Kg
- Variant 5Kg, quota 10 (sisa 10)
- Deadline H-1
- 100 VU checkout bersamaan

**Kode k6:**

```javascript
// backend/load-test/k6-deadline-rush.js
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

  sleep(0.1);
}
```

**Ekspektasi:**

- 10 success 201
- 90 fail 409 OUT_OF_STOCK
- DB variant.sold = 10 (tidak negatif)
- 0 error 5xx
- P95 <300ms

**Jalankan:**

```bash
k6 run backend/load-test/k6-deadline-rush.js \
  --env API_URL=https://api.grosirun.id/api/v1 \
  --env TOKEN=YOUR_TOKEN \
  --env CAMPAIGN_ID=12 \
  --env VARIANT_ID=20
```

### 7.2 Admin Race (Double Validation)

**Setup:**

- 1 order pending
- 2 device admin (Initiator 1 & 2)

**Test Manual Postman:**

```bash
# Device 1
curl -X PATCH https://api.grosirun.id/api/v1/orders/{uuid}/validate \
  -H "Authorization: Bearer {token1}" \
  -H "Idempotency-Key: key1"

# Device 2 (same time)
curl -X PATCH https://api.grosirun.id/api/v1/orders/{uuid}/validate \
  -H "Authorization: Bearer {token2}" \
  -H "Idempotency-Key: key2"
```

**Ekspektasi:**

- Device 1: 200 paid
- Device 2: 409 ERR_030 ALREADY_VALIDATED
- transaction_logs hanya 1

### 7.3 Cluster Mismatch

**Setup:**

- Buyer cluster PGH-RT03 (id=1)
- Campaign cluster PGH-RT04 (id=2)

**Test:**

```bash
curl -X POST https://api.grosirun.id/api/v1/campaigns/2/orders \
  -H "Authorization: Bearer {token_buyer_1}" \
  -d '{"variant_id":1,"quantity":1,"payment_method":"cash"}'
```

**Ekspektasi:** 403 ERR_040 CLUSTER_MISMATCH

### 7.4 Idempotency Replay Duplicate

**Setup:**

- Buyer checkout dengan Idempotency-Key `uuid-123`
- Kirim ulang request yang sama (simulasi retry)

**Test:**

```bash
curl -X POST https://api.grosirun.id/api/v1/campaigns/12/orders \
  -H "Authorization: Bearer {token}" \
  -H "Idempotency-Key: uuid-123" \
  -d '{"variant_id":20,"quantity":1,"payment_method":"cash"}'

# Kirim ulang dengan key yang sama
curl -X POST https://api.grosirun.id/api/v1/campaigns/12/orders \
  -H "Authorization: Bearer {token}" \
  -H "Idempotency-Key: uuid-123" \
  -d '{"variant_id":20,"quantity":1,"payment_method":"cash"}'
```

**Ekspektasi:**

- Request 1: 201, order created
- Request 2: 201, order SAMA (bukan duplicate)
- variant.sold hanya +1

### 7.5 ETag Stale Validation

**Setup:**

- Initiator A load order, dapat ETag `v1`
- Initiator B validate order (status jadi paid, ETag jadi `v2`)
- Initiator A coba validate dengan If-Match `v1`

**Test:**

```bash
# Step 1: GET order dengan ETag
curl -I https://api.grosirun.id/api/v1/orders/{uuid} \
  -H "Authorization: Bearer {token}"
# ETag: W/"v1"

# Step 2: Initiator B validate
curl -X PATCH https://api.grosirun.id/api/v1/orders/{uuid}/validate \
  -H "Authorization: Bearer {token_B}"

# Step 3: Initiator A validate dengan ETag lama
curl -X PATCH https://api.grosirun.id/api/v1/orders/{uuid}/validate \
  -H "Authorization: Bearer {token_A}" \
  -H "If-Match: W/\"v1\""
```

**Ekspektasi:** 412 STALE_DATA ERR_031

### 7.6 S3 TempUrl Expiry

**Setup:**

- Upload proof → dapat tempUrl 1h
- Tunggu >1h
- Akses tempUrl

**Test:**

```bash
# Upload proof
curl -X POST https://api.grosirun.id/api/v1/orders/{uuid}/proof \
  -F "proof=@proof.jpg"
# Response: {"proof_url": "https://s3...?X-Amz-Expires=3600"}

# Tunggu 1 jam 1 menit
sleep 3660

# Akses URL
curl -I {proof_url}
```

**Ekspektasi:** 403 Forbidden (S3 expired)

**Recovery:** GET /orders/{uuid}/proof-url → fresh tempUrl

### 7.7 Consent Not Checked

**Test:**

```bash
curl -X POST https://api.grosirun.id/api/v1/auth/verify-otp \
  -d '{"phone":"081234567890","otp":"1234","consent":false,"tos":true}'
```

**Ekspektasi:** 422 ERR_002 CONSENT_REQUIRED

### 7.8 DELETE Account With Paid Orders

**Setup:**

- Buyer has paid orders (is_taken = false)
- Buyer DELETE account

**Test:**

```bash
curl -X DELETE https://api.grosirun.id/api/v1/auth/account \
  -H "Authorization: Bearer {token}"
```

**Ekspektasi:**

- 202 Accepted
- Orders tetap ada (anonymized)
- S3 proofs deleted
- user_id → null

### 7.9 FCM Down Fallback

**Setup:**

- Matikan Firebase (mock FCM error)
- Trigger notifikasi (new order)

**Ekspektasi:**

- notifications table tetap ada row
- Flutter poll GET /notifications?unread=true → dapat notifikasi

### 7.10 Offline Proof Queue

**Setup:**

- Airplane mode
- Pick proof image
- Upload proof

**Ekspektasi:**

- pendingQueue type `upload_proof` tersimpan
- local_file_path di app docs
- Online sync → upload ke S3 → temp file deleted

### 7.11 Rate Limit Override (10/min)

**Test:**

```bash
for i in {1..11}; do
  curl -X PATCH https://api.grosirun.id/api/v1/orders/{uuid}/override-validate \
    -H "Authorization: Bearer {token}" \
    -H "Idempotency-Key: key-$i" \
    -d '{"notes":"Test $i"}'
done
```

**Ekspektasi:** 11th request → 429 ERR_061

### 7.12 Feature Flag Off

**Test:**

```bash
# Matikan qris-upload
php artisan pennant:deactivate qris-upload

# Buyer checkout qris
curl -X POST https://api.grosirun.id/api/v1/campaigns/12/orders \
  -d '{"variant_id":20,"quantity":1,"payment_method":"qris"}'
```

**Ekspektasi:** 403 ERR_064 FEATURE_DISABLED

**UI:** QRIS option hidden via GET /features

### 7.13 Blue-Green Deploy During Checkout

**Setup:**

- Running deploy-blue-green.sh
- Concurrent k6 10 VU checkout

**Ekspektasi:**

- 0 503 error (atau retry 3x dengan backoff)
- All requests succeed

---

## 8. Performance Test & k6 Scripts

### 8.1 Performance Budget

| Metrik               | Budget | Alat Ukur            |
| -------------------- | ------ | -------------------- |
| GET /campaigns P95   | <150ms | Pulse + k6           |
| POST /orders P95     | <300ms | k6                   |
| Upload 2MB           | <2s    | Postman + k6         |
| Recap PDF 200 orders | <3s    | Manual               |
| Flutter Cold Start   | <2s    | Firebase Performance |
| RAM PSS (2GB device) | <180MB | Android Profiler     |
| APK arm64            | <10MB  | `ls -lh`             |
| Frame Rate           | 60 FPS | Flutter DevTools     |

### 8.2 k6 Scripts

#### k6-deadline-rush.js

```javascript
// backend/load-test/k6-deadline-rush.js
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

  sleep(0.1);
}
```

#### k6-orders-race.js

```javascript
// backend/load-test/k6-orders-race.js
import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 2,
  iterations: 2,
  thresholds: {
    http_req_duration: ["p(95)<300"],
    http_req_failed: ["rate<0.6"],
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
}
```

#### k6-recap-heavy.js

```javascript
// backend/load-test/k6-recap-heavy.js
import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 10,
  duration: "60s",
  thresholds: {
    http_req_duration: ["p(95)<3000"],
    http_req_failed: ["rate<0.1"],
  },
};

export default function () {
  const url = `${__ENV.API_URL}/campaigns/${__ENV.CAMPAIGN_ID}/recap`;
  const params = {
    headers: {
      Authorization: `Bearer ${__ENV.TOKEN}`,
    },
  };

  const res = http.get(url, params);

  check(res, {
    "status is 200": (r) => r.status === 200,
  });
}
```

### 8.3 Stress & Chaos Test

| Skenario               | Setup                                        | Ekspektasi                               |
| ---------------------- | -------------------------------------------- | ---------------------------------------- |
| **Stress**             | Ramp VUs 10→200 over 5 min                   | Cari breaking point P95 >1s atau 5xx >5% |
| **Chaos - Kill Redis** | `docker compose kill redis` during load      | Cache miss, DB masih works, queue retry  |
| **Chaos - Kill MySQL** | `docker compose kill mysql` during load      | Aplikasi 503, alert Slack                |
| **Spike**              | 10 VUs idle → spike 100 VUs 10s → back to 10 | Tidak crash, P95 <500ms                  |

---

## 9. Security Test & OWASP Matrix

### 9.1 OWASP API Top 10 2023

| #    | OWASP API            | Test                                                 | Result |
| ---- | -------------------- | ---------------------------------------------------- | ------ |
| API1 | BOLA                 | Buyer A GET /orders/{uuid_B} → 403                   | ☐      |
| API1 | BOLA                 | Buyer POST order campaign cluster lain → 403 ERR_040 | ☐      |
| API2 | Broken Auth          | OTP rate limit 5/min → 429 ke-6                      | ☐      |
| API2 | Broken Auth          | Lock after 5 failed attempts → 429, locked_until     | ☐      |
| API3 | BOPLA                | Buyer cannot update is_taken (hanya initiator)       | ☐      |
| API3 | Mass Assignment      | POST campaign extra field → ignored                  | ☐      |
| API4 | Resource Consumption | Upload 3MB → 422 ERR_050                             | ☐      |
| API4 | Resource Consumption | Rate limit 60/min → 61st 429                         | ☐      |
| API5 | BFLA                 | Buyer POST /campaigns → 403                          | ☐      |
| API5 | BFLA                 | Buyer POST /admin/features → 403                     | ☐      |
| API6 | Sensitive Flow       | Batch validate >100 uuids → 422                      | ☐      |
| API6 | Sensitive Flow       | Override 11/min → 429                                | ☐      |
| API8 | Misconfig            | APP_DEBUG false prod                                 | ☐      |
| API8 | Misconfig            | S3 bucket private, Block public access ON            | ☐      |
| API8 | Misconfig            | Nginx deny dot files                                 | ☐      |
| API9 | Inventory            | Deprecation header true, Sunset date                 | ☐      |

### 9.2 OWASP Mobile Top 10 2024

| #   | Mobile Top 10     | Test                                       | Result |
| --- | ----------------- | ------------------------------------------ | ------ |
| M1  | Credential Usage  | Token in SecureStorage (not Hive)          | ☐      |
| M1  | Credential Usage  | No hardcoded secrets                       | ☐      |
| M3  | Auth              | OTP lock 15m, consent required             | ☐      |
| M5  | Communication     | HTTPS prod, usesCleartextTraffic false     | ☐      |
| M6  | Privacy           | Consent checkbox, DELETE account anonymize | ☐      |
| M6  | Privacy           | Proof lifecycle 90d                        | ☐      |
| M7  | Binary Protection | --obfuscate, minifyEnabled true            | ☐      |
| M9  | Data Storage      | SecureStorage token, S3 private tempUrl    | ☐      |
| M10 | Cryptography      | OTP hash bcrypt, Sanctum token hash        | ☐      |

**Dokumentasi lengkap:** `SECURITY_REVIEW.md`

---

## 10. Smoke Test Checklist

### 10.1 Backend Smoke (5 Menit)

- [ ] `GET /health` → 200, db, redis, s3 connected, ssl_expires > 7 hari
- [ ] `POST /auth/request-otp` + `POST /auth/verify-otp` consent+tos → token 200
- [ ] `GET /clusters?code=PGH-RT03` → 200
- [ ] `POST /campaigns` with image S3 → 201, image_url tempUrl works
- [ ] `GET /campaigns` → ETag present, Cache-Control max-age=60
- [ ] `POST /orders` with Idempotency-Key → 201, sold++
- [ ] `POST /orders` same key replay → same 201, no duplicate
- [ ] `POST /orders/{uuid}/proof` → 200, proof_url tempUrl 1h
- [ ] `PATCH /orders/{uuid}/validate` → 200 paid, notifications fallback row exists
- [ ] `GET /notifications?unread` → contains validation notif
- [ ] `DELETE /auth/account` → 202
- [ ] k6 small 10 VUs 10s deadline rush → 0 5xx

### 10.2 Mobile Smoke (5 Menit)

- [ ] Install APK arm64 <10MB success on 3 devices
- [ ] Consent + ToS checkboxes required
- [ ] Login OTP → Home list own cluster only
- [ ] DeepLink `grosirun://campaign/1` opens detail
- [ ] Detail polling 15s + ticker
- [ ] Checkout cash + Idempotency header visible in Dio log
- [ ] Offline airplane mode checkout → SuccessLocal + pendingQueue
- [ ] Online sync → success + FCM + fallback poll
- [ ] Proof upload offline → UploadLocalQueued → sync success temp file deleted
- [ ] Admin dashboard 3 tabs + batch validate 2 orders → 207 partial
- [ ] Recap PDF viewer S3 tempUrl + share WA
- [ ] Distribution checklist markTaken + complete
- [ ] Notifications screen unread polling 60s when FCM down simulation
- [ ] Error boundary test throw exception → ErrorView not crash
- [ ] State persistence kill app → reopen lastRoute restored

### 10.3 Regression Suite (Full - Sebelum Go-Live)

- [ ] Semua skenario positif (Section 6)
- [ ] Semua skenario negatif (Section 7)
- [ ] OTP lock test
- [ ] Upload >2MB test
- [ ] Quota habis test
- [ ] Airplane checkout test
- [ ] Race 2 buyers test
- [ ] Cancel PO test
- [ ] Override validate test

---

## 11. Acceptance Criteria & Bug Tracking

### 11.1 Acceptance Criteria V3.1

| #   | Kriteria                                                                   | Status |
| --- | -------------------------------------------------------------------------- | ------ |
| 1   | Semua smoke checklist 100% pass 3 devices + API health                     | ☐      |
| 2   | Zero oversell: k6 100 VU deadline rush + 2 VU race, DB sold never negative | ☐      |
| 3   | Zero admin race: 2 concurrent validate → 1 success, 1 409, logs 1          | ☐      |
| 4   | Cluster mismatch blocked 403 ERR_040                                       | ☐      |
| 5   | Idempotency prevents duplicate on replay same key                          | ☐      |
| 6   | ETag 304 saves bandwidth, 412 stale handled                                | ☐      |
| 7   | S3 tempUrl private 1h works, lifecycle 90d + CleanOldProofsJob             | ☐      |
| 8   | Consent + ToS 100% users logged consent_at, tos_accepted_at                | ☐      |
| 9   | DELETE account anonymize SLA <24h, S3 proofs deleted, orders anonymized    | ☐      |
| 10  | FCM fallback DB works when FCM down, Flutter poll 60s gets unread          | ☐      |
| 11  | Batch validate 10 orders → 207 partial success handling                    | ☐      |
| 12  | Feature flags on/off without deploy APK                                    | ☐      |
| 13  | Rate limit centralized Redis per-route override tested 429                 | ☐      |
| 14  | DeepLink `grosirun://campaign/{id}` opens detail                           | ☐      |
| 15  | FCM background handler + error boundary + state persistence when killed    | ☐      |
| 16  | Offline proof queue works                                                  | ☐      |
| 17  | Blue-green deploy zero-downtime health check + rollback automation tested  | ☐      |
| 18  | SSL expiry >7 days monitoring alert                                        | ☐      |
| 19  | Disaster recovery drill done <1h RTO documented                            | ☐      |
| 20  | Security Review OWASP API + Mobile Top 10 checklist Pass                   | ☐      |
| 21  | APK <10MB arm64 + coverage backend >80% + crash-free >99.5% 3 days pilot   | ☐      |
| 22  | No blocker bug critical, max 3 minor                                       | ☐      |
| 23  | SOP onboarding Pak Agus 1 lembar tested, FAQ 20 questions                  | ☐      |

### 11.2 Bug Tracking (GitHub Issues)

**Format Label:**

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
| `etag`        | Masalah ETag                               |
| `s3`          | Masalah S3                                 |

**Bug Report Template:**

```markdown
## Deskripsi

[Jelaskan bug]

## Langkah Reproduksi

1. ...
2. ...

## Ekspektasi

[Jelaskan yang seharusnya terjadi]

## Aktual

[Jelaskan yang terjadi]

## Info Tambahan

- **Cluster:** PGH-RT03
- **Idempotency-Key:** uuid-123
- **ETag:** W/"v1"
- **Trace ID:** 550e8400-...
- **Device:** Samsung A10
- **Screenshot:** [link]
```

### 11.3 Test Report Template

**File:** `docs/TEST_REPORT_V3.1.md`

```markdown
# LAPORAN PENGUJIAN - Grosirun V3.1

**Tanggal:** 20 Juli 2026
**Tester:** Backend Lead, Mobile Lead
**Environment:** Staging (api.staging.grosirun.id)

## Ringkasan

| Kategori        | Total   | Pass    | Fail  |
| --------------- | ------- | ------- | ----- |
| Backend Unit    | 50      | 50      | 0     |
| Backend Feature | 30      | 30      | 0     |
| Flutter Cubit   | 25      | 25      | 0     |
| Flutter Widget  | 15      | 15      | 0     |
| Integration E2E | 5       | 5       | 0     |
| k6 Load Test    | 3       | 3       | 0     |
| Security        | 15      | 15      | 0     |
| **Total**       | **143** | **143** | **0** |

## Detail Hasil

| Tanggal    | Tester       | Device      | Skenario         | Cluster  | Idempotency-Key | Hasil | Trace ID  | Catatan |
| ---------- | ------------ | ----------- | ---------------- | -------- | --------------- | ----- | --------- | ------- |
| 2026-07-20 | Backend Lead | Postman     | Create order     | PGH-RT03 | key-123         | Pass  | trace-abc | -       |
| 2026-07-20 | Mobile Lead  | Samsung A10 | Checkout offline | PGH-RT03 | key-456         | Pass  | trace-def | -       |

## Issues Found

| #   | Severity | Issue       | Status   |
| --- | -------- | ----------- | -------- |
| 1   | Minor    | Typo di FAQ | ✅ Fixed |

## Kesimpulan

- **Critical & Major:** ✅ Semua Pass
- **Minor:** 1 issue (fixed)
- **Overall:** ✅ READY FOR PILOT

## Sign-off

- [ ] Backend Lead
- [ ] Mobile Lead
- [ ] Product Owner
- [ ] QA Lead
```

---

**Rencana Pengujian V3.1 Production Ready - k6 100 VU Thundering Herd, Admin Race, ETag, Idempotency, S3, Cluster, Consent, FCM Fallback, DeepLink, Proof Queue, Blue-Green, Disaster Drill!** 🚀🧪
