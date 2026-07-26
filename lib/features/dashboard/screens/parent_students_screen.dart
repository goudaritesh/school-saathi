import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parent_provider.dart';
import '../../../core/constants/colors.dart';

class ParentStudentsScreen extends StatelessWidget {
  const ParentStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parentProvider = Provider.of<ParentProvider>(context);
    final data = parentProvider.dashboardData;

    if (parentProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text('No student data available')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Student Photo Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.person, size: 60, color: AppColors.primary),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/editChild');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data['childName'] ?? 'Unknown Child',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              data['classInfo'] ?? 'Class Info Not Available',
              style: theme.textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            // School Details Card
            _buildInfoCard(
              title: 'School Details',
              icon: Icons.school,
              children: [
                _buildInfoRow('School Name', data['schoolName'] ?? 'N/A'),
                _buildInfoRow('Class & Section', data['classInfo'] ?? 'N/A'),
                _buildInfoRow('Roll Number', data['rollNumber'] ?? 'N/A'),
              ]
            ),
            const SizedBox(height: 16),

            // Transportation Details Card
            _buildInfoCard(
              title: 'Transportation Details',
              icon: Icons.directions_bus,
              children: [
                _buildInfoRow('Pickup Time', data['pickupTime'] ?? 'N/A'),
                _buildInfoRow('Drop Time', data['dropTime'] ?? 'N/A'),
                _buildInfoRow('Pickup Address', data['pickupAddress'] ?? 'N/A'),
                _buildInfoRow('Drop Address', data['dropAddress'] ?? 'N/A'),
              ]
            ),
            const SizedBox(height: 16),

            // Emergency Info Card
            _buildInfoCard(
              title: 'Emergency Contact & Medical',
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.error,
              children: [
                _buildInfoRow('Emergency Contact', data['emergencyContact'] ?? 'N/A'),
              ]
            ),
            const SizedBox(height: 16),

            // Recent Attendance Card
            _buildInfoCard(
              title: 'Recent Attendance',
              icon: Icons.calendar_today,
              children: [
                _buildAttendanceRow('Today', 'Picked Up', true, '07:35 AM'),
                _buildAttendanceRow('Yesterday', 'Dropped', true, '03:45 PM'),
                _buildAttendanceRow('Mon, 24 Jul', 'Dropped', true, '03:30 PM'),
              ]
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(String date, String status, bool present, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Text(
                time,
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: present ? Colors.green[100] : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: present ? Colors.green[800] : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title, 
    required IconData icon, 
    required List<Widget> children,
    Color iconColor = AppColors.primary,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
