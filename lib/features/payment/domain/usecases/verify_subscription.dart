import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class VerifySubscription implements UseCase<Subscription, VerifySubscriptionParams> {
  final SubscriptionRepository repository;

  VerifySubscription(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(VerifySubscriptionParams params) {
    return repository.verifySubscription(
      receiptImage: params.receiptImage,
      transactionNumber: params.transactionNumber,
    );
  }
}

class VerifySubscriptionParams extends Equatable {
  final XFile receiptImage;
  final String? transactionNumber;

  const VerifySubscriptionParams({
    required this.receiptImage,
    this.transactionNumber,
  });

  @override
  List<Object?> get props => [receiptImage, transactionNumber];
} 