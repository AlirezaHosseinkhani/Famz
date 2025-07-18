import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final int? id;
  final int? request;
  final String? audioFile;
  final String? videoFile;
  final DateTime? duration;
  final DateTime? createdAt;

  const Alarm({
    this.id,
    this.request,
    this.audioFile,
    this.videoFile,
    this.duration,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        request,
        audioFile,
        videoFile,
        duration,
        createdAt,
      ];
}
