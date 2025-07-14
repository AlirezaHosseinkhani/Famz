import '../../../domain/entities/received_request.dart';

class ReceivedRequestModel {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fromUsername;
  final String? fromUserProfilePicture;

  ReceivedRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fromUsername,
    this.fromUserProfilePicture,
  });

  factory ReceivedRequestModel.fromJson(Map<String, dynamic> json) {
    return ReceivedRequestModel(
      id: json['id'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      fromUsername: json['from_username'],
      fromUserProfilePicture: json['from_user_profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'from_username': fromUsername,
      'from_user_profile_picture': fromUserProfilePicture,
    };
  }

  ReceivedRequest toEntity() {
    return ReceivedRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fromUsername: fromUsername,
      fromUserProfilePicture: fromUserProfilePicture,
    );
  }
}
