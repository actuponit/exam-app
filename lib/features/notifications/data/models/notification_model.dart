import 'package:exam_app/features/notifications/domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.imageUrl,
    required super.likeCount,
    required super.dislikeCount,
    required super.commentCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      likeCount: json['like_count'] as int,
      dislikeCount: json['dislike_count'] as int,
      commentCount: json['comment_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'like_count': likeCount,
      'dislike_count': dislikeCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
