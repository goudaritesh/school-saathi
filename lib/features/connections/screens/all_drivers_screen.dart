import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../../../core/constants/colors.dart';
import 'driver_profile_screen.dart';

class AllDriversScreen extends StatefulWidget {
  const AllDriversScreen({Key? key}) : super(key: key);

  @override
  State<AllDriversScreen> createState() => _AllDriversScreenState();
}

class _AllDriversScreenState extends State<AllDriversScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectionProvider>().fetchAllDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Drivers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ConnectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                provider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.drivers.isEmpty) {
            return const Center(child: Text('No drivers available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.drivers.length,
            itemBuilder: (context, index) {
              final driver = provider.drivers[index];
              final user = driver['user'] ?? {};

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryContainer,
                    child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                  ),
                  title: Text(
                    user['name'] ?? 'Unknown Driver',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Vehicle: ${driver['vehicle_no'] ?? 'N/A'}'),
                      Text('Route: ${driver['route_name'] ?? 'N/A'}'),
                      const SizedBox(height: 4),
                      Text(
                        'Seats Available: ${driver['available_seats'] ?? 0} / ${driver['total_seats'] ?? 0}',
                        style: TextStyle(
                          color: (driver['available_seats'] ?? 0) > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverProfileScreen(driver: driver),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
