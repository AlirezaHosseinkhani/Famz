import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/alarm_recording.dart';
import '../../../domain/usecases/alarm_recording/download_recording_usecase.dart';
import '../../../domain/usecases/alarm_recording/get_recordings_usecase.dart';
import 'alarm_recording_event.dart';
import 'alarm_recording_state.dart';

class AlarmRecordingBloc
    extends Bloc<AlarmRecordingEvent, AlarmRecordingState> {
  final GetRecordingsUseCase getRecordingsUseCase;
  final DownloadRecordingUseCase downloadRecordingUseCase;

  AlarmRecordingBloc({
    required this.getRecordingsUseCase,
    required this.downloadRecordingUseCase,
  }) : super(AlarmRecordingInitial()) {
    on<LoadRecordingsEvent>(_onLoadRecordings);
    on<DownloadRecordingEvent>(_onDownloadRecording);
    on<UpdateRecordingProgressEvent>(_onUpdateRecordingProgress);
    on<RecordingDownloadedEvent>(_onRecordingDownloaded);
  }

  Future<void> _onLoadRecordings(
    LoadRecordingsEvent event,
    Emitter<AlarmRecordingState> emit,
  ) async {
    emit(AlarmRecordingLoading());
    try {
      final recordings = await getRecordingsUseCase();
      emit(AlarmRecordingLoaded(recordings: recordings));
    } catch (e) {
      emit(AlarmRecordingError(
          message: 'Failed to load recordings: ${e.toString()}'));
    }
  }

  Future<void> _onDownloadRecording(
    DownloadRecordingEvent event,
    Emitter<AlarmRecordingState> emit,
  ) async {
    if (state is AlarmRecordingLoaded) {
      final currentState = state as AlarmRecordingLoaded;
      final recordings = List<AlarmRecording>.from(currentState.recordings);

      // Update recording to show download started
      final recordingIndex =
          recordings.indexWhere((r) => r.id == event.recording.id);
      if (recordingIndex >= 0) {
        recordings[recordingIndex] = recordings[recordingIndex].copyWith(
          downloadProgress: 0.0,
        );
        emit(AlarmRecordingLoaded(recordings: recordings));
      }

      try {
        final localPath = await downloadRecordingUseCase(
          event.recording,
          onProgress: (progress) {
            add(UpdateRecordingProgressEvent(
              recordingId: event.recording.id,
              progress: progress,
            ));
          },
        );

        add(RecordingDownloadedEvent(
          recordingId: event.recording.id,
          localPath: localPath,
        ));
      } catch (e) {
        emit(AlarmRecordingError(
            message: 'Failed to download recording: ${e.toString()}'));
      }
    }
  }

  void _onUpdateRecordingProgress(
    UpdateRecordingProgressEvent event,
    Emitter<AlarmRecordingState> emit,
  ) {
    if (state is AlarmRecordingLoaded) {
      final currentState = state as AlarmRecordingLoaded;
      final recordings = List<AlarmRecording>.from(currentState.recordings);

      final recordingIndex =
          recordings.indexWhere((r) => r.id == event.recordingId);
      if (recordingIndex >= 0) {
        recordings[recordingIndex] = recordings[recordingIndex].copyWith(
          downloadProgress: event.progress,
        );
        emit(AlarmRecordingLoaded(recordings: recordings));
      }
    }
  }

  void _onRecordingDownloaded(
    RecordingDownloadedEvent event,
    Emitter<AlarmRecordingState> emit,
  ) {
    if (state is AlarmRecordingLoaded) {
      final currentState = state as AlarmRecordingLoaded;
      final recordings = List<AlarmRecording>.from(currentState.recordings);

      final recordingIndex =
          recordings.indexWhere((r) => r.id == event.recordingId);
      if (recordingIndex >= 0) {
        recordings[recordingIndex] = recordings[recordingIndex].copyWith(
          localPath: event.localPath,
          isDownloaded: true,
          downloadProgress: 1.0,
        );
        emit(AlarmRecordingLoaded(recordings: recordings));
      }
    }
  }
}
