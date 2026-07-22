import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/remote/mock_data.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/campaign/campaign_cubit.dart';
import '../../../logic/cubits/notification/notification_cubit.dart';
import '../../../logic/cubits/order/order_cubit.dart';
import '../../widgets/big_button.dart';
import '../../widgets/offline_banner.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<CampaignCubit>().loadCampaigns();
      context.read<OrderCubit>().loadOrders();
      context.read<NotificationCubit>().loadNotifications();
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final role = user.activeRole ?? UserRole.buyer;

    final tabs = switch (role) {
      UserRole.initiator => const [
          _CampaignListTab(),
          _InitiatorDashboardTab(),
          _NotificationsTab(),
          ProfileScreen(),
        ],
      UserRole.seller => const [
          _SellerDashboardTab(),
          _NotificationsTab(),
          ProfileScreen(),
        ],
      UserRole.admin => const [
          _AdminDashboardTab(),
          _NotificationsTab(),
          ProfileScreen(),
        ],
      _ => const [
          _CampaignListTab(),
          _MyOrdersTab(),
          _NotificationsTab(),
          ProfileScreen(),
        ],
    };

    final navItems = switch (role) {
      UserRole.initiator => const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Validasi'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      UserRole.seller => const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      UserRole.admin => const [
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Admin'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      _ => const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
    };

    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(
              user: user,
              unreadCount: context.select((NotificationCubit cubit) => cubit.getUnreadCount()),
              onCreatePoTap: role == UserRole.initiator ? () => context.go('/initiator/create') : null,
              onNotificationsTap: () => setState(() {
                _currentIndex = tabs.length > 3 ? 2 : 1;
              }),
            ),
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: tabs,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => setState(() => _currentIndex = value),
        items: navItems,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final UserModel user;
  final int unreadCount;
  final VoidCallback? onCreatePoTap;
  final VoidCallback onNotificationsTap;

  const _HomeHeader({
    required this.user,
    required this.unreadCount,
    required this.onCreatePoTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final role = user.activeRole ?? UserRole.buyer;
    final (label, color) = switch (role) {
      UserRole.initiator => ('Inisiator', AppTheme.primary),
      UserRole.seller => ('Seller', AppTheme.warning),
      UserRole.admin => ('Admin', AppTheme.error),
      _ => ('Buyer', AppTheme.info),
    };
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primary,
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppTheme.titleMedium),
                const Gap(2),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: const Text('Grosirun'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppTheme.primaryLight.withOpacity(0.18),
                    ),
                    Chip(
                      label: Text(AppConstants.defaultClusterCode),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(label),
                      backgroundColor: color.withOpacity(0.12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
          badges.Badge(
            showBadge: unreadCount > 0,
            badgeContent: Text(
              unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_outlined),
            ),
          ),
          if (onCreatePoTap != null)
            IconButton(
              tooltip: 'Buat PO',
              onPressed: onCreatePoTap,
              icon: const Icon(Icons.add_circle_outline),
            ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
    );
  }
}

