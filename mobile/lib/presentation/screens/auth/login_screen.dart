import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';

/// OTP verification screen
class LoginScreen extends StatefulWidget {
  final String phoneNumber;
  const LoginScreen({super.key, required this.phoneNumber});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sms, color: AppTheme.primary, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  'Masukkan Kode OTP',
                  style: AppTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kode telah dikirim ke WhatsApp\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                // OTP input
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '------',
                    hintStyle: TextStyle(fontSize: 28, letterSpacing: 8, color: AppTheme.textDisabled),
                    counterText: '',
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Demo: masukkan 6 angka apapun',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.info),
                ),
                const SizedBox(height: 32),
                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final otp = _otpController.text.trim();
                            if (otp.length == 6) {
                              context.read<AuthCubit>().verifyOtp(widget.phoneNumber, otp);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Verifikasi'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().requestOtp(widget.phoneNumber);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP dikirim ulang')),
                    );
                  },
                  child: const Text('Kirim Ulang OTP'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
