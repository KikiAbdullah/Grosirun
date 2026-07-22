import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/remote/mock_data.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../logic/cubits/order/order_cubit.dart';
import '../../../logic/cubits/notification/notification_cubit.dart';
import '../../widgets/big_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = MockData.notifications;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Notifikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(
            icon: Icons.notifications_active_outlined,
            title: 'Notifikasi real-time',
            subtitle: 'Setiap update transaksi, campaign, dan validasi tampil di sini.',
          ),
          const Gap(12),
          ...notifications.map((notification) => _NotificationCard(notification: notification)),
        ],
      ),
    );
  }
}

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Pesanan Saya'),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          final orders = state is OrderLoaded ? state.orders : MockData.myOrders;

          if (orders.isEmpty) {
            return const _EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum ada pesanan',
              subtitle: 'Pesanan kamu akan tampil di sini.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _InfoBanner(
                icon: Icons.receipt_long_outlined,
                title: 'Pesanan buyer',
                subtitle: 'Tiap order menampilkan metode bayar, status, dan total harga.',
              ),
              const Gap(12),
              ...orders.map((order) => _OrderCard(order: order)),
            ],
          );
        },
      ),
    );
  }
}
class InitiatorCreateScreen extends StatelessWidget {
  const InitiatorCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      _OfferSummary(
        title: 'Beras Mahkota Premium - CV Makmur Jaya',
        minimum: '500 Kg',
        capacity: '2000 Kg',
        tierOne: 'Rp10.500/Kg',
        tierTwo: 'Rp10.000/Kg',
        delivery: 'Rp200.000',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Buat Campaign'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(
            icon: Icons.campaign_outlined,
            title: 'Pilih offer lalu publikasi PO',
            subtitle: 'Target, harga buyer, tenggat, dan lokasi distribusi divalidasi sebelum publish.',
          ),
          const Gap(12),
          const Text('Pilih Penawaran', style: AppTheme.titleLarge),
          const Gap(8),
          ...offers.map(
            (offer) => Card(
              child: ListTile(
                leading: const Icon(Icons.local_offer_outlined, color: AppTheme.primary),
                title: Text(offer.title),
                subtitle: Text('${offer.minimum} • ${offer.capacity} • ${offer.tierOne}'),
              ),
            ),
          ),
          const Gap(12),
          const Text('Form Campaign', style: AppTheme.titleLarge),
          const Gap(8),
          const _FormFieldCard(label: 'Target', value: '1000 Kg'),
          const _FormFieldCard(label: 'Harga Buyer', value: 'Rp12.000/Kg'),
          const _FormFieldCard(label: 'Tenggat', value: '2 hari dari sekarang'),
          const _FormFieldCard(label: 'Lokasi Distribusi', value: 'Rumah Pak RT Jl Mawar 12'),
          const Gap(16),
          BigButton(
            label: 'Publikasikan PO',
            icon: Icons.send_outlined,
            onPressed: () => context.push('/initiator/recap/1'),
          ),
        ],
      ),
    );
  }
}

class InitiatorRecapScreen extends StatelessWidget {
  final int campaignId;

  const InitiatorRecapScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final campaign = MockData.campaigns.firstWhere((item) => item.id == campaignId, orElse: () => MockData.campaigns.first);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Recap PO'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoBanner(
            icon: Icons.summarize_outlined,
            title: campaign.title,
            subtitle: 'Review subtotal supplier, biaya kirim, dan total sebelum dikirim ke seller.',
          ),
          const Gap(12),
          _SummaryCard(title: 'Target', value: '${campaign.targetQuantity} ${campaign.unit}'),
          _SummaryCard(title: 'Price Buyer', value: 'Rp${AppConstants.formatPrice(campaign.buyerUnitPrice)}/${campaign.unit}'),
          _SummaryCard(title: 'Supplier Subtotal', value: 'Rp${AppConstants.formatPrice(campaign.supplierUnitPrice * campaign.targetQuantity)}'),
          const Gap(16),
          BigButton(
            label: 'Kirim PO',
            icon: Icons.send_outlined,
            onPressed: () => context.push('/initiator/distribution/${campaign.id}'),
          ),
        ],
      ),
    );
  }
}

class InitiatorDistributionScreen extends StatelessWidget {
  final int campaignId;

