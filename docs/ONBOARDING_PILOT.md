# PANDUAN ONBOARDING PILOT - Grosirun V3.1

**Untuk:** Pak Agus (Initiator/Ketua RT) & Warga RT03  
**Tanggal:** 20 Juli 2026  
**Bahasa:** Indonesia Sederhana  
**Versi:** 3.1  
**Status:** Production Ready

---

## Daftar Isi

1. Pendahuluan & Konteks Bisnis
2. Untuk Pak Agus (Initiator) - Langkah Lengkap
3. Untuk Bu Siti (Buyer) - Langkah Simpel
4. FAQ Singkat Pilot
5. Troubleshooting Ibu-Ibu
6. Kontak Darurat

---

## 1. Pendahuluan & Konteks Bisnis

### 1.1 Selamat Datang di Grosirun!

Grosirun adalah aplikasi patungan belanja sembako khusus warga satu RT. Dengan berpatungan, kita bisa membeli dalam jumlah besar (misal 1 ton beras) sehingga harganya jauh lebih murah.

**Keuntungan untuk Warga:**
| Komponen | Nilai |
|----------|-------|
| Harga grosir untuk warga | **Rp12.000/Kg** |
| Harga eceran di warung | **Rp14.000/Kg** |
| **Hemat** | **Rp2.000/Kg (14%)** |

Jika satu keluarga membeli 20 Kg, hemat **Rp40.000** dalam sekali belanja. Jika sebulan dua kali, hemat **Rp80.000/bulan**!

**Keuntungan untuk Pak Agus (Initiator):**
| Komponen | Nilai |
|----------|-------|
| Margin bruto per PO | Rp1.050.000 |
| Platform fee + PPN | Rp93.240 |
| **Laba bersih per PO** | **Rp956.760** |

### 1.2 Yang Perlu Diingat

- Grosirun **bukan toko online** dan **bukan bank**
- Uang pembayaran (tunai/QRIS) **langsung ke rekening pribadi Pak Agus**, bukan ke Grosirun
- Jika ada masalah, **refund manual 2×24 jam** oleh Pak Agus
- Jika tidak selesai, **eskalasi ke RT/RW**

---

## 2. Untuk Pak Agus (Initiator) - Ketua RT03 Permata Hijau

### 2.1 A. Install APK (5 menit)

1. Buka WA grup RT03, klik link unduhan APK:

   - Firebase App Distribution: `https://appdistribution.firebase.google.com/...`
   - Atau Google Drive: `https://drive.google.com/.../app-arm64-v8a-release.apk`

2. Download file APK (ukuran **~7.8 MB** - sangat kecil dan ringan).

3. Jika HP memperingatkan "File mungkin berbahaya", tap **Tetap Download**.

4. Setelah selesai, tap file APK → HP akan tanya "Install dari sumber tidak dikenal?" → tap **Izinkan** → tap **Install**.

5. Buka aplikasi Grosirun (logo hijau).

6. Izinkan notifikasi: tap **Izinkan** (penting untuk menerima notifikasi pesanan baru).

> **Jika HP tidak bisa install:** Pastikan Android versi 7.0 ke atas. Cek di Pengaturan → Tentang Ponsel → Versi Android. Jika masih Android 6, gunakan HP anak atau keluarga.

---

### 2.2 B. Login OTP + Consent UU PDP + ToS Non-Escrow (3 menit)

1. Buka aplikasi Grosirun.

2. Masukkan nomor WA Anda (contoh: **081234567890** - pakai 08, bukan +62).

3. Centang checkbox **"Saya setuju data WA disimpan untuk PO RT sesuai UU PDP No.27/2022"**. Tap link **Kebijakan Privasi** untuk membaca sekilas.

4. Tap **Kirim OTP**.

5. Tunggu WA atau SMS masuk berisi **4 digit kode OTP** (contoh: `1234`).

   - Jika pilot lokal (uji coba), cek grup WA developer: OTP ada di log.

6. Masukkan 4 digit kode → tap **Verifikasi**.

7. Muncul layar **Syarat Layanan Non-Escrow**:

   - Scroll baca: "Grosirun hanya catat status, dana langsung ke Initiator, bukan penjamin, refund manual 2×24 jam"
   - Centang **"Saya mengerti dan setuju"**
   - Tap **Setuju Lanjut**

8. Masukkan nama lengkap: **Pak Agus Setiawan**.

9. Masuk Beranda, lihat chip cluster **PGH-RT03 Permata Hijau RT03**.

> **Jika OTP tidak masuk:**
>
> - Tunggu 60 detik, tap **Kirim Ulang**
> - Cek sinyal 4G
> - Jika masih tidak, hubungi grup darurat developer, minta kode test `1234` (khusus pilot lokal)
> - Jika produksi, pastikan WA Gateway Fonnte aktif (cek dashboard Fonnte)

