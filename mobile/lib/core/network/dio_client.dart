import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';

class DioClient {
  late final Dio _dio;
  final Logger _logger;
  final FlutterSecureStorage _secureStorage;

  DioClient({
    Logger? logger,
    FlutterSecureStorage? secureStorage,
  })  : _logger = logger ?? Logger(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    _dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: HiveCacheStore('http_cache'),
          policy: CachePolicy.forceCache,
          priority: CachePriority.high,
          maxStale: const Duration(days: 7),
          hitCacheOnErrorExcept: const [401, 403],
          keyBuilder: (request) => request.uri.toString(),
          allowPostMethod: false,
        ),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          options.headers['X-App-Version'] = '1.0.0';
          options.headers['X-Platform'] = 'mobile';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          _logger.e('Error message: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
