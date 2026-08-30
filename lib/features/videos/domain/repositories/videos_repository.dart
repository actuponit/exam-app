import '../entities/video.dart';
import '../entities/video_download.dart';

abstract class VideosRepository {
  /// Fetches the videos of [subjectId] for the logged-in user, in server
  /// order, and replaces the local cache on success.
  Future<List<Video>> getVideosBySubject(String subjectId);

  /// Last successfully fetched list for [subjectId], or `null` when the
  /// subject has never been fetched on this device. Never touches the network.
  Future<List<Video>?> getCachedVideosBySubject(String subjectId);

  /// The saved download for [videoId], or `null` when the video is not on
  /// this device. Carries the local file path and the stored playback
  /// position the player resumes from.
  Future<VideoDownload?> getDownload(String videoId);

  /// Persists the player's position for a saved download. A no-op when the
  /// download record is gone.
  Future<void> saveResumePosition(String videoId, int seconds);
}
