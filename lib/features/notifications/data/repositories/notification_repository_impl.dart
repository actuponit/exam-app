import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:exam_app/core/error/failures.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:exam_app/features/notifications/domain/entities/notification.dart';
import 'package:exam_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final LocalAuthDataSource authDataSource;

  NotificationRepositoryImpl(this.remoteDataSource, this.authDataSource);

  Future<Either<Failure, T>> _handleRequest<T>(
      Future<T> Function() request) async {
    try {
      final result = await request();
      return Right(result);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final message = e.response?.data["message"];
        return Left(ServerFailure(message ?? "An unexpected error occurred."));
      }
      if (e.message != null) {
        return Left(ServerFailure(e.message!));
      }
      return Left(ServerFailure("An unexpected server error occurred."));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred."));
    }
  }

  @override
  Future<Either<Failure, List<Notification>>> getNotifications() async {
    return _handleRequest(() => remoteDataSource.getNotifications());
  }

  @override
  Future<Either<Failure, Notification>> likeNotification(int id) async {
    final userId = await authDataSource.getUserId();
    if (userId == null) {
      return Left(ServerFailure("User is not authenticated."));
    }
    return _handleRequest(() => remoteDataSource.likeNotification(id, userId));
  }

  @override
  Future<Either<Failure, Notification>> dislikeNotification(int id) async {
    final userId = await authDataSource.getUserId();
    if (userId == null) {
      return Left(ServerFailure("User is not authenticated."));
    }
    return _handleRequest(
        () => remoteDataSource.dislikeNotification(id, userId));
  }

  @override
  Future<Either<Failure, void>> commentNotification(
      int id, String comment) async {
    final userId = await authDataSource.getUserId();
    if (userId == null) {
      return Left(ServerFailure("User is not authenticated."));
    }

    return _handleRequest(
        () => remoteDataSource.commentNotification(id, comment, userId));
  }
}
