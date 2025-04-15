import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/local_auth_data_source.dart';
import '../../features/payment/data/datasources/subscription_data_source.dart';
import '../../features/payment/data/repositories/subscription_repository_impl.dart';
import '../../features/payment/domain/repositories/subscription_repository.dart';
import '../../features/payment/domain/usecases/verify_subscription.dart';
import '../../features/payment/presentation/cubit/subscription_verification_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Payment
  // Cubits
  sl.registerFactory(() => SubscriptionVerificationCubit(
        verifySubscription: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => VerifySubscription(sl()));

  // Repositories
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      localAuthDataSource: sl(), remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SubscriptionDataSource>(
    () => SubscriptionDataSourceImpl(dio: sl()),
  );

  // Shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Local auth data source
  sl.registerLazySingleton<LocalAuthDataSource>(
    () => LocalAuthDataSourceImpl(sl()),
  );

  // External
  sl.registerLazySingleton(() {
    final dio = Dio();
    // Configure Dio with base URL and other options
    dio.options.baseUrl = 'https://api.example.com'; // Replace with actual API URL
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    return dio;
  });
} 