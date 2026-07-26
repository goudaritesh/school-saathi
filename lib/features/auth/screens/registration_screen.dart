import 'package:flutter/material.dart';
import 'parent_registration_screen.dart';
import 'driver_registration_screen.dart';
import '../../../core/constants/colors.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isParent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isParent 
            ? ParentRegistrationScreen(
                key: const ValueKey('Parent'),
                onSwitchToDriver: () => setState(() => _isParent = false),
              )
            : DriverRegistrationScreen(
                key: const ValueKey('Driver'),
                onSwitchToParent: () => setState(() => _isParent = true),
              ),
        ),
      ),
    );
  }
}
