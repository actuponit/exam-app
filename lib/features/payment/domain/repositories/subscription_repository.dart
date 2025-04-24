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

  /// Creates a Stream that periodically checks the subscription status
  ///
  /// Parameters:
  ///   - interval: Duration between checks (defaults to 5 minutes)
  ///   - stopWhenApproved: If true, the stream will complete when subscription is approved
  ///
  /// Returns a Stream of Either<Failure, Subscription> that emits the subscription status periodically
  Stream<Either<Failure, Subscription>> watchSubscriptionStatus({
    Duration interval = const Duration(minutes: 5),
    bool stopWhenApproved = true,
  });

  /// Stops any ongoing periodic subscription status checks
  void stopWatchingSubscriptionStatus();
}
