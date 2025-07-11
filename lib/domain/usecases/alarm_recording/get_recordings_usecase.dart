import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
// import '../../entities/alarm_recording.dart';
import '../../repositories/alarm_recording_repository.dart';

class GetRecordingsUseCase {
  final AlarmRecordingRepository repository;

  GetRecordingsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    // Future<Either<Failure, List<AlarmRecording>>> call() async {
    return await repository.getRecordings();
  }
}
