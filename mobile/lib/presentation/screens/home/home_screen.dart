import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:badges/badges.dart' as badges;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/datasources/remote/mock_data.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/campaign/campaign_cubit.dart';
import '../../../logic/cubits/order/order_cubit.dart';
import '../../../logic/cubits/notification/notification_cubit.dart';
import '../campaign/campaign_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Widget? child;

  const HomeScreen({
    super.key,
    this.child,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _logger = GetIt.I<Logger>();

  @override
  void initState() {
    super.initState();
    context.read<CampaignCubit>().loadCampaigns();
    context.read<OrderCubit>().loadOrders();
    context.read<NotificationCubit>().loadNotifications();
    _logger.i('HomeScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final activeRole = authState is AuthAuthenticated ? authState.user.activeRole : 'buyer';

    // Build tabs based on role
    final List<Widget> tabs;
    final List<BottomNavigationBarItem> navItems;

    switch (activeRole) {
      case 'initiator':
        tabs = const [
          _CampaignListTab(),
          _InitiatorDashboardTab(),
          _NotificationsTab(),
          ProfileScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Validasi'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
        break;
      case 'seller':
        tabs = const [
          _SellerDashboardTab(),
          _NotificationsTab(),
          ProfileScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
        break;
      default: // buyer
        tabs = const [
          _CampaignListTab(),
          _MyOrdersTab(),
          _NotificationsTab(),
          ProfileScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
    }

    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: widget.child ?? SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
        onTap: (i) {
          setState(() => _currentIndex = i);
          _logger.d('Switched to tab $i');
        },
        items: navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'User';
    final activeRole = authState is AuthAuthenticated ? authState.user.activeRole : 'buyer';
    final unreadCount = context.select((NotificationCubit c) => c.getUnreadCount());

    final roleLabel = switch (activeRole) {
      'initiator' => 'Inisiator',
      'seller' => 'Penjual',
      'admin' => 'Admin',
      _ => 'Pembeli',
    };
    final roleColor = switch (activeRole) {
      'initiator' => AppTheme.primary,
      'seller' => AppTheme.warning,
      'admin' => AppTheme.error,
      _ => AppTheme.info,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              activeRole == 'seller' ? Icons.store : Icons.shopping_cart,
              color: Colors.white,
              size: 20,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: AppTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: roleColor),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          badges.Badge(
            showBadge: unreadCount > 0,
            badgeContent: Text(
              unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => setState(() => _currentIndex = 2),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── Campaign List Tab ───

class _CampaignListTab extends StatelessWidget {
  const _CampaignListTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<CampaignCubit>().refreshCampaigns(),
      child: BlocBuilder<CampaignCubit, CampaignState>(
        builder: (context, state) {
          if (state is CampaignLoading) {
            return _CampaignListShimmer();
          }
          if (state is CampaignError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 8),
                  Text((state as CampaignError).message, style: AppTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CampaignCubit>().loadCampaigns(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is CampaignLoaded) {
            if ((state as CampaignLoaded).campaigns.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 48, color: AppTheme.textDisabled),
                          const SizedBox(height: 8),
                          Text('Belum ada patungan aktif', style: AppTheme.bodyMedium),
                        ],
                      ),
                    ).animate().fadeIn().scale(),
                  ),
                ],
              );
            }
            return ListView(
              children: [
                const _SocialTicker(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: (state as CampaignLoaded).campaigns
                        .asMap()
                        .entries
                        .map(
                          (entry) => _CampaignCard(
                            campaign: entry.value,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CampaignDetailScreen(campaignId: entry.value.id),
                                ),
                              );
                            },
                          ).animate(delay: (entry.key * 100).ms).fadeIn().slideX(begin: 0.1),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ─── Shimmer Loading ───

class _CampaignListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: double.infinity, height: 20, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: 150, height: 14, color: Colors.white),
              const SizedBox(height: 16),
              Container(width: double.infinity, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 100, height: 14, color: Colors.white),
                  Container(width: 40, height: 14, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social Ticker ───

class _SocialTicker extends StatefulWidget {
  const _SocialTicker();

  @override
  State<_SocialTicker> createState() => _SocialTickerState();
}

class _SocialTickerState extends State<_SocialTicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppTheme.primary.withOpacity(0.05),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.trending_up, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MockData.socialTicker
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(
                          item,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5);
  }
}

// ─── Campaign Card ───

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = campaign.targetQuantity > 0
        ? campaign.currentQuantity / campaign.targetQuantity
        : 0.0;
    final deadlineDays = campaign.deadline.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: AppTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deadlineDays <= 1
                          ? AppTheme.error.withOpacity(0.1)
                          : AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      deadlineDays <= 0 ? 'Hari ini!' : '$deadlineDays hari lagi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: deadlineDays <= 1 ? AppTheme.error : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('oleh ${campaign.initiatorName}', style: AppTheme.bodySmall),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(
                    progress >= 0.7 ? AppTheme.warning : AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${campaign.currentQuantity} / ${campaign.targetQuantity} ${campaign.unit}',
                    style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp${AppConstants.formatPrice(campaign.buyerUnitPrice)}/${campaign.unit}',
                    style: AppTheme.titleMedium.copyWith(color: AppTheme.primary),
                  ),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Ikut Patungan', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── My Orders Tab ───

class _MyOrdersTab extends StatelessWidget {
  const _MyOrdersTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OrderLoaded) {
          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textDisabled),
                  const SizedBox(height: 8),
                  Text('Belum ada pesanan', style: AppTheme.bodyMedium),
                ],
              ),
            );
          }
          return SlidableAutoCloseBehavior(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {},
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Hapus',
                      ),
                    ],
                  ),
                  child: _OrderCard(order: order)
                      .animate(delay: (index * 50).ms)
                      .fadeIn()
                      .slideX(begin: 0.1),
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (order.paymentStatus) {
      'paid' => AppTheme.success,
      'pending' => AppTheme.warning,
      'rejected' => AppTheme.error,
      _ => AppTheme.textSecondary,
    };

    final statusLabel = switch (order.paymentStatus) {
      'paid' => 'Dibayar',
      'pending' => 'Menunggu',
      'rejected' => 'Ditolak',
      _ => order.paymentStatus,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.campaignTitle,
                    style: AppTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.variantName, style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp${AppConstants.formatPrice(order.totalPrice)}',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  timeago.format(order.createdAt, locale: 'id'),
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Initiator Dashboard Tab ───

class _InitiatorDashboardTab extends StatelessWidget {
  const _InitiatorDashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final pendingOrders = state is OrderLoaded
            ? state.orders.where((o) => o.paymentStatus == 'pending' || o.paymentStatus == 'waiting_qris').toList()
            : <OrderModel>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.pending,
                    value: '${pendingOrders.length}',
                    label: 'Menunggu',
                    color: AppTheme.warning,
                  ),
                  _StatItem(
                    icon: Icons.check_circle,
                    value: '${state is OrderLoaded ? state.orders.where((o) => o.paymentStatus == 'paid').length : 0}',
                    label: 'Dibayar',
                    color: AppTheme.success,
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 16),
            Text('Validasi Pembayaran', style: AppTheme.titleMedium),
            const SizedBox(height: 8),
            if (pendingOrders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: AppTheme.success),
                      const SizedBox(height: 8),
                      Text('Semua pesanan sudah divalidasi!', style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              ...pendingOrders.asMap().entries.map(
                (entry) => _ValidationCard(order: entry.value)
                    .animate(delay: (entry.key * 100).ms)
                    .fadeIn()
                    .slideX(begin: 0.1),
              ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.headlineLarge.copyWith(color: color)),
        Text(label, style: AppTheme.bodySmall),
      ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    order.userName.isNotEmpty ? order.userName[0] : '?',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.userName, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      Text(order.variantName, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.proofUrl != null ? AppTheme.info.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.proofUrl != null ? 'QRIS' : 'Tunai',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: order.proofUrl != null ? AppTheme.info : AppTheme.warning),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rp${AppConstants.formatPrice(order.totalPrice)}',
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                  child: const Text('Tolak'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<OrderCubit>().validateOrder(orderId: order.id, isValid: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Validasi', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Seller Dashboard Tab ───

class _SellerDashboardTab extends StatelessWidget {
  const _SellerDashboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Makmur Jaya',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Supplier Sembako • Terverifikasi ✅',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SellerStatCard(
                icon: Icons.receipt_long,
                value: '5',
                label: 'PO Aktif',
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SellerStatCard(
                icon: Icons.inventory,
                value: '12',
                label: 'Penawaran',
                color: AppTheme.info,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 16),
        Text('Purchase Orders', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(3, (i) {
          final statuses = ['submitted', 'processing', 'shipped'];
          final labels = ['Menunggu', 'Diproses', 'Dikirim'];
          final colors = [AppTheme.warning, AppTheme.info, AppTheme.success];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colors[i].withOpacity(0.1),
                child: Icon(Icons.local_shipping, color: colors[i]),
              ),
              title: Text('PO-${1000 + i} • Beras Premium 500 Kg', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text('oleh Pak Agus Setiawan', style: AppTheme.bodySmall),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors[i].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors[i]),
                ),
              ),
            ),
          ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: 0.1);
        }),
      ],
    );
  }
}

class _SellerStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SellerStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headlineLarge.copyWith(color: color)),
          Text(label, style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}

// ─── Notifications Tab ───

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NotificationLoaded) {
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 48, color: AppTheme.textDisabled),
                  const SizedBox(height: 8),
                  Text('Tidak ada notifikasi', style: AppTheme.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notif = state.notifications[index];
              return _NotificationCard(notif: notif)
                  .animate(delay: (index * 50).ms)
                  .fadeIn()
                  .slideX(begin: 0.1);
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notif;

  const _NotificationCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: notif.isRead ? AppTheme.surface : AppTheme.primary.withOpacity(0.1),
          child: Icon(
            notif.isRead ? Icons.notifications : Icons.notifications_active,
            color: notif.isRead ? AppTheme.textSecondary : AppTheme.primary,
          ),
        ),
        title: Text(notif.title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notif.body, style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              timeago.format(notif.createdAt, locale: 'id'),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary, fontSize: 10),
            ),
          ],
        ),
        onTap: () {
          if (!notif.isRead) {
            context.read<NotificationCubit>().markAsRead(notif.id);
          }
        },
      ),
    );
  }
}
