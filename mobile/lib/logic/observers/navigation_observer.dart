import 'package:flutter/material.dart';

import '../../data/datasources/local/app_state_local_datasource.dart';

/// Persists navigation state so the app can restore the last screen.
class NavigationObserver extends NavigatorObserver {
  final AppStateLocalDatasource _appStateLocal = AppStateLocalDatasource();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _saveState(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _saveState(newRoute);
  }

  void _saveState(Route<dynamic> route) {
    final settings = route.settings;
    final name = settings.name ?? 'unknown';

    int? campaignId;
    if (settings.arguments is int) {
      campaignId = settings.arguments as int;
    }

    _appStateLocal.saveAppState(
      lastRoute: name,
      lastCampaignId: campaignId,
    );
  }
}
