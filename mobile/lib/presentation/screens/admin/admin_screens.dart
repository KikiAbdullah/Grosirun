import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dispute_model.dart';
import '../../../data/models/seller_product_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/models/supplier_offer_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/cubits/admin/admin_cubit.dart';
import '../../widgets/big_button.dart';

/// Admin console – supplier verification, offer moderation, role management,
/// dispute resolution, and audit log.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return const _AdminShimmer();
        }

        if (state is AdminError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const Gap(12),
                  Text(state.message, style: AppTheme.titleMedium, textAlign: TextAlign.center),
                  const Gap(16),
                  BigButton(
                    label: 'Coba Lagi',
                    icon: Icons.refresh,
                    onPressed: () => context.read<AdminCubit>().loadDashboard(),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AdminDashboardLoaded) {
          return _AdminContent(state: state);
        }

        return const _AdminShimmer();
      },
    );
  }
}

class _AdminContent extends StatelessWidget {
  final AdminDashboardLoaded state;

  const _AdminContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─── Info Banner ───
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.error.withOpacity(0.15)),
          ),
          child: const Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined, color: AppTheme.error),
              Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Console Admin', style: AppTheme.titleMedium),
                    Gap(4),
                    Text(
                      'Moderasi dan audit terpusat. Perubahan sensitif selalu tercatat.',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(16),

        // ─── Metrics ───
        const Text('Overview', style: AppTheme.titleLarge),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.store_outlined,
                label: 'Pending Supplier',
                value: '${state.metrics['pending_suppliers'] ?? 0}',
                color: AppTheme.warning,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _MetricCard(
                icon: Icons.local_offer_outlined,
                label: 'Pending Offer',
                value: '${state.metrics['pending_offers'] ?? 0}',
                color: AppTheme.info,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _MetricCard(
                icon: Icons.gavel_outlined,
                label: 'Dispute',
                value: '${state.openDisputes}',
                color: AppTheme.error,
              ),
            ),
          ],
        ),
        const Gap(16),

        // ─── Quick Actions ───
        const Text('Aksi Cepat', style: AppTheme.titleLarge),
        const Gap(8),
        _ActionTile(
          icon: Icons.verified_user_outlined,
          title: 'Verifikasi Supplier',
          subtitle: '${state.metrics['pending_suppliers'] ?? 0} menunggu verifikasi',
          onTap: () => context.push('/admin/suppliers/verification'),
          color: AppTheme.warning,
        ),
        const Gap(8),
        _ActionTile(
          icon: Icons.fact_check_outlined,
          title: 'Moderasi Offer',
          subtitle: '${state.metrics['pending_offers'] ?? 0} offer perlu review',
          onTap: () => context.push('/admin/offers/moderation'),
          color: AppTheme.info,
        ),
        const Gap(8),
        _ActionTile(
          icon: Icons.manage_accounts_outlined,
          title: 'Kelola Role',
          subtitle: 'Grant/revoke role pengguna',
          onTap: () => context.push('/admin/roles'),
          color: AppTheme.primary,
        ),
        const Gap(8),
        _ActionTile(
          icon: Icons.gavel_outlined,
          title: 'Mediasi Dispute',
          subtitle: '${state.openDisputes} dispute terbuka',
          onTap: () => context.push('/admin/disputes'),
          color: AppTheme.error,
        ),
        const Gap(8),
        _ActionTile(
          icon: Icons.history_outlined,
          title: 'Audit Log',
          subtitle: 'Riwayat semua aksi admin',
          onTap: () => context.push('/admin/audit'),
          color: AppTheme.textSecondary,
        ),
        const Gap(24),
      ],
    );
  }
}

// ─── Supplier Verification Screen ───

class AdminSupplierVerificationScreen extends StatefulWidget {
  const AdminSupplierVerificationScreen({super.key});

  @override
  State<AdminSupplierVerificationScreen> createState() =>
      _AdminSupplierVerificationScreenState();
}

