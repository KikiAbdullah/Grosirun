import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/repositories.dart';

// ─── States ───

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phoneNumber;
  const AuthOtpSent(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user.id, user.activeRole];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Events ───

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthRequestOtp extends AuthEvent {
  final String phoneNumber;
  const AuthRequestOtp(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtp extends AuthEvent {
  final String phoneNumber;
  final String otpCode;
  const AuthVerifyOtp(this.phoneNumber, this.otpCode);
  @override
  List<Object?> get props => [phoneNumber, otpCode];
}

class AuthSwitchRole extends AuthEvent {
  final String role;
  const AuthSwitchRole(this.role);
  @override
  List<Object?> get props => [role];
}

class AuthLogout extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

// ─── Cubit ───

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> requestOtp(String phoneNumber) async {
    emit(AuthLoading());
    try {
      // Mock: just simulate success
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthOtpSent(phoneNumber));
    } catch (e) {
      emit(AuthError('Gagal mengirim OTP. Coba lagi ya.'));
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otpCode) async {
    emit(AuthLoading());
    try {
      final user = await _repository.loginWithOtp(phoneNumber, otpCode);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Kode OTP salah atau kadaluarsa.'));
    }
  }

  Future<void> switchRole(String role) async {
    try {
      final user = await _repository.switchActiveRole(role);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Gagal mengganti role.'));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(AuthInitial());
  }

  Future<void> checkStatus() async {
    if (_repository.isLoggedIn) {
      final user = await _repository.getCurrentUser();
      emit(AuthAuthenticated(user));
    }
  }
}
