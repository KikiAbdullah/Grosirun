import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../logic/cubits/auth/auth_cubit.dart';
import '../../presentation/screens/auth/consent_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/tos_screen.dart';
import '../../presentation/screens/campaign/campaign_detail_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/role_selection/role_selection_screen.dart';
import '../../presentation/screens/workspaces/buyer_order_detail_screen.dart';
import '../../presentation/screens/workspaces/role_workspaces_screens.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthCubit authCubit) {
  final refreshNotifier = _GoRouterRefreshStream(authCubit.stream);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final currentPath = state.uri.path;
      final authState = authCubit.state;
      final appStateBox = Hive.box(AppConstants.boxAppState);

      if (authState is AuthLoading) {
        return null;
      }

      if (currentPath == '/') {
        return null;
      }

      final isAuthRoute = currentPath == '/login' ||
          currentPath == '/otp' ||
          currentPath == '/consent' ||
          currentPath == '/tos' ||
          currentPath == '/roles';

      if (authState is! AuthAuthenticated) {
        if (!isAuthRoute && currentPath.startsWith('/campaign/')) {
          appStateBox.put(AppConstants.keyPendingDeepLink, currentPath);
          return '/login';
        }

        if (!isAuthRoute) {
          return '/login';
        }

        return null;
      }

      final user = authState.user;
      if (!user.consentGiven) {
        return currentPath == '/consent' ? null : '/consent';
      }

      if (!user.tosAccepted) {
        return currentPath == '/tos' ? null : '/tos';
      }

      if (currentPath == '/login' || currentPath == '/otp' || currentPath == '/consent' || currentPath == '/tos') {
        return '/roles';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final authState = authCubit.state;
          final phoneNumber = authState is AuthOtpSent
              ? authState.phoneNumber
              : '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/consent',
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        path: '/tos',
        builder: (context, state) => const TosScreen(),
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/my-orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return BuyerOrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/initiator/dashboard',
        builder: (context, state) => const HomeScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/initiator/create',
        builder: (context, state) => const InitiatorCreateScreen(),
      ),
      GoRoute(
        path: '/initiator/recap/:id',
        builder: (context, state) {
          final campaignId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return InitiatorRecapScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: '/initiator/distribution/:id',
        builder: (context, state) {
          final campaignId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return InitiatorDistributionScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: '/seller/dashboard',
        builder: (context, state) => const HomeScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/seller/offers',
        builder: (context, state) => const SellerOffersScreen(),
      ),
      GoRoute(
        path: '/seller/purchase-orders',
        builder: (context, state) => const SellerPurchaseOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const HomeScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/admin/suppliers/verification',
        builder: (context, state) => const AdminSupplierVerificationScreen(),
      ),
      GoRoute(
        path: '/admin/offers/moderation',
        builder: (context, state) => const AdminOfferModerationScreen(),
      ),
      GoRoute(
        path: '/admin/disputes',
        builder: (context, state) => const AdminDisputesScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (context, state) => const AdminAuditScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/campaign/:id',
        builder: (context, state) {
          final campaignId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return CampaignDetailScreen(campaignId: campaignId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri.path}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
}
