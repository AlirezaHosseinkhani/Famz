import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/profile/profile_model.dart';
import '../../models/profile/update_profile_request_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile(UpdateProfileRequestModel request);

  Future<ProfileModel> patchProfile(UpdateProfileRequestModel request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await apiClient.get(ApiConstants.profileEndpoint);
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequestModel request) async {
    try {
      final response = await apiClient.put(
        ApiConstants.profileEndpoint,
        body: request.toJson(),
      );
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProfileModel> patchProfile(UpdateProfileRequestModel request) async {
    try {
      final response = await apiClient.patch(
        ApiConstants.profileEndpoint,
        body: request.toJson(),
      );
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
