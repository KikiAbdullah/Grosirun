import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../widgets/big_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(12),
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Center(child: Text(user.name, style: AppTheme.headlineMedium)),
              const Gap(4),
              Center(child: Text(user.phoneNumber, style: AppTheme.bodyMedium)),
              if (user.clusterName != null) ...[
                const Gap(4),
                Center(
                  child: Chip(
                    label: Text(user.clusterName!),
                    backgroundColor: AppTheme.surface,
                  ),
                ),
              ],
              const Gap(20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Kepatuhan', style: AppTheme.titleMedium),
                      const Gap(12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            label: 'Consent',
                            isActive: user.consentGiven,
                          ),
                          _StatusChip(
                            label: 'ToS',
                            isActive: user.tosAccepted,
                          ),
                          _StatusChip(
                            label: 'Role: ${user.activeRole ?? '-'}',
                            isActive: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('FAQ'),
                children: const [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Bagaimana kalau saya offline?'),
                    subtitle: Text('Data cache tetap tampil, dan transaksi tertentu bisa masuk antrian lokal.'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Apakah Grosirun menahan dana?'),
                    subtitle: Text('Tidak. Grosirun bukan escrow dan hanya mencatat status pembayaran.'),
                  ),
                ],
              ),
              const Gap(8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Privacy Policy'),
                children: const [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Versi kebijakan'),
                    subtitle: Text('Data digunakan untuk login, pencatatan transaksi, dan retensi yang diwajibkan.'),
                  ),
                ],
              ),
              const Gap(20),
              BigButton(
                label: 'Hapus Akun',
                icon: Icons.delete_outline,
                backgroundColor: AppTheme.error,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Endpoint hapus akun perlu disambungkan ke backend.'),
                    ),
                  );
                },
              ),
              const Gap(12),
              OutlinedButton.icon(
                onPressed: () => context.read<AuthCubit>().logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
              const Gap(12),
              Text(
                'Versi aplikasi: Grosirun ${AppConstants.tosVersion}',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusChip({
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: isActive ? AppTheme.primaryLight : AppTheme.border,
    );
  }
}
