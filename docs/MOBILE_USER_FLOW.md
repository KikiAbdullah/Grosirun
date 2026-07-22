# 📱 ALUR LENGKAP APLIKASI MOBILE GROSIRUN

**Tanggal:** 22 Juli 2026  
**Versi:** 1.0  
**Owner:** Product & Mobile  
**Review Cycle:** Setiap release  
**Status Dokumen:** Final  
**Status Implementasi:** Ready for Integration

---

## 🎯 OVERVIEW SISTEM

**Grosirun** adalah platform patungan belanja sembako berbasis **non-escrow** (dana tidak ditahan aplikasi). Ada **4 role** dengan akses berbeda:

| Role | Tujuan Utama | Scope Data |
|------|--------------|------------|
| **Pembeli (Buyer)** | Ikut patungan & ambil barang | Campaign cluster & order sendiri |
| **Inisiator (Initiator)** | Kelola PO, validasi bayar, distribusi | Cluster sendiri, offer, PO |
| **Penjual (Seller)** | Kelola produk, PO, fulfillment | Supplier membership, data agregat |
| **Admin** | Verifikasi, moderasi, audit | Operasional platform (teraudit) |

---

# 🛒 1. ALUR PEMBELI (BUYER)

## 📍 Persona: Bu Siti (Ibu-ibu RT, 45 tahun)

### A. **INSTALASI & ONBOARDING** (5 menit pertama)

#### 1. Download & Install APK

```
1. Terima link APK di grup WA RT03
2. Download file (ukuran <10 MB)
3. Izinkan "Install dari sumber tidak dikenal"
4. Install → Buka aplikasi
5. Izinkan notifikasi (PENTING!)
```

#### 2. Splash Screen
- **Tampilan:** Logo Grosirun hijau + tagline "Yuk, Grosirun Bareng!"
- **Auto-redirect:** Ke Login Screen jika belum login, atau ke Home jika sudah login

#### 3. Login dengan OTP WhatsApp

```
Screen: /login
├─ Input: Nomor WhatsApp (081234567890)
├─ Checkbox: "Setuju UU PDP No.27/2022" (WAJIB)
├─ Tombol: "Kirim OTP"
└─ Link: "Masuk demo buyer" (untuk testing)
```

**Flow:**
```
1. Masukkan nomor WA → Tap "Kirim OTP"
2. Terima kode OTP via WA (4 digit, berlaku 5 menit)
3. Masukkan kode → Tap "Verifikasi"
4. Jika sukses → Redirect ke Consent Screen
```

#### 4. Consent UU PDP (Privacy Policy)

```
Screen: /consent
├─ Judul: "Persetujuan UU PDP"
├─ Konten: Ringkasan kebijakan privasi
│  • Data dipakai untuk login & transaksi
│  • Data tidak dijual ke pihak ketiga
│  • Akun bisa dihapus
│  • Bukti transaksi disimpan sesuai retensi
├─ Checkbox: "Saya setuju data WA disimpan untuk PO RT saja"
└─ Tombol: "Lanjutkan" (enabled setelah centang)
```

#### 5. ToS Non-Escrow (Terms of Service)

```
Screen: /tos
├─ Judul: "Syarat Layanan Non-Escrow"
├─ Konten: (WAJIB SCROLL sampai bawah)
│  1. Grosirun BUKAN marketplace/bank
│  2. Dana langsung ke rekening pribadi Initiator
│  3. Jika sengketa → refund manual 2×24 jam
│  4. Eskalasi ke RT/RW jika tidak selesai
├─ Checkbox: "Saya mengerti dan setuju"
└─ Tombol: "Setuju Lanjut"
```

#### 6. Role Selection

```
Screen: /roles
├─ Judul: "Pilih Workspace"
├─ List role yang dimiliki user:
│  ├─ Buyer (default untuk Bu Siti)
│  ├─ Initiator (jika juga Ketua RT)
│  └─ Seller (jika juga penjual)
├─ Radio button untuk pilih role aktif
└─ Tombol: "Masuk ke Beranda"
```

### B. **BERANDA BUYER** (Home Screen)

```
Screen: /home
├─ Header:
│  ├─ Avatar + Nama user
│  ├─ Cluster badge: "PGH-RT03"
│  ├─ Role badge: "Buyer" (biru)
│  ├─ Icon notifikasi (dengan badge unread count)
│  └─ Icon profil
├─ Offline Banner (muncul jika offline)
└─ Bottom Navigation (4 tabs):
   ├─ Tab 1: Beranda (icon: home)
   ├─ Tab 2: Pesanan (icon: receipt)
   ├─ Tab 3: Notifikasi (icon: notifications)
   └─ Tab 4: Profil (icon: person)
```

