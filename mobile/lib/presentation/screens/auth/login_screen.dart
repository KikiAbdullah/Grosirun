import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../widgets/big_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '081234567890');
  bool _accepted = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang persetujuan UU PDP terlebih dahulu.')),
      );
      return;
    }
    context.read<AuthCubit>().requestOtp(_phoneController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.go('/otp');
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(24),
                    Container(
                      width: 88,
                      height: 88,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 42,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      'Masuk ke Grosirun',
                      style: AppTheme.headlineLarge,
                    ),
                    const Gap(8),
                    Text(
                      'Masukkan nomor WhatsApp untuk menerima OTP dan melanjutkan ke consent UU PDP.',
                      style: AppTheme.bodyMedium,
                    ),
                    const Gap(32),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp',
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Nomor WhatsApp wajib diisi';
                        }
                        if (text.length < 10) {
                          return 'Nomor terlalu pendek';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Text(
                        'Data digunakan untuk login, pencatatan transaksi RT, dan kepatuhan UU PDP. Setelah OTP, kamu akan diminta setuju privasi dan ToS non-escrow.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const Gap(12),
                    CheckboxListTile(
                      value: _accepted,
                      onChanged: (value) => setState(() => _accepted = value ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Setuju UU PDP No.27/2022'),
                    ),
                    const Gap(24),
                    BigButton(
                      label: 'Kirim OTP',
                      icon: Icons.sms_outlined,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const Gap(12),
                    TextButton(
                      onPressed: isLoading || !_accepted
                          ? null
                          : () => context.read<AuthCubit>().loginAsDemoUser(
                                UserRole.buyer,
                              ),
                      child: const Text('Masuk demo buyer'),
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
