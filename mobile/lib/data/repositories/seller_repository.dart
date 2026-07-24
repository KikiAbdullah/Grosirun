import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/local/offline_queue_datasource.dart';
import '../datasources/remote/mock_data.dart';
import '../models/purchase_order_model.dart';
import '../models/seller_product_model.dart';
import '../models/supplier_offer_model.dart';

/// Repository for seller-specific operations.
class SellerRepository {
  final Logger _logger = GetIt.I<Logger>();
  final OfflineQueueDatasource _queue = OfflineQueueDatasource();

  SellerRepository();

  Box get _productBox => Hive.box('seller_products_box');
  Box get _offerBox => Hive.box('seller_offers_box');
  Box get _poBox => Hive.box('purchase_orders_box');

  // ─── Products ───

  Future<List<SellerProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.sellerProducts;
  }

  Future<SellerProductModel> getProductDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.sellerProducts.firstWhere((p) => p.id == id);
  }

  Future<SellerProductModel> createProduct({
    required String name,
    required String baseUnit,
    String? description,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final product = SellerProductModel(
      id: DateTime.now().millisecondsSinceEpoch,
      supplierId: 1,
      name: name,
      baseUnit: baseUnit,
      description: description,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
    _logger.i('Product created locally: ${product.name}');
    return product;
  }

  // ─── Offers ───

  Future<List<SupplierOfferModel>> getOffers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.supplierOffers;
  }

  Future<SupplierOfferModel> getOfferDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.supplierOffers.firstWhere((o) => o.id == id);
  }

  Future<SupplierOfferModel> createOffer({
    required int productId,
    required int minimumOrder,
    required int capacity,
    required List<PriceTier> tiers,
    required List<String> serviceAreas,
    required int deliveryCost,
    required DateTime validUntil,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final offer = SupplierOfferModel(
      id: DateTime.now().millisecondsSinceEpoch,
      supplierId: 1,
      supplierName: 'CV Makmur Jaya',
      productName: MockData.sellerProducts.isNotEmpty
          ? MockData.sellerProducts.first.name
          : 'Produk',
      unit: 'kg',
      minimumOrder: minimumOrder,
      capacity: capacity,
      tiers: tiers,
      serviceAreas: serviceAreas,
      deliveryCost: deliveryCost,
      validUntil: validUntil,
      status: OfferStatus.pendingModeration,
      createdAt: DateTime.now(),
    );
    await _queue.enqueue(
      type: 'create_offer',
      payload: offer.toJson(),
    );
    _logger.i('Offer queued locally: ${offer.productName}');
    return offer;
  }

  // ─── Purchase Orders ───

  Future<List<PurchaseOrderModel>> getPurchaseOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.sellerPurchaseOrders;
  }

  Future<PurchaseOrderModel> getPurchaseOrderDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.sellerPurchaseOrders.firstWhere((po) => po.id == id);
  }

  Future<void> acceptPurchaseOrder(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('PO accepted: $id');
  }

  Future<void> rejectPurchaseOrder(int id, {required String reason}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('PO rejected: $id, reason: $reason');
  }

  Future<void> confirmPayment(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('PO payment confirmed: $id');
  }

  Future<void> updatePOStatus(int id, {required String status}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('PO status updated: $id → $status');
    await _queue.enqueue(
      type: 'update_po_status',
      payload: {'id': id, 'status': status},
    );
  }

  Future<void> uploadInvoice(int id, {required String filePath}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('Invoice uploaded for PO: $id');
  }

  Future<void> uploadShippingDoc(int id, {required String filePath}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logger.i('Shipping doc uploaded for PO: $id');
  }
}
