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
    final timeFormat = DateFormat('h:mm');
    final amPm = DateFormat('a').format(alarm.scheduledTime).toUpperCase();

    return Dismissible(
      key: Key(alarm.id ?? ''),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) {
        onDelete();
      },
      background: _buildDismissBackground(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Time display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        timeFormat.format(alarm.scheduledTime),
                        style: TextStyle(
                          color: alarm.isActive ? Colors.white : Colors.grey,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        amPm,
                        style: TextStyle(
                          color: alarm.isActive ? Colors.white70 : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Repeat info
                  Text(
                    alarm.getWeekdaysText(),
                    style: TextStyle(
                      color: alarm.isActive ? Colors.white70 : Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  // Date for one-time alarms
                  if (!alarm.isRecurring)
                    Text(
                      DateFormat('EEE, MMM d, yyyy')
                          .format(alarm.scheduledTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: alarm.isActive ? Colors.white70 : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                // Toggle switch
                Switch(
                  value: alarm.isActive,
                  onChanged: onToggle,
                  activeColor: Colors.orange,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[800],
                ),
                const SizedBox(height: 8),

                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Change',
                      style: TextStyle(
                        color: alarm.isActive ? Colors.orange : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Alarm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this alarm?',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.alarm,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('h:mm a').format(alarm.scheduledTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alarm.isRecurring ? 'Recurring' : 'One-time',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
