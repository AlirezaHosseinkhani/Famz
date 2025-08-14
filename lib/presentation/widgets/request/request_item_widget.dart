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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF2C1A0F), // Deep brown at top
            Color(0xFF000000), // Black at bottom
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.6), // Soft orange
          width: 1,
        ),
        boxShadow: [
          // Outer glow effect
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          // Soft drop shadow
          BoxShadow(
            color: Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.09),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: _getProfileImage() != null
                            ? CircleAvatar(
                                backgroundImage: _getProfileImage(),
                                radius: 25,
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.white70,
                                size: 25,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getUsername()} is waiting for your medal!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _getTimeAgo(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.message,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    // final profilePicture = _getProfilePictureUrl();
    // return profilePicture != null ? NetworkImage(profilePicture) : null;
    return null;
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
      return request.fromUser.email?.split('@')[0] ?? 'Unknown User';
    } else {
      return request.toUser.email?.split('@')[0] ?? 'Unknown User';
    }
  }

  String _getStatusText() {
    return 'Status: ${request.status}';
  }

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFB74D); // Orange
      case 'accepted':
        return const Color(0xFF81C784); // Green
      case 'rejected':
        return const Color(0xFFE57373); // Red
      default:
        return Colors.white70;
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
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3), // Light beige like in Figma
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: onAccept,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Record Now',
                    style: TextStyle(
                      color: Color(0xFF3E2723),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: onReject,
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      } else if (request.status == 'accepted' ||
          request.status == 'recording_pending') {
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: request.status == 'recording_pending'
                ? const Color(0xFFFFB74D)
                : const Color(0xFFF5E6D3),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextButton(
            onPressed: onRecord,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              request.status == 'recording_pending'
                  ? 'Continue Recording'
                  : 'Record Now',
              style: TextStyle(
                color: request.status == 'recording_pending'
                    ? Colors.white
                    : const Color(0xFF3E2723),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    }
    // For sent requests
    else {
      if (request.status == 'pending') {
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE57373)),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Color(0xFFE57373),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      } else if (request.status == 'recording_pending' ||
          request.status == 'complete') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: request.status == 'recording_pending'
                ? const Color(0xFFFFB74D).withOpacity(0.2)
                : const Color(0xFF81C784).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: request.status == 'recording_pending'
                  ? const Color(0xFFFFB74D)
                  : const Color(0xFF81C784),
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
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFF81C784),
              ),
              const SizedBox(width: 8),
              Text(
                request.status == 'recording_pending'
                    ? 'Recording Pending'
                    : 'Completed',
                style: TextStyle(
                  color: request.status == 'recording_pending'
                      ? const Color(0xFFFFB74D)
                      : const Color(0xFF81C784),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
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
