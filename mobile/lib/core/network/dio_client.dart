import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// Dio HTTP client with interceptors for logging, caching, and error handling
class DioClient {
  late final Dio _dio;
  final Logger _logger;

  DioClient({Logger? logger}) : _logger = logger ?? Logger() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Pretty logger (only in debug mode)
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

    // Cache interceptor
    final cacheOptions = CacheOptions(
      store: HiveCacheStore('http_cache'),
      policy: CachePolicy.forceCache,
      priority: CachePriority.high,
      maxStale: const Duration(days: 7),
      hitCacheOnErrorExcept: const [401, 403],
      keyBuilder: (request) => request.uri.toString(),
      allowPostMethod: false,
    );
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    // Auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add custom headers
          options.headers['X-App-Version'] = '1.0.0';
          options.headers['X-Platform'] = 'mobile';
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          _logger.e('Error message: ${error.message}');
          
          // Handle specific errors
          if (error.response?.statusCode == 401) {
            // Token expired, redirect to login
            _logger.w('Token expired, please login again');
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    try {
      final box = await Hive.openBox('secure_box');
      return box.get('auth_token');
    } catch (e) {
      _logger.e('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getToken() => _getToken();

  Future<void> setToken(String token) async {
    try {
      final box = await Hive.openBox('secure_box');
      await box.put('auth_token', token);
    } catch (e) {
      _logger.e('Error setting token: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      final box = await Hive.openBox('secure_box');
      await box.delete('auth_token');
    } catch (e) {
      _logger.e('Error clearing token: $e');
    }
  }

  Dio get dio => _dio;
}
