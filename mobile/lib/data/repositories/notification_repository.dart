import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/remote/mock_data.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Logger _logger = GetIt.I<Logger>();

  NotificationRepository();

  Box get _notificationBox => Hive.box(AppConstants.boxNotifications);

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final notifications = MockData.notifications;
    await _notificationBox.put(
      'notification_list',
      notifications.map((notification) => notification.toJson()).toList(),
    );
    return notifications;
  }

  Future<void> markAsRead(int notificationId) async {
    _logger.i('Notification marked read: $notificationId');
  }

  Future<void> markAllAsRead() async {
    _logger.i('All notifications marked read');
  }

  Future<void> deleteNotification(int notificationId) async {
    _logger.i('Notification deleted: $notificationId');
  }
}
