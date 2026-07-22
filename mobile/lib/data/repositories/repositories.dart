import '../models/user_model.dart';
import '../models/campaign_model.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';
import '../datasources/remote/mock_data.dart';
import '../../core/constants/app_constants.dart';

/// Auth Repository — handles authentication & user state.
/// 
/// Currently uses mock data. When [AppConstants.useMockData] is false,
/// replace method bodies with real Dio HTTP calls to Laravel API.
class AuthRepository {
  UserModel? _currentUser;

  /// Login with OTP (mock: any 6-digit code works)
  Future<UserModel> loginWithOtp(String phoneNumber, String otpCode) async {
    // TODO: Replace with real API call
    // POST /api/v1/auth/request-otp
    // POST /api/v1/auth/verify-otp
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    // Mock: return buyer user for demo
    _currentUser = MockData.buyer;
    return _currentUser!;
  }

  /// Get current logged-in user
  Future<UserModel> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;
    // TODO: GET /api/v1/auth/me
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = MockData.buyer;
    return _currentUser!;
  }

  /// Switch active role
  Future<UserModel> switchActiveRole(String role) async {
    // TODO: PUT /api/v1/auth/active-role
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = _currentUser?.copyWith(activeRole: role);
    return _currentUser!;
  }

  /// Logout
  Future<void> logout() async {
    // TODO: POST /api/v1/auth/logout
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  /// Accept Terms of Service
  Future<void> acceptTos() async {
    // TODO: POST /api/v1/auth/tos-accept
    await Future.delayed(const Duration(milliseconds: 200));
  }

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;
}

/// Campaign Repository — handles campaign data.
class CampaignRepository {
  /// Get list of active campaigns for current cluster
  Future<List<CampaignModel>> getActiveCampaigns() async {
    // TODO: GET /api/v1/campaigns?status=active
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    return MockData.campaigns.where((c) => c.status == 'active').toList();
  }

  /// Get campaign detail by ID
  Future<CampaignModel> getCampaignDetail(int id) async {
    // TODO: GET /api/v1/campaigns/{id}
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.campaigns.firstWhere((c) => c.id == id);
  }
}

/// Order Repository — handles orders.
class OrderRepository {
  /// Get my orders
  Future<List<OrderModel>> getMyOrders() async {
    // TODO: GET /api/v1/orders?user_id=me
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.myOrders;
  }

  /// Create order (checkout)
  Future<OrderModel> createOrder({
    required int campaignId,
    required int variantId,
    required int quantity,
    required String paymentMethod,
  }) async {
    // TODO: POST /api/v1/orders
    // Use Idempotency-Key header for retry safety
    await Future.delayed(const Duration(milliseconds: 600));
    
    final campaign = MockData.campaigns.firstWhere((c) => c.id == campaignId);
    return OrderModel(
      id: 99,
      campaignId: campaignId,
      campaignTitle: campaign.title,
      userId: MockData.buyer.id,
      userName: MockData.buyer.name,
      variantId: variantId,
      variantName: campaign.variants.firstWhere((v) => v.id == variantId).name,
      quantity: quantity,
      totalPrice: campaign.buyerUnitPrice * quantity,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cash' ? 'pending' : 'waiting_qris',
      createdAt: DateTime.now(),
    );
  }

  /// Get pending orders for validation (initiator only)
  Future<List<OrderModel>> getPendingValidation(int campaignId) async {
    // TODO: GET /api/v1/campaigns/{id}/orders?payment_status=pending,waiting_qris
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.pendingValidation
        .where((o) => o.campaignId == campaignId)
        .toList();
  }

  /// Validate order (initiator action)
  Future<void> validateOrder(int orderId) async {
    // TODO: PATCH /api/v1/campaigns/{id}/orders/{orderId}/validate
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Reject order (initiator action)
  Future<void> rejectOrder(int orderId, String reason) async {
    // TODO: PATCH /api/v1/campaigns/{id}/orders/{orderId}/reject
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Notification Repository
class NotificationRepository {
  Future<List<NotificationModel>> getUnreadNotifications() async {
    // TODO: GET /api/v1/notifications?unread=true
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.notifications.where((n) => !n.isRead).toList();
  }

  Future<void> markAsRead(int notificationId) async {
    // TODO: PATCH /api/v1/notifications/{id}/read
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
