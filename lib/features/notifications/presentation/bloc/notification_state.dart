part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}

class NotificationsRead extends NotificationState {
  const NotificationsRead();

  @override
  List<Object> get props => [];
}
