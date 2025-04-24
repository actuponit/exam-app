import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;
  StreamSubscription<dynamic>? _statusSubscription;

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
        emit(VerificationSuccess(subscription));
        // After successful verification, start periodic checking
        add(const StartPeriodicStatusCheck());
      },
    );
  }

  void _onStartPeriodicStatusCheck(
    StartPeriodicStatusCheck event,
    Emitter<SubscriptionState> emit,
  ) {
    // Cancel any existing subscription
    _statusSubscription?.cancel();

    // Start watching for status updates with the repository stream
    final statusStream = repository.watchSubscriptionStatus(
      interval: event.interval ?? const Duration(minutes: 5),
      stopWhenApproved: true,
    );

    _statusSubscription = statusStream.listen((result) {
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
            // Status is approved, so we can stop the periodic checks
            add(const StopPeriodicStatusCheck());
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
    });
  }

  void _onStopPeriodicStatusCheck(
    StopPeriodicStatusCheck event,
    Emitter<SubscriptionState> emit,
  ) {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    repository.stopWatchingSubscriptionStatus();
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    repository.stopWatchingSubscriptionStatus();
    return super.close();
  }
}
