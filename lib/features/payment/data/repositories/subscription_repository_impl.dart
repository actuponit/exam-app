import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/payment/domain/entities/subscription.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_data_source.dart';
import '../datasources/subscription_local_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDataSource remoteDataSource;
  final SubscriptionLocalDataSource localDataSource;
  final LocalAuthDataSource localAuthDataSource;
  final NetworkInfo networkInfo;
  StreamController<Either<Failure, Subscription>>? _statusStreamController;
  Timer? _statusCheckTimer;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.localAuthDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Subscription>> verifySubscription({
    required XFile receiptImage,
    String? transactionNumber,
  }) async {
    try {
      // Get user ID from local storage
      final userId = await localAuthDataSource.getUserId();
      
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }
      
      final subscription = await remoteDataSource.verifySubscription(
        userId: userId,
        receiptImage: receiptImage,
        transactionNumber: transactionNumber,
      );
      
      // Cache the subscription status locally
      await localDataSource.cacheSubscriptionStatus(subscription);
      
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Subscription>> checkSubscriptionStatus() async {
    try {
      // First check if we have an approved subscription in local storage
      final cachedStatus = await localDataSource.getSubscriptionStatus();
      
      // If subscription is approved, only use local storage as per requirements
      if (cachedStatus?.isApproved ?? false) {
        return Right(cachedStatus!);
      }
      
      // If we're offline, return cached data (even if not approved)
      if (!await networkInfo.isConnected) {
        if (cachedStatus != null) {
          return Right(cachedStatus);
        }
        return const Left(CacheFailure('No cached subscription data available'));
      }
      
      // If we're online and not approved, check with server
      final userId = await localAuthDataSource.getUserId();
      
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }
      
      final remoteStatus = await remoteDataSource.checkSubscriptionStatus(userId);
      
      // Cache the updated status
      await localDataSource.cacheSubscriptionStatus(remoteStatus);
      
      return Right(remoteStatus);
    } on ServerException catch (e) {
      // If server fails but we have cached data, return it
      final cachedStatus = await localDataSource.getSubscriptionStatus();
      if (cachedStatus != null) {
        return Right(cachedStatus);
      }
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Subscription>> watchSubscriptionStatus({
    Duration interval = const Duration(minutes: 5),
    bool stopWhenApproved = true,
  }) {
    // Cancel any existing stream
    stopWatchingSubscriptionStatus();

    // Create a new stream controller
    _statusStreamController =
        StreamController<Either<Failure, Subscription>>.broadcast();

    // Immediately check status and add to stream
    // checkSubscriptionStatus().then((status) {
    //   if (!(_statusStreamController?.isClosed ?? true)) {
    //     _statusStreamController?.add(status);

    //     // If status is approved and stopWhenApproved is true, close the stream
    //     if (stopWhenApproved && status.isRight()) {
    //       final subscription = status.getOrElse(() => Subscription(status: ''));
    //       if (subscription.isApproved) {
    //         stopWatchingSubscriptionStatus();
    //         return;
    //       }
    //     }
    //   }
    // });

    // Set up periodic checks
    _statusCheckTimer = Timer.periodic(interval, (_) async {
      if (_statusStreamController?.isClosed ?? true) {
        _statusCheckTimer?.cancel();
        return;
      }

      final status = await checkSubscriptionStatus();
      if (!(_statusStreamController?.isClosed ?? true)) {
        _statusStreamController?.add(status);

        // If status is approved and stopWhenApproved is true, close the stream
        if (stopWhenApproved && status.isRight()) {
          final subscription =
              status.getOrElse(() => const Subscription(status: ''));
          if (!subscription.isPending) {
            stopWatchingSubscriptionStatus();
          }
        }
      }
    });

    return _statusStreamController!.stream;
  }

  @override
  void stopWatchingSubscriptionStatus() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    _statusStreamController?.close();
    _statusStreamController = null;
  }
}
