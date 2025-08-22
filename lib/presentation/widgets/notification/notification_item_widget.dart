import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as time_ago;

import '../../../domain/entities/notification.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationItemWidget({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Consistent dark background
        borderRadius: BorderRadius.circular(12),
        border: !notification.isRead
            ? Border.all(
                color: const Color(0xFFFF6B35).withOpacity(0.3), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFFF6B35).withOpacity(0.1),
          highlightColor: const Color(0xFFFF6B35).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getNotificationTitle(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B35),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: const Color(0xFF8E8E93),
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            time_ago.format(notification.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF636366),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          if (!notification.isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFFF6B35).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNotificationTitle() {
    switch (notification.notificationType.toLowerCase()) {
      case 'alarm_request':
        return 'Alarm Request';
      case 'recording_uploaded':
        return 'Recording Uploaded';
      case 'request_accepted':
        return 'Request Accepted';
      case 'request_rejected':
        return 'Request Rejected';
      case 'reminder':
        return 'Reminder';
      default:
        return notification.notificationType;
    }
  }

  Widget _buildIcon() {
    final iconConfig = _getIconConfig();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconConfig.color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconConfig.icon,
        color: iconConfig.color,
        size: 22,
      ),
    );
  }

  _IconConfig _getIconConfig() {
    switch (notification.notificationType.toLowerCase()) {
      case 'alarm_request':
        return _IconConfig(Icons.access_alarm_rounded, const Color(0xFF007AFF));
      case 'recording_uploaded':
        return _IconConfig(Icons.cloud_upload_rounded, const Color(0xFF34C759));
      case 'request_accepted':
        return _IconConfig(Icons.check_circle_rounded, const Color(0xFF34C759));
      case 'request_rejected':
        return _IconConfig(Icons.cancel_rounded, const Color(0xFFFF3B30));
      case 'reminder':
        return _IconConfig(
            Icons.notifications_rounded, const Color(0xFFFF6B35));
      default:
        return _IconConfig(Icons.info_rounded, const Color(0xFFFF6B35));
    }
  }
}

class _IconConfig {
  final IconData icon;
  final Color color;

  const _IconConfig(this.icon, this.color);
}
