import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../routes/route_names.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/profile/profile_avatar_widget.dart';
import '../../../widgets/profile/profile_info_widget.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ProfileBloc>().add(const GetProfileEvent());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload profile after update
            context.read<ProfileBloc>().add(const GetProfileEvent());
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const LoadingWidget();
          } else if (state is ProfileError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ProfileBloc>().add(const GetProfileEvent());
              },
            );
          } else if (state is ProfileLoaded || state is ProfileUpdating) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileUpdating).currentProfile;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(const GetProfileEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Avatar
                    ProfileAvatarWidget(
                      imageUrl: profile.profilePicture,
                      size: 120,
                      isEditable: true,
                      onTap: () => _navigateToEditProfile(context),
                    ),
                    const SizedBox(height: 16),
                    // Profile Name
                    Text(
                      profile.username,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (profile.bio != null && profile.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 8,
                        ),
                        child: Text(
                          profile.bio!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Profile Information Card
                    ProfileInfoWidget(
                      profile: profile,
                      onEditTap: () => _navigateToEditProfile(context),
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToEditProfile(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutEvent());
                Navigator.of(context).pushReplacementNamed(RouteNames.intro);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
