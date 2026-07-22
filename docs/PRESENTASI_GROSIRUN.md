# Isi Presentasi Grosirun

**Format:** Naskah slide untuk PowerPoint/Google Slides  
**Audiens:** Penjual, Pembeli, Inisiator, dan calon mitra pilot  
**Durasi:** 12–15 menit presentasi + 15 menit diskusi  
**Tanggal:** 21 Juli 2026  
**Versi:** 1.0  
**Owner:** Product & Partnerships  
**Review Cycle:** Setiap release  
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)  
**Status Dokumen:** Final  
**Status Implementasi:** Belum Dimulai

> **Aturan akurasi:** Jangan menyampaikan target, asumsi, contoh, atau proyeksi sebagai hasil aktual. Aplikasi belum dibangun. Nilai harga, penghematan, volume, performa, dan jadwal pilot harus dikonfirmasi sebelum presentasi eksternal.

---

## Petunjuk Penggunaan

- Setiap bagian `Slide` menjadi satu halaman presentasi.
- Bagian **Isi slide** ditampilkan pada layar.
- Bagian **Catatan presenter** tidak perlu ditampilkan.
- Gunakan screenshot hanya setelah aplikasi tersedia; sebelum itu gunakan diagram sederhana dengan label **Konsep**.
- Gunakan istilah Penjual untuk user yang login dan Supplier untuk organisasi usaha.
- Gunakan logo, warna, dan kontak resmi hanya setelah disetujui Product Owner. Lihat [Brand Guidelines](BRAND_GUIDELINES.md) untuk filosofi, palet, tipografi, kepribadian, dan aturan penggunaan brand.

---

# Slide 1 — Sampul

## Isi slide

**Grosirun**  
Belanja bersama lebih hemat, penjualan lebih terencana, koordinasi lebih rapi.

**Proposal untuk:**

- Penjual
- Pembeli
- Inisiator

**Status:** Validasi konsep dan persiapan pilot

## Catatan presenter

> Grosirun sedang disiapkan sebagai alat bantu belanja bersama berbasis komunitas. Hari ini kami ingin menjelaskan konsep, mendengar kebutuhan Bapak/Ibu, dan menilai apakah alur ini layak dilanjutkan menjadi pilot. Aplikasi belum dibangun, jadi sesi ini bukan peluncuran produk dan bukan janji hasil komersial.

---

# Slide 2 — Masalah yang Dihadapi Bersama

## Isi slide

### Penjual

- Permintaan komunitas sulit diprediksi.
- Harga dan minimum order dijelaskan berulang kali.
- Rekap berubah atau tersebar di chat.
- Invoice, surat jalan, dan status pengiriman tidak berada dalam satu alur.

### Pembeli

- Informasi harga, target, dan status kurang transparan.
- Status pembayaran sering harus ditanyakan ulang.
- Jadwal pengambilan tidak selalu jelas.

### Inisiator

- Pesanan dan pembayaran direkap manual.
- Risiko salah jumlah, harga, atau pesanan ganda.
- Purchase order dan distribusi harus dibuat ulang.

## Catatan presenter

> Masalah utama bukan hanya harga. Masalahnya adalah koordinasi tiga pihak. Penjual membutuhkan permintaan yang rapi, Pembeli membutuhkan transparansi, dan Inisiator membutuhkan alat untuk mengurangi rekap manual.

---

# Slide 3 — Solusi yang Diusulkan

## Isi slide

```text
Penjual membuat penawaran
        ↓
Inisiator memilih penawaran
        ↓
Inisiator membuat campaign komunitas
        ↓
Pembeli bergabung
        ↓
Inisiator membuat purchase order
        ↓
Penjual memproses dan mengirim barang
        ↓
Inisiator mendistribusikan kepada Pembeli
```

**Satu alur untuk penawaran, campaign, purchase order, fulfillment, dan distribusi.**

## Catatan presenter

