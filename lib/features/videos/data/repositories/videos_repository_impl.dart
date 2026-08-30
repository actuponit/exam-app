import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';

import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_local_datasource.dart';
import '../datasources/videos_remote_datasource.dart';

class VideosRepositoryImpl implements VideosRepository {
  final VideosRemoteDataSource remoteDataSource;
  final VideosLocalDataSource localDataSource;
  final LocalAuthDataSource localAuthDataSource;

  VideosRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.localAuthDataSource,
  });

  @override
  Future<List<Video>> getVideosBySubject(String subjectId) async {
    final userId = await localAuthDataSource.getUserId();
    if (userId == null) {
      throw Exception('Please log in to see videos');
    }
    final models = await remoteDataSource.getVideosBySubject(
      subjectId: subjectId,
      userId: userId,
    );
    // Cache write failure must not turn a successful fetch into an error.
    try {
      await localDataSource.cacheVideos(subjectId, models);
    } catch (_) {}
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Video>?> getCachedVideosBySubject(String subjectId) async {
    try {
      final models = await localDataSource.getCachedVideos(subjectId);
      return models?.map((m) => m.toEntity()).toList();
    } catch (_) {
      return null;
    }
  }
}
