import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  Future<Either<Failure, String>> markAllAsRead();

  Future<Either<Failure, NotificationEntity>> markAsRead(int requestId);
}
