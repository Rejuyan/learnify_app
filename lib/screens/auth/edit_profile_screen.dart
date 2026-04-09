import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/local_data_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _authService = AuthService();
  final _ds = LocalDataService();
  final _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing display name if it exists
    final user = _authService.currentUser;
    if (user != null && user.displayName != null) {
      _nameController.text = user.displayName!;
    }
    _loadProfilePhoto();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfilePhoto() async {
    final photo = await _ds.getProfilePhoto();
    if (mounted) {
      setState(() {
        _photoBase64 = photo;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 250,
        maxHeight: 250,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not pick image: $e';
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Name cannot be empty.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.updateDisplayName(name);
      
      if (_photoBase64 != null) {
        await _ds.setProfilePhoto(_photoBase64!);
        await FirestoreService().updateUserProfile(photoBase64: _photoBase64!);
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      
      // Pop back to the previous screen (the dashboard)
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppTheme.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
               Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryPurpleLight.withValues(alpha: 0.2),
                        backgroundImage: _photoBase64 != null
                            ? MemoryImage(base64Decode(_photoBase64!))
                            : null,
                        child: _photoBase64 == null
                            ? const Icon(Icons.person, size: 50, color: AppTheme.primaryPurple)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),

              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your email address (${_authService.currentUser?.email}) cannot be changed here.',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