#### **Tab 1: Beranda (Campaign List)**

**Tampilan:**

```
├─ Social Ticker (running text):
│  "Bu Nengsih baru pesan 5Kg • Pak Joko pesan 10Kg • ..."
│
└─ List Campaign Cards:
   └─ Card Campaign "Beras Premium Pulen"
      ├─ Gambar produk (16:9 aspect ratio)
      ├─ Judul: "Beras Premium Pulen"
      ├─ Subtitle: "oleh Pak Agus Setiawan"
      ├─ Progress bar: [████████░░] 80%
      ├─ Status: "Terkumpul 800/1000 Kg"
      ├─ Deadline: "Sisa 2 hari" (merah jika <1 hari)
      ├─ Cluster: "PGH-RT03"
      ├─ Harga: "Rp12.000/Kg"
      └─ Tombol: "Ikut Patungan" (hijau besar)
```

**Interaksi:**
- **Tap card** → Buka detail campaign
- **Pull-to-refresh** → Reload data campaign
- **Shimmer loading** → Tampil saat loading data
- **Empty state** → "Belum ada patungan aktif" + tombol refresh

#### **Tab 2: Pesanan (My Orders)**

**Tampilan:**

```
List Orders:
└─ Order Card
   ├─ Avatar: Jumlah qty (5)
   ├─ Title: "Beras Premium Pulen"
   ├─ Subtitle: "5 Kg • CASH • paid"
   ├─ Harga: "Rp60.000"
   └─ Status badge: "Lunas" (hijau) / "Menunggu" (kuning)
```

**Interaksi:**
- Tap order → Lihat detail order
- Empty state: "Belum ada pesanan"

#### **Tab 3: Notifikasi**

**Tampilan:**

```
List Notifications:
└─ Notification Tile
   ├─ Icon: Bell (aktif jika unread)
   ├─ Title: "Patungan Beras hampir penuh!"
   ├─ Body: "Stok tinggal 180 kg lagi..."
   └─ Time: "2 menit lalu" (pakai timeago)
```

**Interaksi:**
- Tap → Mark as read
- Unread count di header berkurang

#### **Tab 4: Profil**

**Tampilan:**

```
├─ Avatar besar (CircleAvatar)
├─ Nama: "Bu Siti Rahayu"
├─ Phone: "081234567890"
├─ Cluster: "PGH-RT03 Permata Hijau"
├─ Status Kepatuhan:
│  ├─ ✅ Consent (hijau)
│  ├─ ✅ ToS (hijau)
│  └─ Role: Buyer
├─ ExpansionTile: FAQ
├─ ExpansionTile: Privacy Policy
├─ Tombol: "Hapus Akun" (merah)
├─ Tombol: "Keluar" (outlined)
└─ Version: "Grosirun v1.0.0"
```

### C. **DETAIL CAMPAIGN & CHECKOUT**

#### 1. Buka Detail Campaign

```
Screen: /campaign/:id
├─ AppBar:
│  ├─ Back button
│  ├─ Title: "Detail Campaign"
│  └─ Share button (WhatsApp)
├─ Offline Banner
└─ Content:
   ├─ Header:
   │  ├─ Gambar produk besar
   │  ├─ Judul: "Beras Premium Pulen"
   │  └─ Chips: [PGH-RT03] [Pak Agus] [active]
   │
   ├─ Progress Card:
   │  ├─ Icon: truck
   │  ├─ Progress bar besar: [████████░░] 80%
   │  ├─ "Terkumpul 800/1000 Kg"
   │  └─ "Sisa 2 hari"
   │
   ├─ Deskripsi: "Beras premium kualitas terbaik..."
   │
   ├─ Pilih Varian:
   │  ├─ Varian 1: "5 Kg"
   │  │  ├─ Sisa: 20
   │  │  ├─ [-] [1] [+] (tombol qty)
   │  │  └─ Total otomatis: Rp60.000
   │  │
   │  └─ Varian 2: "10 Kg"
   │     ├─ Sisa: 10
   │     └─ [-] [0] [+]
   │
   └─ Metode Pembayaran:
      ├─ [Tunai] [QRIS] (chip selector)
```

#### 2. Pilih Varian & Qty

