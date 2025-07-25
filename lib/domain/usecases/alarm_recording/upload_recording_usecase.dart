// import 'package:dartz/dartz.dart';
//
// import '../../../core/errors/failures.dart';
// // import '../../entities/alarm_recording.dart';
// import '../../repositories/alarm_recording_repository.dart';
//
// class UploadRecordingUseCase {
//   final AlarmRecordingRepository repository;
//
//   UploadRecordingUseCase(this.repository);
//
//   Future<Either<Failure, String>> call(UploadRecordingParams params) async {
//     return await repository.uploadRecording(
//         // requestId: params.requestId,
//         // audioFile: params.audioFile,
//         // videoFile: params.videoFile,
//         // duration: params.duration,
//         );
//   }
// }
//
// class UploadRecordingParams {
//   final int requestId;
//   final String? audioFile;
//   final String? videoFile;
//   final String duration;
//
//   UploadRecordingParams({
//     required this.requestId,
//     this.audioFile,
//     this.videoFile,
//     required this.duration,
//   });
// }
