import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';

part 'subscription_status_state.dart';

class SubscriptionStatusCubit extends Cubit<SubscriptionStatusState> {
  final SubscriptionRepository repository;
  
  SubscriptionStatusCubit({
    required this.repository,
  }) : super(const SubscriptionStatusInitial());
  
  Future<void> checkStatus() async {
    emit(const SubscriptionStatusLoading());
    
    final result = await repository.checkSubscriptionStatus();
    
    result.fold(
      (failure) => emit(SubscriptionStatusError(failure.message)),
      (subscription) {
        if (subscription.isInitial) {
          emit(const SubscriptionStatusInitial());
        } else if (subscription.isPending) {
          emit(SubscriptionStatusPending(subscription));
        } else if (subscription.isApproved) {
          emit(SubscriptionStatusApproved(subscription));
        } else if (subscription.isDenied) {
          emit(SubscriptionStatusDenied(subscription));
        } else {
          emit(const SubscriptionStatusInitial());
        }
      },
    );
  }
} 