> Penjual tidak membuat campaign komunitas. Penjual mengendalikan produk, kemasan, harga, kapasitas, wilayah, dan masa berlaku penawaran. Inisiator memilih penawaran yang sesuai lalu membuat campaign untuk komunitasnya.

---

# Slide 4 — Empat Peran yang Berbeda

## Isi slide

| Peran | Tanggung jawab utama |
| --- | --- |
| **Pembeli** | Memilih kebutuhan, membuat order, membayar Inisiator, mengambil barang |
| **Inisiator** | Memilih offer, membuat campaign, memvalidasi pembayaran, membuat PO, mendistribusikan |
| **Penjual** | Mengelola produk/offer, menerima PO, menyiapkan dan mengirim barang |
| **Admin aplikasi** | Verifikasi, moderasi, keamanan, audit, dan mediasi dispute |

**Penjual = orang yang login**  
**Supplier = organisasi usaha yang diwakili Penjual**

## Catatan presenter

> Pemisahan peran penting agar kewenangan tidak bercampur. Inisiator bukan Admin aplikasi. Seller adalah user, sedangkan Supplier adalah toko, distributor, koperasi, pabrik, atau badan usaha.

---

# Slide 5 — Apa yang Dibuat Penjual?

## Isi slide

Penjual membuat penawaran yang berisi:

- Produk dan satuan dasar.
- Pilihan kemasan.
- Minimum pembelian.
- Kapasitas tersedia.
- Tier harga berdasarkan kuantitas.
- Area layanan.
- Biaya pengiriman.
- Masa berlaku.

### Contoh konsep

```text
Produk: Beras Premium
Satuan dasar: kg
Kemasan: 5 kg dan 10 kg
Minimum order: 500 kg
Tier harga: ditentukan Penjual
Area: ditentukan Penjual
```

## Catatan presenter

> Angka harga tidak ditampilkan pada contoh ini karena harga nyata harus berasal dari calon Penjual dan dikonfirmasi pada saat pilot. Sistem dirancang agar satu kapasitas dasar dapat digunakan oleh beberapa pilihan kemasan tanpa menghitung stok dua kali.

---

# Slide 6 — Apa yang Dibuat Inisiator?

## Isi slide

Setelah memilih penawaran aktif, Inisiator menentukan:

- Target pembelian komunitas.
- Harga kepada Pembeli.
- Pilihan kemasan yang tersedia.
- Deadline.
- Lokasi distribusi.
- Informasi campaign.

Sistem menyimpan **snapshot penawaran** agar perubahan offer berikutnya tidak mengubah campaign yang sedang berjalan.

## Catatan presenter

> Inisiator tidak memasukkan harga modal Supplier secara manual. Sistem mengambil harga Supplier dari penawaran yang dipilih. Inisiator hanya menentukan komponen yang menjadi kewenangannya dan melihat ringkasan margin sebelum campaign diterbitkan.

---

# Slide 7 — Pengalaman Pembeli

## Isi slide

Pembeli dapat:

1. Melihat campaign dalam komunitasnya.
2. Memeriksa produk, kemasan, harga, target, progress, dan deadline.
3. Memilih jumlah.
4. Melihat total sebelum konfirmasi.
5. Membayar langsung kepada Inisiator.
6. Mengunggah bukti jika diperlukan.
7. Memantau status.
8. Mengambil barang pada lokasi distribusi.

## Catatan presenter

> Pembeli tidak bertransaksi langsung dengan Penjual dalam alur ini. Penjual menerima purchase order agregat dari Inisiator. Dengan demikian Penjual tidak perlu memproses puluhan pesanan individual.

---

# Slide 8 — Nilai untuk Penjual

## Isi slide

### Mengapa Penjual dapat tertarik?

