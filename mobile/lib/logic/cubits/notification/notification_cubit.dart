import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/repositories.dart';

// ─── States ───

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications.length, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  Future<void> loadNotifications() async {
    try {
      emit(NotificationLoading());
      final notifications = await _repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError('Gagal memuat notifikasi: $e'));
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      emit(NotificationError('Gagal menandai notifikasi: $e'));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      emit(NotificationError('Gagal menandai semua notifikasi: $e'));
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      await loadNotifications();
    } catch (e) {
      emit(NotificationError('Gagal menghapus notifikasi: $e'));
    }
  }

  int getUnreadCount() {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      return currentState.unreadCount;
    }
    return 0;
  }
}
