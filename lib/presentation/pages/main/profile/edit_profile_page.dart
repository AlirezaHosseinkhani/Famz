import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/profile/profile_avatar_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
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
      _bioController.text = state.profile.bio ?? '';
      _profileImagePath = state.profile.profilePicture;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileUpdating) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return TextButton(
                onPressed: _hasChanges ? _saveProfile : null,
                child: const Text('Save'),
              );
            },
          ),
        ],
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
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image
                ProfileAvatarWidget(
                  imageUrl: _profileImagePath,
                  size: 120,
                  isEditable: true,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Change Profile Picture'),
                ),
                const SizedBox(height: 32),
                // Phone Number Field
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  // prefixIcon: Icons.phone,
                  onChanged: (_) => _markAsChanged(),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Bio Field
                CustomTextField(
                  controller: _bioController,
                  label: 'Bio',
                  hint: 'Tell us about yourself',
                  prefixIcon: Icon(Icons.info),
                  maxLines: 3,
                  maxLength: 150,
                  onChanged: (_) => _markAsChanged(),
                  validator: (value) {
                    if (value != null && value.length > 150) {
                      return 'Bio must be 150 characters or less';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: _hasChanges ? _saveProfile : null,
                    isLoading:
                        context.watch<ProfileBloc>().state is ProfileUpdating,
                  ),
                ),
                const SizedBox(height: 16),
                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        ),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _phoneController.text.trim();
      final bio = _bioController.text.trim();

      context.read<ProfileBloc>().add(
            PatchProfileEvent(
              phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
              bio: bio.isEmpty ? null : bio,
              profilePicture: _profileImageBase64,
            ),
          );
    }
  }
}
