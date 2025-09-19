import 'dart:convert';
import 'dart:io';

import 'package:famz/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../widgets/profile/profile_avatar_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _profileImagePath;
  String? _profileImageBase64;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _phoneController.text = state.profile.phoneNumber ?? '';
      _usernameController.text = state.profile.username ?? '';
      _bioController.text = state.profile.bio ?? '';
      _profileImagePath = state.profile.profilePicture;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      appBar: CustomAppBar(
        title: "Edit Profile",
        backgroundColor: Colors.black,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            Navigator.of(context).pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: Container(
          color: Colors.black,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Image Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ProfileAvatarWidget(
                              imageUrl: _profileImagePath,
                              size: 100,
                              isEditable: false,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B35),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Change Profile Picture',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Information Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username Field
                        _buildInputField(
                          label: 'Username',
                          controller: _usernameController,
                          icon: Icons.perm_identity,
                          keyboardType: TextInputType.text,
                          // validator: (value) {
                          //   if (value != null && value.isNotEmpty) {
                          //     if (!RegExp(r'^\+?[1-9]\d{1,14}$')
                          //         .hasMatch(value)) {
                          //       return 'Please enter a valid phone number';
                          //     }
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 20),

                        // Phone Number Field
                        _buildInputField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^\+?[1-9]\d{1,14}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Bio Field
                        _buildInputField(
                          label: 'Bio',
                          controller: _bioController,
                          icon: Icons.info_outline,
                          maxLines: 3,
                          maxLength: 150,
                          validator: (value) {
                            if (value != null && value.length > 150) {
                              return 'Bio must be 150 characters or less';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _hasChanges ? _saveProfile : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasChanges
                                ? const Color(0xFFFF6B35)
                                : Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              if (state is ProfileUpdating) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                );
                              }
                              return const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (_) => _markAsChanged(),
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.grey[500],
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFF3A3A3A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFFF6B35),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            counterStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        setState(() {
          _profileImagePath = image.path;
          _profileImageBase64 = base64String;
          _hasChanges = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _phoneController.text.trim();
      final username = _usernameController.text.trim();
      final bio = _bioController.text.trim();

      context.read<ProfileBloc>().add(
            PatchProfileEvent(
              phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
              username: username.isEmpty ? null : username,
              bio: bio.isEmpty ? null : bio,
              profilePicture: _profileImageBase64,
            ),
          );
    }
  }
}
