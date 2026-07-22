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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
  final VoidCallback onNotificationsTap;

  const _HomeHeader({
    required this.user,
    required this.unreadCount,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
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
    return BlocBuilder<OrderCubit, OrderState>(
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

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(order.quantity.toString()),
                ),
                title: Text(order.campaignTitle),
                subtitle: Text(
                  '${order.variantName} • ${order.paymentMethod.toUpperCase()} • ${order.paymentStatus}',
                ),
                trailing: Text('Rp${AppConstants.formatPrice(order.totalPrice)}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
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

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _NotificationTile(notification: notification);
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
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
        trailing: Text(timeago.format(notification.createdAt)),
      ),
    );
  }
}

class _InitiatorDashboardTab extends StatelessWidget {
  const _InitiatorDashboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            Expanded(child: _MetricCard(label: 'Pending', value: '2', icon: Icons.pending_actions_outlined)),
            Gap(12),
            Expanded(child: _MetricCard(label: 'Paid', value: '14', icon: Icons.verified_outlined)),
          ],
        ),
        const Gap(12),
        const _SectionTitle('Validasi Cepat'),
        ...MockData.pendingValidation.map(
          (order) => Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(order.userName),
              subtitle: Text('${order.campaignTitle} • ${order.variantName}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }
}

class _SellerDashboardTab extends StatelessWidget {
  const _SellerDashboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionTitle('Workspace Seller'),
        _MetricCard(label: 'Purchase Order', value: '3', icon: Icons.inventory_2_outlined),
        Gap(12),
        _MetricCard(label: 'Fulfillment', value: '87%', icon: Icons.local_shipping_outlined),
        Gap(16),
        _EmptyState(
          icon: Icons.lock_outline,
          title: 'Data Buyer tetap tersembunyi',
          subtitle: 'Seller hanya melihat agregat kuantitas, dokumen PO, dan status fulfillment.',
        ),
      ],
    );
  }
}

class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle('Console Admin'),
          _MetricCard(label: 'Queues', value: '5', icon: Icons.queue_outlined),
          Gap(12),
          _MetricCard(label: 'Audit', value: '99%', icon: Icons.policy_outlined),
          Gap(16),
          _EmptyState(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Moderasi dan audit terpusat',
            subtitle: 'Fitur admin dipisahkan agar perubahan sensitif selalu tercatat.',
          ),
        ],
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
