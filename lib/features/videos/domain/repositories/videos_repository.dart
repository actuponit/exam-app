import '../entities/video.dart';

abstract class VideosRepository {
  /// Fetches the videos of [subjectId] for the logged-in user, in server
  /// order, and replaces the local cache on success.
  Future<List<Video>> getVideosBySubject(String subjectId);

  /// Last successfully fetched list for [subjectId], or `null` when the
  /// subject has never been fetched on this device. Never touches the network.
  Future<List<Video>?> getCachedVideosBySubject(String subjectId);
}
