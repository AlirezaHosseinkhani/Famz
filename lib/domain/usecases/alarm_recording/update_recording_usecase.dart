import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
// import '../../entities/alarm_recording.dart';
import '../../repositories/alarm_recording_repository.dart';

class UpdateRecordingUseCase {
  final AlarmRecordingRepository repository;

  UpdateRecordingUseCase(this.repository);

  // Future<Either<Failure, AlarmRecording>> call(
  Future<Either<Failure, String>> call(UpdateRecordingParams params) async {
    return await repository.updateRecording(
        // id: params.id,
        // audioFile: params.audioFile,
        // videoFile: params.videoFile,
        // duration: params.duration,
        );
  }
}

class UpdateRecordingParams {
  final int id;
  final String? audioFile;
  final String? videoFile;
  final String? duration;

  UpdateRecordingParams({
    required this.id,
    this.audioFile,
    this.videoFile,
    this.duration,
  });
}
