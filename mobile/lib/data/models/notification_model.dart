import 'package:equatable/equatable.dart';

/// Notification model matching API_SPEC fallback notifications
class NotificationModel extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, isRead];
}
