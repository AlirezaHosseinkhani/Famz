import 'package:equatable/equatable.dart';

class ReceivedRequest extends Equatable {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fromUsername;
  final String? fromUserProfilePicture;

  const ReceivedRequest({
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

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        message,
        status,
        createdAt,
        updatedAt,
        fromUsername,
        fromUserProfilePicture,
      ];
}
