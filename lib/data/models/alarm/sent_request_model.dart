import '../../../domain/entities/sent_request.dart';
import '../request/to_user_model.dart';

class SentRequestModel {
  final int id;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ToUserModel toUser;

  SentRequestModel({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.toUser,
  });

  factory SentRequestModel.fromJson(Map<String, dynamic> json) {
    return SentRequestModel(
      id: json['id'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      toUser: ToUserModel.fromJson(json['recipient_data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'to_user': toUser.toJson(),
    };
  }

  SentRequest toEntity() {
    return SentRequest(
      id: id,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      toUser: toUser.toEntity(),
    );
  }
}
