import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/remote/mock_data.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Logger _logger = GetIt.I<Logger>();
  final Uuid _uuid = const Uuid();

  OrderRepository();

  Box get _orderBox => Hive.box(AppConstants.boxOrders);
  Box get _queueBox => Hive.box(AppConstants.boxQueue);
  Box get _proofBox => Hive.box(AppConstants.boxProofUploads);

  Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cached = _orderBox.get('order_list') as List<dynamic>?;
    final cachedOrders = cached
        ?.whereType<Map>()
        .map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    final latest = _orderBox.get('latest_order');
    final latestOrder = latest is Map
        ? OrderModel.fromJson(Map<String, dynamic>.from(latest))
        : null;

    final orders = <OrderModel>[
      if (latestOrder != null) latestOrder,
      ...?cachedOrders,
      ...MockData.myOrders,
    ];
    final uniqueOrders = <int, OrderModel>{};
    for (final order in orders) {
      uniqueOrders[order.id] = order;
    }
    final result = uniqueOrders.values.toList();
    await _orderBox.put('order_list', result.map((order) => order.toJson()).toList());
    return result;
  }

  Future<OrderModel> getOrderDetail(int id) async {
    final cached = _orderBox.get('order_list') as List<dynamic>?;
    final fromCache = cached
        ?.whereType<Map>()
        .map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json)))
        .where((order) => order.id == id)
        .toList();
    if (fromCache != null && fromCache.isNotEmpty) {
      return fromCache.first;
    }
    return MockData.myOrders.firstWhere((order) => order.id == id);
  }

  Future<OrderModel> createOrder({
    required int campaignId,
    required int variantId,
    required int quantity,
    required String paymentMethod,
    required int totalPrice,
    required String variantName,
    required String campaignTitle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final existingOrders = await getOrders();
    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch,
      campaignId: campaignId,
      campaignTitle: campaignTitle,
      userId: MockData.myOrders.first.userId,
      userName: MockData.myOrders.first.userName,
      variantId: variantId,
      variantName: variantName,
      quantity: quantity,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cash'
          ? PaymentStatus.pending
          : PaymentStatus.waitingQris,
      proofUrl: null,
      validationNotes: null,
      validatedById: null,
      createdAt: DateTime.now(),
      validatedAt: null,
    );

    await _queueBox.put(
      _uuid.v4(),
      {
        'type': 'create_order',
        'order': order.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    await _orderBox.put('latest_order', order.toJson());
    await _orderBox.put(
      'order_list',
      [
        order.toJson(),
        ...existingOrders.map((item) => item.toJson()).toList(),
      ],
    );
    _logger.i('Order queued locally: ${order.id}');
    return order;
  }

  Future<void> uploadPaymentProof({
    required int orderId,
    required String filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _proofBox.put(
      'proof_$orderId',
      {
        'order_id': orderId,
        'file_path': filePath,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    await _queueBox.put(
      _uuid.v4(),
      {
        'type': 'upload_proof',
        'order_id': orderId,
        'file_path': filePath,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    final current = await getOrders();
    final updated = current.map((order) {
      if (order.id != orderId) {
        return order;
      }
      return order.copyWith(
        proofUrl: filePath,
        paymentStatus: PaymentStatus.waitingQris,
      );
    }).toList();
    await _orderBox.put('order_list', updated.map((order) => order.toJson()).toList());
    _logger.i('Proof queued locally for order: $orderId');
  }

  Future<void> validateOrder({
    required int orderId,
    required bool isValid,
    String? reason,
  }) async {
    _logger.i('Validate order: $orderId ($isValid)');
  }

  Future<void> cancelOrder(int orderId) async {
    final current = await getOrders();
    final updated = current.map((order) {
      if (order.id != orderId) {
        return order;
      }
      return order.copyWith(paymentStatus: PaymentStatus.cancelled);
    }).toList();
    await _orderBox.put('order_list', updated.map((order) => order.toJson()).toList());
    _logger.i('Cancel order: $orderId');
  }

  Future<void> markAsDelivered(int orderId) async {
    _logger.i('Mark order delivered: $orderId');
  }
}

extension OrderCopy on OrderModel {
  OrderModel copyWith({
    int? id,
    int? campaignId,
    String? campaignTitle,
    int? userId,
    String? userName,
    int? variantId,
    String? variantName,
    int? quantity,
    int? totalPrice,
    String? paymentMethod,
    String? paymentStatus,
    String? proofUrl,
    String? validationNotes,
    int? validatedById,
    DateTime? createdAt,
    DateTime? validatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      proofUrl: proofUrl ?? this.proofUrl,
      validationNotes: validationNotes ?? this.validationNotes,
      validatedById: validatedById ?? this.validatedById,
      createdAt: createdAt ?? this.createdAt,
      validatedAt: validatedAt ?? this.validatedAt,
    );
  }
}