```
Interaksi:
├─ Tap [+] → Qty bertambah (max = sisa stok)
├─ Tap [-] → Qty berkurang (min = 0)
├─ Tombol abu-abu → Stok habis
├─ Input manual TIDAK BISA (hanya tombol +/-)
│  (mencegah salah input 3.5 vs 35)
└─ Total harga auto-calculate
```

#### 3. Pilih Metode Pembayaran

**Opsi A: Tunai**

```
1. Pilih "Tunai"
2. Tap "Checkout" (bottom bar)
3. Konfirmasi order
4. Status: "Menunggu Bayar"
5. Datang ke rumah Pak RT → bayar tunai Rp60.000
6. Pak RT validasi di app
7. Dapat notifikasi: "Pembayaran Lunas ✅"
```

**Opsi B: QRIS**

```
1. Pilih "QRIS"
2. Lihat QR Code Pak RT
3. Scan via mBanking → transfer Rp60.000
4. Screenshot bukti transfer
5. Tap "Upload Bukti"
   ├─ Pilih dari galeri
   ├─ Auto-compress 70%
   └─ Max 2MB
6. Status: "Menunggu Validasi QRIS"
7. Pak RT cek & validasi
8. Dapat notifikasi:
   ├─ ✅ "Pembayaran Lunas" (jika valid)
   └─ ❌ "Bukti ditolak: Foto blur" (jika reject)
```

#### 4. Checkout Bar (Bottom)

```
┌─────────────────────────────────┐
│ Total 1 item                    │
│ Rp60.000           [ Checkout ] │
└─────────────────────────────────┘
```

### D. **SETOR BUKTI QRIS**

**Jika bukti ditolak (blur):**

```
1. Dapat notifikasi: "Bukti ditolak: Foto blur"
2. Buka "Pesanan Saya"
3. Tap pesanan
4. Tap "Upload Ulang"
5. Pilih foto yang lebih jelas
6. Submit ulang
```

**Jika offline saat upload:**

```
1. Bukti disimpan lokal (Hive)
2. Banner kuning: "Kamu offline"
3. Saat online → auto-sync
4. Notifikasi: "Bukti berhasil diupload"
```

### E. **AMBIL BARANG**

```
1. Dapat notifikasi WA dari Pak RT:
   "Barang datang, ambil di rumah RT"

2. Datang ke rumah Pak RT
3. Bawa karung sendiri
4. Pak RT cek nama di app
5. Pak RT tap "Centang Sudah Ambil"
6. Sistem catat:
   ├─ is_taken = true
   ├─ taken_at = now()
   └─ taken_by = Pak Agus (initiator ID)

7. Selesai! Dapat barang 5 Kg
```

### F. **BAGIKAN KE TETANGGA**

```
1. Di detail campaign
2. Tap icon Share (WhatsApp)
3. Auto-generate text:
   "Yuk patungan Beras Premium! 
    Harga cuma Rp12.000/Kg. 
    Klik: grosirun://campaign/123"
4. Pilih grup WA RT03
5. Tap Send
6. Tetangga klik link → deep link ke app
```

### G. **BATALKAN PESANAN**

**Jika PO masih buka (belum 100%):**

```
1. Buka "Pesanan Saya"
2. Tap pesanan
3. Tap "Batalkan Partisipasi"
4. Konfirmasi
5. Order dibatalkan
6. Bisa pesan ulang varian lain
```

**Jika PO sudah 100% (terkunci):**

```
1. Tidak bisa batal sendiri
2. Hubungi Pak RT via WA
3. Pak RT bisa "Transfer Pesanan" ke tetangga
```

---

# 👨‍💼 2. ALUR INISIATOR (INITIATOR)

## 📍 Persona: Pak Agus (Ketua RT03, 50 tahun)

### A. **LOGIN & ROLE SELECTION**

Sama seperti Buyer, tapi di Role Selection:

```
Pilih role: "Initiator" (bukan Buyer)
```

### B. **BERANDA INISIATOR**

```
Bottom Navigation (4 tabs):
├─ Tab 1: Beranda (Campaign List)
├─ Tab 2: Validasi (Dashboard Admin)
├─ Tab 3: Notifikasi
└─ Tab 4: Profil
```

**Perbedaan dengan Buyer:**
- Tab 2 = "Validasi" (bukan "Pesanan")
- Ada tombol "+ Buat PO" di header

### C. **BUAT CAMPAIGN BARU**

#### 1. Tap "+ Buat PO"