class _AdminSupplierVerificationScreenState
    extends State<AdminSupplierVerificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadPendingSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Verifikasi Supplier'),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminSuppliersLoaded) {
            if (state.suppliers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 48, color: AppTheme.textDisabled),
                    Gap(12),
                    Text('Tidak ada supplier pending', style: AppTheme.bodyMedium),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = state.suppliers[index];
                return _SupplierCard(supplier: supplier);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;

  const _SupplierCard({required this.supplier});

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
                  child: const Icon(Icons.store_outlined, color: AppTheme.warning),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier.name, style: AppTheme.titleMedium),
                      Text(
                        'Pending ${_timeSince(supplier.createdAt)}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: supplier.statusLabel,
                  color: supplier.isPending ? AppTheme.warning : AppTheme.textSecondary,
                ),
              ],
            ),
            const Gap(12),
            _InfoRow(label: 'SIUP', value: supplier.siup ?? '-'),
            _InfoRow(label: 'NPWP', value: supplier.npwp ?? '-'),
            _InfoRow(label: 'Alamat', value: supplier.address),
            _InfoRow(label: 'Kontak', value: supplier.contactPhone),
            _InfoRow(label: 'Email', value: supplier.contactEmail),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: BigButton(
                    label: 'Approve',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      context.read<AdminCubit>().verifySupplier(supplier.id, approved: true);
                    },
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Reject'),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tolak Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wajib mengisi alasan penolakan.'),
            const Gap(12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Alasan penolakan...'),
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
                context.read<AdminCubit>().verifySupplier(
                      supplier.id,
                      approved: false,
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

  String _timeSince(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes} menit';
    if (diff.inDays < 1) return '${diff.inHours} jam';
    return '${diff.inDays} hari';
  }
}

// ─── Offer Moderation Screen ───

class AdminOfferModerationScreen extends StatefulWidget {
  const AdminOfferModerationScreen({super.key});

  @override
  State<AdminOfferModerationScreen> createState() =>
      _AdminOfferModerationScreenState();
}

