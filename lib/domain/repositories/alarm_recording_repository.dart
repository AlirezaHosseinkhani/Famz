import '../entities/alarm_recording.dart';

abstract class AlarmRecordingRepository {
  Future<List<AlarmRecording>> getRecordings();
  Future<AlarmRecording> uploadRecording({
    required int requestId,
    String? audioPath,
    String? videoPath,
    required String duration,
  });
  Future<AlarmRecording> updateRecording(AlarmRecording recording);
  Future<void> deleteRecording(int id);
  Future<String> downloadRecording(AlarmRecording recording,
      {Function(double)? onProgress});
}
