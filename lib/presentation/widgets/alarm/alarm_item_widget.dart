import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/alarm.dart';

class AlarmItemWidget extends StatelessWidget {
  final Alarm alarm;
  final Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlarmItemWidget({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeFormat.format(alarm.scheduledTime),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: alarm.isActive ? Colors.white : Colors.grey,
                  ),
                ),
                Switch(
                  value: alarm.isActive,
                  onChanged: onToggle,
                  activeColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Display weekday information for recurring alarms
            Text(
              alarm.isRecurring ? alarm.getWeekdaysText() : 'One time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: alarm.isActive ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (!alarm.isRecurring)
              Text(
                DateFormat('EEE, MMM d, yyyy').format(alarm.scheduledTime),
                style: TextStyle(
                  fontSize: 14,
                  color: alarm.isActive ? Colors.white70 : Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            // Video information
            if (alarm.videoPath.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.videocam, size: 16, color: Colors.white54),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getFileName(alarm.videoPath),
                      style: TextStyle(
                        color: alarm.isActive ? Colors.white54 : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label:
                      const Text('Edit', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFileName(String path) {
    if (path.isEmpty) return 'Default Alarm';
    return path.split('/').last;
  }
}
