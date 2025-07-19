// data/models/received_request_model.dart
import '../../../domain/entities/received_request.dart';
import '../auth/user_model.dart';

class ReceivedRequestModel {
  final int id;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel fromUser;

  ReceivedRequestModel({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.fromUser,
  });

  factory ReceivedRequestModel.fromJson(Map<String, dynamic> json) {
    return ReceivedRequestModel(
      id: json['id'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      fromUser: UserModel.fromJson(json['from_user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'from_user': fromUser.toJson(),
    };
  }

  ReceivedRequest toEntity() {
    return ReceivedRequest(
      id: id,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fromUser: fromUser.toEntity(),
    );
  }
}
