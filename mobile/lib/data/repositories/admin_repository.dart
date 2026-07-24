import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../datasources/local/offline_queue_datasource.dart';
import '../datasources/remote/mock_data.dart';
import '../models/dispute_model.dart';
import '../models/seller_product_model.dart';
import '../models/supplier_model.dart';
import '../models/supplier_offer_model.dart';
import '../models/user_model.dart';

/// Repository for admin-specific operations.
///
/// All admin mutations are audited on the server. The client must always be
/// online for these operations – they are **never** queued offline.
class AdminRepository {
  final Logger _logger = GetIt.I<Logger>();

  AdminRepository();

  // ─── Dashboard Metrics ───

  Future<Map<String, dynamic>> getAdminMetrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'pending_suppliers': MockData.pendingSuppliers.length,
      'pending_offers': MockData.pendingOffers.length,
      'open_disputes': MockData.disputes.where((d) => d.isOpen || d.isInReview).length,
      'active_campaigns': MockData.campaigns.where((c) => c.status == 'active').length,
      'total_users': 42,
      'total_suppliers': 6,
      'total_orders_today': 18,
      'gmv_today': 2850000,
    };
  }

  // ─── Supplier Verification ───

  Future<List<SupplierModel>> getPendingSuppliers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.pendingSuppliers;
  }

  Future<SupplierModel> getSupplierDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.allSuppliers.firstWhere(
      (s) => s.id == id,
      orElse: () => MockData.pendingSuppliers.first,
    );
  }

  Future<void> verifySupplier(int id, {required bool approved, String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logger.i('Supplier $id ${approved ? "approved" : "rejected"}: ${reason ?? "no reason"}');
  }

  // ─── Offer Moderation ───

  Future<List<SupplierOfferModel>> getPendingOffers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.pendingOffers;
  }

  Future<SupplierOfferModel> getOfferDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.allOffers.firstWhere(
      (o) => o.id == id,
      orElse: () => MockData.pendingOffers.first,
    );
  }

  Future<void> moderateOffer(int id, {required bool approved, String? note}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logger.i('Offer $id ${approved ? "approved" : "rejected"}: ${note ?? "no note"}');
  }

  // ─── Role Management ───

  Future<List<UserModel>> getUsersWithRoles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.usersWithRoles;
  }

  Future<void> grantRole(int userId, String role) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('Role granted: user $userId → $role');
  }

  Future<void> revokeRole(int userId, String role) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('Role revoked: user $userId → $role');
  }

  // ─── Suspend ───

  Future<void> suspendUser(int userId, {required String reason, String? ticketId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logger.i('User $userId suspended: $reason (ticket: $ticketId)');
  }

  Future<void> unsuspendUser(int userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('User $userId unsuspended');
  }

  // ─── Disputes ───

  Future<List<DisputeModel>> getDisputes({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var disputes = MockData.disputes;
    if (status != null) {
      disputes = disputes.where((d) => d.status == status).toList();
    }
    return disputes;
  }

  Future<DisputeModel> getDisputeDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.disputes.firstWhere((d) => d.id == id);
  }

  Future<void> resolveDispute(
    int id, {
    required String resolution,
    String? notes,
    int? refundAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logger.i('Dispute $id resolved: $resolution (refund: $refundAmount)');
  }

  // ─── Audit Log ───

  Future<List<AuditLogModel>> getAuditLogs({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.auditLogs;
  }
}

// Re-export the audit log model path since we put it in seller_product_model.dart
// ignore: unused_element
