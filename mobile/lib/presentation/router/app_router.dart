import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/cubits/auth/auth_cubit.dart';
import '../presentation/screens/role_selection/role_selection_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/campaign/campaign_detail_screen.dart';

/// Global navigation key for go_router
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration using go_router
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    // Get auth state
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    final isLoggedIn = authState is AuthAuthenticated;
    final isOtpSent = authState is AuthOtpSent;
    final currentPath = state.uri.path;

    // If not logged in and not on login/otp screens, redirect to login
    if (!isLoggedIn && !isOtpSent) {
      if (currentPath == '/' || currentPath.startsWith('/home')) {
        return '/login';
      }
    }

    // If OTP sent but not verified, redirect to OTP screen
    if (isOtpSent && currentPath != '/otp') {
      return '/otp';
    }

    // If logged in and on login/otp screens, redirect to home
    if (isLoggedIn && (currentPath == '/login' || currentPath == '/otp')) {
      return '/home';
    }

    return null;
  },
  routes: [
    // Root route - redirects based on auth state
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // Login route
    GoRoute(
      path: '/login',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // OTP verification route
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthOtpSent) {
          return OtpScreen(phoneNumber: authState.phoneNumber);
        }
        return const RoleSelectionScreen();
      },
    ),

    // Home with shell navigator for tabs
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(child: SizedBox.shrink()),
          ),
        ),
        GoRoute(
          path: '/campaigns/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return CampaignDetailScreen(campaignId: id);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri.path}',
        style: const TextStyle(fontSize: 18),
      ),
    ),
  ),
);

/// Extension to simplify navigation
extension GoRouterHelper on GoRouter {
  void pushCampaignDetail(int campaignId) {
    push('/campaigns/$campaignId');
  }
}
