import 'package:dio/dio.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:injectable/injectable.dart';

import '../../../features/videos/data/datasources/videos_remote_datasource.dart';
import '../../../features/videos/data/repositories/videos_repository_impl.dart';
import '../../../features/videos/domain/repositories/videos_repository.dart';
import '../../../features/videos/presentation/cubit/videos_cubit.dart';

@module
abstract class VideosModule {
  @singleton
  VideosRemoteDataSource videosRemoteDatasource(Dio dio) =>
      VideosRemoteDataSourceImpl(dio: dio);

  @lazySingleton
  VideosRepository videosRepository(
    VideosRemoteDataSource remoteDataSource,
    LocalAuthDataSource localAuthDataSource,
  ) =>
      VideosRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localAuthDataSource: localAuthDataSource,
      );

  @factoryMethod
  VideosCubit videosCubit(VideosRepository repository) =>
      VideosCubit(repository: repository);
}
