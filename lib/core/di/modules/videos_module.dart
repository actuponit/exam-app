import 'package:dio/dio.dart';
import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:exam_app/core/services/hive_service.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../features/videos/data/datasources/videos_local_datasource.dart';
import '../../../features/videos/data/datasources/videos_remote_datasource.dart';
import '../../../features/videos/data/repositories/videos_repository_impl.dart';
import '../../../features/videos/domain/repositories/videos_repository.dart';
import '../../../features/videos/presentation/cubit/videos_cubit.dart';

@module
abstract class VideosModule {
  // Named because the box is untyped (Box<dynamic>) and must not be confused
  // with any other untyped box registered later.
  @Named(HiveBoxNames.videos)
  @singleton
  Box<dynamic> videosBox(HiveService hiveService) => hiveService.videosBox;

  @singleton
  VideosLocalDataSource videosLocalDatasource(
    @Named(HiveBoxNames.videos) Box<dynamic> videosBox,
  ) =>
      VideosLocalDataSourceImpl(videosBox);

  @singleton
  VideosRemoteDataSource videosRemoteDatasource(Dio dio) =>
      VideosRemoteDataSourceImpl(dio: dio);

  @lazySingleton
  VideosRepository videosRepository(
    VideosRemoteDataSource remoteDataSource,
    VideosLocalDataSource localDataSource,
    LocalAuthDataSource localAuthDataSource,
  ) =>
      VideosRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        localAuthDataSource: localAuthDataSource,
      );

  @factoryMethod
  VideosCubit videosCubit(VideosRepository repository) =>
      VideosCubit(repository: repository);
}
