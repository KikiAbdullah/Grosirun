/// Grosirun App Constants
///
/// Centralized configuration for the app.
class AppConstants {
  AppConstants._();

  static const bool useMockData = true;
  static const String apiBaseUrl = 'https://api.grosirun.id/api/v1';

  static const String appName = 'Grosirun';
  static const String tagline = 'Yuk, Grosirun Bareng!';
  static const String defaultClusterCode = 'PGH-RT03';
  static const String defaultClusterName = 'Permata Hijau RT03';
  static const String privacyPolicyVersion = 'v1.0';
  static const String tosVersion = 'v1.0';

  static const int tokenExpiryDays = 30;
  static const int otpLength = 4;

  static const int campaignDetailPollingSeconds = 15;
  static const int notificationPollingSeconds = 60;
  static const int socialTickerSeconds = 15;

  static const int maxProofSizeBytes = 2 * 1024 * 1024;
  static const int maxCampaignImageSizeBytes = 5 * 1024 * 1024;
  static const int imageCompressWidth = 800;
  static const int imageCompressHeight = 800;
  static const int imageCompressQuality = 70;

  static const int defaultPageSize = 20;

  static const String boxCampaigns = 'campaigns_box';
  static const String boxOrders = 'orders_box';
  static const String boxNotifications = 'notifications_box';
  static const String boxQueue = 'pending_queue_box';
  static const String boxAppState = 'app_state_box';
  static const String boxUser = 'user_box';
  static const String boxProofUploads = 'proof_uploads_box';
  static const String boxEtag = 'etag_box';
  static const String boxIdempotency = 'idempotency_box';
  static const String boxSellerProducts = 'seller_products_box';
  static const String boxSellerOffers = 'seller_offers_box';
  static const String boxPurchaseOrders = 'purchase_orders_box';

  static const String keyToken = 'auth_token';
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyActiveRole = 'active_role';
  static const String keyCurrentUser = 'current_user';
  static const String keyPendingDeepLink = 'pending_deep_link';
  static const String keyLastRoute = 'last_route';
  static const String keyLastCampaignId = 'last_campaign_id';
  static const String keyLastActiveAt = 'last_active_at';

  static const String deepLinkScheme = 'grosirun';
  static const String deepLinkHost = 'campaign';
  static const String deepLinkPrefix = 'grosirun://campaign/';

  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}

class UserRole {
  UserRole._();

  static const String buyer = 'buyer';
  static const String initiator = 'initiator';
  static const String seller = 'seller';
  static const String admin = 'admin';
}

class CampaignStatus {
  CampaignStatus._();

  static const String draft = 'draft';
  static const String active = 'active';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
  static const String targetReached = 'target_reached';
  static const String poSubmitted = 'po_submitted';
  static const String fulfillment = 'fulfillment';
  static const String completed = 'completed';
}

class PaymentStatus {
  PaymentStatus._();

  static const String pending = 'pending';
  static const String waitingQris = 'waiting_qris';
  static const String paid = 'paid';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
}
