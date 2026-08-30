import '../entities/video.dart';

abstract class VideosRepository {
  /// Fetches the videos of [subjectId] for the logged-in user, in server order.
  Future<List<Video>> getVideosBySubject(String subjectId);
}
