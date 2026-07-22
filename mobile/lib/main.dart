import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'core/constants/app_constants.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/campaign_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/order_repository.dart';
import 'logic/cubits/auth/auth_cubit.dart';
import 'logic/cubits/campaign/campaign_cubit.dart';
import 'logic/cubits/notification/notification_cubit.dart';
import 'logic/cubits/order/order_cubit.dart';
import 'presentation/router/app_router.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: false,
        printTime: true,
      ),
    ),
  );

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  getIt.registerLazySingleton<InternetConnection>(
    () => InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 10),
    ),
  );

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(logger: getIt<Logger>(), secureStorage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(secureStorage: getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<CampaignRepository>(() => CampaignRepository());
  getIt.registerLazySingleton<OrderRepository>(() => OrderRepository());
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepository());

  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(repository: getIt<AuthRepository>()),
  );

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox(AppConstants.boxCampaigns),
    Hive.openBox(AppConstants.boxOrders),
    Hive.openBox(AppConstants.boxNotifications),
    Hive.openBox(AppConstants.boxQueue),
    Hive.openBox(AppConstants.boxAppState),
    Hive.openBox(AppConstants.boxUser),
    Hive.openBox(AppConstants.boxProofUploads),
    Hive.openBox(AppConstants.boxEtag),
    Hive.openBox(AppConstants.boxIdempotency),
  ]);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await getIt<AuthCubit>().checkAuthStatus();
  runApp(GrosirunApp(router: createAppRouter(getIt<AuthCubit>())));
}

class GrosirunApp extends StatelessWidget {
  final GoRouter router;

  const GrosirunApp({super.key, required this.router});

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
          BlocProvider.value(value: getIt<AuthCubit>()),
          BlocProvider(
            create: (_) => CampaignCubit(repository: getIt<CampaignRepository>()),
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
          routerConfig: router,
        ),
      ),
    );
  }
}
