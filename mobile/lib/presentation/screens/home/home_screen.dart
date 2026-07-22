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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  _CampaignListTab(),
                  _MyOrdersTab(),
                  _NotificationsTab(),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'User';
    final clusterName = authState is AuthAuthenticated ? authState.user.clusterName : '';

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
            child: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: AppTheme.titleMedium),
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
