import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/colors.dart';

class DriverRegistrationScreen extends StatefulWidget {
  final VoidCallback onSwitchToParent;
  const DriverRegistrationScreen({super.key, required this.onSwitchToParent});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _licenseNoController = TextEditingController();
  bool _obscurePassword = true;
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, Partner',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentStep == 1
                  ? 'Let\'s start with your basic information.'
                  : 'Secure your van registration.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (authProvider.errorMessage.isNotEmpty)
               Padding(
                 padding: const EdgeInsets.only(top: 16),
                 child: Text(
                   authProvider.errorMessage,
                   style: const TextStyle(color: AppColors.error),
                 ),
               ),
            const SizedBox(height: 24),
            
            if (_currentStep == 1) ...[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (val) => val!.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Create Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) => val!.length < 6 ? 'Password too short' : null,
              ),
            ] else ...[
              TextFormField(
                controller: _vehicleNoController,
                decoration: const InputDecoration(labelText: 'Vehicle Plate Number'),
                validator: (val) => val!.isEmpty ? 'Enter vehicle number' : null,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseNoController,
                decoration: const InputDecoration(labelText: 'Driving License Number'),
                validator: (val) => val!.isEmpty ? 'Enter license number' : null,
              ),
            ],
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      if (_currentStep == 1) {
                         if (_nameController.text.isNotEmpty && _mobileController.text.isNotEmpty) {
                            setState(() => _currentStep = 2);
                         }
                      } else {
                        if (_formKey.currentState!.validate()) {
                          final success = await authProvider.registerDriver({
                            'name': _nameController.text,
                            'phone': _mobileController.text,
                            'vehicle_no': _vehicleNoController.text,
                            'license_no': _licenseNoController.text,
                            'password': _passwordController.text,
                          });
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registered Successfully!')),
                            );
                            Navigator.pop(context); // Go back to login
                          }
                        }
                      }
                    },
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_currentStep == 1 ? 'Next' : 'Complete Registration'),
            ),
            if (_currentStep == 2) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('Back'),
              ),
            ],
            const SizedBox(height: 16),
            if (_currentStep == 1)
              TextButton(
                onPressed: widget.onSwitchToParent,
                child: const Text('Are you a Parent? Register here'),
              ),
          ],
        ),
      ),
    );
  }
}