- Satu purchase order agregat.
- Harga, minimum quantity, dan kapasitas dikendalikan Penjual.
- Area dan masa berlaku penawaran jelas.
- Owner, sales, dan warehouse dapat memiliki akses berbeda.
- Invoice, surat jalan, dan status fulfillment tertelusur.
- Hubungan operasional dilakukan dengan Inisiator.
- Data pribadi individual Pembeli tidak dibuka kepada Penjual.

## Catatan presenter

> Grosirun tidak menjanjikan volume penjualan tertentu. Nilai yang ditawarkan adalah proses permintaan yang lebih terstruktur dan peluang hubungan berulang dengan komunitas melalui Inisiator.

---

# Slide 9 — Nilai untuk Pembeli

## Isi slide

### Mengapa Pembeli dapat tertarik?

- Akses ke pembelian kolektif.
- Harga dan total terlihat sebelum memesan.
- Target, progress, deadline, dan lokasi lebih jelas.
- Status pembayaran dan pesanan dapat dipantau.
- Riwayat order lebih rapi.
- Informasi pengambilan tersedia.
- Ada jalur komplain dan eskalasi.

## Catatan presenter

> Tidak ada jaminan persentase penghematan. Harga akhir bergantung pada penawaran, tier, target, biaya pengiriman, dan keputusan campaign. Pembeli selalu harus melihat harga sebelum memesan.

---

# Slide 10 — Nilai untuk Inisiator

## Isi slide

### Mengapa Inisiator dapat tertarik?

- Tidak mengulang data Supplier secara manual.
- Rekap pesanan dan pembayaran dalam satu tempat.
- Validasi pembayaran lebih tertelusur.
- Purchase order dibuat dari agregasi campaign.
- Dokumen Supplier tersimpan dalam alur yang sama.
- Konfirmasi barang dan discrepancy dapat dicatat.
- Checklist distribusi dan refund tracking tersedia.
- Tindakan sensitif memiliki audit trail.

## Catatan presenter

> Tujuannya bukan menghilangkan tanggung jawab Inisiator, tetapi mengurangi beban administratif dan membuat tanggung jawab tersebut lebih mudah ditelusuri.

---

# Slide 11 — Purchase Order dan Fulfillment

## Isi slide

```text
Campaign mencapai syarat
→ Inisiator mengirim PO
→ Penjual accept/reject
→ Inisiator membayar Supplier
→ Penjual konfirmasi pembayaran
→ Processing
→ Invoice dan surat jalan
→ Shipped
→ Inisiator memeriksa barang
→ Delivered atau dispute
```

### SLA konsep pilot

- Respons PO Penjual: maksimal 12 jam.
- Konfirmasi pembayaran: maksimal 1×24 jam.
- Discrepancy dilaporkan: maksimal 1×24 jam setelah penerimaan.

## Catatan presenter

> SLA di slide adalah rancangan awal untuk pilot, bukan SLA komersial final. Nilainya harus disetujui bersama Penjual dan Inisiator sebelum transaksi nyata.

---

# Slide 12 — Pembayaran dan Non-Escrow

## Isi slide

**Grosirun tidak menahan dana Pembeli.**

```text
Pembeli → membayar langsung → Inisiator
Inisiator → membayar sesuai PO → Supplier
Grosirun → mencatat status dan bukti
```

### Konsekuensi

- Inisiator bertanggung jawab menjaga dana Pembeli.
- Jika campaign dibatalkan setelah pembayaran, Inisiator menjalankan refund sesuai SOP.
- Klaim Inisiator kepada Supplier diproses terpisah.
- Grosirun menyediakan catatan untuk operasional dan mediasi.

## Catatan presenter

> Hindari mengatakan Grosirun menjamin dana atau menjadi escrow. Posisi hukum dan perjanjian para pihak harus ditinjau sebelum pilot transaksi nyata.

---

# Slide 13 — Privasi dan Batas Akses

## Isi slide

### Penjual menerima

