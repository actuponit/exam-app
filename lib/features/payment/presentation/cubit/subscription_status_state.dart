part of 'subscription_status_cubit.dart';

abstract class SubscriptionStatusState extends Equatable {
  const SubscriptionStatusState();
  
  @override
  List<Object?> get props => [];
}

class SubscriptionStatusInitial extends SubscriptionStatusState {
  const SubscriptionStatusInitial();
}

class SubscriptionStatusLoading extends SubscriptionStatusState {
  const SubscriptionStatusLoading();
}

class SubscriptionStatusPending extends SubscriptionStatusState {
  final Subscription subscription;
  
  const SubscriptionStatusPending(this.subscription);
  
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionStatusApproved extends SubscriptionStatusState {
  final Subscription subscription;
  
  const SubscriptionStatusApproved(this.subscription);
  
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionStatusDenied extends SubscriptionStatusState {
  final Subscription subscription;
  
  const SubscriptionStatusDenied(this.subscription);
  
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionStatusError extends SubscriptionStatusState {
  final String message;
  
  const SubscriptionStatusError(this.message);
  
  @override
  List<Object?> get props => [message];
} 