---

### 2.3 C. Buat Campaign PO Beras (3 menit)

1. Di Beranda, tap tombol **+ Buat PO** (hijau, pojok kanan bawah).

2. Isi form dengan data berikut:

| Field                      | Isian                                      | Keterangan                                 |
| -------------------------- | ------------------------------------------ | ------------------------------------------ |
| Nama Barang                | **Beras Mahkota Premium**                  | Wajib                                      |
| Deskripsi                  | **Pulen langsung dari pabrik Makmur Jaya** | Opsional                                   |
| Target Kg                  | **1000**                                   | Wajib, harus kelipatan varian terkecil (5) |
| Total Harga Modal Supplier | **10000000** (10 juta)                     | Wajib, untuk rekap                         |
| Tenggat Waktu              | Pilih **2 hari dari sekarang**             | Minimal 24 jam                             |
| Lokasi Pengambilan         | **Rumah Pak RT Jl Mawar 12**               | Opsional                                   |
| Foto                       | Tap **Pilih Foto**, ambil dari galeri      | Otomatis kompres 800×800 70%               |

3. Tambahkan Varian:

| Varian   | Ukuran | Harga     | Kuota   |
| -------- | ------ | --------- | ------- |
| Varian 1 | 5 Kg   | Rp60.000  | 100 sak |
| Varian 2 | 10 Kg  | Rp115.000 | 50 sak  |

> **Cek total Kg:** 5×100 + 10×50 = 500 + 500 = 1000 Kg = target 1000 Kg ✅

4. Tap **Publikasikan PO**.

5. PO muncul di Beranda Anda dan semua warga cluster PGH-RT03.

---

### 2.4 D. Share ke WA Grup RT (1 menit)

1. Buka detail PO Beras yang baru dibuat.

2. Tap tombol **Bagikan ke WA** (hijau).

3. WA terbuka dengan teks otomatis:

   > "Yuk patungan Beras Mahkota Premium! Harga cuma Rp12.000/Kg. Klik link: grosirun://campaign/beras-mahkota-premium-abc123"

4. Pilih grup **RT03** → tap **Kirim**.

5. Warga klik link → langsung buka detail PO di aplikasi (deep link).

---

### 2.5 E. Validasi Pembayaran Tunai & QRIS (Setiap hari cek 10 menit)

1. Buka aplikasi → tap **Dashboard Admin** (bottom nav Admin).

2. Ada 3 Tab:

| Tab                   | Isi                                      |
| --------------------- | ---------------------------------------- |
| **Menunggu Bayar**    | Warga sudah pesan tapi belum bayar tunai |
| **Lunas Tunai**       | Warga sudah bayar tunai & divalidasi     |
| **QRIS Menunggu Cek** | Warga sudah upload bukti transfer QRIS   |

#### Validasi Tunai:

1. Warga Bu Siti datang bayar tunai Rp60.000 fisik.

2. Cari nama **Bu Siti** di tab Menunggu Bayar (pakai search).

3. Tap tombol **Validasi Tunai** (hijau besar, 48dp).

4. Status jadi **Lunas**, progress bar naik 5Kg, Bu Siti dapat notifikasi "Pembayaran Lunas".

#### Validasi QRIS:

1. Buka tab **QRIS Menunggu Cek**.

2. Lihat foto bukti (tap foto zoom, cek nominal Rp60.000 + tanggal transfer).

3. Jika jelas → tap **Validasi**.

4. Jika blur → tap **Tolak** + isi alasan "Foto blur nominal tidak terlihat".
   - Sistem kirim notifikasi ke Bu Siti: "Bukti ditolak, upload ulang"

#### Undo dalam 5 Menit:

Jika salah klik Validasi padahal belum terima uang:

1. Dalam 5 menit: tap **Batalkan Validasi** di list Lunas.
2. Jika lewat 5 menit: gunakan **Validasi Paksa Override** + isi alasan "Salah klik, sudah cek mutasi BCA jam 10:05"

#### Batch Validate (V3.1):

Centang checkbox 5 pesanan sekaligus → tap **Validasi 5 Terpilih** → validasi massal dengan dialog partial success.

> **Penting Sebelum Distribusi:** Pastikan tab Menunggu Bayar kosong (semua sudah validasi atau batal). Jika masih ada pending, validasi dulu atau hubungi warga.

---

### 2.6 F. Perpanjangan Tenggat & Batal PO Jika Gagal Target

**H-1 Deadline:**

- Sistem otomatis kirim notifikasi: "PO Hampir Gagal! Beras Mahkota baru 60%, sisa 24 jam"

