import 'package:dartz/dartz.dart';
import 'package:exam_app/core/error/failures.dart';
import 'package:exam_app/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<Notification>>> getNotifications();
  Future<Either<Failure, Notification>> likeNotification(int id);
  Future<Either<Failure, Notification>> dislikeNotification(int id);
  Future<Either<Failure, void>> commentNotification(int id, String comment);
}
