import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../widgets/big_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final roles = user.roles.isEmpty ? const [UserRole.buyer] : user.roles;
        _selectedRole ??= user.activeRole ?? roles.first;

        return Scaffold(
          appBar: AppBar(title: const Text('Pilih Workspace')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Selamat datang, ${user.name}', style: AppTheme.headlineLarge),
                  const Gap(8),
                  Text(
                    AppConstants.defaultClusterCode,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Gap(24),
                  ...roles.map(
                    (role) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoleCard(
                        role: role,
                        selected: _selectedRole == role,
                        onTap: () => setState(() => _selectedRole = role),
                      ),
                    ),
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
                      'Role yang dipilih akan menentukan workspace dan data yang tampil. Buyer dan Initiator tetap mengikuti scope cluster.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Gap(24),
                  BigButton(
                    label: 'Masuk ke Beranda',
                    icon: Icons.home_outlined,
                    onPressed: () async {
                      final selectedRole = _selectedRole ?? roles.first;
                      await context.read<AuthCubit>().updateActiveRole(selectedRole);
                      final appState = Hive.box(AppConstants.boxAppState);
                      final pendingDeepLink = appState.get(AppConstants.keyPendingDeepLink) as String?;
                      await appState.delete(AppConstants.keyPendingDeepLink);

                      if (!mounted) {
                        return;
                      }

                      if (pendingDeepLink != null && pendingDeepLink.isNotEmpty) {
                        context.go(pendingDeepLink);
                        return;
                      }

                      context.go('/home');
                    },
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

class _RoleCard extends StatelessWidget {
  final String role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon, color) = switch (role) {
      UserRole.initiator => ('Inisiator', 'Kelola campaign dan validasi pembayaran', Icons.groups_rounded, AppTheme.primary),
      UserRole.seller => ('Seller', 'Kelola penawaran dan purchase order', Icons.storefront_rounded, AppTheme.warning),
      UserRole.admin => ('Admin', 'Moderasi dan audit platform', Icons.admin_panel_settings_rounded, AppTheme.error),
      _ => ('Buyer', 'Lihat campaign dan buat pesanan', Icons.shopping_bag_rounded, AppTheme.info),
    };

    return Card(
      color: selected ? color.withOpacity(0.08) : AppTheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleMedium),
                    const Gap(4),
                    Text(subtitle, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? color : AppTheme.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
