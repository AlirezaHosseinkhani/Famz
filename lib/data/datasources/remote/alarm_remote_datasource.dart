import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/alarm/alarm_model.dart';

abstract class AlarmRemoteDataSource {
  Future<AlarmModel> createAlarm({
    required DateTime time,
    required bool isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  });

  Future<bool> deleteAlarm(int alarmId);

  Future<List<AlarmModel>> getAlarms();

  Future<AlarmModel> toggleAlarm(int id, bool isActive);

  Future<AlarmModel> updateAlarm({
    required int id,
    DateTime? time,
    bool? isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  });
}

class AlarmRemoteDataSourceImpl implements AlarmRemoteDataSource {
  final ApiClient apiClient;

  AlarmRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AlarmModel> createAlarm({
    required DateTime time,
    required bool isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.alarmsEndpoint,
        body: {
          'time': time.toIso8601String(),
          'is_active': isActive,
          'recording_id': recordingId,
          'repeat_days': repeatDays,
          'label': label,
        },
      );

      return AlarmModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteAlarm(int alarmId) async {
    try {
      await apiClient.delete('${ApiConstants.alarmsEndpoint}$alarmId/');
      return true;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  // Future<List<AlarmModel>> getAlarms() async {
  //   try {
  //     final response = await apiClient.get(ApiConstants.alarmsEndpoint);
  //     final List<dynamic> alarmsJson = response['results'] ?? response;
  //
  //     return alarmsJson
  //         .map((alarmJson) => AlarmModel.fromJson(alarmJson))
  //         .toList();
  //   } catch (e) {
  //     throw ServerException(e.toString());
  //   }
  // }

  Future<List<AlarmModel>> getAlarms() async {
    final response = await apiClient.get(ApiConstants.alarmsEndpoint,
        expectList: true); // <-- we'll add expectList
    return (response as List<dynamic>)
        .map((item) => AlarmModel.fromJson(item))
        .toList();
  }

  @override
  Future<AlarmModel> toggleAlarm(int id, bool isActive) async {
    try {
      final response = await apiClient.patch(
        '${ApiConstants.alarmsEndpoint}$id/',
        body: {'is_active': isActive},
      );

      return AlarmModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AlarmModel> updateAlarm({
    required int id,
    DateTime? time,
    bool? isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (time != null) data['time'] = time.toIso8601String();
      if (isActive != null) data['is_active'] = isActive;
      if (recordingId != null) data['recording_id'] = recordingId;
      if (repeatDays != null) data['repeat_days'] = repeatDays;
      if (label != null) data['label'] = label;

      final response = await apiClient.patch(
        '${ApiConstants.alarmsEndpoint}$id/',
        body: data,
      );

      return AlarmModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
