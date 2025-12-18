part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class GetNotificationsEvent extends NotificationEvent {}

class LikeNotificationEvent extends NotificationEvent {
  final int id;

  const LikeNotificationEvent(this.id);

  @override
  List<Object> get props => [id];
}

class DislikeNotificationEvent extends NotificationEvent {
  final int id;

  const DislikeNotificationEvent(this.id);

  @override
  List<Object> get props => [id];
}

class CommentNotificationEvent extends NotificationEvent {
  final int id;
  final String comment;

  const CommentNotificationEvent(this.id, this.comment);

  @override
  List<Object> get props => [id, comment];
}
