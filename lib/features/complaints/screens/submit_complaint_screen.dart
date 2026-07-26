import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/complaint_provider.dart';
import '../../dashboard/providers/parent_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({Key? key}) : super(key: key);

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final parentProvider = Provider.of<ParentProvider>(context, listen: false);
      final driverId = parentProvider.dashboardData?['driverId'];
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (driverId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No connected driver found.')));
        return;
      }

      final success = await Provider.of<ComplaintProvider>(context, listen: false).submitComplaint(
        driverId: driverId,
        subject: _subjectController.text.trim(),
        description: _descController.text.trim(),
        attachment: _image,
        token: authProvider.token!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted successfully')));
        Navigator.pop(context);
      } else if (mounted) {
        final err = Provider.of<ComplaintProvider>(context, listen: false).error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File a Complaint')),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a subject' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => value!.isEmpty ? 'Please provide details' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  if (_image != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_image!, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          onPressed: () => setState(() => _image = null),
                        )
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Attach Evidence (Optional)'),
                    ),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Complaint', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
