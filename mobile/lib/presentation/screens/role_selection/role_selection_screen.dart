import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_theme.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _logger = GetIt.I<Logger>();

  void _selectRole(String role) {
    _logger.d('Role selected: $role');
    context.read<AuthCubit>().loginAsDemoUser(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),

              // Title
              Text(
                'Selamat Datang',
                style: AppTheme.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Grosirun\nBelanja Patungan Super Ringan',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),

              // Role selection buttons
              Text(
                'Pilih Role untuk Demo',
                style: AppTheme.titleMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 16),

              _RoleCard(
                icon: Icons.person,
                title: 'Pembeli (Buyer)',
                description: 'Buat dan pantau pesanan',
                color: AppTheme.info,
                onTap: () => _selectRole('buyer'),
              ).animate(delay: 800.ms).fadeIn().slideX(begin: -0.1),
              
              _RoleCard(
                icon: Icons.group,
                title: 'Inisiator',
                description: 'Buat campaign dan validasi pesanan',
                color: AppTheme.primary,
                onTap: () => _selectRole('initiator'),
              ).animate(delay: 900.ms).fadeIn().slideX(begin: -0.1),
              
              _RoleCard(
                icon: Icons.store,
                title: 'Penjual (Seller)',
                description: 'Kelola produk dan pesanan',
                color: AppTheme.warning,
                onTap: () => _selectRole('seller'),
              ).animate(delay: 1000.ms).fadeIn().slideX(begin: -0.1),

              const Spacer(),

              // Footer
              Text(
                '© 2026 Grosirun\nBelanja Patungan Super Ringan',
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
