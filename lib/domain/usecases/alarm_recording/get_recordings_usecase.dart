import '../../entities/alarm_recording.dart';
import '../../repositories/alarm_recording_repository.dart';

class GetRecordingsUseCase {
  final AlarmRecordingRepository repository;

  GetRecordingsUseCase(this.repository);

  Future<List<AlarmRecording>> call() async {
    return await repository.getRecordings();
  }
}
