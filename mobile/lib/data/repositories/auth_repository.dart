import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../datasources/remote/mock_data.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = GetIt.I<Logger>();

  AuthRepository({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(
        key: AppConstants.keyAuthToken,
        value: token,
      );
      _logger.i('Token saved successfully');
    } catch (e) {
      _logger.e('Error saving token: $e');
      throw Exception('Gagal menyimpan token');
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
      return token;
    } catch (e) {
      _logger.e('Error getting token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.keyAuthToken);
      _logger.i('Token cleared successfully');
    } catch (e) {
      _logger.e('Error clearing token: $e');
    }
  }

  Future<UserModel> requestOtp(String phoneNumber) async {
    try {
      _logger.d('Requesting OTP for $phoneNumber');
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock OTP request
      _logger.i('OTP sent successfully');
      return MockData.buyer;
    } catch (e) {
      _logger.e('Error requesting OTP: $e');
      throw Exception('Gagal mengirim OTP');
    }
  }

  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      _logger.d('Verifying OTP for $phoneNumber');
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock OTP verification
      final user = MockData.buyer;
      await saveToken('mock_token_${user.id}');
      
      _logger.i('OTP verified successfully');
      return user;
    } catch (e) {
      _logger.e('Error verifying OTP: $e');
      throw Exception('OTP salah atau kadaluarsa');
    }
  }

  Future<UserModel> loginAsDemoUser(String role) async {
    try {
      _logger.d('Logging in as demo user with role: $role');
      await Future.delayed(const Duration(milliseconds: 500));

      UserModel user;
      switch (role) {
        case 'initiator':
          user = MockData.initiator;
          break;
        case 'seller':
          user = MockData.seller;
          break;
        default:
          user = MockData.buyer;
      }

      await saveToken('demo_token_${user.id}');
      _logger.i('Demo login successful: ${user.name}');
      return user;
    } catch (e) {
      _logger.e('Error in demo login: $e');
      throw Exception('Gagal login sebagai demo user');
    }
  }

  Future<void> logout() async {
    try {
      await clearToken();
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Error during logout: $e');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      // Mock get current user
      _logger.d('Getting current user');
      return MockData.buyer;
    } catch (e) {
      _logger.e('Error getting current user: $e');
      throw Exception('Gagal mendapatkan data user');
    }
  }

  Future<UserModel> updateActiveRole(String role) async {
    try {
      _logger.d('Updating active role to: $role');
      await Future.delayed(const Duration(milliseconds: 300));

      final user = MockData.buyer.copyWith(activeRole: role);
      _logger.i('Active role updated: $role');
      return user;
    } catch (e) {
      _logger.e('Error updating role: $e');
      throw Exception('Gagal mengubah role');
    }
  }
}
