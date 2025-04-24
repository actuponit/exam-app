import 'package:dio/dio.dart';
import 'package:exam_app/features/payment/presentation/bloc/subscription_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exam_app/core/network/network_info.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/payment/data/datasources/subscription_data_source.dart';
import 'package:exam_app/features/payment/data/datasources/subscription_local_data_source.dart';
import 'package:exam_app/features/payment/data/repositories/subscription_repository_impl.dart';
import 'package:exam_app/features/payment/domain/repositories/subscription_repository.dart';

@module
abstract class PaymentModule {
  @lazySingleton
  InternetConnectionChecker internetConnectionChecker() =>
      InternetConnectionChecker.createInstance();

  @lazySingleton
  NetworkInfo networkInfo(InternetConnectionChecker connectionChecker) =>
      NetworkInfoImpl(connectionChecker);

  @lazySingleton
  SubscriptionDataSource subscriptionDataSource(Dio dio) =>
      SubscriptionDataSourceImpl(dio: dio);

  @lazySingleton
  SubscriptionLocalDataSource subscriptionLocalDataSource(
          SharedPreferences sharedPreferences) =>
      SubscriptionLocalDataSourceImpl(sharedPreferences: sharedPreferences);

  @lazySingleton
  SubscriptionRepository subscriptionRepository(
    SubscriptionDataSource remoteDataSource,
    SubscriptionLocalDataSource localDataSource,
    LocalAuthDataSource localAuthDataSource,
    NetworkInfo networkInfo,
  ) =>
      SubscriptionRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        localAuthDataSource: localAuthDataSource,
        networkInfo: networkInfo,
      );

  @factoryMethod
  SubscriptionBloc subscriptionBloc(SubscriptionRepository repository) {
    return SubscriptionBloc(repository: repository);
  }
}
