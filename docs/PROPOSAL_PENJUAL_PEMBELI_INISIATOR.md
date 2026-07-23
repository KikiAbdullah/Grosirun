# Proposal Grosirun untuk Penjual, Pembeli, dan Inisiator

**Tagline:** Belanja bersama lebih hemat, penjualan lebih pasti, koordinasi lebih rapi.  
**Tanggal:** 21 Juli 2026  
**Versi:** 1.0  
**Owner:** Product & Partnerships  
**Review Cycle:** Setiap release  
**Global Glossary:** [Indeks Dokumentasi](README.md#glossary-global-indonesiainggris)  
**Status Dokumen:** Final  
**Status Implementasi:** Flutter Ready for Integration | Backend Not Started

> Dokumen ini adalah materi proposal dan komunikasi pilot. Fitur, jadwal, harga, penghematan, serta hasil aktual harus dikonfirmasi kembali sebelum disampaikan sebagai komitmen kepada calon mitra atau pengguna.

---

## Daftar Isi

1. Ringkasan Proposal
2. Masalah yang Diselesaikan
3. Cara Kerja Grosirun
4. Proposal untuk Penjual
5. Proposal untuk Pembeli
6. Proposal untuk Inisiator
7. Nilai Bersama dan Batas Tanggung Jawab
8. Rencana Pilot
9. Indikator Keberhasilan
10. FAQ Singkat
11. Materi Presentasi 5 Menit
12. Template Pesan WhatsApp
13. Form Minat dan Langkah Berikutnya

---

## 1. Ringkasan Proposal

Grosirun adalah alat bantu belanja bersama berbasis komunitas. Penjual menerbitkan penawaran grosir, Inisiator memilih penawaran dan membuka campaign untuk komunitasnya, lalu Pembeli bergabung sesuai kebutuhan.

Grosirun dirancang agar:

- **Penjual** menerima permintaan yang lebih terencana dan teragregasi.
- **Pembeli** memperoleh akses ke harga kolektif dengan informasi yang transparan.
- **Inisiator** tidak lagi mengandalkan catatan dan rekap manual yang mudah tercecer.

Alur utamanya:

```text
Penjual membuat penawaran
→ Inisiator memilih penawaran
→ Inisiator membuka campaign
→ Pembeli bergabung
→ Inisiator membuat purchase order
→ Penjual memproses dan mengirim barang
→ Inisiator membagikan barang kepada Pembeli
```

Grosirun menggunakan prinsip **non-escrow**: aplikasi tidak menahan dana Pembeli. Pembayaran Pembeli dilakukan langsung kepada Inisiator, sedangkan pembayaran Supplier dilakukan oleh Inisiator sesuai kesepakatan purchase order.

---

## 2. Masalah yang Diselesaikan

### Bagi Penjual

- Permintaan datang satu per satu dan sulit diprediksi.
- Banyak waktu habis untuk menjawab pertanyaan harga dan minimum order yang sama.
- Rekap pesanan komunitas sering berubah atau tidak terstruktur.
- Invoice, surat jalan, dan status pengiriman tersebar di berbagai percakapan.

### Bagi Pembeli

- Harga eceran lebih tinggi daripada harga pembelian kolektif.
- Informasi target, harga, deadline, dan status pesanan kurang transparan.
- Bukti pembayaran dan status validasi sering harus ditanyakan berulang kali.
- Pembeli tidak mengetahui kapan barang diproses, tiba, dan dapat diambil.

### Bagi Inisiator

- Pesanan dicatat manual melalui chat atau spreadsheet.
- Risiko salah jumlah, salah harga, atau pesanan ganda.
- Validasi pembayaran memakan waktu.
- Rekap ke Penjual dan daftar distribusi harus dibuat ulang.
- Komplain serta refund sulit ditelusuri jika bukti tersebar.

---

## 3. Cara Kerja Grosirun

### Tahap 1 — Penawaran

Penjual memasukkan:

- Produk dan satuan dasar.
- Pilihan kemasan.
- Minimum pembelian.
- Kapasitas tersedia.
- Tier harga berdasarkan kuantitas.
- Area layanan.
- Biaya dan ketentuan pengiriman.
- Masa berlaku penawaran.

### Tahap 2 — Campaign komunitas

Inisiator:

1. Melihat penawaran aktif yang melayani wilayahnya.
2. Memilih produk dan kemasan.
3. Menentukan target pembelian komunitas.
4. Menentukan harga kepada Pembeli secara transparan.
5. Menentukan deadline dan lokasi distribusi.
6. Menerbitkan campaign.

Informasi Penjual disimpan sebagai snapshot agar perubahan penawaran berikutnya tidak mengubah campaign yang sedang berjalan.

### Tahap 3 — Pemesanan Pembeli

Pembeli:

1. Membuka campaign komunitasnya.
2. Memilih kemasan dan jumlah.
3. Melihat total harga sebelum konfirmasi.
4. Membayar langsung kepada Inisiator.
5. Mengunggah bukti jika metode pembayaran membutuhkannya.
6. Memantau status sampai barang dapat diambil.

### Tahap 4 — Purchase order dan pemenuhan

Setelah syarat campaign tercapai:

1. Inisiator mengirim purchase order kepada Penjual.
2. Penjual menerima atau menolak dengan alasan.
3. Inisiator membayar Supplier sesuai kesepakatan.
4. Penjual mengunggah invoice dan surat jalan.
5. Penjual memperbarui status pemrosesan dan pengiriman.
6. Inisiator memeriksa barang yang diterima.
7. Barang dibagikan kepada Pembeli.

---

## 4. Proposal untuk Penjual

### 4.1 Nilai yang Ditawarkan

#### Permintaan lebih teragregasi

Pesanan komunitas dikumpulkan menjadi satu purchase order. Penjual tidak perlu memproses puluhan percakapan Pembeli secara terpisah.

#### Harga dan minimum order lebih jelas

Penjual dapat menetapkan tier harga, minimum quantity, pilihan kemasan, kapasitas, area layanan, dan masa berlaku dalam satu penawaran.

#### Operasional lebih rapi

Purchase order, invoice, surat jalan, bukti pembayaran Inisiator, dan status pengiriman berada pada alur yang dapat ditelusuri.

#### Hubungan langsung dengan koordinator

Penjual berkomunikasi dan bertransaksi dengan Inisiator sebagai koordinator komunitas, bukan dengan setiap Pembeli.

#### Perlindungan data Pembeli

Penjual hanya menerima data agregat yang diperlukan untuk pemenuhan. Nama, nomor WhatsApp, dan bukti pembayaran individual Pembeli tidak diberikan.

### 4.2 Fitur Utama untuk Penjual

- Profil Supplier dan proses verifikasi.
- Anggota Supplier: owner, sales, dan warehouse.
- Katalog produk.
- Kemasan dan tier harga.
- Kapasitas serta area layanan.
- Daftar purchase order.
- Accept/reject dengan alasan.
- Invoice dan surat jalan.
- Status paid, processing, shipped, dan delivered.
- Riwayat status serta dokumen.
- Fulfillment dispute berbasis bukti.

### 4.3 Komitmen yang Diharapkan dari Penjual

- Memberikan informasi harga, kapasitas, dan masa berlaku yang benar.
- Merespons purchase order sesuai SLA pilot.
- Tidak mengubah syarat campaign yang sudah tersimpan sebagai snapshot.
- Mengunggah invoice dan surat jalan yang valid.
- Menjaga kualitas, kuantitas, dan jadwal pengiriman.
- Tidak meminta data pribadi individual Pembeli.
- Menanggapi discrepancy atau dispute dengan bukti.

### 4.4 Contoh Manfaat

Misalnya satu komunitas membutuhkan total 1.000 kg beras. Penjual dapat menerima satu purchase order agregat, bukan 50–100 pesanan individual. Nilai komersial aktual tetap mengikuti penawaran, kapasitas, dan hasil pilot; proposal ini tidak menjanjikan volume tertentu.

### 4.5 Ajakan untuk Penjual

> Jadilah mitra pemasok awal Grosirun. Tawarkan produk grosir kepada komunitas terorganisasi, kelola purchase order dalam satu alur, dan bangun hubungan berulang dengan Inisiator lokal.

---

## 5. Proposal untuk Pembeli

### 5.1 Nilai yang Ditawarkan

#### Akses harga kolektif

Pembeli dapat ikut dalam pembelian bersama tanpa harus mencari Supplier dan mengumpulkan minimum order sendiri.

#### Informasi transparan

Sebelum memesan, Pembeli dapat melihat:

- Produk dan kemasan.
- Harga per kemasan.
- Target campaign.
- Progress.
- Deadline.
- Lokasi distribusi.
- Inisiator yang bertanggung jawab.

#### Pesanan lebih mudah dipantau

Status pesanan, pembayaran, dan pengambilan dapat dilihat tanpa terus menanyakan rekap melalui chat.

#### Bukti dan riwayat lebih rapi

Pesanan dan bukti pembayaran memiliki status yang dapat ditelusuri. Jika terjadi masalah, Pembeli memiliki referensi order dan mekanisme eskalasi.

### 5.2 Fitur Utama untuk Pembeli

- Login menggunakan OTP.
- Campaign sesuai komunitas atau cluster.
- Pilihan kemasan dan jumlah.
- Perhitungan total otomatis.
- Order history.
- Upload bukti pembayaran.
- Notifikasi status.
- Informasi pengambilan barang.
- Checklist barang sudah diambil.
- FAQ, komplain, dan eskalasi.
- Hak akses, koreksi, dan penghapusan data sesuai kebijakan privasi.

### 5.3 Hal yang Perlu Dipahami Pembeli

- Grosirun bukan bank dan tidak menahan dana.
- Pembayaran dilakukan langsung kepada Inisiator.
- Harga kolektif bergantung pada penawaran, target, dan kuantitas aktual.
- Campaign dapat berakhir atau dibatalkan jika syarat tidak tercapai.
- Jika campaign dibatalkan setelah pembayaran, Inisiator menjalankan refund sesuai SOP.
- Pembeli wajib memeriksa harga, deadline, lokasi, dan Inisiator sebelum memesan.

### 5.4 Ajakan untuk Pembeli

> Bergabunglah dengan campaign komunitas, pilih kebutuhan Anda, dan nikmati proses belanja bersama yang lebih transparan serta lebih mudah dipantau.

---

## 6. Proposal untuk Inisiator

### 6.1 Nilai yang Ditawarkan

#### Mengurangi rekap manual

Pesanan, jumlah, pembayaran, dan distribusi dicatat dalam satu alur. Inisiator tidak harus menyalin pesan satu per satu.

#### Memilih penawaran secara terstruktur

Inisiator dapat membandingkan penawaran aktif berdasarkan:

- Harga.
- Minimum quantity.
- Kapasitas.
- Kemasan.
- Area layanan.
- Biaya pengiriman.
- Masa berlaku.

#### Membuat campaign lebih cepat

Data Supplier tidak dimasukkan ulang. Inisiator memilih penawaran, target, harga Pembeli, deadline, kemasan, dan lokasi distribusi.

#### Purchase order otomatis dari rekap

Ketika campaign memenuhi syarat, item agregat dapat menjadi purchase order tanpa membuat rekap baru.

#### Distribusi dan komplain lebih tertelusur

Checklist pengambilan, status pembayaran, invoice, surat jalan, dan evidence dispute berada dalam riwayat yang sama.

### 6.2 Fitur Utama untuk Inisiator

- Marketplace penawaran Supplier.
- Campaign berbasis penawaran.
- Snapshot harga dan syarat Supplier.
- Dashboard progress campaign.
- Validasi pembayaran.
- Purchase order agregat.
- Bukti pembayaran ke Supplier.
- Konfirmasi barang diterima.
- Fulfillment dispute.
- Rekap dan distribusi.
- Refund tracking.
- Audit tindakan sensitif.

### 6.3 Tanggung Jawab Inisiator

- Memilih penawaran dan Supplier dengan cermat.
- Menjelaskan harga, margin, deadline, serta lokasi secara transparan.
- Menjaga dana yang dibayar langsung oleh Pembeli.
- Memvalidasi pembayaran secara akurat.
- Membayar Supplier sesuai purchase order.
- Memeriksa kuantitas dan kualitas barang.
- Membagikan barang dan mencatat pengambilan.
- Melakukan refund kepada Pembeli ketika diwajibkan SOP.
- Menjaga data serta bukti transaksi.

### 6.4 Ajakan untuk Inisiator

> Jadilah penggerak belanja bersama di komunitas Anda. Grosirun membantu mengurangi pekerjaan rekap, menyederhanakan purchase order, dan membuat proses pembayaran serta distribusi lebih tertelusur.

---

## 7. Nilai Bersama dan Batas Tanggung Jawab

| Pihak | Memberikan | Menerima |
| --- | --- | --- |
| Penjual | Penawaran, kapasitas, kualitas, invoice, pengiriman | Purchase order agregat dan hubungan dengan Inisiator |
| Inisiator | Koordinasi, validasi, pembayaran Supplier, distribusi, refund | Alat rekap, offer marketplace, PO, dan audit trail |
| Pembeli | Pesanan, pembayaran, ketepatan pengambilan | Akses campaign, transparansi harga/status, dan riwayat |
| Grosirun | Sistem pencatatan, workflow, notification, dan audit | Platform fee jika disepakati dalam model bisnis final |

### Batas penting

- Grosirun tidak menjamin target campaign selalu tercapai.
- Grosirun tidak menjamin penghematan dalam persentase tertentu.
- Grosirun tidak menjamin volume penjualan tertentu kepada Penjual.
- Grosirun tidak menahan dana Pembeli.
- Tanggung jawab kualitas dan pemenuhan barang berada pada Supplier sesuai purchase order.
- Tanggung jawab dana Pembeli dan refund awal berada pada Inisiator sesuai SOP non-escrow.
- Grosirun membantu menyediakan catatan dan evidence untuk mediasi, bukan menggantikan kewajiban hukum para pihak.

---

## 8. Rencana Pilot

### 8.1 Tujuan

Menguji apakah alur penawaran-ke-campaign dapat:

- Memudahkan Penjual menerima pesanan agregat.
- Memudahkan Inisiator mengelola campaign dan distribusi.
- Memberikan pengalaman yang jelas kepada Pembeli.
- Mengurangi kesalahan rekap dan status yang tidak diketahui.

### 8.2 Ruang Lingkup yang Disarankan

- Satu Supplier terverifikasi.
- Satu atau dua Seller dari Supplier tersebut.
- Satu Inisiator utama dan satu cadangan.
- Satu komunitas atau cluster.
- Satu sampai tiga produk sederhana.
- Satu siklus campaign sampai distribusi.
- Dukungan manual dari tim Grosirun selama pilot.

### 8.3 Tahapan

| Tahap | Kegiatan | Output |
| --- | --- | --- |
| Persiapan | Verifikasi pihak, produk, harga, area, SOP | Data pilot disetujui |
| Simulasi | Dry run offer, campaign, PO, fulfillment | Temuan sebelum transaksi nyata |
| Pelaksanaan | Campaign nyata dengan batas yang disepakati | Data operasional pilot |
| Evaluasi | Wawancara dan review metric | Keputusan perbaikan/lanjut |

### 8.4 Persyaratan Sebelum Pilot

- Aplikasi dan environment pilot tersedia.
- Privacy notice dan ToS ditinjau.
- Kontak eskalasi ditetapkan.
- Harga, kapasitas, refund, dan fulfillment SLA disepakati tertulis.
- Data pribadi nyata tidak digunakan dalam dry run.
- Semua pihak memahami bahwa hasil dan penghematan belum dijamin.

---

## 9. Indikator Keberhasilan

Semua nilai baseline diisi setelah pilot; belum ada hasil aktual.

| Indikator | Cara ukur | Baseline/target pilot |
| --- | --- | --- |
| Seller response time | Waktu submitted → decision | Disepakati sebelum pilot |
| PO acceptance rate | Accepted / submitted | Belum diukur |
| On-time shipment | Shipment sesuai SLA | Belum diukur |
| Fulfillment discrepancy | PO bermasalah / delivered | Belum diukur |
| Kesalahan rekap | Koreksi order/quantity | Belum diukur |
| Waktu administrasi Inisiator | Waktu per campaign | Belum diukur |
| Campaign conversion | Buyer order / viewer | Belum diukur |
| Repeat intention | Survei tiga pihak | Belum diukur |
| Complaint resolution time | Open → resolved | Belum diukur |

---

## 10. FAQ Singkat

### Apakah Penjual harus berkomunikasi dengan semua Pembeli?

Tidak. Penjual menerima purchase order agregat dan berkoordinasi dengan Inisiator.

### Apakah Penjual dapat melihat nomor Pembeli?

Tidak. Seller hanya menerima informasi agregat dan data Inisiator yang diperlukan untuk fulfillment.

### Siapa yang membuat campaign?

Inisiator membuat campaign dari penawaran aktif yang dibuat Seller.

### Siapa yang menerima pembayaran Pembeli?

Pembayaran dilakukan langsung kepada Inisiator. Grosirun tidak menahan dana.

### Siapa yang membayar Supplier?

Inisiator membayar Supplier sesuai purchase order dan kesepakatan para pihak.

### Bagaimana jika target tidak tercapai?

Campaign dapat berakhir atau dibatalkan sesuai aturan. Jika Pembeli sudah membayar, Inisiator menjalankan refund sesuai SOP.

### Bagaimana jika barang kurang atau rusak?

Inisiator membuka fulfillment dispute dengan bukti. Seller merespons, dan Admin aplikasi dapat memediasi sesuai alur yang ditetapkan.

### Apakah harga pasti lebih murah?

Tidak ada jaminan persentase tertentu. Harga bergantung pada penawaran, tier, target, biaya pengiriman, dan keputusan campaign. Pembeli melihat harga sebelum memesan.

### Apakah aplikasi sudah tersedia?

Belum. Status implementasi saat proposal ini dibuat adalah **Belum Dimulai**. Proposal ini digunakan untuk validasi minat dan persiapan pilot.

---

## 11. Materi Presentasi 5 Menit

### Menit 1 — Masalah

> Belanja kolektif sering dilakukan melalui chat. Pesanan berubah, pembayaran sulit dipantau, rekap ke Penjual dibuat ulang, dan distribusi memakan waktu.

### Menit 2 — Solusi

> Grosirun menghubungkan penawaran Penjual, campaign Inisiator, serta pesanan Pembeli dalam satu alur yang tertelusur.

### Menit 3 — Manfaat

> Penjual menerima purchase order agregat, Pembeli melihat harga dan status dengan jelas, sedangkan Inisiator mengurangi pekerjaan rekap manual.

### Menit 4 — Cara kerja

> Seller membuat offer, Inisiator membuat campaign, Pembeli bergabung, Inisiator mengirim PO, Seller memenuhi pesanan, dan Inisiator mendistribusikan barang.

### Menit 5 — Ajakan

> Kami mengundang Bapak/Ibu menjadi calon mitra pilot untuk membantu memvalidasi alur, kebutuhan fitur, SLA, dan manfaat sebelum aplikasi dibangun serta digunakan secara lebih luas.

---

## 12. Template Pesan WhatsApp

### 12.1 Untuk calon Penjual

> Halo Bapak/Ibu [Nama], kami sedang menyiapkan Grosirun, alat bantu belanja bersama untuk komunitas. Penjual dapat membuat penawaran grosir, menerima satu purchase order agregat dari Inisiator, serta mengelola invoice dan pengiriman tanpa menangani pesanan setiap warga satu per satu. Saat ini aplikasi belum dibangun dan kami sedang memvalidasi kebutuhan calon mitra. Apakah Bapak/Ibu bersedia mengikuti sesi penjelasan singkat dan memberi masukan untuk pilot?

### 12.2 Untuk calon Pembeli

> Halo Bapak/Ibu, kami sedang menyiapkan Grosirun untuk membantu warga mengikuti belanja bersama dengan informasi harga, target, deadline, status pembayaran, dan jadwal pengambilan yang lebih jelas. Pembayaran tetap langsung kepada Inisiator dan aplikasi tidak menahan dana. Saat ini kami sedang mengumpulkan minat serta masukan sebelum aplikasi dibangun. Apakah Bapak/Ibu tertarik mengikuti uji coba ketika sudah tersedia?

### 12.3 Untuk calon Inisiator

> Halo Bapak/Ibu [Nama], kami sedang menyiapkan Grosirun untuk membantu Inisiator memilih penawaran Supplier, membuka campaign, merekap pesanan, memvalidasi pembayaran, membuat purchase order, dan mencatat distribusi dalam satu alur. Tujuannya mengurangi pekerjaan manual melalui chat dan spreadsheet. Aplikasi belum dibangun; kami ingin memvalidasi kebutuhan dan mengajak Bapak/Ibu menjadi calon Inisiator pilot. Apakah bersedia mengikuti sesi diskusi singkat?

### 12.4 Pesan tindak lanjut

> Terima kasih atas minat Bapak/Ibu. Tahap berikutnya adalah sesi 30 menit untuk membahas alur saat ini, kendala utama, fitur penting, serta syarat pilot. Partisipasi pada sesi validasi belum merupakan kontrak atau komitmen transaksi.

---

## 13. Form Minat dan Langkah Berikutnya

### Data yang dikumpulkan pada tahap validasi

Kumpulkan data minimum dan hanya dengan persetujuan:

- Nama.
- Peran yang diminati: Penjual, Pembeli, atau Inisiator.
- Nomor kontak.
- Kota/area.
- Jenis produk atau kebutuhan.
- Kendala utama saat ini.
- Kesediaan mengikuti wawancara atau pilot.

Jangan meminta OTP, password, nomor rekening, NPWP, KTP, atau dokumen usaha melalui formulir minat awal.

### Pertanyaan untuk Penjual

1. Produk, unit, kemasan, dan minimum order apa yang tersedia?
2. Bagaimana tier harga ditentukan?
3. Berapa kapasitas dan area pengiriman?
4. Berapa SLA menerima PO dan mengirim barang?
5. Siapa yang mengelola sales, warehouse, invoice, dan surat jalan?
6. Kendala terbesar dalam pesanan komunitas saat ini?

### Pertanyaan untuk Pembeli

1. Produk apa yang paling sering dibeli bersama?
2. Informasi apa yang harus terlihat sebelum memesan?
3. Metode pembayaran yang paling nyaman?
4. Kendala terbesar pada sistem chat/manual saat ini?
5. Bagaimana lokasi dan waktu pengambilan yang ideal?

### Pertanyaan untuk Inisiator

1. Bagaimana proses mengumpulkan dan merekap pesanan saat ini?
2. Berapa lama waktu administrasi per campaign?
3. Bagaimana pembayaran dan refund dicatat?
4. Bagaimana memilih Supplier dan mengirim rekap?
5. Bagaimana barang diterima dan didistribusikan?
6. Fitur apa yang wajib tersedia sebelum pilot?

### Langkah berikutnya

```text
Kirim proposal
→ sesi penjelasan 30 menit
→ wawancara kebutuhan
→ konfirmasi minat
→ susun ruang lingkup dan SOP pilot
→ dry run
→ pilot terbatas
→ evaluasi bersama
```

---

## Referensi Internal

- [PRD — role dan alur utama](PRD.md#45-alur-penawaran-ke-campaign)
- [Business Analysis](BUSINESS_ANALYSIS.md)
- [User & Operations Manual](USER_GUIDE.md)
- [Privacy Policy](PRIVACY_POLICY.md)
- [Indeks Dokumentasi dan Glossary](README.md)
