import 'package:hive/hive.dart';

import '../models/video_download_model.dart';
import '../models/video_model.dart';

/// Wraps `videos_box`.
///
/// The box is untyped because it holds two kinds of record under prefixed
/// keys: `subject:<subjectId>` → `List<VideoModel>` (the cached server list)
/// and `download:<videoId>` → [VideoDownloadModel]. Download records are only
/// read here; ticket 03 adds the writers.
abstract class VideosLocalDataSource {
  /// Last list fetched for [subjectId], or `null` when never cached.
  Future<List<VideoModel>?> getCachedVideos(String subjectId);

  /// Replaces the cached list for [subjectId].
  Future<void> cacheVideos(String subjectId, List<VideoModel> videos);

  Future<VideoDownloadModel?> getDownload(String videoId);
}

class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  final Box<dynamic> _box;

  VideosLocalDataSourceImpl(Box<dynamic> box) : _box = box;

  static String subjectKey(String subjectId) => 'subject:$subjectId';
  static String downloadKey(String videoId) => 'download:$videoId';

  @override
  Future<List<VideoModel>?> getCachedVideos(String subjectId) async {
    final raw = _box.get(subjectKey(subjectId));
    if (raw is! List) return null;
    // A cached list that no longer decodes is treated as absent rather than
    // breaking the tab; the next successful fetch overwrites it.
    try {
      return raw.cast<VideoModel>().toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheVideos(String subjectId, List<VideoModel> videos) {
    return _box.put(subjectKey(subjectId), List<VideoModel>.from(videos));
  }

  @override
  Future<VideoDownloadModel?> getDownload(String videoId) async {
    final raw = _box.get(downloadKey(videoId));
    return raw is VideoDownloadModel ? raw : null;
  }
}
