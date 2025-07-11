// import 'package:famz/core/constants/route_constants.dart';
// import 'package:famz/presentation/bloc/auth/auth_bloc.dart';
// import 'package:famz/presentation/bloc/profile/profile_bloc.dart';
// import 'package:famz/presentation/widgets/common/custom_app_bar.dart';
// import 'package:famz/presentation/widgets/common/error_widget.dart';
// import 'package:famz/presentation/widgets/common/loading_widget.dart';
// import 'package:famz/presentation/widgets/profile/profile_avatar_widget.dart';
// import 'package:famz/presentation/widgets/profile/profile_info_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           context.read<ProfileBloc>()..add(GetProfileRequested()),
//       child: const ProfileView(),
//     );
//   }
// }
//
// class ProfileView extends StatelessWidget {
//   const ProfileView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: CustomAppBar(
//         title: 'Profile',
//         titleColor: Colors.white,
//         backgroundColor: Colors.black,
//         showBackButton: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit, color: Color(0xFFFF6B35)),
//             onPressed: () {
//               context.push(RouteConstants.editProfile);
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<ProfileBloc, ProfileState>(
//         builder: (context, state) {
//           if (state is ProfileLoading) {
//             return const LoadingWidget();
//           }
//
//           if (state is ProfileError) {
//             return CustomErrorWidget(
//               message: state.message,
//               onRetry: () {
//                 context.read<ProfileBloc>().add(GetProfileRequested());
//               },
//             );
//           }
//
//           if (state is ProfileLoaded) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   ProfileAvatarWidget(
//                     imageUrl: state.profile.profilePicture,
//                     size: 100,
//                     onTap: () {
//                       // Handle avatar tap
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     state.profile.user.username,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     state.profile.user.email,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.7),
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   ProfileInfoWidget(profile: state.profile),
//                   const SizedBox(height: 30),
//                   _buildSettingsSection(context),
//                 ],
//               ),
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//   Widget _buildSettingsSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Settings',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildSettingsItem(
//           icon: Icons.notifications,
//           title: 'Notifications',
//           subtitle: 'Manage notification preferences',
//           onTap: () {
//             // Navigate to notification settings
//           },
//         ),
//         _buildSettingsItem(
//           icon: Icons.security,
//           title: 'Privacy & Security',
//           subtitle: 'Manage your privacy settings',
//           onTap: () {
//             // Navigate to privacy settings
//           },
//         ),
//         _buildSettingsItem(
//           icon: Icons.help,
//           title: 'Help & Support',
//           subtitle: 'Get help and contact support',
//           onTap: () {
//             // Navigate to help
//           },
//         ),
//         _buildSettingsItem(
//           icon: Icons.info,
//           title: 'About',
//           subtitle: 'App version and information',
//           onTap: () {
//             // Show about dialog
//           },
//         ),
//         const SizedBox(height: 20),
//         _buildLogoutButton(context),
//       ],
//     );
//   }
//
//   Widget _buildSettingsItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1E1E1E),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.1),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFF6B35).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Icon(
//                 icon,
//                 color: const Color(0xFFFF6B35),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.6),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.chevron_right,
//               color: Colors.white.withOpacity(0.3),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogoutButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _showLogoutDialog(context);
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.red.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: Colors.red.withOpacity(0.3),
//           ),
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.logout,
//               color: Colors.red,
//               size: 20,
//             ),
//             SizedBox(width: 8),
//             Text(
//               'Logout',
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF1E1E1E),
//           title: const Text(
//             'Logout',
//             style: TextStyle(color: Colors.white),
//           ),
//           content: const Text(
//             'Are you sure you want to logout?',
//             style: TextStyle(color: Colors.white70),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.white54),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 context.read<AuthBloc>().add(AuthLogoutRequested());
//               },
//               child: const Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../widgets/common/loading_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // context.read<ProfileBloc>().add(GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const LoadingWidget();
          } else if (state is ProfileLoaded) {
            final profile = state.profile;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // ProfileAvatarWidget(
                  //   imageUrl: profile.profilePicture,
                  //   username: profile.username,
                  //   size: 120,
                  // ),
                  const SizedBox(height: 24),
                  Text(
                    profile.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  // ProfileInfoWidget(profile: profile),
                  const SizedBox(height: 32),
                  _buildSettingsSection(context),
                ],
              ),
            );
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(GetProfileEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to help & support
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to about page
            },
          ),
        ],
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout functionality
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/intro',
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
