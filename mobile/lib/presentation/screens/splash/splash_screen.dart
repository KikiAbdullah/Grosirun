import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) {
        return;
      }

      final authState = context.read<AuthCubit>().state;
      String targetRoute = '/login';
      if (authState is AuthAuthenticated) {
        if (!authState.user.consentGiven) {
          targetRoute = '/consent';
        } else if (!authState.user.tosAccepted) {
          targetRoute = '/tos';
        } else {
          targetRoute = '/roles';
        }
      }

      if (mounted) {
        context.go(targetRoute);
      }
    });
  }

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
