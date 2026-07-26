import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parent_provider.dart';
import '../../../core/constants/colors.dart';
import '../../tracking/screens/parent_tracking_screen.dart';
import 'parent_students_screen.dart';
import 'parent_profile_screen.dart';
import 'parent_tracking_tab.dart';
import '../../chat/screens/chat_screen.dart' as import_chat;
import '../../chat/screens/chat_list_screen.dart' as import_chat_list;
import '../../chat/providers/chat_provider.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParentProvider>(context, listen: false).fetchDashboardStats();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final parentProvider = Provider.of<ParentProvider>(context);
    final theme = Theme.of(context);

    // Build the main dashboard content
    Widget dashboardContent = parentProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : parentProvider.errorMessage.isNotEmpty
            ? Center(child: Text(parentProvider.errorMessage))
            : _buildBody(context, parentProvider.dashboardData, theme);

    final List<Widget> screens = [
      dashboardContent, // 0: Dashboard
      const ParentStudentsScreen(), // 1: Students
      const ParentTrackingTab(), // 2: Tracking
      const import_chat_list.ChatListScreen(), // 3: Chat List (Replaced Payments)
      const ParentProfileScreen(), // 4: Profile
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic>? data, ThemeData theme) {
    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => Provider.of<ParentProvider>(context, listen: false).fetchDashboardStats(),
      child: CustomScrollView(
        slivers: [
          _buildAppBar(data),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Status Card
                  _buildLiveStatusCard(data),
                  const SizedBox(height: 24),
                  
                  // Child Profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Child Profile', style: theme.textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () {
                          try {
                            String? qrData = data['qrCodeData'] ?? data['_id'] ?? data['id'] ?? data['studentId'];
                            if (qrData == null || qrData.isEmpty || qrData == 'NoData') {
                              qrData = 'SVC-MissingData-${DateTime.now().millisecondsSinceEpoch}';
                            }
                            
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) => AlertDialog(
                                title: const Text('Student QR Code'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      color: Colors.white,
                                      child: Image.network(
                                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$qrData',
                                        width: 200.0,
                                        height: 200.0,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red, size: 50),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Data: $qrData'),
                                    const Text('Show this to the driver', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ]
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))
                                ],
                              )
                            ).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dialog Error: $error')));
                            });
                          } catch (e, stack) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e\n$stack')));
                          }
                        }, 
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Show QR')
                      ),
                    ],
                  ),
                  _buildChildProfile(data),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Text('Quick Actions', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildQuickActionsBento(data),
                  const SizedBox(height: 24),
                  
                  // Upcoming Highlights
                  Text('Upcoming', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildUpcoming(data['upcomingEvents'] ?? []),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(Map<String, dynamic> data) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(0.9),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.primaryContainer, width: 2),
            ),
            child: const Icon(Icons.person, color: AppColors.outline),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
              Text(
                'Hello, ${data['parentName']?.split(' ')[0] ?? 'Parent'}!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: AppColors.onSurfaceVariant),
          onPressed: () {
            Navigator.pushNamed(context, '/chatList');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLiveStatusCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LIVE STATUS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['liveStatus']?['message'] ?? 'Van Status Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shuffle, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceVariant,
              image: const DecorationImage(
                image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=New+York,NY&zoom=14&size=400x200&maptype=roadmap&key=DUMMY_KEY'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [AppColors.primary.withOpacity(0.6), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: AppColors.secondary, size: 8),
                        const SizedBox(width: 8),
                        Text(
                          data['liveStatus']?['state'] ?? 'Active',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildChildProfile(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryContainer, width: 2),
            ),
            child: const Icon(Icons.child_care, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['childName'] ?? 'Child Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data['classInfo'] ?? 'Class',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pickup: ${data['pickupTime'] ?? '--'}',
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: const [
              Icon(Icons.verified_user, color: AppColors.secondary),
              SizedBox(height: 4),
              Text(
                'VERIFIED',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActionsBento(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildBentoAction(Icons.route, 'Track Van', AppColors.primary, AppColors.primaryContainer.withOpacity(0.3), () {
          final driverId = data['driverId'];
          if (driverId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ParentTrackingScreen(driverId: driverId)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No driver assigned.')));
          }
        }),
        _buildBentoAction(Icons.search, 'Find Driver', Colors.purple, Colors.purpleAccent.withOpacity(0.3), () {
          Navigator.pushNamed(context, '/allDrivers');
        }),
        _buildBentoAction(Icons.payments, 'Pay Fee', AppColors.secondary, AppColors.secondaryContainer.withOpacity(0.4), () {
          Navigator.pushNamed(context, '/parentPayment');
        }),
        _buildBentoAction(Icons.directions_bus, 'Enter Code', Colors.orange, Colors.orangeAccent.withOpacity(0.3), () {
          Navigator.pushNamed(context, '/connectDriver');
        }),
        _buildBentoAction(Icons.event_busy, 'Apply Leave', Colors.redAccent, Colors.redAccent.withOpacity(0.2), () {
          Navigator.pushNamed(context, '/applyLeave');
        }),
        _buildBentoAction(Icons.chat, 'Chat Driver', AppColors.onSurfaceVariant, AppColors.surfaceVariant, () {
          final driverId = data['driverId'];
          final driverName = data['driverName'];
          if (driverId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => import_chat.ChatScreen(
                  userId: driverId,
                  userName: driverName ?? 'Driver',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No driver assigned.')));
          }
        }),
        _buildBentoAction(Icons.report_problem, 'Complaints', Colors.red, Colors.red[100]!, () {
          Navigator.pushNamed(context, '/complaintsList');
        }),
      ],
    );
  }

  Widget _buildBentoAction(IconData icon, String label, Color iconColor, Color bgColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcoming(List<dynamic> events) {
    if (events.isEmpty) {
      return const Text('No upcoming events');
    }

    return Column(
      children: events.map((event) {
        final isError = event['type'] == 'exam';
        final bgColor = isError ? AppColors.errorContainer.withOpacity(0.3) : AppColors.surface;
        final borderColor = isError ? AppColors.errorContainer.withOpacity(0.5) : AppColors.outlineVariant.withOpacity(0.1);
        final textColor = isError ? AppColors.onErrorContainer : AppColors.onSurface;
        final iconColor = isError ? AppColors.error : AppColors.onSurfaceVariant;
        final icon = isError ? Icons.assignment_late : Icons.calendar_today;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                    ),
                    Text(
                      event['subtitle'],
                      style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: textColor.withOpacity(0.4)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
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
                isLabelVisible: false,
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
