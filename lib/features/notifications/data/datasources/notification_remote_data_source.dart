import 'package:dio/dio.dart';
import 'package:exam_app/features/notifications/data/models/notification_model.dart';
import 'package:injectable/injectable.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> likeNotification(int id, int userId);
  Future<NotificationModel> dislikeNotification(int id, int userId);
  Future<void> commentNotification(int id, String comment, int userId);
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get(
      'notifications',
      options: Options(
        extra: {'cacheResponse': true, 'fallbackToCache': true},
      ),
    );

    final List<dynamic> data = response.data['data'];
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<NotificationModel> likeNotification(int id, int userId) async {
    final response = await dio.post('notifications/$id/like', data: {
      'user_id': userId,
    });
    return NotificationModel.fromJson(response.data['data']);
  }

  @override
  Future<NotificationModel> dislikeNotification(int id, int userId) async {
    final response = await dio.post('notifications/$id/dislike', data: {
      'user_id': userId,
    });
    return NotificationModel.fromJson(response.data['data']);
  }

  @override
  Future<void> commentNotification(
    int id,
    String comment,
    int userId,
  ) async {
    await dio.post(
      'notifications/$id/comment',
      data: {
        'user_id': userId,
        'comment': comment,
      },
    );
  }
}
