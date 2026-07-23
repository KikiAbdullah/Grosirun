import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../logic/cubits/order/order_cubit.dart';
import '../../widgets/big_button.dart';
import '../../widgets/offline_banner.dart';

class CampaignDetailScreen extends StatefulWidget {
  final int campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final Map<int, int> _quantities = {};
  String _paymentMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Pesanan tersimpan'),
              content: Text(
                state.order.paymentMethod == 'cash'
                    ? 'Pesanan kamu tercatat sebagai Menunggu Bayar. Datang ke rumah inisiator untuk bayar tunai.'
                    : 'Pesanan kamu tercatat sebagai Menunggu Validasi QRIS. Upload bukti transfer dari detail pesanan.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Tutup'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.go('/my-orders');
                  },
                  child: const Text('Lihat Pesanan'),
                ),
              ],
            ),
          );
        }
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, orderState) {
        return FutureBuilder<CampaignModel>(
          future: context.read<CampaignRepository>().getCampaignDetail(widget.campaignId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(title: const Text('Detail Campaign')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 56, color: AppTheme.error),
                      const Gap(12),
                      Text('Gagal memuat campaign', style: AppTheme.titleLarge),
                      const Gap(12),
                      BigButton(
                        label: 'Coba lagi',
                        icon: Icons.refresh_rounded,
                        onPressed: () => setState(() {}),
                      ),
                    ],
                  ),
                ),
              );
            }

            final campaign = snapshot.data!;
            final selectedEntries = _quantities.entries.where((entry) => entry.value > 0).toList();
            final totalQuantity = selectedEntries.fold<int>(0, (sum, entry) => sum + entry.value);
            final selectedEntry = selectedEntries.isNotEmpty ? selectedEntries.first : null;
            final selectedVariant = selectedEntry == null
                ? null
                : campaign.variants.firstWhere(
                    (item) => item.id == selectedEntry.key,
                    orElse: () => campaign.variants.first,
                  );
            final totalPrice = selectedEntry == null
                ? 0
                : selectedEntry.value * (selectedVariant?.quantityPerVariant ?? 1) * campaign.buyerUnitPrice;

            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: const Text('Detail Campaign'),
                actions: [
                  IconButton(
                    tooltip: 'Share WhatsApp',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      final shareText =
                          'Lihat campaign "${campaign.title}" di Grosirun: ${AppConstants.deepLinkPrefix}${campaign.id}';
                      Share.share(shareText);
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  const OfflineBanner(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _CampaignHeader(campaign: campaign),
                        const Gap(16),
                        _ProgressCard(campaign: campaign),
                        const Gap(16),
                        Text('Deskripsi', style: AppTheme.titleLarge),
                        const Gap(8),
                        Text(campaign.description, style: AppTheme.bodyLarge),
                        const Gap(16),
                        Text('Pilih Varian', style: AppTheme.titleLarge),
                        const Gap(8),
                        ...campaign.variants.map(
                          (variant) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _VariantSelector(
                              variant: variant,
                              selectedQty: _quantities[variant.id] ?? 0,
                              onChanged: (qty) {
                                setState(() {
                                  if (qty <= 0) {
                                    _quantities.remove(variant.id);
                                  } else {
                                    _quantities.clear();
                                    _quantities[variant.id] = qty;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        const Gap(16),
                        Text('Metode Pembayaran', style: AppTheme.titleLarge),
                        const Gap(8),
                        Row(
                          children: [
                            Expanded(
                              child: _PaymentChip(
                                label: 'Tunai',
                                icon: Icons.payments_outlined,
                                selected: _paymentMethod == 'cash',
                                onTap: () => setState(() => _paymentMethod = 'cash'),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _PaymentChip(
                                label: 'QRIS',
                                icon: Icons.qr_code_2_outlined,
                                selected: _paymentMethod == 'qris',
                                onTap: () => setState(() => _paymentMethod = 'qris'),
                              ),
                            ),
                          ],
                        ),
                        const Gap(100),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: SafeArea(
                minimum: const EdgeInsets.all(16),
                child: _CheckoutBar(
                  totalPrice: totalPrice,
                  quantity: totalQuantity,
                  isLoading: orderState is OrderLoading,
                  onCheckout: selectedEntry == null
                      ? null
                      : () {
                          context.read<OrderCubit>().createOrder(
                                campaignId: widget.campaignId,
                                variantId: selectedEntry.key,
                                quantity: selectedEntry.value,
                                paymentMethod: _paymentMethod,
                                totalPrice: totalPrice,
                                variantName: selectedVariant?.name ?? 'Varian',
                                campaignTitle: campaign.title,
                              );
                        },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CampaignHeader extends StatelessWidget {
  final CampaignModel campaign;

  const _CampaignHeader({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: campaign.imageUrl == null
                ? Container(
                    color: AppTheme.surface,
                    child: const Icon(Icons.image_outlined, size: 52, color: AppTheme.primary),
                  )
                : CachedNetworkImage(
                    imageUrl: campaign.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.surface,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
        ),
        const Gap(16),
        Text(campaign.title, style: AppTheme.headlineLarge),
        const Gap(4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text(campaign.clusterName)),
            Chip(label: Text(campaign.initiatorName)),
            Chip(label: Text(campaign.status), backgroundColor: AppTheme.primaryLight),
          ],
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final CampaignModel campaign;

  const _ProgressCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final progress = campaign.progressPercent.clamp(0.0, 1.0);
    final progressColor = progress >= 0.7 ? AppTheme.warning : AppTheme.primary;
    final daysLeft = campaign.deadline.difference(DateTime.now()).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: AppTheme.primary),
                const Gap(8),
                Expanded(
                  child: Text('Progress campaign', style: AppTheme.titleMedium),
                ),
                Text('${(progress * 100).toStringAsFixed(0)}%', style: AppTheme.titleMedium),
              ],
            ),
            const Gap(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 24,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            const Gap(12),
            Text(
              'Terkumpul ${campaign.currentQuantity} ${campaign.unit} dari target ${campaign.targetQuantity} ${campaign.unit}',
              style: AppTheme.bodyMedium,
            ),
            const Gap(4),
            Text(
              daysLeft <= 0 ? 'Sisa hari ini' : 'Sisa $daysLeft hari',
              style: AppTheme.labelMedium.copyWith(
                color: daysLeft < 1 ? AppTheme.error : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantSelector extends StatelessWidget {
  final CampaignVariantModel variant;
  final int selectedQty;
  final ValueChanged<int> onChanged;

  const _VariantSelector({
    required this.variant,
    required this.selectedQty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = selectedQty > 0;
    final canIncrease = variant.remaining > selectedQty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selectedQty > 0 ? AppTheme.primaryLight.withOpacity(0.18) : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selectedQty > 0 ? AppTheme.primary : AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.name, style: AppTheme.titleMedium),
                const Gap(4),
                Text('Sisa ${variant.remaining}', style: AppTheme.bodySmall),
              ],
            ),
          ),
          _QtyButton(
            icon: Icons.remove,
            enabled: canDecrease,
            onTap: () => onChanged(selectedQty - 1),
          ),
          SizedBox(
            width: 40,
            child: Center(child: Text('$selectedQty', style: AppTheme.titleMedium)),
          ),
          _QtyButton(
            icon: Icons.add,
            enabled: canIncrease,
            onTap: () => onChanged(selectedQty + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppTheme.primary : AppTheme.border,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 20, color: enabled ? Colors.white : AppTheme.textDisabled),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight.withOpacity(0.18) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? AppTheme.primary : AppTheme.textSecondary),
            const Gap(8),
            Text(label, style: AppTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final int totalPrice;
  final int quantity;
  final bool isLoading;
  final VoidCallback? onCheckout;

  const _CheckoutBar({
    required this.totalPrice,
    required this.quantity,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total $quantity item', style: AppTheme.bodyMedium),
                  Text(
                    'Rp${AppConstants.formatPrice(totalPrice)}',
                    style: AppTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: BigButton(
                label: 'Checkout',
                icon: Icons.check_circle_outline,
                isLoading: isLoading,
                onPressed: onCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
