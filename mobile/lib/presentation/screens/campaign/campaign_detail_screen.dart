import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/repositories/repositories.dart';
import '../../../logic/cubits/campaign/campaign_cubit.dart';

/// Campaign detail screen with progress, variants, and checkout.
class CampaignDetailScreen extends StatefulWidget {
  final int campaignId;
  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final Map<int, int> _selectedQuantities = {};
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    // Use a separate cubit for detail
    context.read<CampaignListCubit>(); // just to ensure parent is alive
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Patungan'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<CampaignModel>(
        future: context.read<CampaignRepository>().getCampaignDetail(widget.campaignId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          }
          final campaign = snapshot.data!;
          return _buildContent(context, campaign);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CampaignModel campaign) {
    final percent = (campaign.progressPercent * 100).toStringAsFixed(0);
    final deadlineDays = campaign.deadline.difference(DateTime.now()).inDays;
    final totalSelected = _selectedQuantities.values.fold<int>(0, (s, q) => s + q);
    final totalPrice = totalSelected * campaign.buyerUnitPrice;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & initiator
                Text(campaign.title, style: AppTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  'oleh ${campaign.initiatorName}',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Progress section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: campaign.progressPercent,
                          minHeight: 28,
                          backgroundColor: AppTheme.border,
                          valueColor: AlwaysStoppedAnimation(
                            campaign.progressPercent >= 0.7
                                ? AppTheme.warning
                                : AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${campaign.currentQuantity} / ${campaign.targetQuantity} ${campaign.unit}',
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$percent%',
                            style: AppTheme.titleMedium.copyWith(color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Deadline: $deadlineDays hari lagi',
                            style: AppTheme.bodyMedium,
                          ),
                          const Spacer(),
                          const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              campaign.locationDistribution ?? '-',
                              style: AppTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text('Deskripsi', style: AppTheme.titleMedium),
                const SizedBox(height: 4),
                Text(campaign.description, style: AppTheme.bodyLarge),
                const SizedBox(height: 16),

                // Variants
                Text('Pilih Varian', style: AppTheme.titleMedium),
                const SizedBox(height: 8),
                ...campaign.variants.map((variant) => _VariantSelector(
                      variant: variant,
                      unit: campaign.unit,
                      unitPrice: campaign.buyerUnitPrice,
                      selectedQty: _selectedQuantities[variant.id] ?? 0,
                      onChanged: (qty) {
                        setState(() {
                          if (qty <= 0) {
                            _selectedQuantities.remove(variant.id);
                          } else {
                            _selectedQuantities[variant.id] = qty;
                          }
                        });
                      },
                    )),
                const SizedBox(height: 16),

                // Payment method
                Text('Metode Pembayaran', style: AppTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PaymentMethodChip(
                      label: 'Tunai',
                      icon: Icons.money,
                      selected: _paymentMethod == 'cash',
                      onTap: () => setState(() => _paymentMethod = 'cash'),
                    ),
                    const SizedBox(width: 8),
                    _PaymentMethodChip(
                      label: 'QRIS',
                      icon: Icons.qr_code_2,
                      selected: _paymentMethod == 'qris',
                      onTap: () => setState(() => _paymentMethod = 'qris'),
                    ),
                  ],
                ),
                const SizedBox(height: 80), // Space for bottom bar
              ],
            ),
          ),
        ),

        // Bottom checkout bar
        if (totalSelected > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: AppTheme.bodyMedium,
                        ),
                        Text(
                          'Rp${_formatPrice(totalPrice)}',
                          style: AppTheme.headlineLarge.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _checkout(context, campaign),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 56),
                    ),
                    child: const Text('Konfirmasi'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _checkout(BuildContext context, CampaignModel campaign) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Patungan Berhasil! 🎉'),
        content: Text(
          _paymentMethod == 'cash'
              ? 'Pesanan kamu tercatat. Bayar tunai ke ${campaign.initiatorName} ya.'
              : 'Pesanan kamu tercatat. Upload bukti transfer QRIS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

// ─── Variant Selector Widget ───

class _VariantSelector extends StatelessWidget {
  final CampaignVariantModel variant;
  final String unit;
  final int unitPrice;
  final int selectedQty;
  final ValueChanged<int> onChanged;

  const _VariantSelector({
    required this.variant,
    required this.unit,
    required this.unitPrice,
    required this.selectedQty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = selectedQty * unitPrice * variant.quantityPerVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selectedQty > 0 ? AppTheme.primaryLight.withOpacity(0.2) : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedQty > 0 ? AppTheme.primary : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.name, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  'Rp${_formatPrice(unitPrice * variant.quantityPerVariant)}/paket',
                  style: AppTheme.bodyMedium,
                ),
                Text(
                  'Sisa ${variant.remaining}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: variant.remaining < 5 ? AppTheme.error : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QtyButton(
                icon: Icons.remove,
                enabled: selectedQty > 0,
                onTap: () => onChanged(selectedQty - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$selectedQty',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                enabled: selectedQty < variant.remaining,
                onTap: () => onChanged(selectedQty + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppTheme.primary : AppTheme.border,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: enabled ? Colors.white : AppTheme.textDisabled),
        ),
      ),
    );
  }
}

// ─── Payment Method Chip ───

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
