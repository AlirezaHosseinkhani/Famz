import 'package:flutter/material.dart';

class RequestItemWidget extends StatelessWidget {
  final dynamic request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRecord;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const RequestItemWidget({
    super.key,
    required this.request,
    this.onAccept,
    this.onReject,
    this.onRecord,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // CircleAvatar(
                //   backgroundImage: _getProfileImage(),
                //   child: _getProfileImage() == null
                //       ? const Icon(Icons.person)
                //       : null,
                // ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUsername(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _getStatusText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _getTimeAgo(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    final profilePicture = _getProfilePictureUrl();
    return profilePicture != null ? NetworkImage(profilePicture) : null;
  }

  String? _getProfilePictureUrl() {
    if (request.runtimeType.toString().contains('Received')) {
      return request.fromUserProfilePicture;
    } else {
      return request.toUserProfilePicture;
    }
  }

  String _getUsername() {
    if (request.runtimeType.toString().contains('Received')) {
      return request.fromUser.email ?? 'Unknown User';
    } else {
      return request.toUser.email ?? 'Unknown User';
    }
  }

  String _getStatusText() {
    return 'Status: ${request.status}';
  }

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(request.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    // For received requests
    if (request.runtimeType.toString().contains('Received')) {
      if (request.status == 'pending') {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check, color: Colors.white70),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, color: Colors.white70),
                label: const Text('Reject'),
              ),
            ),
          ],
        );
      } else if (request.status == 'accepted' ||
          request.status == 'recording_pending') {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onRecord,
            icon: const Icon(Icons.mic),
            label: Text(request.status == 'recording_pending'
                ? 'Continue Recording'
                : 'Record Alarm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: request.status == 'recording_pending'
                  ? Colors.orange
                  : Colors.blue,
            ),
          ),
        );
      }
    }
    // For sent requests - UPDATED LOGIC
    else {
      // Only show edit and delete buttons if status is 'pending'
      if (request.status == 'pending') {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        );
      }
      // For recording_pending or complete status, show status info only
      else if (request.status == 'recording_pending' ||
          request.status == 'complete') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: request.status == 'recording_pending'
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: request.status == 'recording_pending'
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                request.status == 'recording_pending'
                    ? Icons.pending
                    : Icons.check_circle,
                color: request.status == 'recording_pending'
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                request.status == 'recording_pending'
                    ? 'Recording Pending'
                    : 'Completed',
                style: TextStyle(
                  color: request.status == 'recording_pending'
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox();
  }
}
