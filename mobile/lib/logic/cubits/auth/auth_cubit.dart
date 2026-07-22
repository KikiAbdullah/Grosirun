import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final Logger _logger = GetIt.I<Logger>();

  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      _logger.d('Checking auth status');
      emit(AuthLoading());

      final token = await _repository.getToken();
      if (token != null) {
        final user = await _repository.getCurrentUser();
        emit(AuthAuthenticated(user));
        _logger.i('User authenticated: ${user.name}');
      } else {
        emit(AuthInitial());
        _logger.i('No token found, user not authenticated');
      }
    } catch (e) {
      _logger.e('Error checking auth status: $e');
      emit(AuthInitial());
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    try {
      _logger.d('Requesting OTP for $phoneNumber');
      emit(AuthLoading());
      
      await _repository.requestOtp(phoneNumber);
      
      emit(AuthOtpSent(phoneNumber));
      _logger.i('OTP sent successfully');
    } catch (e) {
      _logger.e('Error requesting OTP: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      _logger.d('Verifying OTP for $phoneNumber');
      emit(AuthLoading());
      
      final user = await _repository.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      
      emit(AuthAuthenticated(user));
      _logger.i('OTP verified, user authenticated');
    } catch (e) {
      _logger.e('Error verifying OTP: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginAsDemoUser(String role) async {
    try {
      _logger.d('Logging in as demo user: $role');
      emit(AuthLoading());
      
      final user = await _repository.loginAsDemoUser(role);
      
      emit(AuthAuthenticated(user));
      _logger.i('Demo login successful: ${user.name}');
    } catch (e) {
      _logger.e('Error in demo login: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      _logger.d('Logging out');
      emit(AuthLoading());
      
      await _repository.logout();
      
      emit(AuthInitial());
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Error during logout: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateActiveRole(String role) async {
    try {
      _logger.d('Updating active role: $role');
      
      if (state is AuthAuthenticated) {
        final currentUser = (state as AuthAuthenticated).user;
        final updatedUser = await _repository.updateActiveRole(role);
        
        emit(AuthAuthenticated(updatedUser));
        _logger.i('Active role updated: $role');
      }
    } catch (e) {
      _logger.e('Error updating active role: $e');
      emit(AuthError(e.toString()));
    }
  }
}
