import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/alarm/received_request_model.dart';
import '../../models/alarm/sent_request_model.dart';

abstract class AlarmRequestRemoteDataSource {
  Future<List<SentRequestModel>> getSentRequests();

  Future<List<ReceivedRequestModel>> getReceivedRequests();

  Future<SentRequestModel> createAlarmRequest({
    required int toUserId,
    required String message,
  });

  Future<SentRequestModel> updateAlarmRequest({
    required int requestId,
    required String message,
  });

  Future<void> deleteAlarmRequest(int requestId);

  Future<void> acceptRequest(int requestId);

  Future<void> rejectRequest(int requestId);
}

class AlarmRequestRemoteDataSourceImpl implements AlarmRequestRemoteDataSource {
  final ApiClient apiClient;

  AlarmRequestRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SentRequestModel>> getSentRequests() async {
    try {
      final response = await apiClient.get(ApiConstants.sentRequestsEndpoint,
          expectList: true) as List;
      // return response.map((json) => SentRequestModel.fromJson(json)).toList();
      return (response).map((item) => SentRequestModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException('Failed to get sent requests');
    }
  }

  @override
  Future<List<ReceivedRequestModel>> getReceivedRequests() async {
    try {
      final response = await apiClient
          .get(ApiConstants.receivedRequestsEndpoint, expectList: true) as List;
      return (response)
          .map((item) => ReceivedRequestModel.fromJson(item))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get received requests');
    }
  }

  @override
  Future<SentRequestModel> createAlarmRequest({
    required int toUserId,
    required String message,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.sentRequestsEndpoint,
        body: {
          'to_user_id': toUserId,
          'message': message,
        },
      );
      return SentRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create alarm request');
    }
  }

  @override
  Future<SentRequestModel> updateAlarmRequest({
    required int requestId,
    required String message,
  }) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.sentRequestsEndpoint}$requestId/',
        body: {
          'message': message,
        },
      );
      return SentRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update alarm request');
    }
  }

  @override
  Future<void> deleteAlarmRequest(int requestId) async {
    try {
      await apiClient.delete('${ApiConstants.sentRequestsEndpoint}$requestId/');
    } catch (e) {
      throw ServerException('Failed to delete alarm request');
    }
  }

  @override
  Future<void> acceptRequest(int requestId) async {
    try {
      await apiClient
          .post('${ApiConstants.receivedRequestsEndpoint}$requestId/accept/');
    } catch (e) {
      throw ServerException('Failed to accept alarm request');
    }
  }

  @override
  Future<void> rejectRequest(int requestId) async {
    try {
      await apiClient
          .post('${ApiConstants.receivedRequestsEndpoint}/$requestId/reject/');
    } catch (e) {
      throw ServerException('Failed to reject alarm request');
    }
  }
}
