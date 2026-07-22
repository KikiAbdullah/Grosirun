import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final Logger _logger = GetIt.I<Logger>();

  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      final token = await _repository.getToken();
      if (token == null) {
        emit(AuthInitial());
        return;
      }

      final user = await _repository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } catch (error) {
      _logger.e('Error checking auth status: $error');
      emit(AuthInitial());
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    try {
      emit(AuthLoading());
      await _repository.requestOtp(phoneNumber);
      emit(AuthOtpSent(phoneNumber));
    } catch (error) {
      emit(AuthError('Gagal mengirim OTP: $error'));
    }
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      emit(AuthLoading());
      final user = await _repository.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthError('OTP salah atau kedaluwarsa: $error'));
    }
  }

  Future<void> loginAsDemoUser(String role) async {
    try {
      emit(AuthLoading());
      final user = await _repository.loginAsDemoUser(role);
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthError('Gagal login demo: $error'));
    }
  }

  Future<void> acceptConsent() async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      return;
    }

    try {
      emit(AuthLoading());
      final user = await _repository.acceptConsent(currentState.user);
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthError('Gagal menyimpan consent: $error'));
    }
  }

  Future<void> acceptTos() async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      return;
    }

    try {
      emit(AuthLoading());
      final user = await _repository.acceptTos(currentState.user);
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthError('Gagal menyimpan ToS: $error'));
    }
  }

  Future<void> updateActiveRole(String role) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      return;
    }

    try {
      emit(AuthLoading());
      final user = await _repository.updateActiveRole(role);
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthError('Gagal mengubah role aktif: $error'));
    }
  }

  Future<void> logout() async {
    try {
      emit(AuthLoading());
      await _repository.logout();
      emit(AuthInitial());
    } catch (error) {
      emit(AuthError('Gagal logout: $error'));
    }
  }
}
