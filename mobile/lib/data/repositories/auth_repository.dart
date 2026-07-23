import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/remote/mock_data.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = GetIt.I<Logger>();

  AuthRepository({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyAuthToken, value: token);
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyAuthToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
  }

  Future<void> saveCurrentUser(UserModel user) async {
    await _secureStorage.write(
      key: AppConstants.keyCurrentUser,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getStoredUser() async {
    try {
      final raw = await _secureStorage.read(key: AppConstants.keyCurrentUser);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error) {
      _logger.e('Error loading stored user: $error');
      return null;
    }
  }

  Future<void> clearStoredUser() async {
    await _secureStorage.delete(key: AppConstants.keyCurrentUser);
  }

  Future<void> requestOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logger.i('OTP requested for $phoneNumber');
  }

  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = MockData.authenticatedUser(
      activeRole: UserRole.buyer,
      consentGiven: false,
      tosAccepted: false,
    ).copyWith(
      phoneNumber: phoneNumber,
      name: 'Bu Siti Rahayu',
    );

    await saveToken('mock_token_${user.id}');
    await saveCurrentUser(user);
    return user;
  }

  Future<UserModel> acceptConsent(UserModel user) async {
    final updated = user.copyWith(
      consentGiven: true,
      activeRole: user.activeRole,
    );
    await saveCurrentUser(updated);
    return updated;
  }

  Future<UserModel> acceptTos(UserModel user) async {
    final updated = user.copyWith(
      tosAccepted: true,
      activeRole: user.activeRole,
    );
    await saveCurrentUser(updated);
    return updated;
  }

  Future<UserModel> loginAsDemoUser(String role) async {
    final user = MockData.authenticatedUser(
      activeRole: role,
      consentGiven: true,
      tosAccepted: true,
    );
    await saveToken('demo_token_${user.id}');
    await saveCurrentUser(user);
    return user;
  }

  Future<UserModel> getCurrentUser() async {
    final stored = await getStoredUser();
    if (stored != null) {
      return stored;
    }

    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final fallback = MockData.authenticatedUser(
      activeRole: UserRole.buyer,
      consentGiven: false,
      tosAccepted: false,
    );
    await saveCurrentUser(fallback);
    return fallback;
  }

  Future<UserModel> updateActiveRole(String role) async {
    final currentUser = await getCurrentUser();
    final updated = currentUser.copyWith(activeRole: role);
    await saveCurrentUser(updated);
    return updated;
  }

  Future<void> logout() async {
    await clearToken();
    await clearStoredUser();
  }
}
