import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../core/theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = GetIt.I<InternetConnection>();

    return StreamBuilder<InternetStatus>(
      stream: connection.onStatusChange,
      initialData: InternetStatus.connected,
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == InternetStatus.connected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.offlineBannerBackground,
          child: const Row(
            children: [
              Icon(Icons.signal_wifi_off, size: 18, color: AppTheme.offlineBannerText),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kamu offline, data mungkin tidak terbaru',
                  style: TextStyle(
                    color: AppTheme.offlineBannerText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