class _CampaignListTab extends StatelessWidget {
  const _CampaignListTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<CampaignCubit>().refreshCampaigns(),
      child: BlocBuilder<CampaignCubit, CampaignState>(
        builder: (context, state) {
          if (state is CampaignLoading || state is CampaignInitial) {
            return _CampaignListShimmer();
          }

          if (state is CampaignError) {
            return _EmptyState(
              icon: Icons.error_outline,
              title: 'Gagal memuat campaign',
              subtitle: state.message,
              actionLabel: 'Coba lagi',
              onAction: () => context.read<CampaignCubit>().loadCampaigns(),
            );
          }

          final campaigns = state is CampaignLoaded ? state.campaigns : MockData.campaigns;
          if (campaigns.isEmpty) {
            return _EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Belum ada patungan aktif',
              subtitle: 'Silakan refresh nanti, atau buat campaign dari workspace inisiator.',
              actionLabel: 'Refresh',
              onAction: () => context.read<CampaignCubit>().loadCampaigns(),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              const _InfoBanner(
                icon: Icons.receipt_long_outlined,
                title: 'Patungan non-escrow',
                subtitle: 'Buyer hanya melihat campaign cluster sendiri dan status order pribadi.',
              ),
              const Gap(12),
              const _SocialTicker(),
              const Gap(12),
              ...campaigns.map(
                (campaign) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CampaignCard(
                    campaign: campaign,
                    onTap: () => context.go('/campaign/${campaign.id}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CampaignListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 180, color: Colors.white),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 180, height: 18, color: Colors.white),
                    const Gap(8),
                    Container(width: 220, height: 14, color: Colors.white),
                    const Gap(16),
                    Container(width: double.infinity, height: 12, color: Colors.white),
                    const Gap(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 120, height: 14, color: Colors.white),
                        Container(width: 80, height: 14, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialTicker extends StatelessWidget {
  const _SocialTicker();

  @override
  Widget build(BuildContext context) {
    final items = [...MockData.socialTicker, ...MockData.socialTicker];

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('•', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        itemBuilder: (context, index) => Center(
          child: Text(
            items[index],
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = campaign.progressPercent.clamp(0.0, 1.0);
    final progressColor = progress >= 0.7 ? AppTheme.warning : AppTheme.primary;
    final daysLeft = campaign.deadline.difference(DateTime.now()).inDays;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: campaign.imageUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0.12),
                            AppTheme.primaryLight.withOpacity(0.35),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.image_outlined, size: 48, color: AppTheme.primary),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: AppTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    'oleh ${campaign.initiatorName}',
                    style: AppTheme.bodyMedium,
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 16,
                            backgroundColor: AppTheme.border,
                            valueColor: AlwaysStoppedAnimation(progressColor),
                          ),
                        ),
                      ),
                      const Gap(12),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: AppTheme.labelMedium.copyWith(color: progressColor),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 16, color: AppTheme.textSecondary),
                      const Gap(6),
                      Expanded(
                        child: Text(
                          'Terkumpul ${campaign.currentQuantity} ${campaign.unit} dari target ${campaign.targetQuantity} ${campaign.unit}',
                          style: AppTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 16, color: AppTheme.textSecondary),
                      const Gap(6),
                      Text(
                        daysLeft <= 0 ? 'Sisa hari ini' : 'Sisa $daysLeft hari',
                        style: AppTheme.bodySmall.copyWith(
                          color: daysLeft < 1 ? AppTheme.error : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(label: Text(campaign.clusterName)),
                      Text(
                        'Rp${AppConstants.formatPrice(campaign.buyerUnitPrice)}/${campaign.unit}',
                        style: AppTheme.titleMedium.copyWith(color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const Gap(12),
                  BigButton(
                    label: 'Ikut Patungan',
                    icon: Icons.shopping_cart_checkout_outlined,
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyOrdersTab extends StatelessWidget {
  const _MyOrdersTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<OrderCubit>().loadOrders(),
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderError) {
            return _EmptyState(
              icon: Icons.error_outline,
              title: 'Gagal memuat pesanan',
              subtitle: state.message,
              actionLabel: 'Coba lagi',
              onAction: () => context.read<OrderCubit>().loadOrders(),
            );
          }

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
                icon: Icons.payments_outlined,
                title: 'Workspace Buyer',
                subtitle: 'Pesanan tampil per akun, dengan status pembayaran dan metode yang jelas.',
              ),
              const Gap(12),
              ...orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          builder: (_) => _OrderDetailSheet(order: order),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.primaryLight,
                                  child: Text(order.quantity.toString()),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(order.campaignTitle, style: AppTheme.titleMedium),
                                      const Gap(4),
                                      Text(
                                        '${order.variantName} • ${order.paymentMethod.toUpperCase()} • ${order.paymentStatus}',
                                        style: AppTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Rp${AppConstants.formatPrice(order.totalPrice)}',
                                  style: AppTheme.titleMedium.copyWith(color: AppTheme.primary),
                                ),
                              ],
                            ),
                            const Gap(12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _StatusPill(
                                  label: order.paymentStatus == 'paid' ? 'Lunas' : 'Menunggu',
                                  color: order.paymentStatus == 'paid' ? AppTheme.success : AppTheme.warning,
                                ),
                                _StatusPill(
                                  label: order.paymentMethod.toUpperCase(),
                                  color: AppTheme.primary,
                                ),
                                _StatusPill(
                                  label: '${order.quantity} item',
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                            if (order.paymentStatus == 'waiting_qris') ...[
                              const Gap(12),
                              BigButton(
                                label: 'Upload Ulang Bukti',
                                icon: Icons.upload_file_outlined,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Aksi upload bukti QRIS akan disambungkan ke layar bukti.')),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return _EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Gagal memuat notifikasi',
              subtitle: state.message,
              actionLabel: 'Coba lagi',
              onAction: () => context.read<NotificationCubit>().loadNotifications(),
            );
          }

          final notifications = state is NotificationLoaded ? state.notifications : MockData.notifications;
          if (notifications.isEmpty) {
            return const _EmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'Belum ada notifikasi',
              subtitle: 'Saat ada update campaign atau transaksi, notifikasi akan muncul di sini.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _InfoBanner(
                icon: Icons.notifications_active_outlined,
                title: 'Notifikasi real-time',
                subtitle: 'Tap notifikasi untuk melihat detail alur transaksi dan update campaign.',
              ),
              const Gap(12),
              ...notifications.map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationTile(notification: notification),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
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

class _InitiatorDashboardTab extends StatelessWidget {
  const _InitiatorDashboardTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                const _InfoBanner(
                  icon: Icons.fact_check_outlined,
                  title: 'Validasi tunai dan QRIS',
                  subtitle: 'Inisiator hanya melihat order cluster sendiri dan mengelola validasi pembayaran.',
                ),
                const Gap(12),
                BigButton(
                  label: 'Buat PO',
                  icon: Icons.add_circle_outline,
                  onPressed: () => context.go('/initiator/create'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(child: _MetricCard(label: 'Pending', value: '2', icon: Icons.pending_actions_outlined)),
                Gap(12),
                Expanded(child: _MetricCard(label: 'Lunas', value: '14', icon: Icons.verified_outlined)),
                Gap(12),
                Expanded(child: _MetricCard(label: 'QRIS', value: '3', icon: Icons.qr_code_2_outlined)),
              ],
            ),
          ),
          const Gap(12),
          const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Tunai'),
              Tab(text: 'QRIS Waiting'),
            ],
          ),
          const Gap(12),
          Expanded(
            child: TabBarView(
              children: [
                _ValidationQueueTab(
                  title: 'Order menunggu validasi',
                  showProof: false,
                  orders: MockData.pendingValidation.where((order) => order.paymentStatus == 'pending').toList(),
                ),
                _ValidationQueueTab(
                  title: 'Pembayaran tunai',
                  showProof: false,
                  orders: MockData.pendingValidation.where((order) => order.paymentMethod == 'cash').toList(),
                ),
                _ValidationQueueTab(
                  title: 'Bukti QRIS',
                  showProof: true,
                  orders: MockData.pendingValidation.where((order) => order.paymentMethod == 'qris').toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerDashboardTab extends StatelessWidget {
  const _SellerDashboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.storefront_outlined,
          title: 'Workspace Seller',
          subtitle: 'Seller hanya melihat agregat kuantitas, dokumen PO, dan status fulfillment.',
        ),
        const Gap(12),
        Row(
          children: const [
            Expanded(child: _MetricCard(label: 'Purchase Order', value: '3', icon: Icons.inventory_2_outlined)),
            Gap(12),
            Expanded(child: _MetricCard(label: 'Fulfillment', value: '87%', icon: Icons.local_shipping_outlined)),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
            child: _ActionTile(
                icon: Icons.add_box_outlined,
                title: 'Buat Produk',
                subtitle: 'Tambah katalog supplier',
                onTap: () => context.go('/seller/offers'),
              ),
            ),
            const Gap(12),
            Expanded(
            child: _ActionTile(
                icon: Icons.local_offer_outlined,
                title: 'Buat Offer',
                subtitle: 'Ajukan harga tier',
                onTap: () => context.go('/seller/offers'),
              ),
            ),
          ],
        ),
        const Gap(12),
        BigButton(
          label: 'Lihat Purchase Orders',
          icon: Icons.inventory_2_outlined,
          onPressed: () => context.go('/seller/purchase-orders'),
        ),
        const Gap(16),
        const _SectionTitle('Purchase Order Masuk'),
        ..._sellerPurchaseOrders.map(
          (po) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(po.code, style: AppTheme.titleMedium)),
                        _StatusPill(
                          label: po.status,
                          color: po.status == 'accepted' ? AppTheme.success : AppTheme.warning,
                        ),
                      ],
                    ),
                    const Gap(8),
                    Text(po.title, style: AppTheme.titleLarge),
                    const Gap(4),
                    Text('${po.quantity} • ${po.subtotal} + ${po.delivery}', style: AppTheme.bodyMedium),
                    const Gap(12),
                    const Text(
                      'Buyer detail disembunyikan dari seller. Yang tampil hanya agregat, dokumen PO, dan status fulfillment.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/seller/purchase-orders'),
                          child: const Text('Lihat PO'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('PO disetujui dan pindah ke awaiting payment.')),
                            );
                          },
                          child: const Text('Accept'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Alasan reject perlu diisi pada flow detail PO.')),
                            );
                          },
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Console Admin',
          subtitle: 'Moderasi dan audit terpusat agar setiap perubahan sensitif tetap tercatat.',
        ),
        const Gap(12),
        Row(
          children: const [
            Expanded(child: _MetricCard(label: 'Queues', value: '5', icon: Icons.queue_outlined)),
            Gap(12),
            Expanded(child: _MetricCard(label: 'Audit', value: '99%', icon: Icons.policy_outlined)),
          ],
        ),
        const Gap(16),
        const _SectionTitle('Quick Actions'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _ActionTile(
              icon: Icons.verified_user_outlined,
              title: 'Verifikasi Supplier',
              subtitle: 'Review dokumen usaha',
              onTap: () => context.go('/admin/suppliers/verification'),
            ),
            _ActionTile(
              icon: Icons.fact_check_outlined,
              title: 'Moderasi Offer',
              subtitle: 'Cek tier dan masa berlaku',
              onTap: () => context.go('/admin/offers/moderation'),
            ),
            _ActionTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Kelola Role',
              subtitle: 'Grant atau revoke akses',
              onTap: () => context.go('/admin/dashboard'),
            ),
            _ActionTile(
              icon: Icons.safety_check_outlined,
              title: 'Mediasi Dispute',
              subtitle: 'Audit fulfillment dan refund',
              onTap: () => context.go('/admin/disputes'),
            ),
          ],
        ),
        const Gap(12),
        BigButton(
          label: 'Audit & Monitoring',
          icon: Icons.history_outlined,
          onPressed: () => context.go('/admin/audit'),
        ),
        const Gap(16),
        const _SectionTitle('Pending Queue'),
        const _QueueCard(
          title: 'CV Makmur Jaya',
          subtitle: 'Pending supplier verification - 2 jam',
          icon: Icons.storefront_outlined,
        ),
        const _QueueCard(
          title: 'Beras Premium - CV Makmur Jaya',
          subtitle: 'Pending moderation - tier harga, kapasitas, area',
          icon: Icons.local_offer_outlined,
        ),
        const _QueueCard(
          title: 'Audit trail ready',
          subtitle: 'Semua transaksi terekam append-only',
          icon: Icons.history_outlined,
        ),
      ],
    );
  }
}

class _ValidationQueueTab extends StatelessWidget {
  final String title;
  final bool showProof;
  final List<OrderModel> orders;

