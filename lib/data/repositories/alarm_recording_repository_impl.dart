import '../../domain/entities/alarm_recording.dart';
import '../../domain/repositories/alarm_recording_repository.dart';
import '../datasources/remote/alarm_recording_remote_datasource.dart';
import '../models/alarm/alarm_recording_model.dart';

class AlarmRecordingRepositoryImpl implements AlarmRecordingRepository {
  final AlarmRecordingRemoteDataSource remoteDataSource;

  AlarmRecordingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AlarmRecording>> getRecordings() async {
    final recordingModels = await remoteDataSource.getRecordings();
    return recordingModels.cast<AlarmRecording>();
  }

  @override
  Future<AlarmRecording> uploadRecording({
    required int requestId,
    String? audioPath,
    String? videoPath,
    required String duration,
  }) async {
    final recordingModel = await remoteDataSource.uploadRecording(
      requestId: requestId,
      audioPath: audioPath,
      videoPath: videoPath,
      duration: duration,
    );
    return recordingModel;
  }

  @override
  Future<AlarmRecording> updateRecording(AlarmRecording recording) async {
    final recordingModel = AlarmRecordingModel.fromEntity(recording);
    final updatedModel = await remoteDataSource.updateRecording(recordingModel);
    return updatedModel;
  }

  @override
  Future<void> deleteRecording(int id) async {
    await remoteDataSource.deleteRecording(id);
  }

  @override
  Future<String> downloadRecording(AlarmRecording recording,
      {Function(double)? onProgress}) async {
    final fileName =
        '${recording.id}_${recording.mediaType}_${DateTime.now().millisecondsSinceEpoch}';
    final extension = recording.hasVideo ? '.mp4' : '.mp3';
    return await remoteDataSource.downloadFile(
      recording.mediaUrl,
      '$fileName$extension',
      onProgress: onProgress,
    );
  }
}