class _AdminOfferModerationScreenState extends State<AdminOfferModerationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadPendingOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Moderasi Offer'),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminOffersLoaded) {
            if (state.offers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_outlined, size: 48, color: AppTheme.textDisabled),
                    Gap(12),
                    Text('Tidak ada offer pending', style: AppTheme.bodyMedium),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.offers.length,
              itemBuilder: (context, index) {
                final offer = state.offers[index];
                return _OfferCard(offer: offer);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final SupplierOfferModel offer;

  const _OfferCard({required this.offer});

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
                  backgroundColor: AppTheme.info.withOpacity(0.15),
                  child: const Icon(Icons.local_offer_outlined, color: AppTheme.info),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.productName, style: AppTheme.titleMedium),
                      Text(offer.supplierName, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            _InfoRow(label: 'Unit', value: offer.unit.toUpperCase()),
            _InfoRow(label: 'Min. Order', value: '${offer.minimumOrder} ${offer.unit}'),
            _InfoRow(label: 'Kapasitas', value: '${offer.capacity} ${offer.unit}'),
            _InfoRow(label: 'Biaya Kirim', value: 'Rp${AppConstants.formatPrice(offer.deliveryCost)}'),
            _InfoRow(label: 'Area', value: offer.serviceAreas.join(', ')),
            const Gap(8),
            const Text('Tier Harga:', style: AppTheme.labelMedium),
            const Gap(4),
            ...offer.tiers.map(
              (tier) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text(
                  '• ${tier.minQuantity}${tier.maxQuantity > 0 ? '-${tier.maxQuantity}' : '+'} ${offer.unit}: Rp${AppConstants.formatPrice(tier.unitPrice)}/${offer.unit}',
                  style: AppTheme.bodyMedium,
                ),
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: BigButton(
                    label: 'Approve',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      context.read<AdminCubit>().moderateOffer(offer.id, approved: true);
                    },
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AdminCubit>().moderateOffer(offer.id, approved: false, note: 'Tidak sesuai kriteria');
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Disputes Screen ───

class AdminDisputesScreen extends StatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  State<AdminDisputesScreen> createState() => _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends State<AdminDisputesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadDisputes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Mediasi Dispute'),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminDisputesLoaded) {
            if (state.disputes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gavel_outlined, size: 48, color: AppTheme.textDisabled),
                    Gap(12),
                    Text('Tidak ada dispute', style: AppTheme.bodyMedium),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.disputes.length,
              itemBuilder: (context, index) {
                final dispute = state.disputes[index];
                return _DisputeCard(dispute: dispute);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final DisputeModel dispute;

  const _DisputeCard({required this.dispute});

  Color get _statusColor {
    if (dispute.isOpen) return AppTheme.error;
    if (dispute.isInReview) return AppTheme.warning;
    if (dispute.isResolved) return AppTheme.success;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor.withOpacity(0.12),
          child: Icon(Icons.gavel_outlined, color: _statusColor),
        ),
        title: Text(dispute.purchaseOrderCode, style: AppTheme.titleMedium),
        subtitle: Text(
          '${dispute.initiatorName} vs ${dispute.supplierName}',
          style: AppTheme.bodySmall,
        ),
        trailing: _StatusBadge(label: dispute.statusLabel, color: _statusColor),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Tipe', value: dispute.disputeType.replaceAll('_', ' ')),
                _InfoRow(label: 'Deskripsi', value: dispute.description),
                _InfoRow(label: 'Dibuat', value: timeago.format(dispute.createdAt, locale: 'id')),
                if (dispute.evidenceUrls.isNotEmpty)
                  _InfoRow(label: 'Bukti', value: '${dispute.evidenceUrls.length} file'),
                if (dispute.isResolved) ...[
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resolusi: ${dispute.resolution ?? "-"}', style: AppTheme.labelMedium),
                        const Gap(4),
                        Text(dispute.resolutionNotes ?? '', style: AppTheme.bodyMedium),
                        if (dispute.refundAmount != null)
                          Text('Refund: Rp${AppConstants.formatPrice(dispute.refundAmount!)}', style: AppTheme.labelMedium),
                      ],
                    ),
                  ),
                ],
                if (dispute.isOpen || dispute.isInReview) ...[
                  const Gap(12),
                  BigButton(
                    label: 'Resolve Dispute',
                    icon: Icons.gavel_outlined,
                    onPressed: () => _showResolveDialog(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(BuildContext context) {
    String resolution = DisputeResolution.none;
    final notesController = TextEditingController();
    final refundController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Resolve Dispute'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pilih resolusi:'),
                const Gap(12),
                RadioListTile<String>(
                  title: const Text('Replacement'),
                  value: DisputeResolution.replacement,
                  groupValue: resolution,
                  onChanged: (v) => setDialogState(() => resolution = v!),
                ),
                RadioListTile<String>(
                  title: const Text('Refund'),
                  value: DisputeResolution.refund,
                  groupValue: resolution,
                  onChanged: (v) => setDialogState(() => resolution = v!),
                ),
                RadioListTile<String>(
                  title: const Text('Tidak Ada'),
                  value: DisputeResolution.none,
                  groupValue: resolution,
                  onChanged: (v) => setDialogState(() => resolution = v!),
                ),
                const Gap(12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(hintText: 'Catatan resolusi...'),
                  maxLines: 3,
                ),
                if (resolution == DisputeResolution.refund) ...[
                  const Gap(8),
                  TextField(
                    controller: refundController,
                    decoration: const InputDecoration(hintText: 'Jumlah refund (Rp)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                context.read<AdminCubit>().resolveDispute(
                      dispute.id,
                      resolution: resolution,
                      notes: notesController.text,
                      refundAmount: resolution == DisputeResolution.refund
                          ? int.tryParse(refundController.text)
                          : null,
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Resolve', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Audit Log Screen ───

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Audit Log'),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminAuditLogsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryLight.withOpacity(0.3),
                      child: const Icon(Icons.history, color: AppTheme.primary),
                    ),
                    title: Text(log.action.replaceAll('_', ' '), style: AppTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.description ?? '-', style: AppTheme.bodySmall),
                        Text(
                          'oleh ${log.userName} • ${timeago.format(log.createdAt, locale: 'id')}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Role Management Screen ───

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadUsersWithRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Kelola Role'),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminUsersLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return _UserRoleCard(user: user);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _UserRoleCard extends StatelessWidget {
  final UserModel user;

  const _UserRoleCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTheme.titleMedium),
                      Text(user.phoneNumber, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final role in [UserRole.buyer, UserRole.initiator, UserRole.seller, UserRole.admin])
                  _RoleChip(
                    label: role[0].toUpperCase() + role.substring(1),
                    isAssigned: user.roles.contains(role),
                    onToggle: () {
                      if (user.roles.contains(role)) {
                        context.read<AdminCubit>().revokeRole(user.id, role);
                      } else {
                        context.read<AdminCubit>().grantRole(user.id, role);
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isAssigned;
  final VoidCallback onToggle;

  const _RoleChip({
    required this.label,
    required this.isAssigned,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isAssigned,
      onSelected: (_) => onToggle(),
      selectedColor: AppTheme.primaryLight,
      checkmarkColor: AppTheme.primary,
    );
  }
}

// ─── Shared Helper Widgets ───

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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleMedium),
                    Text(subtitle, style: AppTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTheme.bodySmall),
          ),
          const Gap(8),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AdminShimmer extends StatelessWidget {
  const _AdminShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        5,
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