```
Screen: Pilih Penawaran
├─ Filter: Area cluster (PGH-RT03)
├─ List offer aktif dari seller:
│  └─ "Beras Mahkota Premium - CV Makmur Jaya"
│     ├─ Unit: Kg
│     ├─ Minimum: 500 Kg
│     ├─ Kapasitas: 2000 Kg
│     ├─ Tier 1: Rp10.500/Kg (500-999 Kg)
│     ├─ Tier 2: Rp10.000/Kg (≥1000 Kg)
│     ├─ Biaya kirim: Rp200.000
│     └─ Berlaku sampai: 30 Juli 2026
└─ Tap offer → Lanjut ke form campaign
```

#### 2. Isi Form Campaign

```
Screen: Buat Campaign
├─ Target: [1000] Kg
│  └─ Validasi: tidak melebihi kapasitas
├─ Harga Pembeli: [Rp12.000]/Kg
│  └─ Validasi: tidak lebih rendah dari supplier
├─ Tenggat: [2 hari dari sekarang]
│  └─ Validasi: min 24 jam, sebelum offer berakhir
├─ Lokasi distribusi: "Rumah Pak RT Jl Mawar 12"
│  └─ Wajib diisi
└─ Tombol: "Publikasikan PO"
```

#### 3. Konfirmasi & Publish

```
1. Tap "Publikasikan PO"
2. Sistem:
   ├─ Lock offer (atomic)
   ├─ Reserve kapasitas
   ├─ Simpan offer_snapshot
   └─ Create campaign (status: active)
3. Campaign muncul di Beranda semua warga
4. Auto-share ke WA grup:
   "Yuk patungan Beras Mahkota! 
    Klik: grosirun://campaign/123"
```

### D. **VALIDASI PEMBAYARAN**

#### Tab "Validasi" - Dashboard Admin

**Tampilan:**

```
├─ Metrics Cards (3 cards):
│  ├─ Pending: 2 (kuning)
│  ├─ Paid: 14 (hijau)
│  └─ QRIS Waiting: 3 (biru)
│
├─ Section: "Validasi Cepat"
│  └─ List pending orders:
│     ├─ Bu Dewi - 10 Kg - QRIS - Rp120.000
│     ├─ Pak Budi - 5 Kg - Tunai - Rp60.000
│     └─ Bu Ratna - 2L x3 - QRIS - Rp96.000
│
└─ Tombol aksi per order:
   ├─ [Lihat Bukti] (untuk QRIS)
   ├─ [Validasi] (hijau)
   └─ [Tolak] (merah)
```

#### Validasi Tunai

```
Skenario: Bu Siti datang bayar tunai Rp60.000

1. Cari "Bu Siti" di tab "Pending"
2. Tap tombol "Validasi Tunai" (hijau besar, 48dp)
3. Sistem:
   ├─ Update status: paid
   ├─ Progress bar naik 5 Kg
   ├─ Catat transaction_log
   └─ Kirim notifikasi FCM ke Bu Siti:
      "Pembayaran Lunas ✅"
4. Bu Siti dapat notif di HP
```

#### Validasi QRIS

```
Skenario: Bu Dewi upload bukti QRIS

1. Buka tab "QRIS Waiting"
2. Tap "Lihat Bukti"
   ├─ Zoom foto bukti
   ├─ Cek nominal: Rp120.000
   ├─ Cek tanggal transfer
   └─ Cek nama pengirim
3. Keputusan:
   ├─ Jika jelas → Tap "Validasi"
   │  └─ Status: paid, notif ke buyer
   └─ Jika blur → Tap "Tolak"
      ├─ Isi alasan: "Foto blur nominal tidak terlihat"
      ├─ Sistem kirim notif ke Bu Dewi:
      │  "Bukti ditolak, upload ulang"
      └─ Bu Dewi upload ulang foto jelas
```

#### Undo dalam 5 Menit

```
Jika salah klik Validasi:
1. Dalam 5 menit → Tap "Batalkan Validasi"
   └─ Status kembali ke pending
2. Jika >5 menit → Tap "Validasi Paksa Override"
   ├─ Isi alasan: "Salah klik, sudah cek mutasi BCA"
   └─ Audit log tercatat
```

#### Batch Validate (V3.1)

```
1. Centang checkbox 5 orders
2. Tap "Validasi 5 Terpilih"
3. Dialog konfirmasi
4. Validasi massal dengan partial success report
```

### E. **PERPANJANGAN DEADLINE**

**H-1 Deadline, progres 60%:**

