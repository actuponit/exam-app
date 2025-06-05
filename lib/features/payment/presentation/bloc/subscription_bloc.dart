import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:exam_app/core/error/failures.dart';
import 'package:exam_app/features/payment/domain/entities/subscription.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/repositories/subscription_repository.dart';
part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;

  SubscriptionBloc({
    required this.repository,
  }) : super(const SubscriptionInitial()) {
    on<CheckSubscriptionStatus>(_onCheckSubscriptionStatus);
    on<SubmitVerification>(_onSubmitVerification);
    on<StartPeriodicStatusCheck>(_onStartPeriodicStatusCheck);
    on<StopPeriodicStatusCheck>(_onStopPeriodicStatusCheck);
  }

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());

    final result = await repository.checkSubscriptionStatus();

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) {
        if (subscription.isInitial) {
          emit(SubscriptionStatusLoaded(
            subscription: subscription,
            status: SubscriptionStatus.initial,
          ));
        } else if (subscription.isPending) {
          emit(SubscriptionStatusLoaded(
            subscription: subscription,
            status: SubscriptionStatus.pending,
          ));
        } else if (subscription.isApproved) {
          emit(SubscriptionStatusLoaded(
            subscription: subscription,
            status: SubscriptionStatus.approved,
          ));
        } else if (subscription.isDenied) {
          emit(SubscriptionStatusLoaded(
            subscription: subscription,
            status: SubscriptionStatus.denied,
          ));
        } else {
          emit(SubscriptionStatusLoaded(
            subscription: subscription,
            status: SubscriptionStatus.initial,
          ));
        }
      },
    );
  }

  Future<void> _onSubmitVerification(
    SubmitVerification event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());

    final result = await repository.verifySubscription(
      receiptImage: event.receiptImage,
      transactionNumber: event.transactionNumber,
    );

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) {
        emit(SubscriptionStatusLoaded(
          subscription: subscription,
          status: SubscriptionStatus.pending,
        ));
      },
    );
  }

  void _onStartPeriodicStatusCheck(
    StartPeriodicStatusCheck event,
    Emitter<SubscriptionState> emit,
  ) async {
    // Start watching for status updates with the repository stream
    final statusStream = repository.watchSubscriptionStatus(
      interval: event.interval ?? const Duration(minutes: 2),
      stopWhenApproved: true,
    );

    // Use emitForEach to handle the stream
    await emit.forEach<Either<Failure, Subscription>>(
      statusStream,
      onData: (result) {
        return result.fold(
          (failure) => SubscriptionError(failure.message),
          (subscription) {
            if (subscription.isPending) {
              return SubscriptionStatusLoaded(
                subscription: subscription,
                status: SubscriptionStatus.pending,
              );
            } else if (subscription.isApproved) {
              return SubscriptionStatusLoaded(
                subscription: subscription,
                status: SubscriptionStatus.approved,
              );
            } else if (subscription.isDenied) {
              return SubscriptionStatusLoaded(
                subscription: subscription,
                status: SubscriptionStatus.denied,
              );
            } else {
              return SubscriptionStatusLoaded(
                subscription: subscription,
                status: SubscriptionStatus.initial,
              );
            }
          },
        );
      },
      onError: (error, stackTrace) => SubscriptionError(error.toString()),
    );
  }

  void _onStopPeriodicStatusCheck(
    StopPeriodicStatusCheck event,
    Emitter<SubscriptionState> emit,
  ) {
    repository.stopWatchingSubscriptionStatus();
  }

  @override
  Future<void> close() {
    // Clean up any resources
    repository.stopWatchingSubscriptionStatus();
    return super.close();
  }
}
