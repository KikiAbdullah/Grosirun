import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/purchase_order_model.dart';
import '../../../data/models/seller_product_model.dart';
import '../../../data/models/supplier_offer_model.dart';
import '../../../data/repositories/seller_repository.dart';

part 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final SellerRepository _repository;

  SellerCubit(this._repository) : super(SellerInitial());

  Future<void> loadProducts() async {
    try {
      emit(SellerLoading());
      final products = await _repository.getProducts();
      emit(SellerProductsLoaded(products));
    } catch (e) {
      emit(SellerError('Gagal memuat produk: $e'));
    }
  }

  Future<void> loadOffers() async {
    try {
      emit(SellerLoading());
      final offers = await _repository.getOffers();
      emit(SellerOffersLoaded(offers));
    } catch (e) {
      emit(SellerError('Gagal memuat penawaran: $e'));
    }
  }

  Future<void> loadPurchaseOrders() async {
    try {
      emit(SellerLoading());
      final orders = await _repository.getPurchaseOrders();
      emit(SellerPurchaseOrdersLoaded(orders));
    } catch (e) {
      emit(SellerError('Gagal memuat purchase order: $e'));
    }
  }

  Future<void> acceptPurchaseOrder(int id) async {
    try {
      emit(SellerLoading());
      await _repository.acceptPurchaseOrder(id);
      emit(const SellerActionSuccess('Purchase Order diterima'));
      await loadPurchaseOrders();
    } catch (e) {
      emit(SellerError('Gagal menerima PO: $e'));
    }
  }

  Future<void> rejectPurchaseOrder(int id, {required String reason}) async {
    try {
      emit(SellerLoading());
      await _repository.rejectPurchaseOrder(id, reason: reason);
      emit(const SellerActionSuccess('Purchase Order ditolak'));
      await loadPurchaseOrders();
    } catch (e) {
      emit(SellerError('Gagal menolak PO: $e'));
    }
  }

  Future<void> confirmPayment(int id) async {
    try {
      emit(SellerLoading());
      await _repository.confirmPayment(id);
      emit(const SellerActionSuccess('Pembayaran dikonfirmasi'));
      await loadPurchaseOrders();
    } catch (e) {
      emit(SellerError('Gagal konfirmasi pembayaran: $e'));
    }
  }

  Future<void> updatePOStatus(int id, {required String status}) async {
    try {
      emit(SellerLoading());
      await _repository.updatePOStatus(id, status: status);
      emit(SellerActionSuccess('Status PO diperbarui'));
      await loadPurchaseOrders();
    } catch (e) {
      emit(SellerError('Gagal memperbarui status PO: $e'));
    }
  }

  Future<void> createProduct({
    required String name,
    required String baseUnit,
    String? description,
  }) async {
    try {
      emit(SellerLoading());
      await _repository.createProduct(name: name, baseUnit: baseUnit, description: description);
      emit(const SellerActionSuccess('Produk berhasil dibuat'));
      await loadProducts();
    } catch (e) {
      emit(SellerError('Gagal membuat produk: $e'));
    }
  }

  Future<void> createOffer({
    required int productId,
    required int minimumOrder,
    required int capacity,
    required List<PriceTier> tiers,
    required List<String> serviceAreas,
    required int deliveryCost,
    required DateTime validUntil,
  }) async {
    try {
      emit(SellerLoading());
      await _repository.createOffer(
        productId: productId,
        minimumOrder: minimumOrder,
        capacity: capacity,
        tiers: tiers,
        serviceAreas: serviceAreas,
        deliveryCost: deliveryCost,
        validUntil: validUntil,
      );
      emit(const SellerActionSuccess('Offer berhasil dibuat'));
      await loadOffers();
    } catch (e) {
      emit(SellerError('Gagal membuat offer: $e'));
    }
  }

  Future<void> loadDashboard() async {
    try {
      emit(SellerLoading());
      final orders = await _repository.getPurchaseOrders();
      final products = await _repository.getProducts();
      final offers = await _repository.getOffers();
      emit(SellerDashboardLoaded(
        purchaseOrders: orders,
        products: products,
        offers: offers,
        totalPO: orders.length,
        activeOffers: offers.where((o) => o.isActive).length,
        fulfillmentRate: _calculateFulfillmentRate(orders),
      ));
    } catch (e) {
      emit(SellerError('Gagal memuat dashboard: $e'));
    }
  }

  double _calculateFulfillmentRate(List<PurchaseOrderModel> orders) {
    if (orders.isEmpty) return 0;
    final completed = orders.where((po) => po.isCompleted || po.isShipped).length;
    return completed / orders.length;
  }
}