```
1. Dapat notif: "PO Hampir Gagal! Beras baru 60%"
2. Buka detail campaign
3. Tap "Perpanjang +24 Jam"
   └─ Max 2 kali perpanjangan
4. Notifikasi ke semua buyer:
   "Tenggat diperpanjang 24 jam"
```

**Jika tetap gagal setelah perpanjang:**

```
1. Tap "Batalkan PO"
2. Konfirmasi dengan peringatan:
   "⚠️ 35 buyer sudah paid (Rp8.4jt)
    Anda wajib refund 100% dalam 2×24 jam"
3. Status: expired
4. Broadcast notifikasi:
   "PO dibatalkan, refund 2×24 jam hubungi Initiator"
5. WAJIB refund manual tunai ke semua buyer paid
6. Catat refund di transaction_logs
```

### F. **BUAT PURCHASE ORDER KE SELLER**

**Setelah target & payment threshold tercapai:**

```
1. Buka campaign (status: target_reached)
2. Tap "Buat Purchase Order"
3. Review:
   ├─ Snapshot supplier
   ├─ Item agregat: 1000 Kg beras
   ├─ supplier_unit_price: Rp10.000
   ├─ supplier_subtotal: Rp10.000.000
   ├─ delivery_cost: Rp200.000
   └─ Total: Rp10.200.000
4. Tap "Kirim PO"
5. Status PO: draft → submitted
6. Seller terima notifikasi
```

**Seller response (max 12 jam):**

```
├─ Jika accepted → Status: awaiting_payment
├─ Jika rejected → Alasan tampil, Inisiator bisa:
   ├─ Pilih offer lain
   └─ Batalkan campaign + refund
```

**Setelah transfer ke supplier:**

```
1. Inisiator upload bukti pembayaran PO
   (berbeda dari bukti pembayaran buyer)
2. Seller konfirmasi pembayaran
3. Status: paid → processing → shipped
4. Seller upload invoice + surat jalan
```

### G. **CHECKLIST DISTRIBUSI**

**Truk tiba di lokasi:**

```
1. Buka "Distribusi" (di detail PO completed)
2. Lihat list 120 buyer paid
3. Progress: 0/120 sudah diambil
4. Search nama: "Bu Siti"
5. Tap "Centang Sudah Ambil"
   ├─ is_taken = true
   ├─ taken_at = now()
   └─ taken_by = Pak Agus ID
6. Ulangi untuk semua buyer
7. Setelah 120/120 → Tap "Selesai Distribusi"
   └─ distribution_completed_at = now()
8. Sesi ditutup, PO status: completed
```

**Audit trail:**
- Semua aksi tercatat di transaction_logs
- Anti klaim "saya belum ambil tapi sudah dicentang"

---

# 🏪 3. ALUR PENJUAL (SELLER)

## 📍 Persona: Andi (Staff CV Makmur Jaya)

### A. **REGISTRASI & VERIFIKASI SUPPLIER**

```
1. Login → Pilih role "Seller"
2. Buat profil supplier:
   ├─ Nama usaha: CV Makmur Jaya
   ├─ Alamat: Jl Industri No.45 Surabaya
   ├─ Area layanan: Surabaya, Sidoarjo
   ├─ Kontak bisnis: 031-1234567
   └─ Upload dokumen usaha
3. Submit verifikasi
4. Status: pending_verification
5. Admin verifikasi (max 2×24 jam)
   ├─ Approved → Bisa publish offer
   └─ Rejected → Alasan ditampilkan
```

### B. **KELOLA PRODUK & OFFER**

#### 1. Buat Produk

```
Screen: Buat Produk
├─ Nama: "Beras Premium Pulen"
├─ Base unit: Kg
├─ Deskripsi: "Beras premium kualitas terbaik..."
├─ Gambar produk (upload)
└─ Save
```

#### 2. Buat Packaging Variant

```
├─ Variant 1: "5 Kg" (package_quantity: 5)
├─ Variant 2: "10 Kg" (package_quantity: 10)
└─ Variant 3: "25 Kg Sak" (package_quantity: 25)
```

#### 3. Buat Offer

```
Screen: Buat Offer
├─ Produk: Beras Premium Pulen
├─ Minimum order: 500 Kg
├─ Kapasitas: 2000 Kg
├─ Tier harga supplier:
   ├─ Tier 1: Rp10.500/Kg (500-999 Kg)
   └─ Tier 2: Rp10.000/Kg (≥1000 Kg)
├─ Area layanan: PGH-RT03, PGH-RT05
├─ Biaya kirim: Rp200.000
├─ Berlaku sampai: 30 Juli 2026
└─ Submit untuk moderasi
```

