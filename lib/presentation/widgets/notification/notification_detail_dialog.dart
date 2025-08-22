import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as time_ago;

import '../../../domain/entities/notification.dart';

class NotificationDetailDialog extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationDetailDialog({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF2C2C2E),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getNotificationTitle(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          time_ago.format(notification.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF8E8E93),
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message Section
                    _buildSection(
                      'Message',
                      notification.message,
                      isMessage: true,
                    ),

                    const SizedBox(height: 20),

                    // Status Section
                    _buildStatusSection(),

                    const SizedBox(height: 20),

                    // Timestamp Section
                    _buildSection(
                      'Received',
                      _formatFullDate(notification.createdAt),
                    ),
                  ],
                ),
              ),
            ),

            // Action Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF2C2C2E),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isMessage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMessage ? 15 : 14,
              height: isMessage ? 1.4 : 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFF6B35).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: notification.isRead
                ? null
                : Border.all(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    width: 1,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                notification.isRead
                    ? Icons.check_circle_rounded
                    : Icons.fiber_manual_record_rounded,
                color: notification.isRead
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFFFF6B35),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                notification.isRead ? 'Read' : 'Unread',
                style: TextStyle(
                  color: notification.isRead
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFFFF6B35),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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

  String _formatFullDate(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$month $day, $year at $displayHour:$minute $amPm';
  }

  Widget _buildIcon() {
    final iconConfig = _getIconConfig();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconConfig.color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconConfig.icon,
        color: iconConfig.color,
        size: 24,
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
