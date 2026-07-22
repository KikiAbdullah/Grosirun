import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/datasources/remote/mock_data.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/campaign/campaign_cubit.dart';
import '../campaign/campaign_detail_screen.dart';
import '../profile/profile_screen.dart';

/// Main home screen with bottom navigation and campaign list.
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
    context.read<CampaignListCubit>().loadCampaigns();
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

    // Clamp index if switching roles reduces tab count
    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: SafeArea(
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
        onTap: (i) => setState(() => _currentIndex = i),
        items: navItems,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'User';
    final clusterName = authState is AuthAuthenticated ? authState.user.clusterName : '';
    final activeRole = authState is AuthAuthenticated ? authState.user.activeRole : 'buyer';

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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(userName, style: AppTheme.titleMedium)),
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
                    ),
                  ],
                ),
                if (clusterName != null && clusterName.isNotEmpty)
                  Text(clusterName, style: AppTheme.bodyMedium),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => setState(() => _currentIndex = 2),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Campaign List Tab ───

class _CampaignListTab extends StatelessWidget {
  const _CampaignListTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<CampaignListCubit>().refresh(),
      child: BlocBuilder<CampaignListCubit, CampaignListState>(
        builder: (context, state) {
          if (state is CampaignListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CampaignListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 8),
                  Text(state.message, style: AppTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CampaignListCubit>().loadCampaigns(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is CampaignListLoaded) {
            if (state.campaigns.isEmpty) {
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
                    ),
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
                    children: state.campaigns
                        .map(
                          (c) => _CampaignCard(
                            campaign: c,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CampaignDetailScreen(campaignId: c.id),
                                ),
                              );
                            },
                          ),
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

// ─── Social Ticker ───

class _SocialTicker extends StatelessWidget {
  const _SocialTicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppTheme.primaryLight.withOpacity(0.3),
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
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary, fontSize: 12),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Campaign Card ───

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;

  const _CampaignCard({required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = (campaign.progressPercent * 100).toStringAsFixed(0);
    final deadlineDays = campaign.deadline.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    child: Text(campaign.title, style: AppTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: deadlineDays <= 1 ? AppTheme.error : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('oleh ${campaign.initiatorName} • ${campaign.clusterName}', style: AppTheme.bodyMedium),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: campaign.progressPercent,
                  minHeight: 24,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(
                    campaign.progressPercent >= 0.7 ? AppTheme.warning : AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terkumpul ${campaign.currentQuantity} ${campaign.unit} dari ${campaign.targetQuantity} ${campaign.unit}',
                    style: AppTheme.bodyMedium,
                  ),
                  Text('$percent%', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp${_formatPrice(campaign.buyerUnitPrice)}/${campaign.unit}',
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: onTap, child: const Text('Ikut Patungan')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

// ─── My Orders Tab ───

class _MyOrdersTab extends StatelessWidget {
  const _MyOrdersTab();

  @override
  Widget build(BuildContext context) {
    final orders = MockData.myOrders;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List<Widget>.generate(orders.length, (i) {
        final order = orders[i];
        final isPaid = order.paymentStatus == 'paid';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isPaid ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? AppTheme.success : AppTheme.warning,
              ),
            ),
            title: Text(order.campaignTitle, style: AppTheme.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${order.variantName} x ${order.quantity}', style: AppTheme.bodyMedium),
                Text(
                  'Rp${_formatPrice(order.totalPrice)} • ${order.paymentMethod.toUpperCase()}',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ),
        );
      }),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

// ─── Notifications Tab ───

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    final notifs = MockData.notifications;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List<Widget>.generate(notifs.length, (i) {
        final notif = notifs[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: notif.isRead ? AppTheme.surface : AppTheme.primaryLight.withOpacity(0.15),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Icon(Icons.campaign, color: AppTheme.primary, size: 20),
            ),
            title: Text(notif.title, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(notif.body, style: AppTheme.bodyMedium),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Initiator Dashboard Tab ───

class _InitiatorDashboardTab extends StatelessWidget {
  const _InitiatorDashboardTab();

  @override
  Widget build(BuildContext context) {
    final orders = MockData.pendingValidation;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
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
                value: '${orders.length}',
                label: 'Menunggu Validasi',
                color: AppTheme.warning,
              ),
              Container(width: 1, height: 40, color: AppTheme.border),
              _StatItem(
                icon: Icons.check_circle,
                value: '24',
                label: 'Tervalidasi',
                color: AppTheme.success,
              ),
              Container(width: 1, height: 40, color: AppTheme.border),
              _StatItem(
                icon: Icons.shopping_cart,
                value: '3',
                label: 'Campaign Aktif',
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Validasi Pembayaran', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        if (orders.isEmpty)
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
          ...List<Widget>.generate(orders.length, (i) {
            final order = orders[i];
            final hasProof = order.proofUrl != null;
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
                              Text(order.userName, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                              Text('${order.variantName} x ${order.quantity}', style: AppTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasProof
                                ? AppTheme.info.withOpacity(0.1)
                                : AppTheme.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hasProof ? 'QRIS' : 'Tunai',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasProof ? AppTheme.info : AppTheme.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rp${_formatPrice(order.totalPrice)}',
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${order.userName} ditolak')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: const BorderSide(color: AppTheme.error),
                            minimumSize: const Size(80, 40),
                          ),
                          child: const Text('Tolak'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${order.userName} divalidasi ✅'),
                                backgroundColor: AppTheme.success,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 40),
                          ),
                          child: const Text('Validasi'),
                        ),
                      ],
                    ),
                    if (hasProof) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.image, size: 16),
                        label: const Text('Lihat Bukti Transfer'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
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
        Text(value, style: AppTheme.headlineLarge.copyWith(fontSize: 20, color: color)),
        Text(label, style: AppTheme.bodyMedium.copyWith(fontSize: 10)),
      ],
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
        // Seller info
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
              const Text('Makmur Jaya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Supplier Sembako • Terverifikasi ✅',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats
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
        ),
        const SizedBox(height: 16),

        // Recent Purchase Orders
        Text('Purchase Orders', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        ...List<Widget>.generate(3, (i) {
          final statuses = ['submitted', 'processing', 'shipped'];
          final labels = ['Menunggu Konfirmasi', 'Sedang Diproses', 'Dalam Pengiriman'];
          final colors = [AppTheme.warning, AppTheme.info, AppTheme.success];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colors[i].withOpacity(0.1),
                child: Icon(Icons.local_shipping, color: colors[i]),
              ),
              title: Text('PO-${1000 + i} • Beras Premium 500 Kg'),
              subtitle: Text('oleh Pak Agus Setiawan • Permata Hijau RT03', style: AppTheme.bodyMedium),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors[i].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors[i]),
                ),
              ),
            ),
          );
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
          Text(value, style: AppTheme.headlineLarge.copyWith(fontSize: 24, color: color)),
          Text(label, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}
