import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../widgets/big_button.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().length != AppConstants.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit OTP')),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(
          phoneNumber: widget.phoneNumber,
          otpCode: _controller.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Verifikasi OTP')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(12),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 42,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      'Masukkan kode OTP',
                      style: AppTheme.headlineLarge,
                    ),
                    const Gap(8),
                    Text(
                      'Kode dikirim ke ${widget.phoneNumber}. Setelah verifikasi, kamu akan masuk ke consent dan ToS.',
                      style: AppTheme.bodyMedium,
                    ),
                    const Gap(32),
                    PinCodeTextField(
                      appContext: context,
                      length: AppConstants.otpLength,
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      autoDismissKeyboard: true,
                      enableActiveFill: true,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 56,
                        fieldWidth: 48,
                        activeFillColor: Colors.white,
                        inactiveFillColor: AppTheme.surface,
                        selectedFillColor: AppTheme.primaryLight,
                        activeColor: AppTheme.primary,
                        inactiveColor: AppTheme.border,
                        selectedColor: AppTheme.primary,
                      ),
                      onCompleted: (_) => _submit(),
                    ),
                    const Gap(16),
                    const Text(
                      'Jika belum menerima OTP, tunggu sebentar lalu kirim ulang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Gap(24),
                    BigButton(
                      label: 'Verifikasi',
                      icon: Icons.verified_outlined,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const Gap(12),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<AuthCubit>().requestOtp(widget.phoneNumber),
                      child: const Text('Kirim ulang OTP'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
