import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/record_alarm_repository.dart';

class DeleteAlarmRecordingUseCase {
  final RecordAlarmRepository repository;

  DeleteAlarmRecordingUseCase(this.repository);

  Future<Either<Failure, void>> call(int recordingId) async {
    return await repository.deleteRecording(recordingId);
  }
}
