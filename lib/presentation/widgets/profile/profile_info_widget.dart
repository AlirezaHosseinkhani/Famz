import 'package:flutter/material.dart';

import '../../../domain/entities/profile.dart';

class ProfileInfoWidget extends StatelessWidget {
  final Profile profile;
  final VoidCallback? onEditTap;

  const ProfileInfoWidget({
    Key? key,
    required this.profile,
    this.onEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Membership Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Get Premium Membership',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upgrade for more features',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Profile Information Fields
          _buildInfoField(
            context,
            'Name',
            profile.username,
          ),

          const SizedBox(height: 24),

          _buildInfoField(
            context,
            'Phone Number',
            profile.phoneNumber ?? "---",
          ),

          const SizedBox(height: 24),

          _buildInfoField(
            context,
            'Email',
            profile.email ?? "---",
          ),

          const SizedBox(height: 24),

          _buildInfoField(
            context,
            'Subscription Details',
            'Basic User',
          ),

          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildInfoField(
              context,
              'Bio',
              profile.bio!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white10, // Light white background
            borderRadius: BorderRadius.circular(8), // Rounded border
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
              // Darker text for better contrast on light background
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
