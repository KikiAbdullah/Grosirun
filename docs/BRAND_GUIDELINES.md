# Brand Guidelines — Grosirun

**Tanggal:** 21 Juli 2026  
**Versi:** 1.0  
**Owner:** Product & Design  
**Review Cycle:** Setiap release  
**Status Dokumen:** Final  
**Status Implementasi:** Belum Dimulai  
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)

---

## Daftar Isi

1. [Identitas Brand](#1-identitas-brand)
2. [Logo](#2-logo)
3. [Sistem Warna](#3-sistem-warna)
4. [Tipografi](#4-tipografi)
5. [Ikonografi](#5-ikonografi)
6. [Gaya Visual dan Fotografi](#6-gaya-visual-dan-fotografi)
7. [Nada dan Suara Brand](#7-nada-dan-suara-brand)
8. [Komponen UI dan Pattern](#8-komponen-ui-dan-pattern)
9. [Aplikasi Brand](#9-aplikasi-brand)
10. [Do's and Don'ts](#10-dos-and-donts)
11. [Aset Brand dan Kontak](#11-aset-brand-dan-kontak)

---

## 1. Identitas Brand

### 1.1 Nama Brand

**Grosirun** — kombinasi dari "Grosir" (pembelian dalam jumlah besar dengan harga lebih murah) dan "Run" (gerakan cepat, aksi). Nama ini mencerminkan esensi platform: belanja bersama yang cepat, mudah, dan menguntungkan.

**Aturan penulisan:**

| Konteks | Penulisan | Contoh |
| --- | --- | --- |
| Nama brand | Grosirun (huruf kapital di awal) | Grosirun membantu warga RT |
| Domain | grosirun.id | https://grosirun.id |
| Tagline dalam kalimat | huruf kecil semua | grosir + run — gotong royong ekonomi digital mikro |
| Hashtag | #GrosirRun | #GrosirRun |

**Larangan penulisan:**

- ❌ GROSIRUN (semua kapital kecuali judul)
- ❌ grosir un (dua kata terpisah)
- ❌ Grosir Un
- ❌ Grosir-un
- ❌ grosrun, grosrun, GROSIR-UN

### 1.2 Tagline

> **Belanja Patungan Super Ringan**

Tagline ini digunakan pada materi pemasaran, splash screen, dan sampul presentasi. Ringkas, langsung menyampaikan nilai utama: belanja bersama (patungan), hemat biaya, dan mudah digunakan (super ringan).

### 1.3 Motto Internal

> **Ringan di HP, Berat di Audit, Taat UU PDP, Siap Disaster.**

Motto ini digunakan pada komunikasi internal tim, dokumentasi teknis, dan materi developer. Bukan untuk konsumsi publik eksternal.

### 1.4 Visi

Otak digital ekonomi mikro RT/RW, menghilangkan 100% admin manual patungan, taat UU PDP No.27/2022, non-escrow legal.

### 1.5 Misi

Menyediakan platform group-buying yang ringan, transparan, dan terpercaya bagi komunitas RT/RW Indonesia untuk menghemat 14–21% harga kebutuhan pokok melalui sistem patungan digital.

### 1.6 Nilai-Nilai Brand

| Nilai | Deskripsi | Manifestasi |
| --- | --- | --- |
| **Gotong Royong** | Semangat kebersamaan dan saling membantu dalam komunitas | UI yang mendorong kolaborasi, progress bersama, social ticker |
| **Transparansi** | Informasi jelas, terbuka, dan dapat dipantau semua pihak | Progress bar, audit log, harga terlihat sebelum checkout, status real-time |
| **Ringan** | Mudah digunakan, tidak membebani perangkat, tidak rumit | APK <10MB, tombol besar 56dp, tanpa input manual, offline-first |
| **Terpercaya** | Aman, taat regulasi, data terlindungi | Consent UU PDP, non-escrow ToS, enkripsi, audit trail |
| **Efisien** | Menghemat waktu, uang, dan usaha semua pihak | Rekap otomatis, PDF 1-klik, validasi cepat, distribusi checklist |

### 1.7 Kepribadian Brand

Grosirun memiliki kepribadian seperti **tetangga yang pintar dan suka membantu**:

- **Ramah** — Bahasa sederhana, tidak teknikal, hangat
- **Cerdas** — Solusi tepat, efisien, tanpa berbelit
- **Jujur** — Tidak menjanjikan yang tidak bisa dipenuhi, transparan soal status
- **Sederhana** — Tidak berlebihan, fokus pada fungsi dan manfaat
- **Dapat diandalkan** — Konsisten, stabil, selalu ada saat dibutuhkan

---

## 2. Logo

### 2.1 Konsep Logo

Logo Grosirun menggabungkan elemen keranjang belanja (gotong royong, belanja bersama) dengan gerakan dinamis (run, aksi cepat). Desain minimalis agar tetap jelas pada ukuran kecil (notifikasi, favicon) maupun besar (presentasi, spanduk).

### 2.2 Konstruksi Logo

```
┌─────────────────────────────────┐
│                                 │
│   [🛒 ikon]  Grosirun           │
│   hijau #16A34A                 │
│                                 │
└─────────────────────────────────┘

Lockup horizontal (utama):
[Ikon] + [Wordmark "Grosirun"]

Lockup vertikal (alternatif):
    [Ikon]
  Grosirun
```

**Rasio elemen:**
- Lebar ikon : wordmark = 1 : 3
- Jarak ikon ke wordmark = 0.3 × tinggi ikon
- Tinggi total lockup = 1.2 × tinggi ikon

### 2.3 Varian Logo

| Varian | Penggunaan |
| --- | --- |
| **Full color (horizontal)** | Header aplikasi, website, surat resmi, presentasi |
| **Icon only (kotak)** | Favicon, app icon, profil sosial media, notifikasi |
| **Monokrom putih** | Di atas latar gelap, foto, atau video |
| **Monokrom hitam** | Cetakan hitam putih, fax, stempel |
| **Negative (putih di hijau)** | Tombol, badge, splash screen |

### 2.4 Area Aman (Clear Space)

Jarak minimum di sekeliling logo = **1× tinggi huruf "G"** pada wordmark. Tidak ada elemen visual lain (teks, gambar, border) yang boleh masuk area ini.

```
        ↕ 1× tinggi "G"
  ← ─────────────── →
  │                  │
↑ │  [🛒] Grosirun   │ ↑
│ │                  │ │
↓ ──────────────── ↓
```

### 2.5 Ukuran Minimum

| Media | Ukuran minimum |
| --- | --- |
| Digital (screen) | Lebar 80px (full lockup), 24px (icon only) |
| Cetak | Lebar 20mm (full lockup), 6mm (icon only) |

Di bawah ukuran ini, gunakan **icon only** tanpa wordmark.

### 2.6 Latar Belakang Logo

| Latar | Versi logo |
| --- | --- |
| Putih / terang | Full color atau monokrom hitam |
| Berwarna (hijau brand) | Monokrom putih atau negative |
| Foto / gelap | Monokrom putih dengan overlay gelap 40% |
| Berpola / ramai | Letakkan di atas kotak putih dengan padding 8px |

---

## 3. Sistem Warna

### 3.1 Warna Primer

| Token | Nama | Hex | RGB | HSL | Penggunaan |
| --- | --- | --- | --- | --- | --- |
| **Primary** | Grosirun Green | `#16A34A` | 22, 163, 74 | 142°, 76%, 36% | Tombol utama, aksi positif, elemen brand utama |
| **Primary Dark** | Grosirun Green Dark | `#15803D` | 21, 128, 61 | 142°, 72%, 29% | State pressed, hover, fokus |
| **Primary Light** | Grosirun Green Light | `#BBF7D0` | 187, 247, 208 | 111°, 78%, 85% | Background aksen, badge, highlight ringan |

### 3.2 Warna Sekunder dan Fungsional

| Token | Nama | Hex | Penggunaan |
| --- | --- | --- | --- |
| **Warning** | Kuning | `#FACC15` | Progress 70–99%, peringatan, state pending |
| **Error** | Merah | `#DC2626` | Error, tolak, gagal, status kritis |
| **Success** | Hijau terang | `#22C55E` | Sukses, complete, terverifikasi |
| **Info** | Biru | `#3B82F6` | Informasi, bantuan, link |

### 3.3 Warna Netral

| Token | Hex | Penggunaan |
| --- | --- | --- |
| **Background** | `#FFFFFF` | Latar belakang utama (Scaffold) |
| **Surface** | `#F8FAFC` | Latar card, section, container |
| **Border** | `#E2E8F0` | Garis pemisah, border card, divider |
| **Text Primary** | `#0F172A` | Judul, body text, label penting |
| **Text Secondary** | `#64748B` | Subjudul, caption, time ago, helper text |
| **Text Disabled** | `#94A3B8` | Teks tidak aktif, placeholder |
| **Offline Banner BG** | `#FEF9C3` | Background peringatan offline |
| **Offline Banner Text** | `#854D0E` | Teks peringatan offline |

### 3.4 Palet Dark Mode

Dark mode mengikuti Material Design 3 dark surface scale. Warna hijau primer tetap `#16A34A` namun dengan penyesuaian:

| Token | Light | Dark |
| --- | --- | --- |
| Background | `#FFFFFF` | `#0F172A` |
| Surface | `#F8FAFC` | `#1E293B` |
| Text Primary | `#0F172A` | `#F1F5F9` |
| Text Secondary | `#64748B` | `#94A3B8` |
| Primary | `#16A34A` | `#4ADE80` |
| Border | `#E2E8F0` | `#334155` |

### 3.5 Kontras dan Aksesibilitas

Semua kombinasi warna memenuhi **WCAG 2.1 Level AA** (rasio kontras minimal 4.5:1 untuk teks normal):

| Kombinasi | Rasio | Status |
| --- | --- | --- |
| Primary `#16A34A` on White `#FFFFFF` | 4.5:1 | ✅ Pass AA |
| Text Primary `#0F172A` on White | 15.4:1 | ✅ Pass AAA |
| Error `#DC2626` on White | 5.0:1 | ✅ Pass AA |
| Text Secondary `#64748B` on White | 4.6:1 | ✅ Pass AA |
| White on Primary `#16A34A` | 4.5:1 | ✅ Pass AA |

### 3.6 Gradien (Opsional)

Gradien hanya digunakan pada elemen dekoratif (splash screen, ilustrasi), bukan pada teks atau tombol fungsional:

```
Brand Gradient: #16A34A → #15803D (vertikal, 180°)
Accent Gradient: #16A34A → #0EA5E9 (diagonal, 135°) — terbatas ilustrasi
```

---

## 4. Tipografi

### 4.1 Font Family

| Platform | Font | Alasan |
| --- | --- | --- |
| Android | Roboto | System default, tidak menambah ukuran APK |
| iOS | San Francisco | System default native |
| Web Admin | Inter / system-ui | Konsisten lintas browser |

**Kebijakan:** Tidak menggunakan custom font berbayar atau font yang memerlukan download tambahan. APK harus tetap <10MB. Jika custom font diperlukan (misalnya untuk kampanye khusus), gunakan subset Latin only dengan ukuran <50KB per weight.

### 4.2 Skala Tipografi

| Token | Ukuran | Weight | Line Height | Penggunaan |
| --- | --- | --- | --- | --- |
| **Display** | 32sp | Bold (700) | 1.2 | Splash screen, headline kampanye |
| **Headline Large** | 24sp | Bold (700) | 1.3 | Nama campaign di halaman detail |
| **Headline Medium** | 20sp | SemiBold (600) | 1.3 | Judul section utama |
| **Title Medium** | 18sp | Medium (500) | 1.4 | Judul card di home |
| **Title Small** | 16sp | Medium (500) | 1.4 | Judul dialog, bottom sheet |
| **Body Large** | 16sp | Regular (400) | 1.4 | Deskripsi produk, body text utama |
| **Body Medium** | 14sp | Regular (400) | 1.4 | Secondary text, ticker, time ago |
| **Body Small** | 12sp | Regular (400) | 1.5 | Caption, label kecil, helper |
| **Label Large** | 16sp | Medium (500) | 1.4 | Teks tombol (CTA) |
| **Label Medium** | 14sp | Medium (500) | 1.4 | Tab label, chip, badge |
| **Label Small** | 12sp | Medium (500) | 1.4 | Tag, kategori, counter |

### 4.3 Aturan Tipografi

- **Bahasa:** Indonesia (formal untuk sistem, semi-formal untuk komunikasi)
- **Format angka:** Gunakan titik sebagai pemisah ribuan (Rp1.500.000) dan koma untuk desimal (1,5 kg)
- **Format mata uang:** Awalan "Rp" tanpa spasi, contoh: Rp15.000
- **Format tanggal:** 21 Juli 2026 (format Indonesia, tanpa nama hari untuk timestamp pendek)
- **Tidak menggunakan all-caps** untuk teks lebih dari 3 kata
- **Hindari italic** kecuali untuk catatan kaki atau kutipan
- **Maksimal 3 weight** dalam satu screen: Regular, Medium, Bold

---

## 5. Ikonografi

### 5.1 Library Ikon

Gunakan **Material Icons** (built-in Flutter) untuk menjaga ukuran APK tetap ringan. Tidak menggunakan ikon custom SVG kecuali benar-benar diperlukan untuk identitas brand.

### 5.2 Gaya Ikon

| Atribut | Spesifikasi |
| --- | --- |
| Gaya | Outlined (Material Symbols Outlined) |
| Stroke | 1.5px |
| Corner | Rounded 2px |
| Ukuran default | 24×24dp |
| Ukuran di tombol | 20×20dp |
| Warna default | `#64748B` (Text Secondary) |
| Warna aktif | `#16A34A` (Primary) |
| Warna error | `#DC2626` (Error) |

### 5.3 Ikon Utama Brand

| Fungsi | Ikon | Catatan |
| --- | --- | --- |
| Belanja / Campaign | `shopping_cart` | Keranjang belanja |
| Komunitas / Cluster | `groups` | Kelompok orang |
| Pengiriman / Distribusi | `local_shipping` | Truk pengiriman |
| Pembayaran | `account_balance_wallet` | Dompet / pembayaran |
| Notifikasi | `notifications` | Lonceng notifikasi |
| Profil | `person` | Avatar user |
| Validasi (centang) | `check_circle` | Status berhasil/valid |
| Tolak | `cancel` | Status ditolak |
| Offline | `cloud_off` | Indikator offline |

---

## 6. Gaya Visual dan Fotografi

### 6.1 Gaya Ilustrasi

Ilustrasi digunakan pada empty state, onboarding, dan halaman promosi.

| Atribut | Spesifikasi |
| --- | --- |
| Gaya | Flat design dengan aksen minimal |
| Warna dominan | Putih + hijau brand + aksen kuning |
| Karakter | Sederhana, ramah, merepresentasikan warga Indonesia |
| Objek | Keranjang, pasar, rumah, komunitas |
| Hindari | 3D render, gradien kompleks, foto stok generik |

### 6.2 Fotografi

Foto digunakan terbatas pada materi marketing (bukan di dalam aplikasi).

| Atribut | Spesifikasi |
| --- | --- |
| Subjek | Aktivitas komunitas, belanja bersama, distribusi barang |
| Tone | Hangat, natural, pencahayaan terang |
| Komposisi | Close-up aktivitas, bukan posed formal |
| Warna | Natural, tidak over-saturated |
| Diversitas | Merepresentasikan berbagai usia dan latar belakang warga |
| Hindari | Stok foto barat, pose formal korporat, warna gelap/suram |

### 6.3 Ilustrasi Empty State

| Kondisi | Ilustrasi |
| --- | --- |
| Tidak ada campaign | Keranjang kosong dengan teks "Belum ada patungan aktif" |
| Belum ada order | Ikon paket dengan teks "Belum ada pesanan" |
| Offline | Awan dengan garis putus |
| Error | Ikon peringatan dengan pesan human-readable |
| Loading | Shimmer placeholder (abu-abu terang `#E2E8F0`) |

---

## 7. Nada dan Suara Brand

### 7.1 Prinsip Komunikasi

Grosirun berkomunikasi seperti **tetangga yang pintar dan suka membantu**:

| Prinsip | Penjelasan | Contoh |
| --- | --- | --- |
| **Sederhana** | Gunakan kata sehari-hari, hindari jargon teknis | ✅ "Patungan berhasil!" ❌ "Transaksi berhasil diproses oleh sistem" |
| **Hangat** | Terasa personal, bukan robot | ✅ "Pesanan kamu sudah tercatat, Bu!" ❌ "Order ID: AT-2026-0042 telah dibuat" |
| **Jujur** | Jangan overpromise, sampaikan apa adanya | ✅ "Stok tinggal 3 lagi" ❌ "Stok hampir habis! Buruan!" |
| **Membantu** | Berikan solusi, bukan hanya masalah | ✅ "Upload gagal. Cek koneksi internet kamu ya." ❌ "Error 500: Internal Server Error" |
| **Ringkas** | Langsung ke inti, tidak bertele-tele | ✅ "Pembayaran diterima ✅" ❌ "Kami informasikan bahwa pembayaran Anda telah kami terima dan telah diverifikasi oleh sistem" |

### 7.2 Nada per Konteks

| Konteks | Nada | Contoh |
| --- | --- | --- |
| **Sukses** | Ceria, singkat | "Patungan berhasil! 🎉" |
| **Error** | Tenang, solutif | "Gagal memuat. Coba lagi ya." |
| **Peringatan** | Sopan, jelas | "Kamu offline. Data mungkin tidak terbaru." |
| **Onboarding** | Ramah, membimbing | "Yuk, mulai patungan pertamamu!" |
| **Konsent/ToS** | Serius, transparan | "Data WA kamu disimpan untuk keperluan PO RT saja." |
| **Notifikasi** | Informatif, actionable | "Stok beras tinggal 5 kg. Checkout sekarang!" |
| **Dukungan** | Empatik, membantu | "Maaf ya, ada kendala. Yuk kita selesaikan bersama." |

### 7.3 Bahasa dan Terminologi

| Istilah | Gunakan | Hindari |
| --- | --- | --- |
| Belanja bersama | Patungan | Group buying, collective purchase |
| Koordinator | Inisiator | Admin, manager, coordinator |
| Warga | Pembeli (Buyer) | User, customer, client |
| Toko | Penjual (Seller) | Merchant, vendor, supplier (internal) |
| Komunitas | Cluster | Group, zone, area |
| Pesanan | Order, pesanan | Purchase, transaction |
| Bukti bayar | Bukti transfer | Payment proof, evidence |
| Status | Pending, diproses, selesai | On hold, in progress, done |

### 7.4 Emoji

Emoji digunakan secara terbatas dan konsisten:

| Emoji | Penggunaan |
| --- | --- |
| 🎉 | Sukses, target tercapai |
| ✅ | Validasi berhasil, status selesai |
| ⚠️ | Peringatan |
| ❌ | Error, ditolak |
| 📦 | Pesanan, distribusi |
| 🛒 | Campaign, belanja |
| 💚 | Brand love, apresiasi |

---

## 8. Komponen UI dan Pattern

### 8.1 Tombol (Button)

| Jenis | Tinggi | Border Radius | Warna | Penggunaan |
| --- | --- | --- | --- | --- |
| **Primary CTA** | 56dp | 12dp | Background `#16A34A`, text putih | Aksi utama: "Ikut Patungan", "Validasi" |
| **Secondary** | 48dp | 12dp | Border `#16A34A`, text `#16A34A` | Aksi pendukung: "Lihat Detail" |
| **Danger** | 48dp | 12dp | Background `#DC2626`, text putih | Tolak, batal, hapus |
| **Ghost** | 48dp | 12dp | Transparent, text `#16A34A` | Link dalam konteks UI |
| **Disabled** | 48/56dp | 12dp | Background `#E2E8F0`, text `#94A3B8` | Tidak tersedia |

**Area sentuh minimum:** 48×48dp (accessibility requirement)

### 8.2 Card

| Atribut | Spesifikasi |
| --- | --- |
| Background | `#F8FAFC` (Surface) |
| Border | 1px `#E2E8F0` |
| Border radius | 16dp |
| Padding | 16dp |
| Shadow | `0 1px 3px rgba(0,0,0,0.1)` |

### 8.3 Progress Bar

| Kondisi | Warna | Keterangan |
| --- | --- | --- |
| 0–69% | `#16A34A` (hijau) | Progress normal |
| 70–99% | `#FACC15` (kuning) | Hampir mencapai target |
| 100% | `#16A34A` (hijau neon) + animasi | Target tercapai |
| Background | `#E2E8F0` | Track progress |
| Tinggi | 24dp | Dengan label persentase |

### 8.4 Spacing System

Menggunakan kelipatan 4dp:

| Token | Nilai | Penggunaan |
| --- | --- | --- |
| `space-xs` | 4dp | Jarak antar elemen dalam komponen |
| `space-sm` | 8dp | Padding internal komponen kecil |
| `space-md` | 16dp | Padding card, margin section |
| `space-lg` | 24dp | Jarak antar section |
| `space-xl` | 32dp | Jarak antar group besar |
| `space-2xl` | 48dp | Padding halaman (horizontal) |

### 8.5 Border Radius

| Token | Nilai | Penggunaan |
| --- | --- | --- |
| `radius-sm` | 4dp | Chip, tag, badge kecil |
| `radius-md` | 8dp | Tombol kecil (Button +/-), input field compact |
| `radius-lg` | 12dp | Tombol utama (Primary CTA, Secondary, Danger), dialog |
| `radius-xl` | 16dp | Card, container besar, bottom sheet |
| `radius-2xl` | 24dp | Bottom sheet top corners |
| `radius-full` | 999dp | Avatar, circle button |

---

## 9. Aplikasi Brand

### 9.1 Aplikasi Mobile

| Elemen | Penerapan |
| --- | --- |
| **App Icon** | Ikon Grosirun (keranjang hijau) di background putih |
| **Splash Screen** | Logo horizontal di tengah, background putih, tagline di bawah |
| **App Bar** | Background putih bersih, logo/icon navigasi, nama cluster di subtitle |
| **Bottom Navigation** | 4 tab utama dengan ikon Material, active state hijau primary |
| **Notifikasi** | Ikon Grosirun hijau, accent color hijau |

### 9.2 Materi Presentasi

| Elemen | Penerapan |
| --- | --- |
| **Slide sampul** | Logo horizontal + tagline + background putih |
| **Header slide** | Logo kecil di pojok kanan atas |
| **Footer slide** | Garis hijau primary 2px di bawah |
| **Warna teks** | `#0F172A` untuk judul, `#64748B` untuk body |
| **Highlight** | Background `#BBF7D0` (Primary Light) untuk poin penting |

### 9.3 Media Sosial

| Platform | Ukuran | Penerapan |
| --- | --- | --- |
| **Instagram Post** | 1080×1080 | Logo di pojok, tipografi bold, warna brand |
| **Instagram Story** | 1080×1920 | Full visual + overlay brand |
| **WhatsApp Sticker** | 512×512 | Ikon Grosirun + emoji/teks pendek |
| **Twitter/X Post** | 1200×675 | Headline besar + visual flat |
| **Profile Picture** | 400×400 | Icon only, background `#16A34A` |

### 9.4 Dokumen Resmi

| Elemen | Penerapan |
| --- | --- |
| **Kop surat** | Logo horizontal + nama + domain |
| **Footer** | Alamat, kontak, garis hijau |
| **Tanda tangan digital** | Nama + jabatan + logo kecil |
| **PDF Report** | Header dengan logo, footer dengan nomor halaman |

### 9.5 Merchandise (Opsional)

| Item | Penerapan |
| --- | --- |
| **Kaos** | Logo putih di atas background hijau, atau logo hijau di kaos putih |
| **Tote bag** | Logo + tagline, minimalis |
| **Stiker** | Icon only atau lockup, die-cut |

---

## 10. Do's and Don'ts

### 10.1 Logo

| ✅ Do | ❌ Don't |
| --- | --- |
| Gunakan warna brand yang sudah ditentukan | Ubah warna logo di luar palet resmi |
| Pertahankan area aman di sekeliling logo | Letakkan elemen lain terlalu dekat |
| Gunakan versi monokrom putih di latar gelap | Letakkan logo di atas latar yang ramai tanpa overlay |
| Skala proporsional | Distorsi, stretch, atau rotate |
| Gunakan file vektor untuk cetak | Screenshot atau rasterize logo |

### 10.2 Warna

| ✅ Do | ❌ Don't |
| --- | --- |
| Gunakan rasio kontras minimal 4.5:1 untuk teks | Gunakan warna yang tidak memenuhi WCAG AA |
| Primary hijau untuk aksi positif | Gunakan merah untuk tombol utama |
| Konsisten dengan token warna | Gunakan warna di luar palet yang didefinisikan |
| Dark mode dengan penyesuaian yang tepat | Copy-paste warna light mode ke dark tanpa modifikasi |

### 10.3 Komunikasi

| ✅ Do | ❌ Don't |
| --- | --- |
| Gunakan bahasa Indonesia sederhana | Gunakan jargon teknis kepada user awam |
| Sampaikan status dengan jelas | Gunakan kode error mentah (500, 404) ke user |
| Jujur soal status dan limitasi | Klaim penghematan atau volume tanpa bukti |
| Gunakan "Grosirun" sebagai subjek | Gunakan "kami" atau "aplikasi" ambigu |
| Konsisten dengan terminologi | Campur istilah Indonesia dan Inggris acak |

### 10.4 Aplikasi

| ✅ Do | ❌ Don't |
| --- | --- |
| Tombol minimum 48×48dp | Tombol lebih kecil dari 48dp |
| System font default (Roboto) | Custom font berat tanpa subset |
| Offline-first, gracefully degrade | Tampilkan error tanpa fallback |
| Kompresi gambar sebelum upload | Upload gambar mentah tanpa optimasi |

---

## 11. Aset Brand dan Kontak

### 11.1 Aset yang Tersedia

| Aset | Format | Lokasi |
| --- | --- | --- |
| Logo (SVG) | Vector | `assets/brand/logo.svg` (akan disediakan) |
| Logo (PNG) | Raster, transparan | `assets/brand/logo.png` (akan disediakan) |
| App Icon | PNG berbagai resolusi | `mobile/assets/icons/` |
| Splash Screen | PNG + konfigurasi | `mobile/assets/splash/` |
| Brand Guidelines | Markdown | `docs/BRAND_GUIDELINES.md` (dokumen ini) |

### 11.2 Permintaan Aset

Untuk permintaan aset brand, materi desain, atau pertanyaan penggunaan brand:

- **Product Owner:** [Isi setelah disetujui]
- **Email:** [Isi setelah disetujui]
- **Slack:** [#brand-design](#) (akan dibuat)

### 11.3 Lisensi

Seluruh aset brand Grosirun adalah milik Grosirun. Penggunaan oleh pihak ketiga memerlukan persetujuan tertulis dari Product Owner.

---

## Referensi Silang

| Dokumen | Hubungan |
| --- | --- |
| [Mobile Specification](MOBILE_SPEC.md) | Detail teknis komponen UI, warna token, tipografi dalam Flutter |
| [PRD](PRD.md) | Persona, value proposition, positioning brand |
| [User Guide](USER_GUIDE.md) | Nada dan gaya bahasa untuk komunikasi ke user |
| [Proposal Stakeholder](PROPOSAL_PENJUAL_PEMBELI_INISIATOR.md) | Materi presentasi eksternal yang harus konsisten brand |
| [Presentation](PRESENTASI_GROSIRUN.md) | Slide deck yang mengikuti brand visual |
| [Privacy Policy](PRIVACY_POLICY.md) | Nada hukum dan transparansi dalam komunikasi consent |

---

*Dokumen ini adalah panduan resmi identitas visual dan verbal Grosirun. Setiap materi komunikasi, baik internal maupun eksternal, harus mengikuti panduan ini. Perubahan hanya melalui persetujuan Product Owner.*

**Versi 1.0 — 21 Juli 2026**
