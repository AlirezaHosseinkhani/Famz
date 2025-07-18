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
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onEditTap != null)
                  IconButton(
                    onPressed: onEditTap,
                    icon: const Icon(Icons.edit),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Username',
              profile.username,
              Icons.person,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Email',
              profile.email,
              Icons.email,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Phone Number',
              profile.phoneNumber ?? 'Not provided',
              Icons.phone,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Bio',
              profile.bio ?? 'No bio available',
              Icons.info,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Member Since',
              _formatDate(DateTime.now()),
              // _formatDate(profile.createdAt),
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
