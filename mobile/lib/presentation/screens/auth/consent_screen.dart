import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../widgets/big_button.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Kebijakan Privasi')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined,
                      size: 42,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Gap(24),
                  Text('Persetujuan UU PDP', style: AppTheme.headlineLarge),
                  const Gap(8),
                  Text(
                    'Kami menyimpan nomor WhatsApp, data profil, dan riwayat transaksi untuk kebutuhan PO RT/RW.',
                    style: AppTheme.bodyMedium,
                  ),
                  const Gap(24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text(
                      'Ringkasan dokumen:\n'
                      '1. Data dipakai untuk login dan pencatatan transaksi.\n'
                      '2. Data tidak dijual ke pihak ketiga.\n'
                      '3. Akun bisa dihapus sesuai kebijakan privasi.\n'
                      '4. Bukti transaksi disimpan sesuai retensi dokumen.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const Gap(24),
                  CheckboxListTile(
                    value: _accepted,
                    onChanged: (value) => setState(() => _accepted = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'Saya setuju data WhatsApp disimpan untuk PO RT saja, sesuai UU PDP No.27/2022.',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Gap(16),
                  BigButton(
                    label: 'Lanjutkan',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: isLoading,
                    onPressed: _accepted ? () => context.read<AuthCubit>().acceptConsent() : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
