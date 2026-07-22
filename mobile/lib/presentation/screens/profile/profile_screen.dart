import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../core/constants/app_constants.dart';

/// Profile screen — shows user info, role switcher, and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: Text('Belum login'));
        }
        final user = state.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: AppTheme.headlineLarge),
              Text(user.phoneNumber, style: AppTheme.bodyMedium),
              if (user.clusterName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(user.clusterName!, style: AppTheme.bodyMedium),
                ),
              const SizedBox(height: 24),

              // Role info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role Aktif', style: AppTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: user.roles.map((role) {
                        final isActive = role == user.activeRole;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_roleLabel(role)),
                            selected: isActive,
                            onSelected: isActive
                                ? null
                                : (_) => context.read<AuthCubit>().switchRole(role),
                            selectedColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              color: isActive ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info cards
              _InfoTile(
                icon: Icons.shield,
                title: 'Privasi & Keamanan',
                subtitle: 'Consent UU PDP ✅ • ToS Non-Escrow ✅',
              ),
              _InfoTile(
                icon: Icons.info_outline,
                title: 'Versi Aplikasi',
                subtitle: 'Grosirun v1.0.0 (Mock Data)',
              ),
              _InfoTile(
                icon: Icons.help_outline,
                title: 'Bantuan & FAQ',
                subtitle: 'Panduan penggunaan',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Keluar?'),
                        content: const Text('Kamu perlu login ulang untuk masuk kembali.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthCubit>().logout();
                            },
                            child: Text('Keluar', style: TextStyle(color: AppTheme.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.logout, color: AppTheme.error),
                  label: Text('Keluar', style: TextStyle(color: AppTheme.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.error),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case UserRole.buyer:
        return 'Pembeli';
      case UserRole.initiator:
        return 'Inisiator';
      case UserRole.seller:
        return 'Penjual';
      case UserRole.admin:
        return 'Admin';
      default:
        return role;
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: AppTheme.bodyLarge),
        subtitle: Text(subtitle, style: AppTheme.bodyMedium),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
