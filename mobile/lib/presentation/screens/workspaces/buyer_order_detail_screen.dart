import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../logic/cubits/order/order_cubit.dart';
import '../../widgets/big_button.dart';

class BuyerOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const BuyerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<BuyerOrderDetailScreen> createState() => _BuyerOrderDetailScreenState();
}

class _BuyerOrderDetailScreenState extends State<BuyerOrderDetailScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _busy = false;

  Future<void> _uploadProof(OrderModel order) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() => _busy = true);
    await context.read<OrderCubit>().uploadPaymentProof(
          orderId: order.id,
          filePath: picked.path,
        );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bukti pembayaran disimpan untuk sinkronisasi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<OrderRepository>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Detail Pesanan'),
      ),
      body: FutureBuilder<OrderModel>(
        future: repository.getOrderDetail(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const _EmptyState(
              icon: Icons.error_outline,
              title: 'Pesanan tidak ditemukan',
              subtitle: 'Coba buka ulang dari daftar pesanan.',
            );
          }

          final order = snapshot.data!;
          final isQris = order.paymentMethod == 'qris';
          final canCancel = order.paymentStatus == PaymentStatus.pending ||
              order.paymentStatus == PaymentStatus.waitingQris;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoBanner(
                icon: Icons.receipt_long_outlined,
                title: order.campaignTitle,
                subtitle: '${order.variantName} • ${order.paymentMethod.toUpperCase()} • ${order.paymentStatus}',
              ),
              const Gap(12),
              _SummaryCard(title: 'Total', value: 'Rp${AppConstants.formatPrice(order.totalPrice)}'),
              _SummaryCard(title: 'Quantity', value: '${order.quantity} item'),
              _SummaryCard(title: 'Tanggal dibuat', value: order.createdAt.toIso8601String()),
              const Gap(12),
              if (isQris)
                const _InfoBanner(
                  icon: Icons.qr_code_2_outlined,
                  title: 'QRIS',
                  subtitle: 'Scan QR inisiator, lalu upload bukti transfer dari galeri.',
                ),
              if (order.paymentStatus == PaymentStatus.paid)
                const _InfoBanner(
                  icon: Icons.verified_outlined,
                  title: 'Pembayaran lunas',
                  subtitle: 'Tunggu notifikasi barang datang lalu ambil di rumah RT.',
                ),
              if (order.paymentStatus == PaymentStatus.rejected)
                const _InfoBanner(
                  icon: Icons.report_problem_outlined,
                  title: 'Bukti ditolak',
                  subtitle: 'Upload ulang foto yang lebih jelas dari galeri.',
                ),
              if (order.paymentStatus == PaymentStatus.cancelled)
                const _InfoBanner(
                  icon: Icons.cancel_outlined,
                  title: 'Pesanan dibatalkan',
                  subtitle: 'Kamu bisa pesan ulang selama campaign masih aktif.',
                ),
              const Gap(16),
              if (isQris)
                BigButton(
                  label: order.paymentStatus == PaymentStatus.rejected
                      ? 'Upload Ulang Bukti'
                      : 'Upload Bukti',
                  icon: Icons.upload_file_outlined,
                  isLoading: _busy,
                  onPressed: _busy ? null : () => _uploadProof(order),
                ),
              if (canCancel) ...[
                const Gap(8),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          await context.read<OrderCubit>().cancelOrder(order.id);
                          if (!mounted) {
                            return;
                          }
                          setState(() => _busy = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Partisipasi dibatalkan.')),
                          );
                        },
                  icon: const Icon(Icons.close),
                  label: const Text('Batalkan Partisipasi'),
                ),
              ],
              const Gap(8),
              BigButton(
                label: 'Tutup',
                icon: Icons.close,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium),
                const Gap(4),
                Text(subtitle, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppTheme.textDisabled),
            const Gap(16),
            Text(title, style: AppTheme.titleLarge, textAlign: TextAlign.center),
            const Gap(8),
            Text(subtitle, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
