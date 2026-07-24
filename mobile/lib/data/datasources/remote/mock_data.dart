import '../../models/campaign_model.dart';
import '../../models/dispute_model.dart';
import '../../models/notification_model.dart';
import '../../models/order_model.dart';
import '../../models/purchase_order_model.dart';
import '../../models/seller_product_model.dart';
import '../../models/supplier_model.dart';
import '../../models/supplier_offer_model.dart';
import '../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class MockData {
  MockData._();

  static const UserModel buyer = UserModel(
    id: 1,
    name: 'Bu Siti Rahayu',
    phoneNumber: '081234567890',
    clusterId: 1,
    clusterName: AppConstants.defaultClusterName,
    roles: [UserRole.buyer, UserRole.initiator, UserRole.seller],
    activeRole: UserRole.buyer,
    consentGiven: false,
    tosAccepted: false,
  );

  static const UserModel initiator = UserModel(
    id: 2,
    name: 'Pak Agus Setiawan',
    phoneNumber: '081987654321',
    clusterId: 1,
    clusterName: AppConstants.defaultClusterName,
    roles: [UserRole.buyer, UserRole.initiator],
    activeRole: UserRole.initiator,
    consentGiven: true,
    tosAccepted: true,
  );

  static const UserModel seller = UserModel(
    id: 3,
    name: 'Andi dari Makmur Jaya',
    phoneNumber: '08111222333',
    roles: [UserRole.seller],
    activeRole: UserRole.seller,
    consentGiven: true,
    tosAccepted: true,
  );

  static const UserModel admin = UserModel(
    id: 4,
    name: 'Admin Grosirun',
    phoneNumber: '089900000001',
    roles: [UserRole.admin],
    activeRole: UserRole.admin,
    consentGiven: true,
    tosAccepted: true,
  );

  static UserModel authenticatedUser({
    String? activeRole,
    bool consentGiven = false,
    bool tosAccepted = false,
  }) {
    return buyer.copyWith(
      activeRole: activeRole ?? UserRole.buyer,
      consentGiven: consentGiven,
      tosAccepted: tosAccepted,
      roles: const [
        UserRole.buyer,
        UserRole.initiator,
        UserRole.seller,
        UserRole.admin,
      ],
    );
  }

  static List<CampaignModel> get campaigns => [
        CampaignModel(
          id: 1,
          title: 'Beras Premium Pulen',
          description:
              'Beras premium kualitas terbaik langsung dari pabrik Makmur Jaya. Pulen, wangi, dan bersih.',
          status: CampaignStatus.active,
          clusterId: 1,
          clusterName: AppConstants.defaultClusterName,
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          unit: 'kg',
          targetQuantity: 500,
          currentQuantity: 320,
          buyerUnitPrice: 12000,
          supplierUnitPrice: 10500,
          deadline: DateTime.now().add(const Duration(days: 3)),
          locationDistribution: 'Balai RT03, Jalan Permata No.10',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          variants: const [
            CampaignVariantModel(
              id: 1,
              name: '5 Kg',
              quantityPerVariant: 5,
              maxQuantity: 50,
              soldQuantity: 30,
            ),
            CampaignVariantModel(
              id: 2,
              name: '10 Kg',
              quantityPerVariant: 10,
              maxQuantity: 30,
              soldQuantity: 20,
            ),
            CampaignVariantModel(
              id: 3,
              name: '25 Kg (Sak)',
              quantityPerVariant: 25,
              maxQuantity: 10,
              soldQuantity: 6,
            ),
          ],
        ),
        CampaignModel(
          id: 2,
          title: 'Minyak Goreng 2L',
          description: 'Minyak goreng kemasan 2 liter. Stok terbatas.',
          status: CampaignStatus.active,
          clusterId: 1,
          clusterName: AppConstants.defaultClusterName,
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          unit: 'pcs',
          targetQuantity: 200,
          currentQuantity: 145,
          buyerUnitPrice: 32000,
          supplierUnitPrice: 28000,
          deadline: DateTime.now().add(const Duration(days: 5)),
          locationDistribution: 'Balai RT03, Jalan Permata No.10',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          variants: const [
            CampaignVariantModel(
              id: 4,
              name: '1 pcs (2L)',
              quantityPerVariant: 1,
              maxQuantity: 100,
              soldQuantity: 70,
            ),
            CampaignVariantModel(
              id: 5,
              name: '1 Dus (6 pcs)',
              quantityPerVariant: 6,
              maxQuantity: 20,
              soldQuantity: 12,
            ),
          ],
        ),
        CampaignModel(
          id: 3,
          title: 'Telur Ayam Negeri',
          description: 'Telur ayam segar pilihan, ukuran sedang-besar.',
          status: CampaignStatus.active,
          clusterId: 1,
          clusterName: AppConstants.defaultClusterName,
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          unit: 'butir',
          targetQuantity: 1000,
          currentQuantity: 780,
          buyerUnitPrice: 2800,
          supplierUnitPrice: 2400,
          deadline: DateTime.now().add(const Duration(days: 2)),
          locationDistribution: 'Balai RT03, Jalan Permata No.10',
          createdAt: DateTime.now().subtract(const Duration(hours: 18)),
          variants: const [
            CampaignVariantModel(
              id: 6,
              name: '10 Butir',
              quantityPerVariant: 10,
              maxQuantity: 50,
              soldQuantity: 38,
            ),
            CampaignVariantModel(
              id: 7,
              name: '30 Butir (1 Tray)',
              quantityPerVariant: 30,
              maxQuantity: 20,
              soldQuantity: 15,
            ),
          ],
        ),
      ];

  static List<OrderModel> get myOrders => [
        OrderModel(
          id: 1,
          campaignId: 1,
          campaignTitle: 'Beras Premium Pulen',
          userId: 1,
          userName: 'Bu Siti Rahayu',
          variantId: 1,
          variantName: '5 Kg',
          quantity: 1,
          totalPrice: 60000,
          paymentMethod: 'cash',
          paymentStatus: 'paid',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          validatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        OrderModel(
          id: 2,
          campaignId: 2,
          campaignTitle: 'Minyak Goreng 2L',
          userId: 1,
          userName: 'Bu Siti Rahayu',
          variantId: 4,
          variantName: '1 pcs (2L)',
          quantity: 2,
          totalPrice: 64000,
          paymentMethod: 'qris',
          paymentStatus: 'waiting_qris',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

  static List<OrderModel> get pendingValidation => [
        OrderModel(
          id: 10,
          campaignId: 1,
          campaignTitle: 'Beras Premium Pulen',
          userId: 4,
          userName: 'Bu Dewi',
          variantId: 2,
          variantName: '10 Kg',
          quantity: 1,
          totalPrice: 120000,
          paymentMethod: 'qris',
          paymentStatus: 'waiting_qris',
          proofUrl: 'https://storage.grosirun.id/proofs/proof_001.jpg',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        OrderModel(
          id: 11,
          campaignId: 1,
          campaignTitle: 'Beras Premium Pulen',
          userId: 5,
          userName: 'Pak Budi',
          variantId: 1,
          variantName: '5 Kg',
          quantity: 2,
          totalPrice: 120000,
          paymentMethod: 'cash',
          paymentStatus: 'pending',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ];

  static List<NotificationModel> get notifications => [
        NotificationModel(
          id: 1,
          userId: 1,
          title: 'Patungan Beras hampir penuh!',
          body: 'Stok Beras Premium Pulen tinggal 180 kg lagi. Checkout sekarang!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        NotificationModel(
          id: 2,
          userId: 1,
          title: 'Pembayaran diterima',
          body: 'Pesanan Minyak Goreng 2L kamu sudah tercatat.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

  static List<String> get socialTicker => [
        'Bu Nengsih • 5 Kg Beras • 2 menit lalu',
        'Pak Joko • 10 Kg Beras • 5 menit lalu',
        'Bu Dewi • 2L Minyak x 3 • 8 menit lalu',
        'Pak Rudi • 30 butir Telur • 12 menit lalu',
        'Bu Ani • 5 Kg Gula • 15 menit lalu',
      ];

  // ─── Seller Products ───

  static List<SellerProductModel> get sellerProducts => [
        SellerProductModel(
          id: 1,
          supplierId: 1,
          name: 'Beras Premium Pulen',
          baseUnit: 'kg',
          description: 'Beras premium kualitas terbaik langsung dari pabrik.',
          variants: const [
            ProductVariantModel(id: 1, productId: 1, name: '5 Kg', packageQuantity: 5),
            ProductVariantModel(id: 2, productId: 1, name: '10 Kg', packageQuantity: 10),
            ProductVariantModel(id: 3, productId: 1, name: '25 Kg (Sak)', packageQuantity: 25),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        SellerProductModel(
          id: 2,
          supplierId: 1,
          name: 'Minyak Goreng 2L',
          baseUnit: 'pcs',
          description: 'Minyak goreng kemasan 2 liter berkualitas.',
          variants: const [
            ProductVariantModel(id: 4, productId: 2, name: '1 pcs (2L)', packageQuantity: 1),
            ProductVariantModel(id: 5, productId: 2, name: '1 Dus (6 pcs)', packageQuantity: 6),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

  // ─── Supplier Offers ───

  static List<SupplierOfferModel> get supplierOffers => [
        SupplierOfferModel(
          id: 1,
          supplierId: 1,
          supplierName: 'CV Makmur Jaya',
          productName: 'Beras Premium Pulen',
          unit: 'kg',
          minimumOrder: 500,
          capacity: 2000,
          tiers: const [
            PriceTier(minQuantity: 500, maxQuantity: 999, unitPrice: 10500),
            PriceTier(minQuantity: 1000, maxQuantity: 0, unitPrice: 10000),
          ],
          serviceAreas: const ['PGH-RT03', 'PGH-RT05'],
          deliveryCost: 200000,
          validUntil: DateTime.now().add(const Duration(days: 15)),
          status: OfferStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

  static List<SupplierOfferModel> get pendingOffers => [
        SupplierOfferModel(
          id: 10,
          supplierId: 1,
          supplierName: 'CV Makmur Jaya',
          productName: 'Beras Premium Pulen',
          unit: 'kg',
          minimumOrder: 500,
          capacity: 2000,
          tiers: const [
            PriceTier(minQuantity: 500, maxQuantity: 999, unitPrice: 10500),
            PriceTier(minQuantity: 1000, maxQuantity: 0, unitPrice: 10000),
          ],
          serviceAreas: const ['PGH-RT03', 'PGH-RT05'],
          deliveryCost: 200000,
          validUntil: DateTime.now().add(const Duration(days: 30)),
          status: OfferStatus.pendingModeration,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        SupplierOfferModel(
          id: 11,
          supplierId: 2,
          supplierName: 'UD Sumber Rejeki',
          productName: 'Minyak Goreng 2L',
          unit: 'pcs',
          minimumOrder: 200,
          capacity: 1000,
          tiers: const [
            PriceTier(minQuantity: 200, maxQuantity: 499, unitPrice: 28000),
            PriceTier(minQuantity: 500, maxQuantity: 0, unitPrice: 26500),
          ],
          serviceAreas: const ['PGH-RT03'],
          deliveryCost: 180000,
          validUntil: DateTime.now().add(const Duration(days: 20)),
          status: OfferStatus.pendingModeration,
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ];

  static List<SupplierOfferModel> get allOffers => [...supplierOffers, ...pendingOffers];

  // ─── Purchase Orders (Seller side) ───

  static List<PurchaseOrderModel> get sellerPurchaseOrders => [
        PurchaseOrderModel(
          id: 1001,
          code: 'PO-1001',
          campaignId: 1,
          campaignTitle: 'Beras Premium Pulen',
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          supplierId: 1,
          supplierName: 'CV Makmur Jaya',
          productName: 'Beras Premium Pulen',
          unit: 'kg',
          quantity: 500,
          unitPrice: 10500,
          subtotal: 5250000,
          deliveryCost: 200000,
          totalAmount: 5450000,
          status: POStatus.submitted,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        PurchaseOrderModel(
          id: 1002,
          code: 'PO-1002',
          campaignId: 2,
          campaignTitle: 'Minyak Goreng 2L',
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          supplierId: 1,
          supplierName: 'CV Makmur Jaya',
          productName: 'Minyak Goreng 2L',
          unit: 'pcs',
          quantity: 200,
          unitPrice: 30000,
          subtotal: 6000000,
          deliveryCost: 180000,
          totalAmount: 6180000,
          status: POStatus.accepted,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          acceptedAt: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        PurchaseOrderModel(
          id: 1003,
          code: 'PO-1003',
          campaignId: 3,
          campaignTitle: 'Gula Pasir',
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          supplierId: 2,
          supplierName: 'UD Sumber Rejeki',
          productName: 'Gula Pasir',
          unit: 'kg',
          quantity: 300,
          unitPrice: 16000,
          subtotal: 4800000,
          deliveryCost: 150000,
          totalAmount: 4950000,
          status: POStatus.shipped,
          trackingNumber: 'JNE-123456',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          acceptedAt: DateTime.now().subtract(const Duration(days: 2)),
          paidAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
          shippedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  // ─── Supplier Models (Admin verification) ───

  static List<SupplierModel> get pendingSuppliers => [
        SupplierModel(
          id: 1,
          name: 'CV Makmur Jaya',
          siup: 'SIUP-2024-001',
          npwp: '01.234.567.8-901.000',
          address: 'Jl. Industri Raya No.45, Surabaya',
          contactPhone: '031-1234567',
          contactEmail: 'info@makmurjaya.co.id',
          status: SupplierStatus.pendingVerification,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        SupplierModel(
          id: 2,
          name: 'UD Sumber Rejeki',
          siup: 'SIUP-2024-002',
          npwp: '02.345.678.9-012.000',
          address: 'Jl. Pasar Baru No.12, Sidoarjo',
          contactPhone: '031-7654321',
          contactEmail: 'cs@sumberrejeki.com',
          status: SupplierStatus.pendingVerification,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        SupplierModel(
          id: 3,
          name: 'PT Sembako Jaya',
          siup: 'SIUP-2024-003',
          npwp: '03.456.789.0-123.000',
          address: 'Jl. Gatot Subroto No.88, Surabaya',
          contactPhone: '031-9988776',
          contactEmail: 'admin@sembakojaya.co.id',
          status: SupplierStatus.pendingVerification,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  static List<SupplierModel> get allSuppliers => [
        ...pendingSuppliers,
        SupplierModel(
          id: 10,
          name: 'PT Grosir Nusantara',
          siup: 'SIUP-2023-050',
          npwp: '10.234.567.8-901.000',
          address: 'Jl. Raya Grosir No.1, Jakarta',
          contactPhone: '021-5551234',
          contactEmail: 'info@grosirnusantara.co.id',
          status: SupplierStatus.verified,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          verifiedAt: DateTime.now().subtract(const Duration(days: 55)),
        ),
      ];

  // ─── Disputes ───

  static List<DisputeModel> get disputes => [
        DisputeModel(
          id: 1,
          purchaseOrderId: 1003,
          purchaseOrderCode: 'PO-1003',
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          supplierId: 2,
          supplierName: 'UD Sumber Rejeki',
          disputeType: 'quantity_mismatch',
          description: 'Barang yang diterima hanya 280 Kg dari 300 Kg yang dipesan. 20 Kg kurang dari surat jalan.',
          evidenceUrls: const [
            'https://storage.grosirun.id/disputes/evidence_001.jpg',
            'https://storage.grosirun.id/disputes/evidence_002.jpg',
          ],
          status: DisputeStatus.open,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        DisputeModel(
          id: 2,
          purchaseOrderId: 1002,
          purchaseOrderCode: 'PO-1002',
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          supplierId: 1,
          supplierName: 'CV Makmur Jaya',
          disputeType: 'quality_issue',
          description: 'Minyak goreng yang diterima mendekati expired date (1 bulan lagi).',
          evidenceUrls: const [
            'https://storage.grosirun.id/disputes/evidence_003.jpg',
          ],
          status: DisputeStatus.inReview,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        DisputeModel(
          id: 3,
          purchaseOrderId: 1001,
          purchaseOrderCode: 'PO-1001',
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          supplierId: 1,
          supplierName: 'CV Makmur Jaya',
          disputeType: 'late_delivery',
          description: 'Pengiriman terlambat 3 hari dari jadwal.',
          evidenceUrls: const [],
          status: DisputeStatus.resolved,
          resolution: DisputeResolution.refund,
          resolutionNotes: 'Seller setuju refund 10% dari total PO sebagai kompensasi.',
          refundAmount: 545000,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          resolvedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

  // ─── Audit Logs ───

  static List<AuditLogModel> get auditLogs => [
        AuditLogModel(
          id: 1,
          action: 'supplier_verified',
          targetType: 'supplier',
          targetId: 10,
          userId: 4,
          userName: 'Admin Grosirun',
          description: 'PT Grosir Nusantara diverifikasi dan diaktifkan.',
          createdAt: DateTime.now().subtract(const Duration(days: 55)),
        ),
        AuditLogModel(
          id: 2,
          action: 'offer_approved',
          targetType: 'offer',
          targetId: 1,
          userId: 4,
          userName: 'Admin Grosirun',
          description: 'Offer Beras Premium Pulen oleh CV Makmur Jaya disetujui.',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        AuditLogModel(
          id: 3,
          action: 'dispute_resolved',
          targetType: 'dispute',
          targetId: 3,
          userId: 4,
          userName: 'Admin Grosirun',
          description: 'Dispute PO-1001 diselesaikan dengan refund 10%.',
          ticketId: 'TKT-2026-0042',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        AuditLogModel(
          id: 4,
          action: 'user_suspended',
          targetType: 'user',
          targetId: 15,
          userId: 4,
          userName: 'Admin Grosirun',
          description: 'User ditangguhkan karena pelanggaran kebijakan.',
          ticketId: 'TKT-2026-0043',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        AuditLogModel(
          id: 5,
          action: 'role_granted',
          targetType: 'user',
          targetId: 2,
          userId: 4,
          userName: 'Admin Grosirun',
          description: 'Role initiator diberikan kepada Pak Agus Setiawan.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  // ─── Users with Roles (Admin role management) ───

  static List<UserModel> get usersWithRoles => [
        const UserModel(
          id: 1,
          name: 'Bu Siti Rahayu',
          phoneNumber: '081234567890',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
          roles: [UserRole.buyer],
          activeRole: UserRole.buyer,
          consentGiven: true,
          tosAccepted: true,
        ),
        const UserModel(
          id: 2,
          name: 'Pak Agus Setiawan',
          phoneNumber: '081987654321',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
          roles: [UserRole.buyer, UserRole.initiator],
          activeRole: UserRole.initiator,
          consentGiven: true,
          tosAccepted: true,
        ),
        const UserModel(
          id: 3,
          name: 'Andi dari Makmur Jaya',
          phoneNumber: '08111222333',
          roles: [UserRole.seller],
          activeRole: UserRole.seller,
          consentGiven: true,
          tosAccepted: true,
        ),
        const UserModel(
          id: 5,
          name: 'Bu Dewi Lestari',
          phoneNumber: '081555666777',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
          roles: [UserRole.buyer],
          activeRole: UserRole.buyer,
          consentGiven: true,
          tosAccepted: true,
        ),
        const UserModel(
          id: 6,
          name: 'Pak Budi Santoso',
          phoneNumber: '081777888999',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
          roles: [UserRole.buyer, UserRole.initiator],
          activeRole: UserRole.buyer,
          consentGiven: true,
          tosAccepted: true,
        ),
      ];
}
