import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/repositories.dart';
import 'logic/cubits/auth/auth_cubit.dart';
import 'logic/cubits/campaign/campaign_cubit.dart';
import 'presentation/screens/role_selection/role_selection_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GrosirunApp());
}

class GrosirunApp extends StatelessWidget {
  const GrosirunApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final authRepository = AuthRepository();
    final campaignRepository = CampaignRepository();
    final orderRepository = OrderRepository();
    final notificationRepository = NotificationRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: campaignRepository),
        RepositoryProvider.value(value: orderRepository),
        RepositoryProvider.value(value: notificationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(authRepository)..checkStatus()),
          BlocProvider(create: (_) => CampaignListCubit(campaignRepository)),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const _AppGate(),
        ),
      ),
    );
  }
}

/// Decides which screen to show based on auth state.
class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        if (state is AuthOtpSent) {
          return LoginScreen(phoneNumber: state.phoneNumber);
        }
        return const RoleSelectionScreen();
      },
    );
  }
}
