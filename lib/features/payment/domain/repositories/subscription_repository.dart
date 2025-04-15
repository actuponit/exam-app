import 'package:dartz/dartz.dart';
import 'package:exam_app/core/error/failures.dart';
import 'package:exam_app/features/payment/domain/entities/subscription.dart';
import 'package:image_picker/image_picker.dart';

abstract class SubscriptionRepository {
  /// Verifies a subscription payment by sending receipt image and optional transaction number
  Future<Either<Failure, Subscription>> verifySubscription({
    required XFile receiptImage,
    String? transactionNumber,
  });
  
  /// Checks the current subscription status
  /// Returns cached data if subscription is approved or if offline
  /// Otherwise fetches latest status from server
  Future<Either<Failure, Subscription>> checkSubscriptionStatus();
} 