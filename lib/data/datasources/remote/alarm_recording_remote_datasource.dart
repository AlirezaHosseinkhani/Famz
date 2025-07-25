import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/alarm/alarm_recording_model.dart';

abstract class AlarmRecordingRemoteDataSource {
  Future<List<AlarmRecordingModel>> getRecordings();
  Future<AlarmRecordingModel> uploadRecording({
    required int requestId,
    String? audioPath,
    String? videoPath,
    required String duration,
  });
  Future<AlarmRecordingModel> updateRecording(AlarmRecordingModel recording);
  Future<void> deleteRecording(int id);
  Future<String> downloadFile(String url, String fileName,
      {Function(double)? onProgress});
}

class AlarmRecordingRemoteDataSourceImpl
    implements AlarmRecordingRemoteDataSource {
  final ApiClient apiClient;

  AlarmRecordingRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<List<AlarmRecordingModel>> getRecordings() async {
    try {
      final response = await apiClient.get(
        ApiConstants.alarmRecordingsEndpoint,
        expectList: true,
      );

      return (response as List<dynamic>)
          .map((item) => AlarmRecordingModel.fromJson(item))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AlarmRecordingModel> uploadRecording({
    required int requestId,
    String? audioPath,
    String? videoPath,
    required String duration,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.alarmRecordingsEndpoint),
      );

      // Add form fields
      request.fields['request'] = requestId.toString();
      request.fields['duration'] = duration;

      // Add audio file if provided
      if (audioPath != null) {
        final audioFile = await http.MultipartFile.fromPath(
          'audio_file',
          audioPath,
        );
        request.files.add(audioFile);
      }

      // Add video file if provided
      if (videoPath != null) {
        final videoFile = await http.MultipartFile.fromPath(
          'video_file',
          videoPath,
        );
        request.files.add(videoFile);
      }

      // Add headers if your ApiClient has authentication
      // You might need to get headers from your ApiClient
      // request.headers.addAll(await apiClient.getHeaders());

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        return AlarmRecordingModel.fromJson(jsonData);
      } else {
        throw ServerException('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AlarmRecordingModel> updateRecording(
      AlarmRecordingModel recording) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.alarmRecordingsEndpoint}${recording.id}/',
        body: recording.toJson(),
      );

      return AlarmRecordingModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteRecording(int id) async {
    try {
      await apiClient.delete('${ApiConstants.alarmRecordingsEndpoint}$id/');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> downloadFile(String url, String fileName,
      {Function(double)? onProgress}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/alarm_recordings/$fileName';

      // Create directory if it doesn't exist
      final file = File(filePath);
      await file.parent.create(recursive: true);

      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw ServerException(
            'Failed to download file: ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? -1;
      int downloadedBytes = 0;
      final List<int> bytes = [];

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        downloadedBytes += chunk.length;

        if (contentLength != -1 && onProgress != null) {
          final progress = downloadedBytes / contentLength;
          onProgress(progress);
        }
      }

      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
