import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../logic/cubits/seller/seller_cubit.dart';
import '../../widgets/big_button.dart';

/// Seller workspace – full dashboard with metrics, PO list, and navigation.
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerCubit>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerCubit, SellerState>(
      builder: (context, state) {
        if (state is SellerLoading || state is SellerInitial) {
          return const _DashboardShimmer();
        }

        if (state is SellerError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context.read<SellerCubit>().loadDashboard(),
          );
        }

        if (state is SellerDashboardLoaded) {
          return _DashboardContent(state: state);
        }

        return const _DashboardShimmer();
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final SellerDashboardLoaded state;

  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─── Privacy Banner ───
        _PrivacyBanner(),
        const Gap(16),

        // ─── Metrics ───
        const Text('Metrik', style: AppTheme.titleLarge),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.shopping_cart_outlined,
                label: 'Purchase Order',
                value: '${state.totalPO}',
                color: AppTheme.info,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _MetricCard(
                icon: Icons.local_offer_outlined,
                label: 'Offer Aktif',
                value: '${state.activeOffers}',
                color: AppTheme.primary,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _MetricCard(
                icon: Icons.percent_outlined,
                label: 'Fulfillment',
                value: '${(state.fulfillmentRate * 100).toStringAsFixed(0)}%',
                color: AppTheme.success,
              ),
            ),
          ],
        ),
        const Gap(16),

        // ─── Quick Actions ───
        const Text('Aksi Cepat', style: AppTheme.titleLarge),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.inventory_2_outlined,
                label: 'Produk',
                onTap: () => context.push('/seller/products'),
              ),
            ),
            const Gap(8),
            Expanded(
              child: _QuickAction(
                icon: Icons.local_offer_outlined,
                label: 'Offer',
                onTap: () => context.push('/seller/offers'),
              ),
            ),
            const Gap(8),
            Expanded(
              child: _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'PO',
                onTap: () => context.push('/seller/purchase-orders'),
              ),
            ),
          ],
        ),
        const Gap(16),

        // ─── Recent Purchase Orders ───
        Row(
          children: [
            const Expanded(child: Text('Purchase Orders', style: AppTheme.titleLarge)),
            TextButton(
              onPressed: () => context.push('/seller/purchase-orders'),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const Gap(8),
        if (state.purchaseOrders.isEmpty)
          const _EmptyList(
            icon: Icons.receipt_long_outlined,
            message: 'Belum ada purchase order',
          )
        else
          ...state.purchaseOrders.take(5).map((po) => _POCard(
                po: po,
                onTap: () => context.push('/seller/purchase-orders/${po.id}'),
              )),
        const Gap(24),
      ],
    );
  }
}

// ─── Purchase Order Card ───

class _POCard extends StatelessWidget {
  final PurchaseOrderModel po;
  final VoidCallback onTap;

  const _POCard({required this.po, required this.onTap});

  Color get _statusColor {
    if (po.isSubmitted) return AppTheme.warning;
    if (po.isAccepted || po.isPaid) return AppTheme.info;
    if (po.isProcessing || po.isShipped) return AppTheme.primary;
    if (po.isCompleted) return AppTheme.success;
    if (po.isRejected || po.isCancelled) return AppTheme.error;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _statusColor.withOpacity(0.12),
                    child: Text(
                      po.code.substring(po.code.length - 1),
                      style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(po.code, style: AppTheme.titleMedium),
                        Text(
                          '${po.initiatorName} • ${po.productName}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(label: po.statusLabel, color: _statusColor),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Text(
                    '${po.quantity} ${po.unit}',
                    style: AppTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    'Rp${AppConstants.formatPrice(po.totalAmount)}',
                    style: AppTheme.titleMedium,
                  ),
                ],
              ),
              if (po.isSubmitted) ...[
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: BigButton(
                        label: 'Accept',
                        icon: Icons.check_circle_outline,
                        onPressed: () {
                          context.read<SellerCubit>().acceptPurchaseOrder(po.id);
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context, po),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
              if (po.isPaid) ...[
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: BigButton(
                        label: 'Proses',
                        icon: Icons.work_outline,
                        onPressed: () {
                          context.read<SellerCubit>().updatePOStatus(po.id, status: POStatus.processing);
                        },
                      ),
                    ),
                  ],
                ),
              ],
              if (po.isProcessing) ...[
                const Gap(12),
                BigButton(
                  label: 'Kirim',
                  icon: Icons.local_shipping_outlined,
                  onPressed: () {
                    context.read<SellerCubit>().updatePOStatus(po.id, status: POStatus.shipped);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, PurchaseOrderModel po) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tolak Purchase Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wajib mengisi alasan penolakan.'),
            const Gap(12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<SellerCubit>().rejectPurchaseOrder(
                      po.id,
                      reason: controller.text,
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Tolak', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ───

class _PrivacyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppTheme.info),
          const Gap(12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privasi Data Buyer', style: AppTheme.titleMedium),
                Gap(4),
                Text(
                  'Data Buyer tetap tersembunyi. Seller hanya melihat agregat kuantitas, dokumen PO, dan status fulfillment.',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const Gap(8),
            Text(value, style: AppTheme.headlineMedium),
            const Gap(2),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary),
              const Gap(8),
              Text(label, style: AppTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyList({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppTheme.textDisabled),
            const Gap(12),
            Text(message, style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const Gap(12),
            Text(message, style: AppTheme.titleMedium, textAlign: TextAlign.center),
            const Gap(16),
            BigButton(label: 'Coba Lagi', icon: Icons.refresh, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        6,
        (i) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
