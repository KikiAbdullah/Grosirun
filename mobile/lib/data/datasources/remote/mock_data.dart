import '../../models/campaign_model.dart';
import '../../models/notification_model.dart';
import '../../models/order_model.dart';
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
}