**Status offer:**
- `draft` → Belum disubmit
- `pending_moderation` → Menunggu admin
- `active` → Terlihat oleh Inisiator
- `expired` → Melewati masa berlaku

### C. **DASHBOARD SELLER**

```
Bottom Navigation (3 tabs):
├─ Tab 1: Dashboard
├─ Tab 2: Notifikasi
└─ Tab 3: Profil
```

**Tab Dashboard:**

```
├─ Metrics:
│  ├─ Purchase Order: 3
│  └─ Fulfillment: 87%
│
├─ Info Box:
│  "Data Buyer tetap tersembunyi
│   Seller hanya melihat agregat kuantitas,
│   dokumen PO, dan status fulfillment."
│
└─ List Purchase Orders:
   ├─ PO-1001: Beras 500 Kg - submitted
   ├─ PO-1002: Minyak 200L - accepted
   └─ PO-1003: Gula 300 Kg - shipped
```

### D. **RESPON PURCHASE ORDER**

**PO baru masuk (status: submitted):**

```
1. Buka PO-1001
2. Review:
   ├─ Produk: Beras Premium Pulen
   ├─ Quantity: 500 Kg
   ├─ Tier harga: Rp10.500/Kg
   ├─ Subtotal: Rp5.250.000
   ├─ Biaya kirim: Rp200.000
   └─ Total: Rp5.450.000
3. Keputusan (max 12 jam):
   ├─ Tap "Accept" → Status: awaiting_payment
   └─ Tap "Reject" → Wajib isi alasan
      └─ Inisiator terima notifikasi reject
```

**Setelah Inisiator transfer:**

```
1. Cek mutasi rekening: Rp5.450.000 masuk
2. Tap "Konfirmasi Pembayaran"
   └─ Status: paid
3. Siapkan barang
4. Tap "Proses" → Status: processing
5. Upload invoice + surat jalan
6. Tap "Kirim" → Status: shipped
7. Inisiator terima notifikasi
```

### E. **PRIVACY & DATA ACCESS**

**Seller TIDAK BISA melihat:**
- ❌ Nama individual Buyer
- ❌ Nomor WA Buyer
- ❌ Bukti pembayaran Buyer
- ❌ Riwayat transaksi Buyer

**Seller HANYA melihat:**
- ✅ Quantity agregat per varian
- ✅ Alamat pengiriman Inisiator
- ✅ Kontak bisnis Inisiator
- ✅ Dokumen PO (invoice, surat jalan)

---

# 🔐 4. ALUR ADMIN APLIKASI

## 📍 Persona: Operator Platform Grosirun

### A. **LOGIN & AKSES**

```
1. Login dengan akun admin
2. Pilih role "Admin"
3. Akses console admin
```

### B. **DASHBOARD ADMIN**

```
Bottom Navigation (3 tabs):
├─ Tab 1: Admin (Console)
├─ Tab 2: Notifikasi
└─ Tab 3: Profil
```

**Tab Admin Console:**

```
├─ Metrics:
   ├─ Queues: 5
   └─ Audit: 99%
│
├─ Info Box:
   "Moderasi dan audit terpusat
    Fitur admin dipisahkan agar perubahan
    sensitif selalu tercatat."
│
└─ Quick Actions:
   ├─ Verifikasi Supplier
   ├─ Moderasi Offer
   ├─ Kelola Role
   ├─ Suspend User
   └─ Mediasi Dispute
```

### C. **VERIFIKASI SUPPLIER**

```
1. List supplier pending:
   ├─ CV Makmur Jaya - pending 2 jam
   ├─ UD Sumber Rejeki - pending 5 jam
   └─ PT Sembako Jaya - pending 1 hari

2. Tap supplier → Review dokumen:
   ├─ SIUP
   ├─ NPWP
   ├─ Alamat usaha
   └─ Kontak bisnis

3. Keputusan:
   ├─ Tap "Approve" → Supplier aktif
   └─ Tap "Reject" → Wajib isi alasan
      └─ Seller terima notifikasi reject
```

### D. **MODERASI OFFER**

```
1. List offer pending moderation:
   ├─ Beras Premium - CV Makmur Jaya
   └─ Minyak Goreng - UD Sumber Rejeki

2. Review offer:
   ├─ Unit: Kg, Liter, Piece, Pack
   ├─ Tier harga: Logis?
   ├─ Kapasitas: Realistis?
   ├─ Area: Valid?
   ├─ Masa berlaku: Sesuai?
   └─ Konten: Tidak melanggar?

3. Keputusan:
   ├─ Tap "Approve" → Offer active
   └─ Tap "Reject" → Alasan ditampilkan
```

