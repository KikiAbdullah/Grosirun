/// Mock data for Grosirun app.
///
/// This file provides dummy data that matches the API_SPEC response format.
/// When [AppConstants.useMockData] is false, these are replaced by real API calls.

import '../models/user_model.dart';
import '../models/campaign_model.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';

class MockData {
  MockData._();

  // ─── Users ───
  static const User buyer = UserModel(
    id: 1,
    name: 'Bu Siti',
    phoneNumber: '081234567890',
    clusterId: 1,
    clusterName: 'Permata Hijau RT03',
    roles: ['buyer'],
    activeRole: 'buyer',
    consentGiven: true,
    tosAccepted: true,
  );

  static const User initiator = UserModel(
    id: 2,
    name: 'Pak Agus Setiawan',
    phoneNumber: '081987654321',
    clusterId: 1,
    clusterName: 'Permata Hijau RT03',
    roles: ['buyer', 'initiator'],
    activeRole: 'initiator',
    consentGiven: true,
    tosAccepted: true,
  );

  static const User seller = UserModel(
    id: 3,
    name: 'Andi dari Makmur Jaya',
    phoneNumber: '08111222333',
    roles: ['seller'],
    activeRole: 'seller',
    consentGiven: true,
    tosAccepted: true,
  );

  // ─── Campaigns ───
  static List<CampaignModel> get campaigns => [
        CampaignModel(
          id: 1,
          title: 'Beras Premium Pulen',
          description: 'Beras premium kualitas terbaik langsung dari pabrik Makmur Jaya. Pulen, wangi, dan bersih.',
          status: 'active',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
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
            CampaignVariantModel(id: 1, name: '5 Kg', quantityPerVariant: 5, maxQuantity: 50, soldQuantity: 30),
            CampaignVariantModel(id: 2, name: '10 Kg', quantityPerVariant: 10, maxQuantity: 30, soldQuantity: 20),
            CampaignVariantModel(id: 3, name: '25 Kg (Sak)', quantityPerVariant: 25, maxQuantity: 10, soldQuantity: 6),
          ],
        ),
        CampaignModel(
          id: 2,
          title: 'Minyak Goreng 2L',
          description: 'Minyak goreng kemasan 2 liter, merk Sania/Bimoli. Stok terbatas!',
          status: 'active',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
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
            CampaignVariantModel(id: 4, name: '1 pcs (2L)', quantityPerVariant: 1, maxQuantity: 100, soldQuantity: 70),
            CampaignVariantModel(id: 5, name: '1 Dus (6 pcs)', quantityPerVariant: 6, maxQuantity: 20, soldQuantity: 12),
          ],
        ),
        CampaignModel(
          id: 3,
          title: 'Telur Ayam Negeri',
          description: 'Telur ayam segar pilihan, ukuran sedang-besar. Langsung dari peternak lokal.',
          status: 'active',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
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
            CampaignVariantModel(id: 6, name: '10 Butir', quantityPerVariant: 10, maxQuantity: 50, soldQuantity: 38),
            CampaignVariantModel(id: 7, name: '30 Butir (1 Tray)', quantityPerVariant: 30, maxQuantity: 20, soldQuantity: 15),
          ],
        ),
        CampaignModel(
          id: 4,
          title: 'Gula Pasir Putih',
          description: 'Gula pasir putih kualitas premium, manis dan bersih.',
          status: 'active',
          clusterId: 1,
          clusterName: 'Permata Hijau RT03',
          initiatorId: 2,
          initiatorName: 'Pak Agus Setiawan',
          unit: 'kg',
          targetQuantity: 300,
          currentQuantity: 85,
          buyerUnitPrice: 14500,
          supplierUnitPrice: 12800,
          deadline: DateTime.now().add(const Duration(days: 7)),
          locationDistribution: 'Balai RT03, Jalan Permata No.10',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          variants: const [
            CampaignVariantModel(id: 8, name: '1 Kg', quantityPerVariant: 1, maxQuantity: 100, soldQuantity: 30),
            CampaignVariantModel(id: 9, name: '5 Kg', quantityPerVariant: 5, maxQuantity: 30, soldQuantity: 11),
          ],
        ),
      ];

  // ─── Orders ───
  static List<OrderModel> get myOrders => [
        OrderModel(
          id: 1,
          campaignId: 1,
          campaignTitle: 'Beras Premium Pulen',
          userId: 1,
          userName: 'Bu Siti',
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
          userName: 'Bu Siti',
          variantId: 4,
          variantName: '1 pcs (2L)',
          quantity: 2,
          totalPrice: 64000,
          paymentMethod: 'qris',
          paymentStatus: 'pending',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

  // ─── Pending Validation (for Initiator dashboard) ───
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
        OrderModel(
          id: 12,
          campaignId: 2,
          campaignTitle: 'Minyak Goreng 2L',
          userId: 6,
          userName: 'Bu Ratna',
          variantId: 4,
          variantName: '1 pcs (2L)',
          quantity: 3,
          totalPrice: 96000,
          paymentMethod: 'qris',
          paymentStatus: 'waiting_qris',
          proofUrl: 'https://storage.grosirun.id/proofs/proof_002.jpg',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];

  // ─── Notifications ───
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
          title: 'Pembayaran diterima ✅',
          body: 'Pesanan Minyak Goreng 2L kamu sudah tercatat. Upload bukti transfer ya.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        NotificationModel(
          id: 3,
          userId: 1,
          title: 'Bu Nengsih baru pesan 5 Kg',
          body: 'di PO Beras Premium Pulen. Yuk ikut patungan!',
          data: {'campaign_id': 1},
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

  // ─── Social Ticker ───
  static List<String> get socialTicker => [
      'Bu Nengsih • 5 Kg Beras • 2 menit lalu',
      'Pak Joko • 10 Kg Beras • 5 menit lalu',
      'Bu Dewi • 2L Minyak × 3 • 8 menit lalu',
      'Pak Rudi • 30 butir Telur • 12 menit lalu',
      'Bu Ani • 5 Kg Gula • 15 menit lalu',
      'Pak Hasan • 25 Kg Beras (Sak) • 20 menit lalu',
    ];
}

// Alias for convenience
typedef User = UserModel;