- Item dan quantity agregat.
- Purchase order.
- Kontak bisnis Inisiator.
- Alamat pengiriman.
- Dokumen fulfillment yang relevan.

### Penjual tidak menerima

- Nama individual Pembeli.
- Nomor WhatsApp Pembeli.
- Bukti pembayaran Pembeli.
- Riwayat transaksi Pembeli.

**Akses berdasarkan role, kepemilikan, cluster, dan Supplier membership.**

## Catatan presenter

> Pembatasan data adalah bagian inti desain, bukan fitur tambahan. Seller hanya menerima data minimum yang diperlukan untuk menyiapkan dan mengirim barang.

---

# Slide 14 — Jika Terjadi Masalah

## Isi slide

| Masalah | Penanganan awal |
| --- | --- |
| Target tidak tercapai | Campaign berakhir; refund sesuai SOP jika ada pembayaran |
| Penjual menolak PO | Pilih alternatif atau batalkan dan lakukan refund |
| Penjual tidak merespons | Reminder dan eskalasi Admin |
| Barang kurang/rusak | Fulfillment dispute dengan evidence |
| Bukti pembayaran bermasalah | Verifikasi ulang oleh pihak berwenang |
| Distribusi belum lengkap | Campaign belum boleh completed |

## Catatan presenter

> Setiap kasus memiliki status, actor, timestamp, alasan, dan evidence. Namun sistem tidak menggantikan tanggung jawab hukum atau kewajiban para pihak.

---

# Slide 15 — Rencana Pilot

## Isi slide

### Ruang lingkup yang disarankan

- 1 Supplier terverifikasi.
- 1–2 Seller.
- 1 Inisiator utama dan 1 cadangan.
- 1 komunitas atau cluster.
- 1–3 produk sederhana.
- 1 siklus sampai distribusi.

### Tahapan

```text
Validasi kebutuhan
→ kesepakatan SOP
→ dry run tanpa transaksi nyata
→ pilot terbatas
→ evaluasi bersama
```

## Catatan presenter

> Pilot baru dijalankan setelah aplikasi tersedia, privacy notice dan ToS ditinjau, harga serta SLA disepakati, dan jalur eskalasi ditetapkan.

---

# Slide 16 — Apa yang Akan Diukur?

## Isi slide

**Belum ada hasil aktual.** Pilot dirancang untuk mengukur:

- Waktu respons Penjual.
- PO acceptance rate.
- Ketepatan waktu pengiriman.
- Fulfillment discrepancy.
- Kesalahan rekap.
- Waktu administrasi Inisiator.
- Kejelasan pengalaman Pembeli.
- Waktu penyelesaian komplain.
- Minat menggunakan kembali.

## Catatan presenter

> Jangan menampilkan angka baseline atau target yang belum disepakati. Semua hasil harus berasal dari artefak pilot dan disetujui dalam laporan evaluasi.

---

# Slide 17 — Yang Belum Kami Klaim

## Isi slide

Grosirun belum mengklaim:

- Aplikasi sudah tersedia.
- Penghematan dengan persentase tertentu.
- Volume penjualan tertentu.
- Campaign selalu mencapai target.
- Ukuran APK atau performa aktual.
- Izin atau kesimpulan hukum final.
- Hasil pilot yang belum dilakukan.

**Status implementasi: Belum Dimulai.**

## Catatan presenter

> Slide ini menjaga ekspektasi. Proposal bertujuan memvalidasi masalah, alur, minat, dan syarat pilot secara jujur.

---

# Slide 18 — Ajakan Bergabung

## Isi slide

### Kami mengundang

- **Penjual:** memvalidasi offer, packaging, kapasitas, PO, dan fulfillment.
- **Pembeli:** memvalidasi informasi campaign, order, pembayaran, dan pengambilan.
- **Inisiator:** memvalidasi rekap, campaign, validasi pembayaran, PO, serta distribusi.

### Langkah berikutnya

