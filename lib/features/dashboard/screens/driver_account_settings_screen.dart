import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';

class DriverAccountSettingsScreen extends StatefulWidget {
  const DriverAccountSettingsScreen({super.key});

  @override
  State<DriverAccountSettingsScreen> createState() => _DriverAccountSettingsScreenState();
}

class _DriverAccountSettingsScreenState extends State<DriverAccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _routeController = TextEditingController();
  final _seatsController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  Future<void> _loadProfileData() async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _phoneController.text = user['phone'] ?? '';
      }
      
      // We don't have a direct GET profile, but we can just use the update endpoint to set them.
      // Let's try to get them from local state if we have them, else leave blank.
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final data = {
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_phoneController.text.isNotEmpty) 'phone': _phoneController.text,
        if (_vehicleController.text.isNotEmpty) 'vehicle_no': _vehicleController.text,
        if (_modelController.text.isNotEmpty) 'vehicle_model': _modelController.text,
        if (_colorController.text.isNotEmpty) 'vehicle_color': _colorController.text,
        if (_routeController.text.isNotEmpty) 'route_name': _routeController.text,
        if (_seatsController.text.isNotEmpty) 'total_seats': int.parse(_seatsController.text),
      };
      
      final apiClient = ApiClient();
      await apiClient.put('/driver/profile', data: data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Van Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Plate Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_bus),
                  hintText: 'e.g. MH 12 AB 1234'
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Van Model',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.car_repair),
                  hintText: 'e.g. Maruti Suzuki Eeco'
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Van Color',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                  hintText: 'e.g. White'
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.route),
                  hintText: 'e.g. Downtown to School'
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Seats in Van',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.airline_seat_recline_normal),
                ),
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
