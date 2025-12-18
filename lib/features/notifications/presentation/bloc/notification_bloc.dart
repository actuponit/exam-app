import 'package:equatable/equatable.dart';
import 'package:exam_app/features/notifications/domain/entities/notification.dart';
import 'package:exam_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'notification_event.dart';
part 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<LikeNotificationEvent>(_onLikeNotification);
    on<DislikeNotificationEvent>(_onDislikeNotification);
    on<CommentNotificationEvent>(_onCommentNotification);
  }

  Future<void> _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await _repository.getNotifications();
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onLikeNotification(
    LikeNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistic update or just refresh list?
    // For now, let's refresh the list after action or handle state update locally if needed.
    // Given the requirement "give me a nice ui", handling state updates smoothly is better.
    // However, the API returns the updated notification.
    // We can update the list in the state.

    if (state is NotificationLoaded) {
      final currentNotifications = (state as NotificationLoaded).notifications;
      final result = await _repository.likeNotification(event.id);

      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (updatedNotification) {
          final updatedList = currentNotifications.map((n) {
            return n.id == updatedNotification.id ? updatedNotification : n;
          }).toList();
          emit(NotificationLoaded(updatedList));
        },
      );
    }
  }

  Future<void> _onDislikeNotification(
    DislikeNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentNotifications = (state as NotificationLoaded).notifications;
      final result = await _repository.dislikeNotification(event.id);

      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (updatedNotification) {
          final updatedList = currentNotifications.map((n) {
            return n.id == updatedNotification.id ? updatedNotification : n;
          }).toList();
          emit(NotificationLoaded(updatedList));
        },
      );
    }
  }

  Future<void> _onCommentNotification(
    CommentNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // Commenting doesn't return the updated notification in the example,
    // but usually we'd want to refresh or increment comment count locally.
    // The example: POST /notifications/{id}/comment -> success
    // Let's assume we just refresh the list or show success message.
    // But to keep it simple and consistent, let's re-fetch or just ignore if API doesn't return updated data.
    // Wait, the user request says:
    // POST /notifications/{id}/comment
    // { "user_id": 123, "comment": "..." }
    // It doesn't show the response structure for comment, but implies success.
    // Let's just call the API. If we want to update UI, we might need to re-fetch.
    // For now, let's just call it.

    final result =
        await _repository.commentNotification(event.id, event.comment);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) {
        // Success. Ideally we should re-fetch to get updated comment count if the server updates it.
        add(GetNotificationsEvent());
      },
    );
  }
}
