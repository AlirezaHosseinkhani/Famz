import '../../entities/alarm_recording.dart';
import '../../repositories/alarm_recording_repository.dart';

class DownloadRecordingUseCase {
  final AlarmRecordingRepository repository;

  DownloadRecordingUseCase(this.repository);

  Future<String> call(AlarmRecording recording,
      {Function(double)? onProgress}) async {
    return await repository.downloadRecording(recording,
        onProgress: onProgress);
  }
}