**Jika progres 60% di jam terakhir:**

1. Buka detail PO → tap **Perpanjang +24 Jam** (maksimal 2 kali).
2. Warga dapat notifikasi: "Tenggat diperpanjang 24 jam"

**Jika setelah perpanjang tetap gagal:**

1. Tap **Batalkan PO** → konfirmasi.
2. Status menjadi **Expired**, semua pending jadi cancelled.
3. Notifikasi ke semua buyer: "PO Beras Mahkota dibatalkan, refund 2×24 jam hubungi Initiator"
4. **Wajib refund manual tunai 100% dalam 2×24 jam** ke buyer yang sudah paid (lihat list di Rekap).
5. Catat manual kwitansi refund.

> **Detail SOP Refund:** Lihat **DISPUTE_SOP.md**

---

### 2.7 G. Auto-Rekap Supplier (Saat target 100%)

1. Saat progress 100%, status otomatis **Completed** + notifikasi "PO Selesai!"

2. Buka detail PO → tap **Rekap Supplier**.

3. Lihat data rekap:

| Komponen          | Nilai                               |
| ----------------- | ----------------------------------- |
| Total Kg          | 1000 Kg                             |
| Rincian           | 5Kg × 100 sak = 500Kg (Rp6.000.000) |
|                   | 10Kg × 50 sak = 500Kg (Rp5.750.000) |
| Total buyer lunas | 120 orang                           |
| Total revenue     | Rp11.750.000                        |

4. Tap **Kirim ke Supplier** → buka WA dengan teks rekap otomatis → kirim ke kontak **Pabrik Makmur Jaya**.

5. Atau tap **Share PDF** → share file PDF via WA atau email.

---

### 2.8 H. Checklist Distribusi Saat Truk Tiba

1. Truk beras datang, buka **Distribusi** (di detail PO Completed).

2. Lihat list 120 buyer paid + search + progress `0/120` sudah diambil.

3. Warga datang ambil:

   - Cari nama **Bu Siti** → tap **Centang Sudah Ambil**
   - Sistem catat: `is_taken = true`, `taken_at = now`, `taken_by = initiator id`

4. Jika warga ambil via tetangga: tetap centang nama yang ambil, catat manual di buku.

5. Setelah semua 120 dicentang → tap **Selesai Distribusi**.

   - `distribution_completed_at` tercatat, sesi ditutup.

6. Jika ada klaim "Saya belum ambil tapi sudah dicentang":
   - Ada audit log `taken_by` + timestamp → anti klaim hilang.

**Selesai 1 siklus PO!** Ulangi buat PO baru untuk beras, gula, atau minyak.

---

## 3. Untuk Bu Siti (Buyer) - Ibu-Ibu RT (Langkah Simpel 2 Menit)

### 3.1 A. Install APK

1. Sama seperti Pak Agus: download APK 7.8MB dari link WA grup RT.
2. Install, izinkan notifikasi.

### 3.2 B. Login OTP

1. Masukkan nomor WA (08...), centang **Setuju Privasi UU PDP**.
2. Kirim OTP, masukkan 4 digit.
3. Centang **Setuju Syarat Non-Escrow**.
4. Masukkan nama **Bu Siti Rahayu**.

### 3.3 C. Lihat PO

1. Beranda ada Card besar foto beras.
2. Progress: "Terkumpul 750/1000 Kg", sisa waktu.
3. Tap Card untuk lihat detail.

### 3.4 D. Ikut Patungan

1. Lihat detail: foto besar, progress truck, ticker "Bu Nengsih baru pesan 5Kg 2 menit lalu".
2. Pilih varian:
   - Tap **+** atau **-** untuk atur jumlah.
   - Contoh: Varian 5Kg tap + jadi 1, total Rp60.000 otomatis.
   - **Tidak bisa ketik angka manual!** Hanya tombol + dan - (mencegah salah input).

### 3.5 E. Pilih Pembayaran

**Tunai:**

1. Pilih Tunai → Pesan → status **Menunggu Bayar**.
2. Datang ke rumah Pak RT bayar tunai Rp60.000.
3. Tunggu Pak RT validasi di app → dapat notif Lunas.

**QRIS:**

1. Pilih QRIS → lihat QR Code Pak RT.
2. Scan via mBanking transfer Rp60.000.
3. Screenshot bukti → tap **Upload Bukti** (pilih dari galeri, otomatis kompres 70%).
4. Status **Menunggu Validasi QRIS**.
5. Tunggu Pak RT cek & validasi → dapat notif Lunas atau Ditolak (jika blur).

### 3.6 F. Jika Salah Pilih Varian

- Selama PO masih buka (belum 100%):
  1. Buka **Pesanan Saya** → tap pesanan.
  2. Tap **Batalkan Partisipasi** → pesan ulang varian benar.