  const InitiatorDistributionScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final orders = MockData.myOrders;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Distribusi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(
            icon: Icons.local_shipping_outlined,
            title: 'Checklist pengambilan barang',
            subtitle: 'Centang buyer yang sudah ambil agar audit trail tetap rapi.',
          ),
          const Gap(12),
          ...orders.map(
            (order) => Card(
              child: CheckboxListTile(
                value: false,
                onChanged: (_) {},
                title: Text(order.campaignTitle),
                subtitle: Text('${order.userName} • ${order.variantName}'),
              ),
            ),
          ),
          const Gap(16),
          BigButton(
            label: 'Selesai Distribusi',
            icon: Icons.verified_outlined,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class SellerOffersScreen extends StatelessWidget {
  const SellerOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Kelola Offer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _InfoBanner(
            icon: Icons.local_offer_outlined,
            title: 'Buat produk, packaging, dan offer',
            subtitle: 'Isi minimal order, kapasitas, tier harga, area layanan, dan masa berlaku.',
          ),
          Gap(12),
          _FormFieldCard(label: 'Nama Produk', value: 'Beras Premium Pulen'),
          _FormFieldCard(label: 'Base Unit', value: 'Kg'),
          _FormFieldCard(label: 'Minimum Order', value: '500 Kg'),
          _FormFieldCard(label: 'Kapasitas', value: '2000 Kg'),
          _FormFieldCard(label: 'Area Layanan', value: 'PGH-RT03, PGH-RT05'),
          _FormFieldCard(label: 'Berlaku Sampai', value: '30 Juli 2026'),
        ],
      ),
    );
  }
}