### E. **KELOLA ROLE**

```
1. List users dengan multi-role:
   └─ Pak Agus: [Buyer, Initiator]

2. Grant/Revoke role:
   ├─ Tap user
   ├─ Toggle role
   └─ Confirm

3. Validasi:
   └─ Tidak bisa revoke owner terakhir supplier
```

### F. **SUSPEND USER/SUPPLIER**

```
1. Tap user/supplier
2. Tap "Suspend"
3. Wajib isi:
   ├─ Alasan suspend
   ├─ Tiket insiden
   └─ Re-authentication (2FA)
4. Sistem:
   ├─ Suspend session
   ├─ Catat audit log
   └─ Notifikasi pihak terdampak
```

### G. **MEDIASI DISPUTE**

**Sengketa fulfillment:**

```
1. Inisiator buka dispute (max 1×24 jam setelah terima)
   ├─ Upload foto penerimaan
   ├─ Upload surat jalan
   └─ Deskripsi masalah

2. Admin review:
   ├─ PO details
   ├─ Invoice
   ├─ Surat jalan
   ├─ Foto penerimaan
   └─ Status logs

3. Mediasi:
   ├─ Hubungi Inisiator
   ├─ Hubungi Seller
   └─ Putusan: replacement/refund/none

4. Refund Buyer tetap tanggung jawab Inisiator
   Klaim Inisiator ke Supplier = proses terpisah
```

### H. **AUDIT & MONITORING**

**Admin bisa melihat:**
- ✅ Semua transaction_logs
- ✅ Audit trail (append-only)
- ✅ Security alerts
- ✅ Queue status
- ✅ SLA violations

**Admin TIDAK BISA:**
- ❌ Ubah nominal transaksi tanpa audit
- ❌ Hapus audit log
- ❌ Akses data tanpa jejak

---

# 🔄 5. ALUR END-TO-END (SATU SIKLUS PO)

## Contoh: Patungan Beras Premium

### **Phase 1: Inisiasi (Pak Agus)**

```
1. Pak Agus pilih offer dari CV Makmur Jaya
2. Buat campaign:
   ├─ Target: 1000 Kg
   ├─ Harga buyer: Rp12.000/Kg
   ├─ Deadline: 2 hari
   └─ Lokasi: Rumah Pak RT
3. Publish → Auto-share ke WA grup
```

### **Phase 2: Partisipasi (Bu Siti & warga)**

```
1. Bu Siti lihat campaign di Beranda
2. Tap "Ikut Patungan"
3. Pilih varian 5 Kg
4. Pilih "Tunai"
5. Checkout → Status: Menunggu Bayar
6. Datang ke rumah Pak RT → bayar Rp60.000
7. Pak RT validasi → Status: Lunas
8. Progress: 5/1000 Kg
```

### **Phase 3: Target Tercapai**

```
Setelah 200 buyer ikut (1000 Kg terkumpul):
├─ Status: target_reached
├─ Checkout ditutup
├─ Notifikasi ke semua buyer:
│  "Target tercapai! PO akan diproses"
└─ Pak Agus buat Purchase Order ke seller
```

### **Phase 4: Fulfillment (CV Makmur Jaya)**

```
1. Seller terima PO-1001
2. Accept → awaiting_payment
3. Pak Agus transfer Rp10.200.000
4. Seller konfirmasi → paid
5. Seller proses → processing
6. Upload invoice + surat jalan
7. Seller kirim → shipped
```

### **Phase 5: Distribusi (Pak Agus)**

```
1. Truk tiba di rumah Pak RT
2. Pak Agus buka checklist distribusi
3. Warga datang satu per satu:
   ├─ Bu Siti → centang "Sudah Ambil"
   ├─ Pak Joko → centang "Sudah Ambil"
   └─ ... (120 buyer)
4. Setelah 120/120 → Selesai Distribusi
5. Status PO: completed
6. Siklus selesai!
```

### **Phase 6: Refund (jika PO batal)**

```
Jika target gagal (hanya 600 Kg):
1. Status: expired
2. Pak Agus WAJIB refund manual:
   ├─ 35 buyer sudah paid
   ├─ Total: Rp8.400.000
   └─ Refund 100% dalam 2×24 jam
3. Catat refund di transaction_logs
4. Jika tidak refund → eskalasi RT/RW
```

