/// Grosirun App Constants
/// 
/// Centralized configuration for the app.
/// Switch [_useMockData] to false when connecting to real Laravel API.
class AppConstants {
  AppConstants._();

  // ─── API Configuration ───
  // Toggle this to switch between mock data and real API
  static const bool useMockData = true;

  // Real API base URL (used when useMockData = false)
  static const String apiBaseUrl = 'https://api.grosirun.id/api/v1';

  // ─── App Info ───
  static const String appName = 'Grosirun';
  static const String tagline = 'Yuk, Grosirun Bareng!';

  // ─── Token ───
  static const int tokenExpiryDays = 30;

  // ─── Polling Intervals ───
  static const int campaignDetailPollingSeconds = 15;
  static const int notificationPollingSeconds = 60;
  static const int socialTickerSeconds = 15;

  // ─── Upload ───
  static const int maxProofSizeBytes = 2 * 1024 * 1024; // 2MB
  static const int maxCampaignImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int imageCompressWidth = 800;
  static const int imageCompressHeight = 800;
  static const int imageCompressQuality = 70;

  // ─── Pagination ───
  static const int defaultPageSize = 20;

  // ─── Hive Box Names ───
  static const String boxCampaigns = 'campaigns_box';
  static const String boxOrders = 'orders_box';
  static const String boxNotifications = 'notifications_box';
  static const String boxQueue = 'pending_queue_box';
  static const String boxAppState = 'app_state_box';
  static const String boxUser = 'user_box';
  static const String boxProofUploads = 'proof_uploads_box';

  // ─── Secure Storage Keys ───
  static const String keyToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyActiveRole = 'active_role';

  // ─── Deep Link ───
  static const String deepLinkScheme = 'grosirun';
  static const String deepLinkHost = 'campaign';
}

/// User Roles
class UserRole {
  UserRole._();
  static const String buyer = 'buyer';
  static const String initiator = 'initiator';
  static const String seller = 'seller';
  static const String admin = 'admin';
}

/// Campaign Status
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

/// Order Payment Status
class PaymentStatus {
  PaymentStatus._();
  static const String pending = 'pending';
  static const String waitingQris = 'waiting_qris';
  static const String paid = 'paid';
  static const String rejected = 'rejected';
}
