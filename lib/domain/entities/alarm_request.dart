import 'package:equatable/equatable.dart';

class AlarmRequest extends Equatable {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String message;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fromUserName;
  final String? toUserName;

  const AlarmRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fromUserName,
    this.toUserName,
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
        fromUserName,
        toUserName,
      ];
}
