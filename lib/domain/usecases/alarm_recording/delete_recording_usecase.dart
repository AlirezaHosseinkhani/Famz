import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/alarm_recording_repository.dart';

class DeleteRecordingUseCase {
  final AlarmRecordingRepository repository;

  DeleteRecordingUseCase(this.repository);

  Future<Either<Failure, void>> call(int recordingId) async {
    return await repository.deleteRecording(recordingId);
  }
}
