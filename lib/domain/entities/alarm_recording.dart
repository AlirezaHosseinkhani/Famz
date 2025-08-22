import 'package:equatable/equatable.dart';

class AlarmRecording extends Equatable {
  final int id;
  final int requestId;
  final String? audioFile;
  final String? videoFile;
  final String duration;
  final String username;
  final DateTime createdAt;
  final String? localPath; // For downloaded files
  final bool isDownloaded;
  final double downloadProgress;

  const AlarmRecording({
    required this.id,
    required this.requestId,
    this.audioFile,
    this.videoFile,
    required this.duration,
    required this.username,
    required this.createdAt,
    this.localPath,
    this.isDownloaded = false,
    this.downloadProgress = 0.0,
  });

  bool get hasAudio =>
      audioFile != null && audioFile!.isNotEmpty && audioFile != 'null';

  bool get hasVideo =>
      videoFile != null && videoFile!.isNotEmpty && videoFile != 'null';

  bool get isAudioOnly => hasAudio && !hasVideo;

  bool get isVideoOnly => hasVideo && !hasAudio;

  String get mediaUrl => hasVideo ? videoFile! : (hasAudio ? audioFile! : '');

  String get mediaType => hasVideo ? 'video' : (hasAudio ? 'audio' : 'unknown');

  AlarmRecording copyWith({
    int? id,
    int? requestId,
    String? audioFile,
    String? videoFile,
    String? duration,
    String? username,
    DateTime? createdAt,
    String? localPath,
    bool? isDownloaded,
    double? downloadProgress,
  }) {
    return AlarmRecording(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      audioFile: audioFile ?? this.audioFile,
      videoFile: videoFile ?? this.videoFile,
      duration: duration ?? this.duration,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requestId,
        audioFile,
        videoFile,
        duration,
        username,
        createdAt,
        localPath,
        isDownloaded,
        downloadProgress,
      ];
}