- Jika PO sudah terkunci 100%: tidak bisa batal, hubungi Pak RT untuk transfer pesanan ke tetangga.

### 3.7 G. Jika Bukti Ditolak Blur

1. Dapat notif: "Bukti ditolak: Foto blur".
2. Buka **Pesanan Saya** → Upload ulang foto jelas.

### 3.8 H. Share ke Tetangga

1. Di detail PO tap **Bagikan ke WA**.
2. Share ke grup arisan → tetangga ikut patungan, target cepat 100%.

### 3.9 I. Ambil Barang

1. Saat truk tiba, dapat notif WA dari Pak RT: "Barang datang ambil di rumah RT".
2. Datang, ambil 5Kg, Pak RT centang di app checklist Anda sudah ambil.

### 3.10 J. Selesai Hemat!

**Hemat Rp12.000/Kg vs eceran Rp14.000/Kg = Rp2.000/Kg (14%)!**

---

## 4. FAQ Singkat Pilot

| Pertanyaan                                  | Jawaban                                                                                                          |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **OTP tidak masuk?**                        | Tunggu 60s tap Kirim Ulang, cek sinyal. Pilot lokal: minta kode test 1234 di grup dev.                           |
| **Beda Tunai vs QRIS?**                     | Tunai: bayar fisik ke Pak RT. QRIS: transfer ke rekening pribadi Pak RT + upload bukti.                          |
| **Tidak punya HP Android?**                 | Pak RT bisa catatkan pesanan manual via fitur "Atas Nama Warga".                                                 |
| **APK tidak bisa install?**                 | Android minimal 7.0. Cek Pengaturan → Tentang Ponsel → Versi Android. Izinkan Install dari sumber tidak dikenal. |
| **Kuota varian habis?**                     | Tombol + dan - jadi abu-abu. Pilih varian lain atau tunggu PO baru.                                              |
| **Sudah bayar tapi status masih Menunggu?** | Hubungi Pak RT, mungkin lupa validasi. Tunjukkan kwitansi manual.                                                |

> **FAQ Lengkap (20 pertanyaan):** Lihat **FAQ_END_USER.md**

---

## 5. Troubleshooting Ibu-Ibu (Bahasa Simpel)

| Masalah                                  | Solusi Simpel                                                                                                    |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Aplikasi crash HP tua RAM 2GB**        | Update APK terbaru via link Firebase. Clear cache aplikasi di Pengaturan → Restart HP.                           |
| **Gambar tidak muncul**                  | Cek sinyal 4G. Tarik ke bawah untuk refresh. Jika masih tidak muncul, cek banner kuning "Kamu offline".          |
| **Upload bukti gagal ukuran kegedean**   | Aplikasi otomatis kompres 70%. Jika masih >2MB, pilih foto lain atau screenshot ulang lebih kecil. Maksimal 2MB. |
| **Tombol tidak bisa ditekan**            | Tombol abu-abu? Kuota habis, pilih varian lain. Tombol hijau tapi tidak respon? Tutup aplikasi, buka lagi.       |
| **Tidak dapat notifikasi pesanan lunas** | Cek Pengaturan HP → Aplikasi → Grosirun → Notifikasi → Izinkan. Cek internet on.                                 |
| **Lupa bayar padahal sudah pesan**       | Buka Pesanan Saya → ada list Menunggu Bayar. Datang ke Pak RT bayar.                                             |

---

## 6. Kontak Darurat Pilot

| Keperluan                            | Kontak                                                                          |
| ------------------------------------ | ------------------------------------------------------------------------------- |
| **Developer Backend**                | backend@grosirun.id (jam kerja 09-17 WIB)                                       |
| **Developer Mobile**                 | mobile@grosirun.id                                                              |
| **Grup WA Darurat Pilot RT03**       | [Link Grup WA]                                                                  |
| **Pelaporan Bug**                    | Buat Issue di GitHub atau WA ke Dev dengan: screenshot + langkah + HP type      |
| **Jika aplikasi error total >1 jam** | Pak RT pakai fallback manual Excel/Google Form sementara (file di Google Drive) |

### SOP Darurat

Jika API Down / 5xx:

1. Aplikasi tampil: "Koneksi terputus, coba lagi".
2. Data pesanan terakhir masih ada di cache offline Hive.
3. Pending order disimpan lokal → akan sync saat online.
4. Pak RT Excel manual sementara.

---

**Selamat Pilot! Semangat gotong royong hemat 15-20%!** 🎉🙌

---

_Cetak panduan ini 1 lembar A4 untuk Pak Agus._

_Versi Pilot 1 RT Permata Hijau RT03, 20 Juli 2026._
