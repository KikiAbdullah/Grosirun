import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  final String phoneNumber;

  const LoginScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _logger = GetIt.I<Logger>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _otpController.text;
    if (otp.length == 6) {
      context.read<AuthCubit>().verifyOtp(
        phoneNumber: widget.phoneNumber,
        otpCode: otp,
      );
      _logger.i('OTP verification attempted for ${widget.phoneNumber}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            _logger.i('User authenticated successfully');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Login berhasil!'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Masukkan Kode OTP',
                    style: AppTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Kode telah dikirim ke\n${widget.phoneNumber}',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 40),

                  // OTP Input with PinCodeFields
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textStyle: AppTheme.titleLarge.copyWith(letterSpacing: 8),
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 56,
                      fieldWidth: 48,
                      activeFillColor: Colors.white,
                      inactiveFillColor: AppTheme.surface,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.border,
                      selectedFillColor: AppTheme.primary.withOpacity(0.1),
                      selectedColor: AppTheme.primary,
                    ),
                    enableActiveFill: true,
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enablePinAutofill: true,
                    errorTextSpace: 16,
                    onCompleted: (v) {
                      _logger.d('OTP completed: $v');
                      _verifyOtp();
                    },
                    onChanged: (value) {
                      // Optional: handle changes
                    },
                    beforeTextPaste: (text) {
                      _logger.d('Pasting OTP');
                      return true;
                    },
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                  const SizedBox(height: 24),

                  // Helper text
                  Text(
                    '💡 Demo: Masukkan 6 angka apapun',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 32),

                  // Verify button
                  ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Verifikasi',
                            style: TextStyle(fontSize: 16),
                          ),
                  ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),

                  // Resend button
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthCubit>().requestOtp(widget.phoneNumber);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('OTP dikirim ulang'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    child: const Text('Kirim Ulang OTP'),
                  ).animate().fadeIn(delay: 1200.ms),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