```text
Sesi diskusi 30 menit
→ wawancara kebutuhan
→ konfirmasi minat
→ penyusunan SOP pilot
```

**Kontak:** [Isi kontak resmi setelah disetujui]

## Catatan presenter

> Tutup dengan ajakan yang spesifik: meminta waktu wawancara, bukan langsung meminta komitmen transaksi. Catat peran, masalah utama, dan kesediaan mengikuti dry run atau pilot.

---

# Slide 19 — Pertanyaan Diskusi

## Isi slide

### Untuk Penjual

- Bagaimana minimum order, tier harga, kapasitas, dan pengiriman dikelola saat ini?
- Siapa yang menangani sales, warehouse, invoice, dan surat jalan?

### Untuk Pembeli

- Informasi apa yang wajib terlihat sebelum memesan?
- Kendala terbesar pada pembelian bersama saat ini?

### Untuk Inisiator

- Berapa banyak waktu yang digunakan untuk rekap dan distribusi?
- Bagaimana pembayaran, refund, serta komplain dicatat?

## Catatan presenter

> Prioritaskan mendengar. Jangan membela solusi jika peserta menyampaikan bahwa alurnya tidak cocok. Masukan tersebut adalah hasil utama tahap validasi.

---

# Slide 20 — Penutup

## Isi slide

**Grosirun**

```text
Penawaran lebih terstruktur
Campaign lebih transparan
Purchase order lebih rapi
Distribusi lebih tertelusur
```

**Terima kasih.**  
Mari diskusikan kebutuhan Bapak/Ibu.

## Catatan presenter

> Rangkum kembali nilai untuk ketiga pihak dan pastikan peserta memahami bahwa aplikasi belum tersedia. Sepakati langkah lanjut, PIC, serta waktu diskusi berikutnya.

---

# Lampiran A — Versi Presentasi Singkat 5 Slide

## Slide A1 — Masalah

Pesanan komunitas, pembayaran, purchase order, dan distribusi masih tersebar serta direkap manual.

## Slide A2 — Solusi

```text
Penjual membuat offer
→ Inisiator membuat campaign
→ Pembeli bergabung
→ PO agregat
→ fulfillment dan distribusi
```

## Slide A3 — Nilai

- Penjual: permintaan agregat dan fulfillment tertelusur.
- Pembeli: harga serta status lebih transparan.
- Inisiator: rekap dan distribusi lebih rapi.

## Slide A4 — Batas Penting

- Non-escrow.
- Tidak menjamin penghematan atau volume.
- Data Pembeli tidak dibuka kepada Penjual.
- Status implementasi belum dimulai.

## Slide A5 — Ajakan

Wawancara kebutuhan → SOP → dry run → pilot terbatas setelah aplikasi tersedia.

---

# Lampiran B — Checklist Sebelum Presentasi Eksternal

- [ ] Nama dan logo sudah disetujui.
- [ ] Kontak resmi telah diisi.
- [ ] Status implementasi masih benar.
- [ ] Tidak ada screenshot fiktif yang menyerupai produk jadi.
- [ ] Harga dan SLA contoh diberi label konsep/asumsi.
- [ ] Tidak ada klaim penghematan atau volume tanpa bukti.
- [ ] Privacy, non-escrow, refund, dan tanggung jawab dijelaskan.
- [ ] Audiens dan tujuan pertemuan ditentukan.
- [ ] Form minat menggunakan data minimum.
- [ ] Catatan masukan dan tindak lanjut telah disiapkan.

---

# Referensi Internal

- [Proposal stakeholder](PROPOSAL_PENJUAL_PEMBELI_INISIATOR.md)
- [PRD dan alur utama](PRD.md#45-alur-penawaran-ke-campaign)
- [User & Operations Manual](USER_GUIDE.md)
- [Privacy Policy](PRIVACY_POLICY.md)
- [Indeks Dokumentasi dan Glossary](README.md)
