import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/subscription.dart';

abstract class SubscriptionVerificationState extends Equatable {
  const SubscriptionVerificationState();
  
  @override
  List<Object?> get props => [];
}

class SubscriptionVerificationInitial extends SubscriptionVerificationState {
  const SubscriptionVerificationInitial();
}

class SubscriptionVerificationLoading extends SubscriptionVerificationState {
  const SubscriptionVerificationLoading();
}

class SubscriptionVerificationSuccess extends SubscriptionVerificationState {
  final Subscription subscription;
  
  const SubscriptionVerificationSuccess(this.subscription);
  
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionVerificationError extends SubscriptionVerificationState {
  final String message;
  
  const SubscriptionVerificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ReceiptSelected extends SubscriptionVerificationState {
  final XFile receipt;
  
  const ReceiptSelected(this.receipt);
  
  @override
  List<Object?> get props => [receipt];
} 