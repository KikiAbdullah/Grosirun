import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import '../models/order_model.dart';
import '../datasources/remote/mock_data.dart';
import '../../core/network/dio_client.dart';

class OrderRepository {
  final DioClient _dioClient;
  final Logger _logger = GetIt.I<Logger>();

  OrderRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('Fetching orders - page: $page');
      
      // TODO: Implement real API call
      // final response = await _dioClient.dio.get(
      //   '/orders',
      //   queryParameters: {
      //     'page': page,
      //     'limit': limit,
      //   },
      // );
      // return (response.data['data'] as List)
      //     .map((json) => OrderModel.fromJson(json))
      //     .toList();

      // Mock response
      await Future.delayed(const Duration(milliseconds: 600));
      final orders = MockData.orders;
      
      _logger.i('Orders fetched: ${orders.length} items');
      return orders;
    } catch (e) {
      _logger.e('Error fetching orders: $e');
      throw Exception('Gagal memuat pesanan');
    }
  }

  Future<OrderModel> getOrderDetail(int id) async {
    try {
      _logger.d('Fetching order detail: $id');
      
      // TODO: Implement real API call
      // final response = await _dioClient.dio.get('/orders/$id');
      // return OrderModel.fromJson(response.data['data']);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 400));
      final order = MockData.orders.firstWhere((o) => o.id == id);
      
      _logger.i('Order detail fetched: ${order.campaignTitle}');
      return order;
    } catch (e) {
      _logger.e('Error fetching order detail: $e');
      throw Exception('Gagal memuat detail pesanan');
    }
  }

  Future<OrderModel> createOrder({
    required int campaignId,
    required int variantId,
    required int quantity,
    required String paymentMethod,
  }) async {
    try {
      _logger.d('Creating order - campaign: $campaignId, quantity: $quantity');
      
      // TODO: Implement real API call
      // final response = await _dioClient.dio.post(
      //   '/orders',
      //   data: {
      //     'campaign_id': campaignId,
      //     'variant_id': variantId,
      //     'quantity': quantity,
      //     'payment_method': paymentMethod,
      //   },
      // );
      // return OrderModel.fromJson(response.data['data']);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 800));
      final order = MockData.orders.first;
      
      _logger.i('Order created: ${order.id}');
      return order;
    } catch (e) {
      _logger.e('Error creating order: $e');
      throw Exception('Gagal membuat pesanan');
    }
  }

  Future<void> uploadPaymentProof({
    required int orderId,
    required String filePath,
  }) async {
    try {
      _logger.d('Uploading payment proof - order: $orderId, file: $filePath');
      
      // TODO: Implement real API call with multipart
      // final formData = FormData.fromMap({
      //   'proof': await MultipartFile.fromFile(filePath),
      // });
      // await _dioClient.dio.post(
      //   '/orders/$orderId/proof',
      //   data: formData,
      // );

      // Mock response
      await Future.delayed(const Duration(milliseconds: 1000));
      
      _logger.i('Payment proof uploaded for order: $orderId');
    } catch (e) {
      _logger.e('Error uploading payment proof: $e');
      throw Exception('Gagal upload bukti pembayaran');
    }
  }

  Future<void> validateOrder({
    required int orderId,
    required bool isValid,
    String? reason,
  }) async {
    try {
      _logger.d('Validating order: $orderId - valid: $isValid');
      
      // TODO: Implement real API call
      // await _dioClient.dio.post(
      //   '/orders/$orderId/validate',
      //   data: {
      //     'is_valid': isValid,
      //     if (reason != null) 'reason': reason,
      //   },
      // );

      // Mock response
      await Future.delayed(const Duration(milliseconds: 600));
      
      _logger.i('Order validated: $orderId');
    } catch (e) {
      _logger.e('Error validating order: $e');
      throw Exception('Gagal validasi pesanan');
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      _logger.d('Cancelling order: $orderId');
      
      // TODO: Implement real API call
      // await _dioClient.dio.post('/orders/$orderId/cancel');

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));
      
      _logger.i('Order cancelled: $orderId');
    } catch (e) {
      _logger.e('Error cancelling order: $e');
      throw Exception('Gagal membatalkan pesanan');
    }
  }

  Future<void> markAsDelivered(int orderId) async {
    try {
      _logger.d('Marking order as delivered: $orderId');
      
      // TODO: Implement real API call
      // await _dioClient.dio.post('/orders/$orderId/delivered');

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));
      
      _logger.i('Order marked as delivered: $orderId');
    } catch (e) {
      _logger.e('Error marking order as delivered: $e');
      throw Exception('Gagal menandai pesanan sebagai diterima');
    }
  }
}
