import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/notification.dart';
import '../../repositories/notification_repository.dart';

class MarkAsReadUseCase {
  final NotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<Either<Failure, NotificationEntity>> call(int notificationId) async {
    // Future<Either<Failure, Notification>> call(int notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
