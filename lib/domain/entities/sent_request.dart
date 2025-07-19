import 'package:equatable/equatable.dart';
import 'package:famz/domain/entities/to_user.dart';

class SentRequest extends Equatable {
  final int id;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ToUser toUser;

  const SentRequest({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.toUser,
  });

  @override
  List<Object?> get props => [
        id,
        message,
        status,
        createdAt,
        updatedAt,
        toUser,
      ];
}
