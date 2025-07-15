import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/referral/data/datasources/referral_remote_data_source.dart';
import 'package:exam_app/features/referral/data/repositories/referral_repository_impl.dart';
import 'package:exam_app/features/referral/domain/repositories/referral_repository.dart';
import 'package:exam_app/features/referral/presentation/bloc/referral_bloc.dart';

@module
abstract class ReferralModule {
  @lazySingleton
  ReferralRemoteDataSource referralRemoteDataSource(Dio dio) =>
      ReferralRemoteDataSourceImpl(dio);

  @lazySingleton
  ReferralRepository referralRepository(
    ReferralRemoteDataSource remoteDataSource,
    LocalAuthDataSource localAuthDataSource,
  ) =>
      ReferralRepositoryImpl(
        remoteDataSource,
        localAuthDataSource,
      );

  @factoryMethod
  ReferralBloc referralBloc(ReferralRepository referralRepository) =>
      ReferralBloc(referralRepository);
}
