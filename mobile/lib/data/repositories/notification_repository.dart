import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import '../models/notification_model.dart';
import '../datasources/remote/mock_data.dart';
import '../../core/network/dio_client.dart';

class NotificationRepository {
  final DioClient _dioClient;
  final Logger _logger = GetIt.I<Logger>();

  NotificationRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('Fetching notifications - page: $page');
      
      // TODO: Implement real API call
      // final response = await _dioClient.dio.get(
      //   '/notifications',
      //   queryParameters: {
      //     'page': page,
      //     'limit': limit,
      //   },
      // );
      // return (response.data['data'] as List)
      //     .map((json) => NotificationModel.fromJson(json))
      //     .toList();

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));
      final notifications = MockData.notifications;
      
      _logger.i('Notifications fetched: ${notifications.length} items');
      return notifications;
    } catch (e) {
      _logger.e('Error fetching notifications: $e');
      throw Exception('Gagal memuat notifikasi');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      _logger.d('Marking notification as read: $notificationId');
      
      // TODO: Implement real API call
      // await _dioClient.dio.post('/notifications/$notificationId/read');

      // Mock response
      await Future.delayed(const Duration(milliseconds: 300));
      
      _logger.i('Notification marked as read: $notificationId');
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
      throw Exception('Gagal menandai notifikasi');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      _logger.d('Marking all notifications as read');
      
      // TODO: Implement real API call
      // await _dioClient.dio.post('/notifications/read-all');

      // Mock response
      await Future.delayed(const Duration(milliseconds: 400));
      
      _logger.i('All notifications marked as read');
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
      throw Exception('Gagal menandai semua notifikasi');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      _logger.d('Deleting notification: $notificationId');
      
      // TODO: Implement real API call
      // await _dioClient.dio.delete('/notifications/$notificationId');

      // Mock response
      await Future.delayed(const Duration(milliseconds: 300));
      
      _logger.i('Notification deleted: $notificationId');
    } catch (e) {
      _logger.e('Error deleting notification: $e');
      throw Exception('Gagal menghapus notifikasi');
    }
  }
}
