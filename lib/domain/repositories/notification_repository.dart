import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, NotificationEntity>> markAsRead(int notificationId);
}
