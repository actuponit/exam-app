part of 'subscription_bloc.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

// Status States
class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionStatusLoaded extends SubscriptionState {
  final Subscription subscription;
  final SubscriptionStatus status;

  const SubscriptionStatusLoaded({
    required this.subscription,
    required this.status,
  });

  @override
  List<Object?> get props => [subscription, status];
}

class VerificationSuccess extends SubscriptionState {
  final Subscription subscription;

  const VerificationSuccess(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

// Error State
class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Enum for subscription status
enum SubscriptionStatus { initial, pending, approved, denied }
