import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_provider.dart';
import '../../../core/constants/colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tracking/services/driver_tracking_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'driver_students_screen.dart';
import 'driver_profile_tab.dart';
import 'driver_tracking_tab.dart';
import '../../chat/screens/chat_list_screen.dart' as import_chat;
import '../../chat/providers/chat_provider.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _currentIndex = 0;
  final DriverTrackingService _trackingService = DriverTrackingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).fetchDashboardStats();
    });
  }

  @override
  void dispose() {
    _trackingService.dispose();
    super.dispose();
  }
  
  void _toggleTracking(String driverId) async {
    if (_trackingService.isTracking) {
      _trackingService.stopTracking();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live Tracking Stopped'))
      );
    } else {
      try {
        await _trackingService.startTracking(driverId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live Tracking Started'), backgroundColor: AppColors.secondary)
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error)
        );
      }
    }
    setState(() {}); // Refresh UI to show state
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          driverProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : driverProvider.errorMessage.isNotEmpty
                  ? Center(child: Text(driverProvider.errorMessage))
                  : _buildBody(context, driverProvider.dashboardData, theme),
          const DriverStudentsScreen(),
          const DriverTrackingTab(),
          const import_chat.ChatListScreen(), // Chat list replaces Payments
          const DriverProfileTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/qrScanner');
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.qr_code_scanner, color: AppColors.onPrimary),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic>? data, ThemeData theme) {
    if (data == null) return const SizedBox.shrink();
    
    // We need the driver ID to broadcast tracking
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverId = authProvider.currentUser?['_id'] ?? 'unknown_driver';

    return RefreshIndicator(
      onRefresh: () => Provider.of<DriverProvider>(context, listen: false).fetchDashboardStats(),
      child: CustomScrollView(
        slivers: [
          _buildAppBar(data['driverName'] ?? 'Driver'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${data['driverName']?.split(' ')[0] ?? 'Captain'}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reference Code Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Reference Code',
                          style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 12),
                        ),
                        Text(
                          data['referenceCode'] ?? '------',
                          style: const TextStyle(
                            color: AppColors.onPrimaryContainer,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const Text(
                          'Share this with parents to link their accounts.',
                          style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // Stats Grid
                  _buildStatsGrid(data),
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  Text('Quick Actions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _buildQuickActions(driverId),
                  const SizedBox(height: 32),
                  
                  // Map Preview
                  _buildMapPreview(),
                  const SizedBox(height: 32),
                  
                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Activity', style: theme.textTheme.titleMedium),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  _buildRecentActivity(data['recentActivity'] ?? []),
                  const SizedBox(height: 80), // Space for FAB/Nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(String name) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(0.9),
      elevation: 0,
      title: const Text(
        'School Van Connect',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: AppColors.onSurfaceVariant),
          onPressed: () {
            Navigator.pushNamed(context, '/chatList');
          },
        ),

        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.error),
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.logout();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15, // Fixed overflow
      children: [
        _buildStatCard(
          title: 'Total Students',
          value: data['totalStudents'].toString(),
          icon: Icons.group,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primaryContainer,
          onTap: () {
            Provider.of<DriverProvider>(context, listen: false).setStudentFilter('All');
            setState(() => _currentIndex = 1);
          },
        ),
        _buildStatCard(
          title: 'Attendance',
          value: data['presentCount'].toString(),
          icon: Icons.how_to_reg,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.secondaryContainer,
          onTap: () {
            Provider.of<DriverProvider>(context, listen: false).setStudentFilter('Present');
            setState(() => _currentIndex = 1);
          },
        ),
        _buildStatCard(
          title: 'Earnings',
          value: '₹${data['todayEarnings']}',
          icon: Icons.payments,
          iconColor: Colors.green[800]!,
          iconBgColor: Colors.green[100]!,
        ),
        _buildStatCard(
          title: 'Pending Fees',
          value: '₹${data['pendingFees']}',
          icon: Icons.account_balance_wallet,
          iconColor: AppColors.error,
          iconBgColor: AppColors.errorContainer,
          badge: 'DUE',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildQuickActions(String driverId) {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Requests', 'color': AppColors.primary, 'onTap': () => Navigator.pushNamed(context, '/connectionRequests')},
      {
        'icon': _trackingService.isTracking ? Icons.stop_circle : Icons.share_location,
        'label': _trackingService.isTracking ? 'Stop Live' : 'Share Live',
        'color': _trackingService.isTracking ? AppColors.error : Colors.orange,
        'onTap': () => _toggleTracking(driverId),
      },
      {'icon': Icons.currency_exchange, 'label': 'Collect Fee', 'color': AppColors.onBackground, 'onTap': () => Navigator.pushNamed(context, '/driverEarnings')},
      {'icon': Icons.event_note, 'label': 'Leaves', 'color': Colors.blueGrey, 'onTap': () => Navigator.pushNamed(context, '/leaveManagement')},
      {'icon': Icons.report_problem, 'label': 'Complaints', 'color': Colors.redAccent, 'onTap': () => Navigator.pushNamed(context, '/complaintsList')},
      {'icon': Icons.analytics, 'label': 'Reports', 'color': Colors.teal, 'onTap': () => Navigator.pushNamed(context, '/reports')},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: action['onTap'] as VoidCallback? ?? () {},
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: action['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action['icon'] as IconData, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          children: [
            // Map Background
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(20.5937, 78.9629),
                initialZoom: 10.0,
                interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.school_sathi',
                ),
              ],
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
          const Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: AppColors.secondary, size: 12),
                    SizedBox(width: 8),
                    Text(
                      'Live Tracking Active',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fullscreen, color: Colors.white),
            ),
          )
        ],
      ),
      ),
    );
  }

  Widget _buildRecentActivity(List<dynamic> activities) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No recent activity')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        IconData icon;
        Color color;
        Color bgColor;

        switch (activity['type']) {
          case 'attendance':
            icon = Icons.check_circle;
            color = AppColors.secondary;
            bgColor = AppColors.secondaryContainer;
            break;
          case 'payment':
            icon = Icons.payments;
            color = Colors.green[800]!;
            bgColor = Colors.green[100]!;
            break;
          default:
            icon = Icons.info;
            color = Colors.orange;
            bgColor = Colors.orange[100]!;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      activity['subtitle'],
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        const BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Students'),
        const BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Tracking'),
        BottomNavigationBarItem(
          icon: Consumer<ChatProvider>(
            builder: (context, chat, child) {
              return Badge(
                isLabelVisible: false, // You can add logic for unread counts here
                child: const Icon(Icons.chat),
              );
            },
          ),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
