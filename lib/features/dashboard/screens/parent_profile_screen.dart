import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';
import 'dart:convert';
import 'edit_child_screen.dart';
import '../../connections/providers/connection_provider.dart';
import '../../support/screens/support_screen.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _isUploading = true;
      });
      
      try {
        final ApiClient apiClient = ApiClient();
        final response = await apiClient.uploadFile('/upload', _imageFile!.path);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final imageUrl = data['url'];
          
          // Optionally save this imageUrl to user profile via an API call
          await apiClient.put('/auth/profile', data: {'profile_photo_url': imageUrl});
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated successfully!')));
          }
        } else {
          throw Exception('Failed to upload');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No User Data')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surfaceVariant,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (user['profile_photo_url'] != null
                              ? NetworkImage(user['profile_photo_url'])
                              : null) as ImageProvider?,
                      child: _imageFile == null && user['profile_photo_url'] == null
                          ? const Icon(Icons.person, size: 50, color: AppColors.outline)
                          : null,
                    ),
                  ),
                  if (_isUploading)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircularProgressIndicator(),
                    )
                  else
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user['name'] ?? 'User Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user['email'] ?? user['phone'] ?? 'Contact Info',
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            _buildProfileMenu(
              icon: Icons.person_outline,
              title: 'Account Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditChildScreen()),
                );
              },
            ),
            _buildProfileMenu(
              icon: Icons.person_remove,
              title: 'Disconnect from Driver',
              iconColor: Colors.orange,
              textColor: Colors.orange,
              onTap: () {
                _showDisconnectDialog(context);
              },
              showTrailing: false,
            ),
            _buildProfileMenu(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildProfileMenu(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () {
                _showLogoutDialog(context, authProvider);
              },
              showTrailing: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.primary,
    Color textColor = AppColors.onSurface,
    bool showTrailing = true,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        ),
        trailing: showTrailing
            ? const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant)
            : null,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Driver'),
        content: const Text('Are you sure you want to disconnect from your current driver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<ConnectionProvider>(context, listen: false).disconnectUser();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disconnected successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to disconnect. You might not have an active connection.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
