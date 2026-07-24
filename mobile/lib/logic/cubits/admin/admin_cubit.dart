import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/dispute_model.dart';
import '../../../data/models/seller_product_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/models/supplier_offer_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/admin_repository.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit(this._repository) : super(AdminInitial());

  Future<void> loadDashboard() async {
    try {
      emit(AdminLoading());
      final metrics = await _repository.getAdminMetrics();
      final disputes = await _repository.getDisputes();
      emit(AdminDashboardLoaded(
        metrics: metrics,
        openDisputes: disputes.where((d) => d.isOpen || d.isInReview).length,
      ));
    } catch (e) {
      emit(AdminError('Gagal memuat dashboard: $e'));
    }
  }

  // ─── Supplier Verification ───

  Future<void> loadPendingSuppliers() async {
    try {
      emit(AdminLoading());
      final suppliers = await _repository.getPendingSuppliers();
      emit(AdminSuppliersLoaded(suppliers));
    } catch (e) {
      emit(AdminError('Gagal memuat supplier: $e'));
    }
  }

  Future<void> verifySupplier(int id, {required bool approved, String? reason}) async {
    try {
      emit(AdminLoading());
      await _repository.verifySupplier(id, approved: approved, reason: reason);
      emit(AdminActionSuccess(
        approved ? 'Supplier diverifikasi ✅' : 'Supplier ditolak ❌',
      ));
      await loadPendingSuppliers();
    } catch (e) {
      emit(AdminError('Gagal memverifikasi supplier: $e'));
    }
  }

  // ─── Offer Moderation ───

  Future<void> loadPendingOffers() async {
    try {
      emit(AdminLoading());
      final offers = await _repository.getPendingOffers();
      emit(AdminOffersLoaded(offers));
    } catch (e) {
      emit(AdminError('Gagal memuat offer: $e'));
    }
  }

  Future<void> moderateOffer(int id, {required bool approved, String? note}) async {
    try {
      emit(AdminLoading());
      await _repository.moderateOffer(id, approved: approved, note: note);
      emit(AdminActionSuccess(
        approved ? 'Offer disetujui ✅' : 'Offer ditolak ❌',
      ));
      await loadPendingOffers();
    } catch (e) {
      emit(AdminError('Gagal memoderasi offer: $e'));
    }
  }

  // ─── Role Management ───

  Future<void> loadUsersWithRoles() async {
    try {
      emit(AdminLoading());
      final users = await _repository.getUsersWithRoles();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError('Gagal memuat pengguna: $e'));
    }
  }

  Future<void> grantRole(int userId, String role) async {
    try {
      emit(AdminLoading());
      await _repository.grantRole(userId, role);
      emit(AdminActionSuccess('Role $role diberikan ✅'));
      await loadUsersWithRoles();
    } catch (e) {
      emit(AdminError('Gagal memberikan role: $e'));
    }
  }

  Future<void> revokeRole(int userId, String role) async {
    try {
      emit(AdminLoading());
      await _repository.revokeRole(userId, role);
      emit(AdminActionSuccess('Role $role dicabut'));
      await loadUsersWithRoles();
    } catch (e) {
      emit(AdminError('Gagal mencabut role: $e'));
    }
  }

  // ─── Suspend ───

  Future<void> suspendUser(int userId, {required String reason, String? ticketId}) async {
    try {
      emit(AdminLoading());
      await _repository.suspendUser(userId, reason: reason, ticketId: ticketId);
      emit(const AdminActionSuccess('User ditangguhkan'));
      await loadUsersWithRoles();
    } catch (e) {
      emit(AdminError('Gagal menangguhkan user: $e'));
    }
  }

  // ─── Disputes ───

  Future<void> loadDisputes({String? status}) async {
    try {
      emit(AdminLoading());
      final disputes = await _repository.getDisputes(status: status);
      emit(AdminDisputesLoaded(disputes));
    } catch (e) {
      emit(AdminError('Gagal memuat dispute: $e'));
    }
  }

  Future<void> resolveDispute(
    int id, {
    required String resolution,
    String? notes,
    int? refundAmount,
  }) async {
    try {
      emit(AdminLoading());
      await _repository.resolveDispute(
        id,
        resolution: resolution,
        notes: notes,
        refundAmount: refundAmount,
      );
      emit(const AdminActionSuccess('Dispute terselesaikan ✅'));
      await loadDisputes();
    } catch (e) {
      emit(AdminError('Gagal menyelesaikan dispute: $e'));
    }
  }

  // ─── Audit Log ───

  Future<void> loadAuditLogs({int page = 1}) async {
    try {
      emit(AdminLoading());
      final logs = await _repository.getAuditLogs(page: page);
      emit(AdminAuditLogsLoaded(logs));
    } catch (e) {
      emit(AdminError('Gagal memuat audit log: $e'));
    }
  }
}
