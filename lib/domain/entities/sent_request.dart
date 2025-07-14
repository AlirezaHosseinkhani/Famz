import 'package:equatable/equatable.dart';

class SentRequest extends Equatable {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? toUsername;
  final String? toUserProfilePicture;

  const SentRequest({
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

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        message,
        status,
        createdAt,
        updatedAt,
        toUsername,
        toUserProfilePicture,
      ];
}
