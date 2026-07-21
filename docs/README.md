# Indeks Dokumentasi Grosirun

**Tanggal:** 21 Juli 2026  
**Versi:** 3.1  
**Owner:** Product & Engineering  
**Review Cycle:** Setiap release  
**Status Dokumen:** Final  
**Status Implementasi:** Belum Dimulai

---

## Tujuan

Indeks ini adalah titik masuk dokumentasi Grosirun. Gunakan dokumen **Source of Truth** untuk keputusan normatif; dokumen lain tidak boleh mendefinisikan ulang kontrak yang sama.

## Urutan Membaca

### Product dan stakeholder

1. [PRD — kebutuhan, role, dan lifecycle](PRD.md)
2. [Business Analysis — asumsi bisnis dan unit economics](BUSINESS_ANALYSIS.md)
3. [User & Operations Manual — panduan role, FAQ, refund, dan dispute](USER_GUIDE.md)
4. [Proposal Penjual, Pembeli, dan Inisiator](PROPOSAL_PENJUAL_PEMBELI_INISIATOR.md)
5. [Isi Presentasi Grosirun](PRESENTASI_GROSIRUN.md)
6. [Privacy Policy — consent, hak subjek data, dan retensi](PRIVACY_POLICY.md)

### Engineering

1. [Architecture Decision Records](ARCHITECTURE_DECISION_RECORDS.md)
2. [Technical Specification](TECHNICAL_SPEC.md)
3. [API Specification](API_SPEC.md)
4. [Mobile Specification](MOBILE_SPEC.md)
5. [Security](SECURITY.md)
6. [Test Plan](TEST_PLAN.md)

### Development dan operations

1. [Setup Guide](SETUP_GUIDE.md)
2. [Development Guide](DEVELOPMENT_GUIDE.md)
3. [Deployment](DEPLOYMENT.md)
4. [Observability, Performance & Analytics](OBSERVABILITY.md)
5. [Changelog dan Versioning](CHANGELOG.md)

## Source of Truth

