import 'package:famz/domain/entities/alarm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlarmItemWidget extends StatelessWidget {
  final Alarm alarm;
  final ValueChanged<bool> onToggle;
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alarm.isActive
              ? const Color(0xFFFF6B35).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(alarm.time),
                      style: TextStyle(
                        color: alarm.isActive ? Colors.white : Colors.white54,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('a').format(alarm.time),
                      style: TextStyle(
                        color: alarm.isActive ? Colors.white70 : Colors.white38,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (alarm.title != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    alarm.title!,
                    style: TextStyle(
                      color: alarm.isActive ? Colors.white70 : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (alarm.repeatDays != null &&
                    alarm.repeatDays!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatRepeatDays(alarm.repeatDays!),
                    style: TextStyle(
                      color: alarm.isActive
                          ? const Color(0xFFFF6B35)
                          : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (alarm.recordingType != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        alarm.recordingType == RecordingType.audio
                            ? Icons.audiotrack
                            : Icons.videocam,
                        size: 16,
                        color: alarm.isActive
                            ? const Color(0xFFFF6B35)
                            : Colors.white38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alarm.recordingType == RecordingType.audio
                            ? 'Audio Alarm'
                            : 'Video Alarm',
                        style: TextStyle(
                          color: alarm.isActive
                              ? const Color(0xFFFF6B35)
                              : Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: alarm.isActive,
                onChanged: onToggle,
                activeColor: const Color(0xFFFF6B35),
                activeTrackColor: const Color(0xFFFF6B35).withOpacity(0.3),
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: Colors.white12,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRepeatDays(List<int> days) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    if (days.length == 7) {
      return 'Every day';
    }

    if (days.length == 5 && days.every((day) => day >= 1 && day <= 5)) {
      return 'Weekdays';
    }

    if (days.length == 2 && days.contains(0) && days.contains(6)) {
      return 'Weekends';
    }

    return days.map((day) => dayNames[day]).join(', ');
  }
}
