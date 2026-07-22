# Grosirun Mobile — Flutter App

**Platform:** Flutter 3.22+ (Android arm64 target)  
**State Management:** Cubit (flutter_bloc)  
**Network:** Dio (+ mock interceptor for dummy data)  
**Local Storage:** Hive (offline cache) + flutter_secure_storage (tokens)  
**Architecture:** Offline-first Repository Pattern  
**Target APK Size:** <10MB arm64

---

## Struktur Folder

```
mobile/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── constants/app_constants.dart   # Config, role enums, Hive keys
│   │   ├── theme/app_theme.dart           # Brand colors, typography, widgets
│   │   ├── network/                       # Dio client (TODO)
│   │   └── utils/                         # Helpers (TODO)
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart            # User + auth
│   │   │   ├── campaign_model.dart        # Campaign + variants
│   │   │   ├── order_model.dart           # Orders
│   │   │   └── notification_model.dart    # Fallback notifications
│   │   ├── datasources/
│   │   │   ├── remote/mock_data.dart      # 🔑 DUMMY DATA (ganti ke API)
│   │   │   └── local/                     # Hive boxes (TODO)
│   │   └── repositories/
│   │       └── repositories.dart          # Auth, Campaign, Order, Notification repos
│   ├── logic/
│   │   └── cubits/
│   │       ├── auth/auth_cubit.dart       # Auth state management
│   │       ├── campaign/campaign_cubit.dart
│   │       ├── order/                     # (TODO)
│   │       └── notification/              # (TODO)
│   └── presentation/
│       └── screens/
│           ├── role_selection/            # First screen: login + demo
│           ├── auth/                      # OTP verification
│           ├── home/                      # Main screen + bottom nav
│           ├── campaign/                  # Campaign detail + checkout
│           ├── profile/                   # Profile + role switch + logout
│           └── widgets/                   # Shared widgets
├── test/
├── integration_test/
├── assets/
├── pubspec.yaml
└── README.md
```

---

## Quick Start

### Prerequisites
- Flutter SDK 3.22+
- Dart SDK 3.4+

### Run with Mock Data (Default)

```bash
cd mobile
flutter pub get
flutter run
```

App menggunakan dummy data dari `lib/data/datasources/remote/mock_data.dart`.
Kamu bisa login sebagai Buyer, Initiator, atau Seller untuk demo.

### Switch to Real API

1. Buka `lib/core/constants/app_constants.dart`
2. Ubah `useMockData = false`
3. Ubah `apiBaseUrl` ke server Laravel kamu
4. Implementasikan real API calls di setiap Repository (lihat TODO comments)

---

## Integrasi dengan Laravel API

Setiap method di Repository sudah ada comment `// TODO:` yang menunjukkan endpoint Laravel yang sesuai:

| Repository Method | Laravel Endpoint |
|---|---|
| `AuthRepository.loginWithOtp()` | `POST /api/v1/auth/request-otp` + `POST /api/v1/auth/verify-otp` |
| `AuthRepository.getCurrentUser()` | `GET /api/v1/auth/me` |
| `AuthRepository.switchActiveRole()` | `PUT /api/v1/auth/active-role` |
| `CampaignRepository.getActiveCampaigns()` | `GET /api/v1/campaigns?status=active` |
| `CampaignRepository.getCampaignDetail()` | `GET /api/v1/campaigns/{id}` |
| `OrderRepository.createOrder()` | `POST /api/v1/orders` (+ Idempotency-Key) |
| `OrderRepository.getPendingValidation()` | `GET /api/v1/campaigns/{id}/orders?status=pending` |
| `OrderRepository.validateOrder()` | `PATCH /api/v1/campaigns/{id}/orders/{id}/validate` |

Lihat [API_SPEC.md](../docs/API_SPEC.md) untuk detail lengkap request/response.

---

## Demo Users (Mock)

| Role | Nama | Phone |
|---|---|---|
| Pembeli (Buyer) | Bu Siti | 081234567890 |
| Inisiator (Initiator) | Pak Agus Setiawan | 081987654321 |
| Penjual (Seller) | Andi dari Makmur Jaya | 08111222333 |

OTP: masukkan 6 angka apapun (mock mode).

---

## Brand & Design

Tema mengikuti [Brand Guidelines](../docs/BRAND_GUIDELINES.md):
- Primary: `#16A34A` (Grosirun Green)
- Typography: System font (Roboto)
- Border radius: 12dp buttons, 16dp cards
- Min touch target: 48×48dp

---

**Status:** Mock data ready, siap integrasi dengan Laravel backend.
