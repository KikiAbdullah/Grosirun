import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';

/// First screen: choose phone number role (mock: pick from demo users)
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _phoneController = TextEditingController();
  bool _consentChecked = false;
  bool _tosChecked = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo area
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.shopping_cart, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.tagline,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.primary),
              ),
              const SizedBox(height: 48),

              // Phone input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp',
                  hintText: '08123456789',
                  prefixIcon: Icon(Icons.phone),
                  prefixText: '+62 ',
                ),
              ),
              const SizedBox(height: 16),

              // Quick demo login buttons
              Text(
                'Demo Login (pilih role):',
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DemoButton(
                      label: 'Bu Siti\n(Pembeli)',
                      icon: Icons.person,
                      color: AppTheme.info,
                      onTap: () => _demoLogin('buyer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DemoButton(
                      label: 'Pak Agus\n(Inisiator)',
                      icon: Icons.groups,
                      color: AppTheme.primary,
                      onTap: () => _demoLogin('initiator'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DemoButton(
                      label: 'Andi\n(Penjual)',
                      icon: Icons.store,
                      color: AppTheme.warning,
                      onTap: () => _demoLogin('seller'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Consent checkboxes
              _ConsentCheckbox(
                checked: _consentChecked,
                onChanged: (v) => setState(() => _consentChecked = v ?? false),
                text: 'Saya setuju data WA disimpan untuk PO RT sesuai UU PDP No.27/2022',
              ),
              _ConsentCheckbox(
                checked: _tosChecked,
                onChanged: (v) => setState(() => _tosChecked = v ?? false),
                text: 'Saya paham Grosirun non-escrow (dana tidak ditahan aplikasi)',
              ),
              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _consentChecked && _tosChecked
                      ? () => _requestOtp()
                      : null,
                  child: const Text('Masuk dengan OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _demoLogin(String role) {
    if (!_consentChecked || !_tosChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang persetujuan dulu ya')),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp('081234567890', '123456');
  }

  void _requestOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      context.read<AuthCubit>().requestOtp('081234567890');
    } else {
      context.read<AuthCubit>().requestOtp(phone);
    }
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DemoButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final String text;

  const _ConsentCheckbox({
    required this.checked,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(value: checked, onChanged: onChanged),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
