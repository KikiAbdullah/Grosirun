import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const Gap(24),
            Text(
              AppConstants.appName,
              style: AppTheme.headlineLarge,
            ),
            const Gap(8),
            Text(
              AppConstants.tagline,
              style: AppTheme.bodyMedium,
            ),
            const Gap(32),
            const CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
