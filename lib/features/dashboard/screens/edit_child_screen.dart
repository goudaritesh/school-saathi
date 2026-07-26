import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/parent_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';

class EditChildScreen extends StatefulWidget {
  const EditChildScreen({super.key});

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _childNameController;
  late TextEditingController _classInfoController;
  late TextEditingController _schoolNameController;
  late TextEditingController _rollNumberController;
  late TextEditingController _pickupTimeController;
  late TextEditingController _dropTimeController;
  late TextEditingController _pickupAddressController;
  late TextEditingController _dropAddressController;
  late TextEditingController _emergencyContactController;

  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final parentProvider = Provider.of<ParentProvider>(context, listen: false);
    final data = parentProvider.dashboardData ?? {};

    _currentImageUrl = data['childPhotoUrl'];
    _childNameController = TextEditingController(text: data['childName'] != '--' ? data['childName'] : '');
    _classInfoController = TextEditingController(text: data['classInfo'] != '--' ? data['classInfo'] : '');
    _schoolNameController = TextEditingController(text: data['schoolName'] != '--' ? data['schoolName'] : '');
    _rollNumberController = TextEditingController(text: data['rollNumber'] != '--' ? data['rollNumber'] : '');
    _pickupTimeController = TextEditingController(text: data['pickupTime'] != '--' ? data['pickupTime'] : '');
    _dropTimeController = TextEditingController(text: data['dropTime'] != '--' ? data['dropTime'] : '');
    _pickupAddressController = TextEditingController(text: data['pickupAddress'] != '--' ? data['pickupAddress'] : '');
    _dropAddressController = TextEditingController(text: data['dropAddress'] != '--' ? data['dropAddress'] : '');
    _emergencyContactController = TextEditingController(text: data['emergencyContact'] != '--' ? data['emergencyContact'] : '');
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _classInfoController.dispose();
    _schoolNameController.dispose();
    _rollNumberController.dispose();
    _pickupTimeController.dispose();
    _dropTimeController.dispose();
    _pickupAddressController.dispose();
    _dropAddressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final parentProvider = Provider.of<ParentProvider>(context, listen: false);
      
      final updatedData = {
        'child_name': _childNameController.text.trim(),
        'class_info': _classInfoController.text.trim(),
        'school_name': _schoolNameController.text.trim(),
        'roll_number': _rollNumberController.text.trim(),
        'pickup_time': _pickupTimeController.text.trim(),
        'drop_time': _dropTimeController.text.trim(),
        'pickup_address': _pickupAddressController.text.trim(),
        'drop_address': _dropAddressController.text.trim(),
        'emergency_contact': _emergencyContactController.text.trim(),
      };

      final success = await parentProvider.updateChildDetails(updatedData);
      
      setState(() => _isSaving = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details updated successfully!')));
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(parentProvider.errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Child Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                            : (_currentImageUrl != null
                                ? NetworkImage(_currentImageUrl!)
                                : null) as ImageProvider?,
                        child: _imageFile == null && _currentImageUrl == null
                            ? const Icon(Icons.person, size: 50, color: AppColors.outline)
                            : null,
                      ),
                    ),
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
              const SizedBox(height: 24),
              _buildTextField(_childNameController, 'Child Name', Icons.person),
              _buildTextField(_schoolNameController, 'School Name', Icons.school),
              _buildTextField(_classInfoController, 'Class & Section', Icons.class_),
              _buildTextField(_rollNumberController, 'Roll Number', Icons.numbers),
              _buildTextField(_pickupTimeController, 'Pickup Time', Icons.access_time),
              _buildTextField(_dropTimeController, 'Drop Time', Icons.access_time_filled),
              _buildTextField(_pickupAddressController, 'Pickup Address', Icons.location_on),
              _buildTextField(_dropAddressController, 'Drop Address', Icons.location_city),
              _buildTextField(_emergencyContactController, 'Emergency Contact', Icons.phone, isPhone: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveDetails,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _isSaving = true;
      });
      
      try {
        final ApiClient apiClient = ApiClient();
        final response = await apiClient.uploadFile('/upload', _imageFile!.path);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final imageUrl = data['url'];
          
          setState(() {
            _currentImageUrl = imageUrl;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child image uploaded successfully! Save details to keep changes.')));
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
            _isSaving = false;
          });
        }
      }
    }
  }
}
