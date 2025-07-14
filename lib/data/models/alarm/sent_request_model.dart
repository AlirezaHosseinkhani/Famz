import '../../../domain/entities/sent_request.dart';

class SentRequestModel {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? toUsername;
  final String? toUserProfilePicture;

  SentRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.toUsername,
    this.toUserProfilePicture,
  });

  factory SentRequestModel.fromJson(Map<String, dynamic> json) {
    return SentRequestModel(
      id: json['id'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      toUsername: json['to_username'],
      toUserProfilePicture: json['to_user_profile_picture'],
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
      'to_username': toUsername,
      'to_user_profile_picture': toUserProfilePicture,
    };
  }

  SentRequest toEntity() {
    return SentRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      toUsername: toUsername,
      toUserProfilePicture: toUserProfilePicture,
    );
  }
}