  const _ValidationQueueTab({
    required this.title,
    required this.showProof,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: title,
        subtitle: 'Tidak ada order di antrean ini.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari nama atau campaign',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(label: const Text('Validasi 5 Terpilih'), onPressed: () {}),
            ActionChip(label: const Text('Tandai Semua'), onPressed: () {}),
            ActionChip(label: const Text('Export Log'), onPressed: () {}),
          ],
        ),
        const Gap(16),
        ...orders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryLight,
                          child: Text(order.userName.isNotEmpty ? order.userName[0].toUpperCase() : '?'),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.userName, style: AppTheme.titleMedium),
                              const Gap(4),
                              Text(
                                '${order.campaignTitle} • ${order.variantName} • ${order.paymentMethod.toUpperCase()}',
                                style: AppTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text('Rp${AppConstants.formatPrice(order.totalPrice)}', style: AppTheme.titleMedium),
                      ],
                    ),
                    const Gap(12),
                    if (showProof && order.proofUrl != null) ...[
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Center(child: Icon(Icons.image_outlined, size: 36)),
                      ),
                      const Gap(12),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusPill(
                          label: order.paymentStatus == 'paid' ? 'Lunas' : 'Pending',
                          color: order.paymentStatus == 'paid' ? AppTheme.success : AppTheme.warning,
                        ),
                        _StatusPill(
                          label: order.paymentMethod.toUpperCase(),
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: BigButton(
                            label: 'Validasi',
                            icon: Icons.check_circle_outline,
                            onPressed: () {},
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.close),
                            label: const Text('Tolak'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primary),
              const Gap(12),
              Text(title, style: AppTheme.titleMedium),
              const Gap(4),
              Text(subtitle, style: AppTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _QueueCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
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
            const Gap(16),
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary),
            const Gap(12),
            Text(value, style: AppTheme.headlineMedium),
            const Gap(4),
            Text(label, style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTheme.titleLarge),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
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
            Text(
              subtitle,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const Gap(16),
              BigButton(
                label: actionLabel!,
                icon: Icons.refresh_rounded,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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

const _sellerPurchaseOrders = <_PurchaseOrderSummary>[
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
