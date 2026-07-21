# SPESIFIKASI UI/UX - Grosirun V3.1

**Tanggal:** 20 Juli 2026  
**Platform:** Flutter Android (iOS V1.1)  
**Persona:** Bu Siti (45 tahun, 2GB RAM), Pak Agus (52 tahun, Ketua RT)  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Prinsip Desain
2. Warna, Tipografi & Spasi
3. Widget Standar
4. Daftar Layar & Navigasi
5. State Loading, Empty, Error & Skeleton
6. Bottom Sheet, Dialog & SnackBar
7. Aksesibilitas & Responsif
8. Animasi, Lottie & Performa
9. Layar Consent & ToS (UU PDP)
10. Dark Mode (Future V1.1)

---

## 1. Prinsip Desain

| Prinsip                  | Keterangan                                                                                                                       |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| **Ringan di Mata**       | Latar belakang dominan putih (#FFFFFF), hijau neon (#16A34A) untuk aksi, tidak berlebihan warna                                  |
| **Jempol Friendly**      | Semua tombol utama minimal 56dp, tombol sekunder 48dp, area sentuh minimal 48dp                                                  |
| **Tanpa Typing Manual**  | Varian paten menggunakan tombol +/- saja, tidak ada input text angka (mencegah salah input 3.5 vs 35)                            |
| **Feedback Instant**     | Progress bar truk (Lottie + linear), social ticker marquee, snackbar sukses/error dengan pesan human-readable dari ERROR_CATALOG |
| **Offline Banner**       | Banner kuning di atas: "Kamu offline, data mungkin tidak terbaru" saat isOffline = true                                          |
| **Trust & Transparansi** | Tampilkan nama cluster (PGH-RT03) di app bar, tampilkan consent & ToS, tampilkan audit log untuk override                        |

**Referensi BUSINESS_ANALYSIS.md:**

| Komponen              | Nilai            |
| --------------------- | ---------------- |
| Platform Fee          | 1% GMV + PPN 11% |
| GMV per PO AT_70      | Rp8.400.000      |
| Laba Initiator per PO | Rp956.760        |

**UI/UX harus mendukung transparansi keuangan dan kemudahan bagi warga RT.**

---

## 2. Warna, Tipografi & Spasi

### 2.1 Palet Warna

| Token                   | Hex                           | Penggunaan                             |
| ----------------------- | ----------------------------- | -------------------------------------- |
| **Primary**             | #16A34A                       | Tombol ikut patungan, validasi, sukses |
| **Primary Dark**        | #15803D                       | State pressed                          |
| **Secondary (Warning)** | #FACC15                       | Progress 70-99% (kuning)               |
| **Error**               | #DC2626                       | Tolak, error, gagal upload proof       |
| **Background**          | #FFFFFF                       | Latar belakang Scaffold                |
| **Surface**             | #F8FAFC                       | Latar card abu-abu terang              |
| **Text Primary**        | #0F172A                       | Judul, body                            |
| **Text Secondary**      | #64748B                       | Subjudul, time ago                     |
| **Border**              | #E2E8F0                       | Border card                            |
| **Offline Banner**      | #FEF9C3 (bg) + #854D0E (text) | Peringatan offline                     |

### 2.2 Tipografi

**Font Family:**

- Gunakan system font default (Roboto/San Francisco) untuk menjaga APK <10MB.
- Hindari custom font heavy. Jika terpaksa, subset Latin only.

**Skala Tipografi:**

| Nama               | Ukuran | Weight  | Penggunaan                  |
| ------------------ | ------ | ------- | --------------------------- |
| **Headline Large** | 24sp   | Bold    | Nama campaign di detail     |
| **Title Medium**   | 18sp   | Medium  | Judul card di home          |
| **Body Large**     | 16sp   | Regular | Deskripsi, ukuran varian    |
| **Body Medium**    | 14sp   | Regular | Secondary, ticker, time ago |
| **Label Large**    | 16sp   | Medium  | Text tombol                 |

**Line Height:** 1.4

### 2.3 Spasi

- **Base:** 8dp
- **Skala:** 4, 8, 12, 16, 24, 32
- **Card Padding:** 16dp internal
- **Card Margin:** 12dp antar card
- **Tombol Height:** 56dp
- **Tombol Border Radius:** 12dp
- **Card Border Radius:** 16dp
- **App Bar Height:** 56dp
- **Bottom Sheet Radius Top:** 24dp

---

## 3. Widget Standar

### 3.1 BigButton (Tombol Utama)

**Spesifikasi:**

| Properti      | Nilai           |
| ------------- | --------------- |
| Height        | 56dp (minimal)  |
| Min Width     | 120dp           |
| Border Radius | 12dp            |
| Background    | Primary #16A34A |
| Text Color    | Putih           |
| Font Size     | 16sp            |
| Weight        | Medium          |
| Elevation     | 0               |
| Icon          | Opsional (kiri) |

**State:**

| State        | Tampilan                                                              |
| ------------ | --------------------------------------------------------------------- |
| **Normal**   | Background #16A34A, text putih                                        |
| **Pressed**  | Background #15803D                                                    |
| **Loading**  | CircularProgressIndicator putih 20dp di dalam tombol, tombol disabled |
| **Disabled** | Background #E2E8F0, text #94A3B8                                      |

### 3.2 Progress Truck

**Komponen:**

```
┌──────────────────────────────────────────────────────┐
│  🚚  ████████████████████░░░░░░░░░░░░  75%          │
│  Terkumpul 750 Kg dari Target 1000 Kg (75%)         │
│  ⏰ Sisa 12 Jam 30 Menit                            │
└──────────────────────────────────────────────────────┘
```

**Spesifikasi:**

| Komponen            | Detail                                                                                                         |
| ------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Linear Progress** | Height 24dp, background #E2E8F0                                                                                |
| **Progress 0-70%**  | #16A34A (hijau)                                                                                                |
| **Progress 70-99%** | #FACC15 (kuning)                                                                                               |
| **Progress 100%**   | #16A34A (hijau neon)                                                                                           |
| **Lottie Truck**    | `<100KB`, `assets/lottie/truck.json`, width 48dp, height 32dp, loop idle (tidak bergerak untuk hemat performa) |
| **Text Progress**   | "Terkumpul X Kg dari Target Y Kg (Z%)", 14sp, secondary                                                        |
| **Countdown**       | "Sisa XX Jam XX Menit", 14sp, bold, merah jika <24 jam                                                         |

### 3.3 Social Ticker

```
┌──────────────────────────────────────────────────────┐
│  Bu Nengsih • 5Kg 2 menit lalu • Pak Joko • 10Kg 5  │
└──────────────────────────────────────────────────────┘
```

**Spesifikasi:**

| Properti   | Nilai                                           |
| ---------- | ----------------------------------------------- |
| Height     | 28dp                                            |
| Background | Surface #F8FAFC                                 |
| Text       | 14sp, secondary                                 |
| Marquee    | Scroll infinite right-to-left                   |
| Data       | `GET /campaigns/{id}/activities` (last 10 paid) |

### 3.4 Card Campaign (Home)

```
┌──────────────────────────────────────────────────────┐
│  ┌────────────────────────────────────────────────┐  │
│  │  [Image 16:9]                                 │  │
│  └────────────────────────────────────────────────┘  │
│  Beras Mahkota Premium                              │
│  🚚 ████████████████████░░░░░░░░  75%              │
│  Terkumpul 750 Kg dari Target 1000 Kg              │
│  ⏰ Sisa 12 Jam                                    │
│  [PGH-RT03]  [Aktif]                               │
│  ┌──────────────────────────────────────────────┐  │
│  │           Ikut Patungan                      │  │
│  └──────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

**Spesifikasi:**

| Properti      | Nilai                                                                 |
| ------------- | --------------------------------------------------------------------- |
| Width         | Full                                                                  |
| Border Radius | 16dp                                                                  |
| Elevation     | 2                                                                     |
| Border        | #E2E8F0, 1px                                                          |
| Image         | 16:9, `cached_network_image`, 400x225 placeholder shimmer, error icon |
| Padding       | 16dp                                                                  |
| Title         | 18sp, medium, max 2 lines, ellipsis                                   |
| BigButton     | "Ikut Patungan", full width, 56dp                                     |

### 3.5 Variant Selector (Paten)

```
┌──────────────────────────────────────────────────────┐
│  5 Kg - Rp 60.000        [-]  1  [+]   Sisa 20     │
│  10 Kg - Rp 115.000      [-]  2  [+]   Sisa 13     │
└──────────────────────────────────────────────────────┘
```

**Spesifikasi:**

| Komponen     | Detail                                                   |
| ------------ | -------------------------------------------------------- |
| **Text**     | Ukuran varian "5 Kg - Rp 60.000", 16sp                   |
| **Button -** | 48dp square, border radius 8dp, border Primary, icon "-" |
| **Button +** | 48dp square, border radius 8dp, border Primary, icon "+" |
| **Qty Text** | 16sp bold, 24dp width                                    |
| **Sisa**     | "Sisa 20", 12sp secondary                                |
| **Disabled** | Grey jika remaining = 0 (untuk +) atau qty = 0 (untuk -) |

**Tidak ada TextField manual input!**

### 3.6 Offline Banner

```
┌──────────────────────────────────────────────────────┐
│  📡 Kamu offline, data mungkin tidak terbaru       │
└──────────────────────────────────────────────────────┘
```

**Spesifikasi:**

| Properti   | Nilai                 |
| ---------- | --------------------- |
| Height     | 32dp                  |
| Background | #FEF9C3               |
| Text Color | #854D0E               |
| Font Size  | 12sp                  |
| Icon       | `wifi_off` 16dp, kiri |

### 3.7 ErrorView / EmptyView / Skeleton

**ErrorView:**

```
┌──────────────────────────────────────────────────────┐
│  [Icon Error 48dp]                                  │
│  Stok habis, pilih varian lain                      │
│  Trace ID: 550e8400-...                            │
│  ┌──────────────────────────────────────────────┐  │
│  │              Coba Lagi                       │  │
│  └──────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

**EmptyView:**

```
┌──────────────────────────────────────────────────────┐
│  [Icon Inbox 48dp, grey]                           │
│  Belum ada PO aktif di cluster PGH-RT03            │
│  ┌──────────────────────────────────────────────┐  │
│  │              Refresh                         │  │
│  └──────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

**Skeleton:**

- Custom Container grey #E2E8F0, animated pulse
- Untuk card: image 16:9 grey + lines grey
- Tampilkan saat loading, bukan CircularProgressIndicator full screen (UX lebih baik)

---

## 4. Daftar Layar & Navigasi

### 4.1 Screen Map

```
Splash Screen
    │
    ▼
AuthCheck (cek SecureStorage token)
    │
    ├── No Token ──► LoginScreen ──► OtpScreen ──► ConsentScreen ──► TosScreen ──► HomeScreen
    │
    └── Token ──► HomeScreen (jika ada pendingDeepLink → CampaignDetailScreen)

BottomNav (3 tabs untuk Buyer):
  ├── Home (Beranda PO Aktif)
  ├── MyOrders (Pesanan Saya)
  └── Profile (Profil)

BottomNav (3 tabs untuk Initiator):
  ├── Home (Beranda PO Aktif + FAB Create PO)
  ├── AdminDashboard (3 tabs: Menunggu Bayar, Lunas, QRIS Menunggu Cek)
  └── Profile (Profil)
```

### 4.2 Daftar Layar

#### SplashScreen

- Logo Grosirun
- Loading indicator
- Check autentikasi

#### LoginScreen

- Input field: Nomor HP (08xx)
- Tombol: "Kirim OTP"
- Link: "Privacy Policy"

#### OtpScreen

- Input field: OTP 4 digit
- Timer countdown 5 menit
- Tombol: "Verifikasi"
- Tombol: "Kirim Ulang" (aktif setelah 60 detik)

#### ConsentScreen

- Title: "Kebijakan Privasi (UU PDP)"
- Scrollable text dari PRIVACY_POLICY.md (ringkasan)
- Link: "Baca selengkapnya"
- Checkbox: "Saya setuju data WA disimpan untuk PO RT sesuai UU PDP No.27/2022"
- Tombol: "Setuju Lanjut" (disabled jika checkbox tidak centang)

#### TosScreen

- Title: "Syarat Layanan Non-Escrow"
- Scrollable text dari DISPUTE_SOP.md (ringkasan)
- Checkbox: "Saya mengerti dan setuju"
- Tombol: "Setuju Lanjut" (disabled jika checkbox tidak centang)

#### HomeScreen

**AppBar:**

- Logo Grosirun
- Cluster chip: "PGH-RT03"
- Notification bell (badge unread count)
- Profile icon

**Body:**

- OfflineBanner (jika offline)
- PullToRefresh
- List Campaign Cards (atau EmptyView atau Skeleton)

#### CampaignDetailScreen

**AppBar:**

- Back button
- Share WA button

**Body (Scroll):**

- Image 16:9 + OfflineBanner (jika offline)
- Title + Description + Pickup Location
- ProgressTruck + Countdown + Cluster chip
- SocialTicker (marquee)
- Variant Selector list
- Bottom sticky BigButton: "Pesan Sekarang - Total Rp X"

#### CheckoutScreen (BottomSheet)

- Title: "Pilih Pembayaran"
- RadioListTile: Cash + description "Bayar tunai ke Pak Agus"
- RadioListTile: QRIS + description "Transfer QRIS + upload bukti"
- BigButton: "Konfirmasi"

#### MyOrdersScreen

- List orders dengan status (pending, waiting, paid, rejected, cancelled)
- QRIS waiting: tombol "Upload Bukti"
- Tap order → detail order

#### UploadProofScreen

- Pick image via camera/gallery
- Preview gambar
- Info kompresi: "Ukuran 1.2MB → 0.7MB"
- BigButton: "Upload Proof"
- Offline queue banner jika offline

#### AdminDashboardScreen

**3 Tabs:**

1. Menunggu Bayar (pending)
2. Lunas Tunai (paid)
3. QRIS Menunggu Cek (waiting)

**Fitur:**

- Search bar
- List orders (user name, variant, qty, total)
- Proof thumbnail (tap → view S3 tempUrl)
- BigButton: "Validasi" (48dp, hijau)
- BigButton: "Tolak" (48dp, merah)
- Checkbox multi-select untuk batch validate
- Batch bar bottom: "Validasi 3 terpilih"

#### CreateCampaignScreen

**Form:**

- Nama Barang (wajib)
- Deskripsi (opsional)
- Target Kg (wajib, kelipatan varian terkecil)
- Total Harga Modal Supplier (wajib)
- Tenggat Waktu (date picker, min +24 jam)
- Lokasi Pengambilan (opsional)
- Foto (pick image, compress 800x800 70%)

**Varian:**

- Dinamis add/remove rows
- Size Kg (5.00, 10.00)
- Price (Rp)
- Quota

**Tombol:** "Publikasikan PO" (Idempotency-Key)

#### RecapScreen

- Header: campaign name, target, current
- Text rekap format
- PDF viewer via `flutter_cached_pdfview` atau open tempUrl S3 via `url_launcher`
- BigButton: "Share WA Supplier" (auto text)
- Button: "Share PDF"

#### DistributionChecklistScreen

- List paid orders with checkbox `is_taken`
- Info: `taken_at`, `taken_by`
- Search
- Progress: `taken_count / total`
- BigButton: "Selesai Distribusi"

#### NotificationsScreen

- List notifications (fallback DB + FCM Hive)
- Unread: bold, Read: normal
- Tap → mark read + navigate campaign_id
- Swipe to mark read
- AppBar: "Mark All Read"

#### ProfileScreen

- Name
- Phone (masked)
- Cluster
- `consent_at`
- FAQ (expandable)
- Privacy Policy (full text scroll)
- Button: "Hapus Akun" (dengan konfirmasi)

### 4.3 Navigasi & Deep Link

**Deep Link:** `grosirun://campaign/{id}`

**Flow:**

1. Aplikasi terbuka via deep link
2. Jika sudah login → langsung ke CampaignDetailScreen
3. Jika belum login → simpan pendingDeepLink di Hive `appStateBox`
4. Setelah login → navigasi ke CampaignDetailScreen

**Route Mapping:**

| Route                     | Screen                      |
| ------------------------- | --------------------------- |
| `/`                       | SplashScreen                |
| `/login`                  | LoginScreen                 |
| `/otp`                    | OtpScreen                   |
| `/consent`                | ConsentScreen               |
| `/tos`                    | TosScreen                   |
| `/home`                   | HomeScreen                  |
| `/campaign/:id`           | CampaignDetailScreen        |
| `/my-orders`              | MyOrdersScreen              |
| `/profile`                | ProfileScreen               |
| `/admin/dashboard`        | AdminDashboardScreen        |
| `/admin/create`           | CreateCampaignScreen        |
| `/admin/recap/:id`        | RecapScreen                 |
| `/admin/distribution/:id` | DistributionChecklistScreen |
| `/notifications`          | NotificationsScreen         |

---

## 5. State Loading, Empty, Error & Skeleton

### 5.1 Loading

| Skenario            | Tampilan                                            |
| ------------------- | --------------------------------------------------- |
| **List Campaign**   | Skeleton shimmer 3 cards (image grey + lines grey)  |
| **Detail Campaign** | Shimmer image + shimmer lines                       |
| **Checkout**        | BigButton loading state (CircularProgressIndicator) |
| **Upload Proof**    | BigButton loading state                             |

### 5.2 Empty

| Skenario             | Tampilan                                                  |
| -------------------- | --------------------------------------------------------- |
| **Home (buyer)**     | "Belum ada PO aktif di cluster PGH-RT03" + Button Refresh |
| **Home (initiator)** | "Belum ada PO aktif. Buat PO pertama!" + FAB Create PO    |
| **My Orders**        | "Belum ada pesanan"                                       |
| **Notifications**    | "Belum ada notifikasi"                                    |

### 5.3 Error

| Skenario                 | Tampilan                                                        |
| ------------------------ | --------------------------------------------------------------- |
| **Network Error**        | ErrorView: Icon error + human message + Trace ID + Button Retry |
| **404 Not Found**        | ErrorView: "PO tidak ditemukan" + Button Kembali                |
| **409 OUT_OF_STOCK**     | Dialog: "Stok habis, pilih varian lain"                         |
| **403 CLUSTER_MISMATCH** | Dialog: "Beda cluster RT, tidak bisa pesan di sini"             |

### 5.4 Offline

| Skenario         | Tampilan                                                         |
| ---------------- | ---------------------------------------------------------------- |
| **Home**         | Banner kuning: "Kamu offline, data mungkin tidak terbaru"        |
| **Checkout**     | Snackbar: "Kamu offline, pesanan disimpan lokal akan sync nanti" |
| **Upload Proof** | Banner: "Bukti disimpan lokal, akan upload saat online"          |

---

## 6. Bottom Sheet, Dialog & SnackBar

### 6.1 BottomSheet Payment Method

```
┌──────────────────────────────────────────────────────┐
│  ─── (Handle bar 4dp x 32dp)                       │
│  Pilih Pembayaran                                   │
│                                                    │
│  ○ Cash                                            │
│    Bayar tunai ke Pak Agus                         │
│                                                    │
│  ○ QRIS                                            │
│    Transfer QRIS + upload bukti                   │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │              Konfirmasi                      │  │
│  └──────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### 6.2 Dialog Confirm

```
┌──────────────────────────────────────────────────────┐
│  ⚠️ Konfirmasi                                     │
│                                                    │
│  Yakin batalkan PO?                                │
│  Semua pending akan batal, paid tetap butuh        │
│  refund manual.                                    │
│                                                    │
│  [  Batal  ]    [  Yakin Batalkan  ]              │
└──────────────────────────────────────────────────────┘
```

### 6.3 SnackBar

| Properti      | Nilai                                              |
| ------------- | -------------------------------------------------- |
| Behavior      | Floating                                           |
| Margin        | 16dp                                               |
| Border Radius | 12dp                                               |
| Background    | #0F172A                                            |
| Text Color    | Putih                                              |
| Font Size     | 14sp                                               |
| Action        | "Lihat" (untuk order success → navigate My Orders) |
| Duration      | Sukses: 3s, Error: 4s                              |

### 6.4 Dialog Reject Reason

```
┌──────────────────────────────────────────────────────┐
│  Alasan Penolakan                                   │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │  Foto blur nominal tidak terlihat           │  │
│  └──────────────────────────────────────────────┘  │
│  (Minimal 10 karakter)                             │
│                                                    │
│  [  Batal  ]    [  Tolak  ]                       │
└──────────────────────────────────────────────────────┘
```

### 6.5 Dialog Override Reason

Sama seperti di atas, untuk catatan override.

---

## 7. Aksesibilitas & Responsif

### 7.1 Aksesibilitas

| Aspek             | Implementasi                                                                                                                     |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Semantics**     | Semua BigButton punya label, image punya contentDescription campaign name                                                        |
| **Touch Target**  | Minimal 48dp (WCAG 2.5.5)                                                                                                        |
| **Contrast**      | WCAG 2.1 AA: Primary #16A34A on white (4.5:1 pass), Text Primary #0F172A on white (15:1 pass), Error #DC2626 on white (5:1 pass) |
| **Font Scaling**  | Support `MediaQuery.textScaleFactor` up to 1.3x, layout tidak break                                                              |
| **Screen Reader** | Test TalkBack Android                                                                                                            |

### 7.2 Responsif

| Perangkat                           | Layout                                     |
| ----------------------------------- | ------------------------------------------ |
| **Mobile Portrait** (width ≥ 360dp) | Single column (default)                    |
| **Tablet** (width > 600dp)          | Grid 2 columns menggunakan `LayoutBuilder` |
| **Landscape**                       | Tetap portrait (disarankan)                |

---

## 8. Animasi, Lottie & Performa

### 8.1 Lottie

| Properti  | Nilai                        |
| --------- | ---------------------------- |
| File      | `assets/lottie/truck.json`   |
| Size      | <100KB                       |
| Loop      | True                         |
| FrameRate | Max                          |
| Cache     | `LottieComposition` di-cache |

### 8.2 Animasi

| Animasi            | Durasi | Easing |
| ------------------ | ------ | ------ |
| Progress linear    | 300ms  | ease   |
| Card fade in       | 200ms  | ease   |
| Button press scale | 0.95   | -      |

### 8.3 Performa

| Tips                 | Keterangan                                          |
| -------------------- | --------------------------------------------------- |
| **RepaintBoundary**  | Untuk Lottie agar tidak repaint seluruh screen      |
| **ListView.builder** | Untuk daftar panjang, hindari `ListView(children:)` |
| **const widgets**    | Gunakan `const` untuk widget statis                 |
| **Cubit logic**      | Hindari logic berat di build method                 |
| **Image cache**      | `cached_network_image` disk cache 7 hari            |

---

## 9. Layar Consent & ToS (UU PDP)

### 9.1 ConsentScreen (UU PDP)

```
┌──────────────────────────────────────────────────────┐
│  🔒 Kebijakan Privasi                               │
│                                                    │
│  ──── scroll ────                                  │
│  Kami menghormati privasi Anda...                  │
│  [PRIVACY_POLICY.md content]                       │
│  ──── scroll ────                                  │
│                                                    │
│  ☐ Saya setuju data WA disimpan untuk PO RT        │
│    sesuai UU PDP No.27/2022                        │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │              Setuju Lanjut                   │  │
│  └──────────────────────────────────────────────┘  │
│  (disabled jika checkbox tidak centang)            │
└──────────────────────────────────────────────────────┘
```

**API:** `POST /auth/consent` → `users.consent_at` tercatat

### 9.2 TosScreen (Non-Escrow)

```
┌──────────────────────────────────────────────────────┐
│  ⚖️ Syarat Layanan Non-Escrow                       │
│                                                    │
│  ──── scroll ────                                  │
│  1. Grosirun hanya alat catat...                   │
│  [DISPUTE_SOP.md content]                         │
│  ──── scroll ────                                  │
│                                                    │
│  ☐ Saya mengerti dan setuju dengan Syarat          │
│    Layanan Non-Escrow                              │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │              Setuju Lanjut                   │  │
│  └──────────────────────────────────────────────┘  │
│  (disabled jika checkbox tidak centang)            │
└──────────────────────────────────────────────────────┘
```

**API:** `POST /auth/tos-accept` → `users.tos_accepted_at` tercatat

### 9.3 Flow Consent & ToS

```
OTP Verify Success
    │
    ▼
Cek consent_at & tos_accepted_at
    │
    ├── consent_at null ──► ConsentScreen ──► TosScreen ──► Home
    │
    ├── tos_accepted_at null ──► TosScreen ──► Home
    │
    └── keduanya ada ──► Home
```

---

## 10. Dark Mode (Future V1.1)

### 10.1 Fitur

| Aspek            | Detail                                       |
| ---------------- | -------------------------------------------- |
| **ThemeMode**    | System light/dark                            |
| **Feature Flag** | `dark-mode` (Pennant, false V1.0, true V1.1) |
| **Storage**      | Hive `appStateBox` key `themeMode`           |
| **API**          | `GET /features` → `dark-mode: true/false`    |

### 10.2 Dark Mode Colors

| Token          | Light   | Dark    |
| -------------- | ------- | ------- |
| Background     | #FFFFFF | #0F172A |
| Surface        | #F8FAFC | #1E293B |
| Text Primary   | #0F172A | #F8FAFC |
| Text Secondary | #64748B | #94A3B8 |
| Border         | #E2E8F0 | #334155 |

---

## 11. Ringkasan

### 11.1 Checklist UI/UX

| Item                                 | Status |
| ------------------------------------ | ------ |
| [ ] Design Principles diterapkan     | ☐      |
| [ ] Color Palette konsisten          | ☐      |
| [ ] BigButton 56dp                   | ☐      |
| [ ] Progress Truck                   | ☐      |
| [ ] Social Ticker                    | ☐      |
| [ ] Variant Selector (Paten)         | ☐      |
| [ ] Offline Banner                   | ☐      |
| [ ] ErrorView / EmptyView / Skeleton | ☐      |
| [ ] Consent + ToS Screens            | ☐      |
| [ ] Deep Link handling               | ☐      |
| [ ] Accessibility (TalkBack)         | ☐      |
| [ ] Responsive (tablet)              | ☐      |
| [ ] Lottie <100KB                    | ☐      |
| [ ] ListView.builder                 | ☐      |
| [ ] SnackBar floating                | ☐      |

### 11.2 Referensi Dokumentasi

| Dokumen                  | Keterangan                        |
| ------------------------ | --------------------------------- |
| **PRIVACY_POLICY.md**    | Konten ConsentScreen              |
| **DISPUTE_SOP.md**       | Konten TosScreen                  |
| **FAQ_END_USER.md**      | Konten FAQ di ProfileScreen       |
| **ERROR_CATALOG.md**     | Error mapping untuk ErrorView     |
| **BUSINESS_ANALYSIS.md** | Unit economics untuk transparansi |

---

**Spesifikasi UI/UX V3.1 Production Ready - 8 Layar, Consent & ToS, Deep Link, Aksesibilitas, Performa, Dark Mode Future!** 🎨🚀
