import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../widgets/big_button.dart';

class TosScreen extends StatefulWidget {
  const TosScreen({super.key});

  @override
  State<TosScreen> createState() => _TosScreenState();
}

class _TosScreenState extends State<TosScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Syarat Layanan Non-Escrow')),
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
                      Icons.gavel_rounded,
                      size: 42,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Gap(24),
                  Text('ToS Non-Escrow', style: AppTheme.headlineLarge),
                  const Gap(8),
                  Text(
                    'Grosirun hanya mencatat status pembayaran. Dana tidak ditahan platform dan tetap menjadi tanggung jawab pihak terkait.',
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
                      'Poin utama:\n'
                      '1. Grosirun bukan escrow.\n'
                      '2. Refund manual menjadi tanggung jawab inisiator.\n'
                      '3. Dispute mengikuti SOP pada User Guide.\n'
                      '4. Akun yang melanggar dapat dibatasi aksesnya.',
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
                      'Saya memahami dan menyetujui Syarat Layanan non-escrow Grosirun.',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Gap(16),
                  BigButton(
                    label: 'Saya Setuju',
                    icon: Icons.check_circle_outline,
                    isLoading: isLoading,
                    onPressed: _accepted ? () => context.read<AuthCubit>().acceptTos() : null,
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
