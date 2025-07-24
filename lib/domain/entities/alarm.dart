import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final String? id;
  final DateTime scheduledTime;
  final String videoPath;
  final bool isActive;
  final bool isRecurring;
  final List<bool> weekdays; // Index 0 = Monday, 1 = Tuesday, ..., 6 = Sunday

  const Alarm({
    this.id,
    required this.scheduledTime,
    required this.videoPath,
    this.isActive = true,
    this.isRecurring = false,
    List<bool>? weekdays,
  }) : weekdays =
            weekdays ?? const [false, false, false, false, false, false, false];

  // Helper method to get a human-readable representation of weekdays
  String getWeekdaysText() {
    if (!isRecurring) return 'One time';

    List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> selectedDays = [];

    for (int i = 0; i < 7; i++) {
      if (weekdays[i]) selectedDays.add(dayNames[i]);
    }

    if (selectedDays.length == 7) return 'Every day';
    if (selectedDays.isEmpty) return 'Never';

    return selectedDays.join(', ');
  }

  Alarm copyWith({
    String? id,
    DateTime? scheduledTime,
    String? videoPath,
    bool? isActive,
    bool? isRecurring,
    List<bool>? weekdays,
  }) {
    return Alarm(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      videoPath: videoPath ?? this.videoPath,
      isActive: isActive ?? this.isActive,
      isRecurring: isRecurring ?? this.isRecurring,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  @override
  List<Object?> get props =>
      [id, scheduledTime, videoPath, isActive, isRecurring, weekdays];
}