---

# 📊 6. TABEL PERBANDINGAN ROLE

| Fitur | Buyer | Initiator | Seller | Admin |
|-------|-------|-----------|--------|-------|
| **Lihat campaign** | ✅ | ✅ | ❌ | ✅ |
| **Buat campaign** | ❌ | ✅ | ❌ | ❌ |
| **Ikut patungan** | ✅ | ✅ | ❌ | ❌ |
| **Validasi bayar** | ❌ | ✅ | ❌ | ❌ |
| **Buat PO ke seller** | ❌ | ✅ | ❌ | ❌ |
| **Kelola produk** | ❌ | ❌ | ✅ | ❌ |
| **Buat offer** | ❌ | ❌ | ✅ | ❌ |
| **Respon PO** | ❌ | ❌ | ✅ | ❌ |
| **Verifikasi supplier** | ❌ | ❌ | ❌ | ✅ |
| **Moderasi offer** | ❌ | ❌ | ❌ | ✅ |
| **Suspend user** | ❌ | ❌ | ❌ | ✅ |
| **Mediasi dispute** | ❌ | ❌ | ❌ | ✅ |
| **Lihat audit log** | ❌ | ✅ (own) | ❌ | ✅ (all) |
| **Distribusi checklist** | ❌ | ✅ | ❌ | ❌ |
| **Share ke WA** | ✅ | ✅ | ❌ | ❌ |

---

# 🔐 7. KEAMANAN & PRIVASI

## **Non-Escrow Model**

```
Buyer → Bayar ke Rekening Pribadi Initiator
Initiator → Transfer ke Supplier
Grosirun → HANYA CATAT STATUS (tidak pegang dana)
```

## **UU PDP Compliance**

```
✅ Consent screen wajib
✅ Data tidak dijual
✅ Retensi 90 hari (proof)
✅ Hak hapus akun
✅ Audit log transparan
```

## **Data Privacy**

```
Buyer data:
├─ Seller TIDAK bisa lihat
├─ Hanya Initiator & Admin yang bisa akses
└─ Audit log mencatat setiap akses

Seller data:
├─ Diverifikasi Admin
├─ Moderasi offer
└─ Bisa di-suspend jika melanggar
```

---

# 📞 8. TROUBLESHOOTING & ESKALASI

## **Masalah Umum**

| Masalah | Solusi | Eskalasi |
|---------|--------|----------|
| OTP tidak masuk | Tunggu 60s, kirim ulang | Support/Admin |
| Bukti ditolak blur | Upload ulang foto jelas | - |
| Lupa validasi tunai | Override dengan notes | - |
| PO batal, belum refund | Refund 2×24 jam | RT/RW |
| Seller tidak respon | Reminder 6 jam, Admin 12 jam | Admin |
| Barang tidak sesuai | Buka dispute + foto | Admin mediasi |
| Initiator kabur | Lapor RW, blacklist | Hukum perdata |

## **Timeline Eskalasi**

```
Level 1: Buyer ↔ Initiator (2×24 jam)
    ↓ deadlock
Level 2: Ketua RT (3×24 jam)
    ↓ tidak kooperatif
Level 3: Ketua RW (3×24 jam)
    ↓ nominal >5jt & kabur
Level 4: Hukum Perdata
```

---

# 🎉 KESIMPULAN

Aplikasi mobile Grosirun memiliki **4 role berbeda** dengan alur yang jelas:

1. **Buyer** → Fokus: Ikut patungan, bayar, ambil barang
2. **Initiator** → Fokus: Kelola PO, validasi bayar, distribusi
3. **Seller** → Fokus: Produk, offer, fulfillment PO
4. **Admin** → Fokus: Verifikasi, moderasi, audit, mediasi

## **Keunggulan:**

- ✅ Offline-first (Hive cache)
- ✅ Non-escrow (tidak perlu izin OJK/BI)
- ✅ UU PDP compliant
- ✅ Audit trail transparan
- ✅ Eskalasi bertahap RT/RW
- ✅ APK ringan (<10 MB)
- ✅ Support HP tua (Android 7+, RAM 2GB)

## **Status:**

- ✅ Dokumentasi lengkap
- ✅ Implementasi Flutter siap
- ✅ Backend Laravel API ready
- ✅ Siap untuk integrasi & testing

---

**Dibuat:** 22 Juli 2026  
**Versi:** 1.0  
**Next:** Integrasi dengan backend Laravel API