class SellerPurchaseOrdersScreen extends StatelessWidget {
  const SellerPurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Purchase Orders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _sellerOrders
            .map(
              (po) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: Text(po.code.substring(po.code.length - 1)),
                  ),
                  title: Text(po.code),
                  subtitle: Text('${po.title} • ${po.quantity} • ${po.status}'),
                  trailing: Text(po.subtotal),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class AdminSupplierVerificationScreen extends StatelessWidget {
  const AdminSupplierVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Verifikasi Supplier'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(
            icon: Icons.verified_user_outlined,
            title: 'Supplier pending',
            subtitle: 'Review SIUP, NPWP, alamat usaha, dan kontak bisnis.',
          ),
          const Gap(12),
          ..._supplierQueues.map(
            (supplier) => _ReviewCard(
              title: supplier.title,
              subtitle: supplier.subtitle,
              icon: Icons.storefront_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminOfferModerationScreen extends StatelessWidget {
  const AdminOfferModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Moderasi Offer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(
            icon: Icons.fact_check_outlined,
            title: 'Cek tier harga dan kapasitas',
            subtitle: 'Pastikan konten offer realistis, valid, dan tidak melanggar aturan.',
          ),
          const Gap(12),
          ..._offerQueues.map(
            (offer) => _ReviewCard(
              title: offer.title,
              subtitle: offer.subtitle,
              icon: Icons.local_offer_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDisputesScreen extends StatelessWidget {
  const AdminDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Mediasi Dispute'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _InfoBanner(
            icon: Icons.safety_check_outlined,
            title: 'Sengketa fulfillment',
            subtitle: 'Tinjau PO, invoice, surat jalan, dan foto penerimaan.',
          ),
          Gap(12),
          _ReviewCard(
            title: 'PO-1001 • Barang tidak sesuai',
            subtitle: 'Buyer mengajukan dispute setelah barang diterima.',
            icon: Icons.report_problem_outlined,
          ),
          _ReviewCard(
            title: 'PO-1003 • Selisih jumlah',
            subtitle: 'Cocokkan data log dengan surat jalan.',
            icon: Icons.swap_horiz_outlined,
          ),
        ],
      ),
    );
  }
}

class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Audit & Monitoring'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _InfoBanner(
            icon: Icons.history_outlined,
            title: 'Append-only log',
            subtitle: 'Admin dapat melihat queue, security alert, SLA, dan transaksi yang sudah tercatat.',
          ),
          Gap(12),
          _ReviewCard(
            title: 'Security alert - login baru',
            subtitle: 'Perangkat baru terdeteksi pada akun supplier.',
            icon: Icons.security_outlined,
          ),
          _ReviewCard(
            title: 'SLA violation - offer moderation',
            subtitle: 'Offer menunggu lebih dari batas waktu.',
            icon: Icons.timer_outlined,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<NotificationCubit>().markAsRead(notification.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifikasi ditandai sudah dibaca.')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.isRead ? AppTheme.border : AppTheme.primaryLight,
            child: Icon(
              Icons.notifications_active_outlined,
              color: notification.isRead ? AppTheme.textSecondary : AppTheme.primary,
            ),
          ),
          title: Text(notification.title),
          subtitle: Text(notification.body),
          trailing: Text(timeago.format(notification.createdAt, locale: 'id')),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/orders/${order.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryLight,
            child: Text(order.quantity.toString()),
          ),
          title: Text(order.campaignTitle),
          subtitle: Text('${order.variantName} • ${order.paymentMethod.toUpperCase()} • ${order.paymentStatus}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rp${AppConstants.formatPrice(order.totalPrice)}'),
              const Gap(4),
              Text(
                order.paymentStatus == 'paid' ? 'Lunas' : 'Menunggu',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSheet extends StatefulWidget {
  final OrderModel order;

  const _OrderSheet({required this.order});

  @override
  State<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<_OrderSheet> {
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
    final order = widget.order;
    final isQris = order.paymentMethod == 'qris';
    final canCancel = order.paymentStatus == PaymentStatus.pending || order.paymentStatus == PaymentStatus.waitingQris;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(order.campaignTitle, style: AppTheme.headlineSmall),
            const Gap(8),
            Text('${order.variantName} • ${order.paymentMethod.toUpperCase()}', style: AppTheme.bodyMedium),
            const Gap(12),
            Text('Total Rp${AppConstants.formatPrice(order.totalPrice)}', style: AppTheme.titleLarge),
            const Gap(12),
            _StatusPill(
              label: order.paymentStatus == PaymentStatus.paid ? 'Lunas' : order.paymentStatus,
              color: order.paymentStatus == PaymentStatus.paid ? AppTheme.success : AppTheme.warning,
            ),
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
                label: order.paymentStatus == PaymentStatus.rejected ? 'Upload Ulang Bukti' : 'Upload Bukti',
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
        ),
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

class _FormFieldCard extends StatelessWidget {
  final String label;
  final String value;

  const _FormFieldCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
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

class _ReviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ReviewCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title di-approve')),
                );
              },
              child: const Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title ditolak')),
                );
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferSummary {
  final String title;
  final String minimum;
  final String capacity;
  final String tierOne;
  final String tierTwo;
  final String delivery;

  const _OfferSummary({
    required this.title,
    required this.minimum,
    required this.capacity,
    required this.tierOne,
    required this.tierTwo,
    required this.delivery,
  });
}

class _SupplierQueue {
  final String title;
  final String subtitle;

  const _SupplierQueue({
    required this.title,
    required this.subtitle,
  });
}

class _OfferQueue {
  final String title;
  final String subtitle;

  const _OfferQueue({
    required this.title,
    required this.subtitle,
  });
}

const _supplierQueues = <_SupplierQueue>[
  _SupplierQueue(
    title: 'CV Makmur Jaya',
    subtitle: 'Pending 2 jam',
  ),
  _SupplierQueue(
    title: 'UD Sumber Rejeki',
    subtitle: 'Pending 5 jam',
  ),
  _SupplierQueue(
    title: 'PT Sembako Jaya',
    subtitle: 'Pending 1 hari',
  ),
];

const _offerQueues = <_OfferQueue>[
  _OfferQueue(
    title: 'Beras Premium - CV Makmur Jaya',
    subtitle: 'Unit, tier harga, dan kapasitas sedang diverifikasi.',
  ),
  _OfferQueue(
    title: 'Minyak Goreng - UD Sumber Rejeki',
    subtitle: 'Cek konten dan masa berlaku offer.',
  ),
];

const _sellerOrders = <_PurchaseOrderSummary>[
  _PurchaseOrderSummary(
    code: 'PO-1001',
    title: 'Beras Premium Pulen',
    quantity: '500 Kg',
    subtotal: 'Rp5.250.000',
    delivery: 'Rp200.000',
    status: 'submitted',
  ),
  _PurchaseOrderSummary(
    code: 'PO-1002',
    title: 'Minyak Goreng 2L',
    quantity: '200 L',
    subtotal: 'Rp6.000.000',
    delivery: 'Rp180.000',
    status: 'accepted',
  ),
  _PurchaseOrderSummary(
    code: 'PO-1003',
    title: 'Gula Pasir',
    quantity: '300 Kg',
    subtotal: 'Rp4.800.000',
    delivery: 'Rp150.000',
    status: 'shipped',
  ),
];

class _PurchaseOrderSummary {
  final String code;
  final String title;
  final String quantity;
  final String subtotal;
  final String delivery;
  final String status;

  const _PurchaseOrderSummary({
    required this.code,
    required this.title,
    required this.quantity,
    required this.subtotal,
    required this.delivery,
    required this.status,
  });
}
