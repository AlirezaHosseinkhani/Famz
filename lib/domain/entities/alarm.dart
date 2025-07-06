import 'package:equatable/equatable.dart';

enum RecordingType { audio, video }

class Alarm extends Equatable {
  final int id;
  final DateTime time;
  final bool isActive;
  final String? title;
  final String? description;
  final List<int>? repeatDays; // 0-6 (Sunday-Saturday)
  final int? recordingId;
  final RecordingType? recordingType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Alarm({
    required this.id,
    required this.time,
    required this.isActive,
    this.title,
    this.description,
    this.repeatDays,
    this.recordingId,
    this.recordingType,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        time,
        isActive,
        title,
        description,
        repeatDays,
        recordingId,
        recordingType,
        createdAt,
        updatedAt,
      ];
}
