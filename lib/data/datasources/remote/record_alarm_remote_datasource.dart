import 'dart:io';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/alarm/record_alarm_request_model.dart';
import '../../models/alarm/upload_recording_request_model.dart';

abstract class RecordAlarmRemoteDataSource {
  Future<RecordAlarmRequestModel> uploadRecording(
    UploadRecordingRequestModel request,
  );
  Future<void> deleteRecording(int recordingId);
  Future<RecordAlarmRequestModel> updateRecording(
    int recordingId,
    UploadRecordingRequestModel request,
  );
}

class RecordAlarmRemoteDataSourceImpl implements RecordAlarmRemoteDataSource {
  final ApiClient apiClient;

  RecordAlarmRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<RecordAlarmRequestModel> uploadRecording(
    UploadRecordingRequestModel request,
  ) async {
    try {
      final response = await apiClient.multipartRequest(
        'POST',
        ApiConstants.alarmRecordingsEndpoint,
        fields: _convertFormDataToStringMap(request.toFormData()),
        files: _buildFileMap(request),
      );
      return RecordAlarmRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to upload recording$e');
    }
  }

  @override
  Future<void> deleteRecording(int recordingId) async {
    try {
      await apiClient
          .delete('${ApiConstants.alarmRecordingsEndpoint}$recordingId/');
    } catch (e) {
      throw ServerException('Failed to delete recording');
    }
  }

  @override
  Future<RecordAlarmRequestModel> updateRecording(
    int recordingId,
    UploadRecordingRequestModel request,
  ) async {
    try {
      final response = await apiClient.multipartRequest(
        'PUT',
        '${ApiConstants.alarmRecordingsEndpoint}$recordingId/',
        fields: _convertFormDataToStringMap(request.toFormData()),
        files: _buildFileMap(request),
      );
      return RecordAlarmRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update recording');
    }
  }

  Map<String, File> _buildFileMap(UploadRecordingRequestModel request) {
    final Map<String, File> files = {};

    if (request.audioFile != null) {
      files['audio_file'] = request.audioFile!;
    }

    if (request.videoFile != null) {
      files['video_file'] = request.videoFile!;
    }

    return files;
  }

  Map<String, String> _convertFormDataToStringMap(
      Map<String, dynamic> formData) {
    final Map<String, String> stringMap = {};

    formData.forEach((key, value) {
      if (value != null) {
        stringMap[key] = value.toString();
      }
    });

    return stringMap;
  }
}
