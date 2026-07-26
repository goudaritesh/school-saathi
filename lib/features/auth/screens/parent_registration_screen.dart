import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/colors.dart';

class ParentRegistrationScreen extends StatefulWidget {
  final VoidCallback onSwitchToDriver;
  const ParentRegistrationScreen({super.key, required this.onSwitchToDriver});

  @override
  State<ParentRegistrationScreen> createState() => _ParentRegistrationScreenState();
}

class _ParentRegistrationScreenState extends State<ParentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _childNameController = TextEditingController();
  final _refCodeController = TextEditingController();
  bool _obscurePassword = true;

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
              'Create Parent Account',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register to start monitoring your child\'s journey.',
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (val) => val!.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              validator: (val) => val!.isEmpty ? 'Enter mobile number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _childNameController,
              decoration: const InputDecoration(labelText: 'Child\'s Name'),
              validator: (val) => val!.isEmpty ? 'Enter child\'s name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _refCodeController,
              decoration: const InputDecoration(labelText: 'Driver Reference Code (Optional)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (val) => val!.length < 6 ? 'Password too short' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.registerParent({
                          'name': _nameController.text,
                          'phone': _mobileController.text,
                          'child_name': _childNameController.text,
                          'refcode': _refCodeController.text,
                          'password': _passwordController.text,
                        });
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registered Successfully!')),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register as Parent'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: widget.onSwitchToDriver,
              child: const Text('Are you a Driver? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