| Domain | Sumber normatif | Bagian utama |
| --- | --- | --- |
| Role, persona, scope, campaign lifecycle, PO lifecycle | [PRD](PRD.md) | [Role dan alur perdagangan](PRD.md#45-alur-penawaran-ke-campaign), [failure/refund](PRD.md#83-failure-refund-dan-reservation-matrix) |
| Architecture dan keputusan | [ADR](ARCHITECTURE_DECISION_RECORDS.md) | [Decision index](ARCHITECTURE_DECISION_RECORDS.md#decision-index) |
| Database, ERD, unit, harga, reservation, migration | [Technical Specification](TECHNICAL_SPEC.md) | [Arsitektur data](TECHNICAL_SPEC.md#4-arsitektur-data--database-penawaran-ke-campaign) |
| Endpoint, request/response, error, feature flag | [API Specification](API_SPEC.md) | [Katalog error](API_SPEC.md#14-format-error--error-catalog), [feature flags](API_SPEC.md#12-feature-flags) |
| UI, navigation, state, Cubit, offline, FCM | [Mobile Specification](MOBILE_SPEC.md) | [Screen map](MOBILE_SPEC.md#41-screen-map-canonical-empat-role) |
| Threat model dan authorization | [Security](SECURITY.md) | [RBAC dan cluster scope](SECURITY.md#7-rbac--cluster-scope--pencegahan-idor) |
| Acceptance dan verification | [Test Plan](TEST_PLAN.md) | [Acceptance criteria](TEST_PLAN.md#11-acceptance-criteria--bug-tracking) |
| CI, build, deploy, rollback, DR | [Deployment](DEPLOYMENT.md) | [CI gates](DEPLOYMENT.md#2-ci-quality-gates--build-pipelines) |
| Logs, metrics, performance, analytics | [Observability](OBSERVABILITY.md) | [Telemetry governance](OBSERVABILITY.md#1-telemetry-governance) |
| Coding, Git, PR, contribution | [Development Guide](DEVELOPMENT_GUIDE.md) | [Dokumentasi wajib](DEVELOPMENT_GUIDE.md#10-dokumentasi-wajib) |
| Consent, privacy, retention | [Privacy Policy](PRIVACY_POLICY.md) | [Data yang dikumpulkan](PRIVACY_POLICY.md#2-data-yang-dikumpulkan) |
| Release history dan perubahan keputusan | [Changelog](CHANGELOG.md) | [Decision log](CHANGELOG.md#decision-log) |

> [Proposal stakeholder](PROPOSAL_PENJUAL_PEMBELI_INISIATOR.md) dan [isi presentasi](PRESENTASI_GROSIRUN.md) adalah materi komunikasi dan validasi minat, bukan source of truth requirement atau komitmen komersial.

> Nama anchor mengikuti renderer GitHub. Jika judul bagian berubah, link indeks dan traceability matrix wajib diperbarui pada PR yang sama.

## Traceability Matrix

| Requirement | PRD | API | Database/Service | Mobile UI/State | Verification |
| --- | --- | --- | --- | --- | --- |
| Empat role dan active role | [§4.5](PRD.md#45-alur-penawaran-ke-campaign) | [Auth active role](API_SPEC.md#310-put-authactive-role) | [Role schema](TECHNICAL_SPEC.md#44-aturan-role-dan-organisasi) | [Role navigation](MOBILE_SPEC.md#2-role-screen-map-dan-navigation) | [Role tests](TEST_PLAN.md#93-pengujian-penawaran-ke-campaign-dan-empat-role) |
| Seller membuat offer, Inisiator membuat campaign | [§4.5](PRD.md#45-alur-penawaran-ke-campaign) | [Supply API](API_SPEC.md#5-seller-supplier-offer-purchase-order--fulfillment-dispute) | [Offer rules](TECHNICAL_SPEC.md#45-aturan-penawaran-dan-kapasitas) | [Create campaign](MOBILE_SPEC.md#createcampaignscreen) | [Offer/campaign tests](TEST_PLAN.md#93-pengujian-penawaran-ke-campaign-dan-empat-role) |
| Shared capacity dan reservation | [Failure matrix](PRD.md#83-failure-refund-dan-reservation-matrix) | [Failure/reservation](API_SPEC.md#524-kegagalan-refund-dan-reservation) | [Capacity invariant](TECHNICAL_SPEC.md#423-penawaran-tier-area-dan-kapasitas) | [Conflict state](MOBILE_SPEC.md#5-state-loading-empty-error--skeleton) | [Concurrency tests](TEST_PLAN.md#94-matrix-test-unit-lifecycle-failure-dan-admin) |
| Campaign lifecycle | [Main flow](PRD.md#5-alur-pengguna--flowchart-bisnis-bpmn) | [Campaign API](API_SPEC.md#6-campaign-po) | [Lifecycle](TECHNICAL_SPEC.md#47-unit-variant-harga-dan-campaign-lifecycle) | [CampaignCubit](MOBILE_SPEC.md#7-campaigncubit-polling--etag--cache--cluster) | [CL tests](TEST_PLAN.md#94-matrix-test-unit-lifecycle-failure-dan-admin) |
| Purchase-order lifecycle | [Main flow](PRD.md#45-alur-penawaran-ke-campaign) | [PO API](API_SPEC.md#513-post-campaignsidpurchase-orders) | [PO state machine](TECHNICAL_SPEC.md#48-state-machine-purchase-order) | [PurchaseOrderCubit](MOBILE_SPEC.md#95-rolecontextcubit-sellercubit-dan-purchaseordercubit) | [PO tests](TEST_PLAN.md#94-matrix-test-unit-lifecycle-failure-dan-admin) |
| Seller tidak dapat melihat data Buyer | [Privacy boundary](PRD.md#454-privasi-penjual) | [Seller response rules](API_SPEC.md#514-get-sellerpurchase-orders-dan-get-purchase-ordersuuid) | [Resource policy](TECHNICAL_SPEC.md#64-arsitektur-penawaran-ke-campaign-dan-multi-role) | [Seller workspace](MOBILE_SPEC.md#41-screen-map-canonical-empat-role) | [Privacy serialization](TEST_PLAN.md#94-matrix-test-unit-lifecycle-failure-dan-admin) |
| Fulfillment dispute dan refund | [Failure matrix](PRD.md#83-failure-refund-dan-reservation-matrix) | [Dispute API](API_SPEC.md#521-post-purchase-ordersuuiddisputes) | [Documents/log](TECHNICAL_SPEC.md#424-purchase-order-dan-dokumen) | [Dispute UI](MOBILE_SPEC.md#41-screen-map-canonical-empat-role) | [Failure tests](TEST_PLAN.md#94-matrix-test-unit-lifecycle-failure-dan-admin) |
| Admin verification dan override | [Admin role](PRD.md#451-peran-dan-batas-kewenangan) | [Admin API](API_SPEC.md#17-admin-application-operations) | [Audit rules](TECHNICAL_SPEC.md#425-purchase-order-status-log) | [Admin workspace](MOBILE_SPEC.md#adminapplicationdashboardscreen) | [Admin tests](TEST_PLAN.md#94-matrix-test-unit-lifecycle-failure-dan-admin) |
| CI, release, rollback, DR | [NFR/roadmap](PRD.md#7-fase-rilis--roadmap-visual) | [Health/version](API_SPEC.md#14-health--version) | [Environment](TECHNICAL_SPEC.md#16-environment-versioning--etag) | [Build target](MOBILE_SPEC.md#7-accessibility-dan-performance) | [Smoke/acceptance](TEST_PLAN.md#10-smoke-test-checklist) |

## Glossary Global Indonesia–Inggris

| Istilah canonical | Padanan/arti | Aturan penggunaan |
| --- | --- | --- |
| Pembeli | Buyer | Role `buyer`; warga yang membuat order |
| Inisiator | Initiator | Role `initiator`; koordinator campaign dan distribusi |
| Penjual | Seller | Role `seller`; manusia yang login dan mewakili Supplier |
| Admin aplikasi | Application Admin | Role `admin`; operator platform, bukan Inisiator |
| Supplier | Pemasok/organisasi usaha | Organisasi; bukan user dan bukan role |
| Supplier member | Anggota Supplier | Relasi Seller dengan Supplier: owner/sales/warehouse |
| Penawaran | Offer/Supplier Offer | Harga, tier, packaging, kapasitas, area, validity dari Supplier |
| Campaign/PO warga | Group-buying campaign | Dibuat Inisiator dari penawaran aktif |
| Purchase Order | PO Supplier | Pesanan agregat Inisiator kepada Supplier; berbeda dari campaign |
| Base unit | Satuan dasar | kg/liter/piece/pack; basis kapasitas, target, dan harga |
| Packaging variant | Varian kemasan | Kelipatan base unit, misalnya sak 5 kg |
| Snapshot | Salinan immutable | Data offer saat campaign/PO dibuat |
| Reservation | Reservasi kapasitas | Quantity yang dicadangkan campaign aktif |
| Committed quantity | Kuantitas terkomit | Reservation yang menjadi kewajiban setelah PO diterima |
| Fulfillment | Pemenuhan | Proses Supplier dari pembayaran sampai pengiriman |
| Distribution | Distribusi | Pembagian barang oleh Inisiator kepada Pembeli |
| Active role | Role aktif | Konteks UI/API saat user memiliki beberapa role |
| Non-escrow | Tidak menahan dana | Pembayaran Buyer langsung ke Inisiator; Grosirun mencatat status |
| Idempotency-Key | Kunci idempotensi | Mencegah mutation ganda saat retry |
| ETag/If-Match | Versi resource | Optimistic concurrency dan stale-data protection |
| RTO | Recovery Time Objective | Target waktu pemulihan layanan |
| RPO | Recovery Point Objective | Target maksimum kehilangan data |

## Aturan Perubahan Dokumentasi

1. Perubahan requirement memperbarui PRD dan traceability matrix.
2. Perubahan keputusan arsitektur menambah/mengubah ADR dan Decision Log Changelog.
3. Perubahan API memperbarui API spec, error catalog, mobile mapping, dan test.
4. Perubahan database memperbarui Technical Specification, migration plan, dan test.
5. Perubahan user flow memperbarui Mobile Specification dan User Guide.
6. Perubahan metric/event memperbarui Observability serta privacy review.
7. PR tidak boleh memperkenalkan sumber kebenaran kedua untuk domain yang sama.
