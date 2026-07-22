import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/network/dio_client.dart';
import 'data/repositories/repositories.dart';
import 'logic/cubits/auth/auth_cubit.dart';
import 'logic/cubits/campaign/campaign_cubit.dart';
import 'logic/cubits/order/order_cubit.dart';
import 'logic/cubits/notification/notification_cubit.dart';
import 'presentation/router/app_router.dart';

/// GetIt service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // ─── Logger ───
  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    ),
  );

  // ─── Secure Storage ───
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // ─── Network ───
  getIt.registerLazySingleton<InternetConnection>(
    () => InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 10),
    ),
  );

  // ─── Dio Client ───
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(logger: getIt<Logger>()),
  );

  // ─── Repositories ───
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(secureStorage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<CampaignRepository>(
    () => CampaignRepository(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepository(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(dioClient: getIt<DioClient>()),
  );

  // ─── Hive Initialization ───
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox(AppConstants.boxUser),
    Hive.openBox(AppConstants.boxCampaigns),
    Hive.openBox(AppConstants.boxOrders),
    Hive.openBox(AppConstants.boxNotifications),
    Hive.openBox(AppConstants.boxQueue),
  ]);

  getIt.registerLazySingleton<Box>(
    () => Hive.box(AppConstants.boxAppState),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initDependencies();

  // Initialize Sentry (optional, uncomment when you have DSN)
  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn = 'YOUR_SENTRY_DSN';
  //     options.tracesSampleRate = 1.0;
  //   },
  // );

  runApp(const GrosirunApp());
}

class GrosirunApp extends StatelessWidget {
  const GrosirunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: getIt<AuthRepository>()),
        RepositoryProvider.value(value: getIt<CampaignRepository>()),
        RepositoryProvider.value(value: getIt<OrderRepository>()),
        RepositoryProvider.value(value: getIt<NotificationRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthCubit(getIt<AuthRepository>())..checkStatus(),
          ),
          BlocProvider(
            create: (_) => CampaignListCubit(getIt<CampaignRepository>()),
          ),
          BlocProvider(
            create: (_) => OrderCubit(getIt<OrderRepository>()),
          ),
          BlocProvider(
            create: (_) => NotificationCubit(getIt<NotificationRepository>()),
          ),
        ],
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
          builder: (context, child) {
            return Scaffold(
              body: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
