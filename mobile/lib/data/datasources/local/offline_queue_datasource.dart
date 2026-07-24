import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';

/// Manages the offline mutation queue stored in Hive.
///
/// Only idempotent, non-financial operations are queued. Financial mutations,
/// verification, moderation, and dispute actions are **never** queued.
class OfflineQueueDatasource {
  final Logger _logger = GetIt.I<Logger>();
  final Uuid _uuid = const Uuid();

  Box get _box => Hive.box(AppConstants.boxQueue);

  /// Enqueue a pending mutation.
  Future<String> enqueue({
    required String type,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _uuid.v4();
    await _box.put(key, {
      'idempotency_key': key,
      'type': type,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
    _logger.i('Enqueued offline mutation: $type [$key]');
    return key;
  }

  /// Get all pending mutations.
  List<Map<String, dynamic>> getPending() {
    return _box.values.whereType<Map>().map((dynamic raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      return map;
    }).toList()
      ..sort((a, b) {
        final dateA = a['created_at'] as String? ?? '';
        final dateB = b['created_at'] as String? ?? '';
        return dateA.compareTo(dateB);
      });
  }

  /// Remove a processed mutation.
  Future<void> remove(String key) async {
    await _box.delete(key);
    _logger.i('Removed processed mutation: $key');
  }

  /// Increment retry count.
  Future<void> incrementRetry(String key) async {
    final existing = _box.get(key);
    if (existing is Map) {
      final map = Map<String, dynamic>.from(existing);
      final count = (map['retry_count'] as int? ?? 0) + 1;
      map['retry_count'] = count;
      await _box.put(key, map);
    }
  }

  /// Clear the entire queue.
  Future<void> clearAll() async {
    await _box.clear();
    _logger.i('Offline queue cleared');
  }

  /// Get count of pending mutations.
  int get pendingCount => _box.length;

  /// Serialize an item for the queue.
  static String serialize(Map<String, dynamic> data) => jsonEncode(data);

  /// Deserialize an item from the queue.
  static Map<String, dynamic> deserialize(String data) =>
      jsonDecode(data) as Map<String, dynamic>;
}
