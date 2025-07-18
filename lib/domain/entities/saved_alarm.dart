import 'package:equatable/equatable.dart';

class SavedAlarm extends Equatable {
  final int? id;
  final DateTime time;
  final bool isActive;
  final int? recordingId;
  final List<int>? repeatDays;
  final String? label;
  final String? recordingTitle;
  final String? recordingType; // 'audio' or 'video'
  final String? recordingUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavedAlarm({
    this.id,
    required this.time,
    required this.isActive,
    this.recordingId,
    this.repeatDays,
    this.label,
    this.recordingTitle,
    this.recordingType,
    this.recordingUrl,
    this.createdAt,
    this.updatedAt,
  });

  SavedAlarm copyWith({
    int? id,
    DateTime? time,
    bool? isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
    String? recordingTitle,
    String? recordingType,
    String? recordingUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedAlarm(
      id: id ?? this.id,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      recordingId: recordingId ?? this.recordingId,
      repeatDays: repeatDays ?? this.repeatDays,
      label: label ?? this.label,
      recordingTitle: recordingTitle ?? this.recordingTitle,
      recordingType: recordingType ?? this.recordingType,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        time,
        isActive,
        recordingId,
        repeatDays,
        label,
        recordingTitle,
        recordingType,
        recordingUrl,
        createdAt,
        updatedAt,
      ];
}
