import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/remote/mock_data.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../data/models/seller_product_model.dart';
import '../../../data/models/supplier_offer_model.dart';
import '../../../logic/cubits/seller/seller_cubit.dart';
import '../../widgets/big_button.dart';

/// ─── Purchase Order Detail ───
class SellerPurchaseOrderDetailScreen extends StatelessWidget {
  final int poId;

  const SellerPurchaseOrderDetailScreen({super.key, required this.poId});

  @override
  Widget build(BuildContext context) {
    final po = MockData.sellerPurchaseOrders.firstWhere(
      (p) => p.id == poId,
      orElse: () => MockData.sellerPurchaseOrders.first,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(po.code),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusHeader(po: po),
          const Gap(16),
          _DetailCard(
            title: 'Detail PO',
            children: [
              _InfoRow(label: 'Campaign', value: po.campaignTitle),
              _InfoRow(label: 'Inisiator', value: po.initiatorName),
              _InfoRow(label: 'Produk', value: po.productName),
              _InfoRow(label: 'Quantity', value: '${po.quantity} ${po.unit}'),
              _InfoRow(label: 'Harga/unit', value: 'Rp${AppConstants.formatPrice(po.unitPrice)}'),
              _InfoRow(label: 'Subtotal', value: 'Rp${AppConstants.formatPrice(po.subtotal)}'),
              _InfoRow(label: 'Biaya Kirim', value: 'Rp${AppConstants.formatPrice(po.deliveryCost)}'),
              _InfoRow(label: 'Total', value: 'Rp${AppConstants.formatPrice(po.totalAmount)}'),
            ],
          ),
          const Gap(16),
          if (po.isSubmitted) ...[
            Row(
              children: [
                Expanded(
                  child: BigButton(
                    label: 'Accept',
                    icon: Icons.check_circle_outline,
                    onPressed: () => context.read<SellerCubit>().acceptPurchaseOrder(po.id),
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
          if (po.isPaid)
            BigButton(
              label: 'Proses Order',
              icon: Icons.work_outline,
              onPressed: () => context.read<SellerCubit>().updatePOStatus(po.id, status: POStatus.processing),
            ),
          if (po.isProcessing)
            BigButton(
              label: 'Tandai Dikirim',
              icon: Icons.local_shipping_outlined,
              onPressed: () => context.read<SellerCubit>().updatePOStatus(po.id, status: POStatus.shipped),
            ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, PurchaseOrderModel po) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Purchase Order'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Alasan penolakan...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<SellerCubit>().rejectPurchaseOrder(po.id, reason: controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tolak', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final PurchaseOrderModel po;
  const _StatusHeader({required this.po});

  Color get _color {
    if (po.isSubmitted) return AppTheme.warning;
    if (po.isAccepted || po.isPaid) return AppTheme.info;
    if (po.isProcessing || po.isShipped) return AppTheme.primary;
    if (po.isCompleted) return AppTheme.success;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined, color: _color),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(po.code, style: AppTheme.titleLarge),
                Text('Status: ${po.statusLabel}', style: AppTheme.bodyMedium.copyWith(color: _color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.titleMedium),
            const Gap(12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: AppTheme.bodySmall)),
          const Gap(8),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// ─── Products List ───
class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerCubit>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Kelola Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/seller/create-product'),
          ),
        ],
      ),
      body: BlocBuilder<SellerCubit, SellerState>(
        builder: (context, state) {
          final products = state is SellerProductsLoaded
              ? state.products
              : state is SellerDashboardLoaded
                  ? state.products
                  : MockData.sellerProducts;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textDisabled),
                  const Gap(12),
                  const Text('Belum ada produk', style: AppTheme.bodyMedium),
                  const Gap(16),
                  BigButton(
                    label: 'Buat Produk',
                    icon: Icons.add,
                    onPressed: () => context.push('/seller/create-product'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary),
                  ),
                  title: Text(product.name),
                  subtitle: Text('${product.baseUnit.toUpperCase()} • ${product.variants.length} varian'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ─── Create Product ───
class SellerCreateProductScreen extends StatefulWidget {
  const SellerCreateProductScreen({super.key});

  @override
  State<SellerCreateProductScreen> createState() => _SellerCreateProductScreenState();
}

class _SellerCreateProductScreenState extends State<SellerCreateProductScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _baseUnit = 'kg';
  final _units = ['kg', 'pcs', 'liter', 'pack', 'dus', 'box'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Buat Produk'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Produk'),
          ),
          const Gap(16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Deskripsi'),
            maxLines: 3,
          ),
          const Gap(16),
          const Text('Base Unit', style: AppTheme.labelMedium),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _units.map((unit) {
              final selected = _baseUnit == unit;
              return ChoiceChip(
                label: Text(unit.toUpperCase()),
                selected: selected,
                onSelected: (_) => setState(() => _baseUnit = unit),
                selectedColor: AppTheme.primaryLight,
              );
            }).toList(),
          ),
          const Gap(24),
          BigButton(
            label: 'Simpan Produk',
            icon: Icons.save_outlined,
            onPressed: _nameController.text.isNotEmpty
                ? () {
                    context.read<SellerCubit>().createProduct(
                          name: _nameController.text,
                          baseUnit: _baseUnit,
                          description: _descController.text,
                        );
                    context.pop();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

/// ─── Create Offer ───
class SellerCreateOfferScreen extends StatefulWidget {
  const SellerCreateOfferScreen({super.key});

  @override
  State<SellerCreateOfferScreen> createState() => _SellerCreateOfferScreenState();
}

class _SellerCreateOfferScreenState extends State<SellerCreateOfferScreen> {
  final _minOrderController = TextEditingController(text: '500');
  final _capacityController = TextEditingController(text: '2000');
  final _deliveryCostController = TextEditingController(text: '200000');
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  final List<String> _selectedAreas = [];

  @override
  void dispose() {
    _minOrderController.dispose();
    _capacityController.dispose();
    _deliveryCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = MockData.sellerProducts;
    final allAreas = ['PGH-RT01', 'PGH-RT02', 'PGH-RT03', 'PGH-RT04', 'PGH-RT05'];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Buat Offer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Produk', style: AppTheme.labelMedium),
          const Gap(8),
          ...products.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<int>(
                  value: p.id,
                  groupValue: products.first.id,
                  onChanged: (_) {},
                  title: Text(p.name),
                  subtitle: Text(p.baseUnit.toUpperCase()),
                ),
              )),
          const Gap(16),
          TextField(
            controller: _minOrderController,
            decoration: const InputDecoration(labelText: 'Minimum Order'),
            keyboardType: TextInputType.number,
          ),
          const Gap(16),
          TextField(
            controller: _capacityController,
            decoration: const InputDecoration(labelText: 'Kapasitas Maks'),
            keyboardType: TextInputType.number,
          ),
          const Gap(16),
          TextField(
            controller: _deliveryCostController,
            decoration: const InputDecoration(labelText: 'Biaya Kirim (Rp)'),
            keyboardType: TextInputType.number,
          ),
          const Gap(16),
          const Text('Area Layanan', style: AppTheme.labelMedium),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allAreas.map((area) {
              final selected = _selectedAreas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedAreas.add(area);
                    } else {
                      _selectedAreas.remove(area);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const Gap(16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Berlaku Sampai'),
            subtitle: Text('${_validUntil.day}/${_validUntil.month}/${_validUntil.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _validUntil,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _validUntil = picked);
              }
            },
          ),
          const Gap(24),
          BigButton(
            label: 'Submit Offer',
            icon: Icons.send_outlined,
            onPressed: () {
              context.read<SellerCubit>().createOffer(
                    productId: products.first.id,
                    minimumOrder: int.tryParse(_minOrderController.text) ?? 500,
                    capacity: int.tryParse(_capacityController.text) ?? 2000,
                    tiers: const [
                      PriceTier(minQuantity: 500, maxQuantity: 999, unitPrice: 10500),
                      PriceTier(minQuantity: 1000, maxQuantity: 0, unitPrice: 10000),
                    ],
                    serviceAreas: _selectedAreas.isEmpty ? ['PGH-RT03'] : _selectedAreas,
                    deliveryCost: int.tryParse(_deliveryCostController.text) ?? 200000,
                    validUntil: _validUntil,
                  );
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

/// ─── Initiator Validation Screen ───
class InitiatorValidationScreen extends StatelessWidget {
  const InitiatorValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingOrders = MockData.pendingValidation;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Validasi Pembayaran'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
            ),
            child: const Row(
              children: [
                Icon(Icons.fact_check_outlined, color: AppTheme.primary),
                Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dashboard Validasi', style: AppTheme.titleMedium),
                      Gap(4),
                      Text(
                        'Validasi pembayaran tunai atau QRIS dari buyer. Periksa bukti transfer sebelum validasi.',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          if (pendingOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: AppTheme.success),
                    Gap(12),
                    Text('Semua pembayaran sudah divalidasi!', style: AppTheme.titleMedium),
                  ],
                ),
              ),
            )
          else
            ...pendingOrders.map((order) => _ValidationCard(order: order)),
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  final OrderModel order;
  const _ValidationCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.warning.withOpacity(0.15),
                  child: Text(
                    '${order.quantity}',
                    style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w700),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.userName, style: AppTheme.titleMedium),
                      Text(
                        '${order.campaignTitle} • ${order.variantName}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                _Badge(label: order.paymentMethod.toUpperCase(), color: AppTheme.info),
                const Gap(8),
                _Badge(
                  label: order.paymentStatus == 'waiting_qris' ? 'Menunggu QRIS' : 'Menunggu Tunai',
                  color: AppTheme.warning,
                ),
                const Spacer(),
                Text('Rp${AppConstants.formatPrice(order.totalPrice)}', style: AppTheme.titleMedium),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: BigButton(
                    label: 'Validasi',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      context.read<OrderCubit>().validateOrder(orderId: order.id, isValid: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pembayaran divalidasi ✅')),
                      );
                    },
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Tolak'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pembayaran'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Alasan penolakan...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<OrderCubit>().validateOrder(
                    orderId: order.id,
                    isValid: false,
                    reason: controller.text,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Tolak', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// Re-export OrderModel and OrderCubit for use in validation screen
import '../../../data/models/order_model.dart';
import '../../../logic/cubits/order/order_cubit.dart';
