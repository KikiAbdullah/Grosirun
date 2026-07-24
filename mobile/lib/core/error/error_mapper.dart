/// Human-readable error messages from API error codes.
///
/// Maps backend API error codes (ERR_xxx) to localized Indonesian strings
/// following the format defined in API_SPEC section 1.4.
library;

import 'package:dio/dio.dart';

class ErrorMapper {
  ErrorMapper._();

  /// Convert a [DioException] into a user-friendly Indonesian message.
  static String humanMessage(Object error) {
    if (error is! DioException) {
      return 'Koneksi terputus';
    }

    // Network-level errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi lambat, silakan coba lagi';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak ada koneksi internet';
    }
    if (error.type == DioExceptionType.cancel) {
      return 'Permintaan dibatalkan';
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'] as String?;
      final message = data['message'] as String?;
      if (code != null) {
        return _mapCode(code, message, data);
      }
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    final status = error.response?.statusCode;
    switch (status) {
      case 401:
        return 'Sesi habis, silakan login ulang';
      case 403:
        return 'Anda tidak memiliki akses ke fitur ini';
      case 404:
        return 'Data tidak ditemukan';
      case 409:
        return 'Data konflik, silakan refresh halaman';
      case 412:
        return 'Data sudah lama, silakan refresh dulu';
      case 413:
        return 'File terlalu besar';
      case 422:
        return 'Data tidak valid, periksa kembali';
      case 429:
        final retryAfter = error.response?.headers.value('retry-after');
        if (retryAfter != null) {
          return 'Terlalu banyak permintaan, tunggu $retryAfter detik';
        }
        return 'Terlalu banyak permintaan, tunggu sebentar';
      case 503:
        return 'Aplikasi sedang maintenance, coba lagi nanti';
      case null:
        return 'Koneksi terputus';
      default:
        return 'Terjadi kesalahan, coba lagi nanti';
    }
  }

  static String _mapCode(String code, String? fallback, Map<String, dynamic> data) {
    switch (code) {
      // ─── Auth Errors ───
      case 'ERR_001':
        return 'Kode OTP kadaluarsa, minta ulang';
      case 'ERR_001_RL':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'ERR_002':
        return 'Harus setuju privasi UU PDP';
      case 'ERR_003':
        return 'Harus setuju Syarat Layanan Non-Escrow';
      case 'ERR_004':
        final attempts = data['attempts'] ?? 0;
        return 'Kode OTP salah. Sisa $attempts percobaan.';
      case 'ERR_005':
        return 'Sesi habis, silakan login ulang';
      case 'ERR_006':
        return 'Anda tidak memiliki akses ke fitur ini';

      // ─── Cluster Errors ───
      case 'ERR_040':
        return 'Beda cluster RT, tidak bisa pesan di sini';
      case 'ERR_041':
        return 'Kode cluster tidak valid';

      // ─── Campaign Errors ───
      case 'ERR_011':
        return 'Target harus kelipatan varian terkecil';
      case 'ERR_012':
        return 'Tenggat waktu minimal 24 jam';
      case 'ERR_013':
        return 'PO tidak ditemukan';
      case 'ERR_014':
        return 'PO sudah tidak aktif';
      case 'ERR_017':
        return 'Maksimal 2 kali perpanjangan';

      // ─── Order Errors ───
      case 'ERR_020':
        return 'Pesanan tidak ditemukan';
      case 'ERR_021':
        return 'Anda tidak memiliki akses ke pesanan ini';
      case 'ERR_024':
        return 'Stok habis, pilih varian lain';
      case 'ERR_025':
        return 'Minimal 1, maksimal 100';

      // ─── Validation Errors ───
      case 'ERR_030':
        return 'Sudah divalidasi di device lain, refresh';
      case 'ERR_031':
        return 'Data sudah lama, refresh dulu';
      case 'ERR_033':
        return 'Alasan penolakan wajib diisi';
      case 'ERR_034':
        return 'Sudah lewat 5 menit, gunakan Override';
      case 'ERR_035':
        return 'Catatan override wajib diisi';

      // ─── Upload Errors ───
      case 'ERR_050':
        return 'File terlalu besar (max 2MB)';
      case 'ERR_051':
        return 'Format harus JPG atau PNG';
      case 'ERR_054':
        return 'Status tidak bisa upload bukti';
      case 'ERR_055':
        return 'Link bukti kadaluarsa, generate ulang';

      // ─── Rate Limit ───
      case 'ERR_060':
        return 'Terlalu banyak permintaan, tunggu sebentar';
      case 'ERR_061':
        return 'Terlalu banyak override, tunggu sebentar';

      // ─── System ───
      case 'ERR_100':
        return 'Terjadi kesalahan server, coba lagi';
      case 'ERR_101':
        return 'Aplikasi sedang maintenance, coba lagi nanti';
      case 'ERR_104':
        return 'Gagal upload, akan dicoba ulang nanti';
      case 'ERR_106':
        return 'Idempotency-Key tidak valid';

      default:
        return fallback ?? 'Terjadi kesalahan';
    }
  }

  /// Whether the error requires re-authentication.
  static bool requiresReAuth(Object error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }

  /// Whether the error indicates stale data needing a refresh.
  static bool isStaleData(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final code = (error.response?.data is Map)
          ? (error.response!.data as Map)['code']
          : null;
      return status == 412 || code == 'ERR_031';
    }
    return false;
  }
}
