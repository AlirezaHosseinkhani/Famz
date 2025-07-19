import 'package:equatable/equatable.dart';

import 'user.dart';

class ReceivedRequest extends Equatable {
  final int id;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User fromUser;

  const ReceivedRequest({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.fromUser,
  });

  @override
  List<Object?> get props => [
        id,
        message,
        status,
        createdAt,
        updatedAt,
        fromUser,
      ];
}
