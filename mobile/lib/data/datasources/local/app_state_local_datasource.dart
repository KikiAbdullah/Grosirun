import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

/// Persists the last navigation state so the app can restore context after
/// being killed by the OS.
class AppStateLocalDatasource {
  Box get _box => Hive.box(AppConstants.boxAppState);

  Future<void> saveAppState({
    required String lastRoute,
    int? lastCampaignId,
  }) async {
    await _box.put(AppConstants.keyLastRoute, lastRoute);
    if (lastCampaignId != null) {
      await _box.put(AppConstants.keyLastCampaignId, lastCampaignId);
    }
    await _box.put(
      AppConstants.keyLastActiveAt,
      DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> getAppState() {
    return <String, dynamic>{
      AppConstants.keyLastRoute: _box.get(AppConstants.keyLastRoute),
      AppConstants.keyLastCampaignId: _box.get(AppConstants.keyLastCampaignId),
      AppConstants.keyLastActiveAt: _box.get(AppConstants.keyLastActiveAt),
    };
  }

  /// Whether the saved state is still valid (< 30 minutes old).
  bool get isStateFresh {
    final raw = _box.get(AppConstants.keyLastActiveAt) as String?;
    if (raw == null) return false;
    final lastActive = DateTime.parse(raw);
    return DateTime.now().difference(lastActive).inMinutes < 30;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
