import 'dart:io';

import 'package:hive/hive.dart';

import '../models/video_download_model.dart';
import '../models/video_model.dart';

/// Wraps `videos_box`.
///
/// The box is untyped because it holds three kinds of record under prefixed
/// keys: `subject:<subjectId>` → `List<VideoModel>` (the cached server list),
/// `download:<videoId>` → [VideoDownloadModel] (a finished, recorded
/// download) and `pending:<videoId>` → [VideoModel] (the metadata snapshot of
/// a download that is still in flight).
///
/// The pending snapshot exists because a download can finish after an app
/// kill, in a process that never saw the video list: without it the completion
/// handler would know neither the checksum to verify against nor the metadata
/// to keep in the record.
abstract class VideosLocalDataSource {
  /// Last list fetched for [subjectId], or `null` when never cached.
  Future<List<VideoModel>?> getCachedVideos(String subjectId);

  /// Replaces the cached list for [subjectId].
  Future<void> cacheVideos(String subjectId, List<VideoModel> videos);

  Future<VideoDownloadModel?> getDownload(String videoId);

  /// Every finished download on this device, keyed by video id.
  Future<Map<String, VideoDownloadModel>> getAllDownloads();

  Future<void> putDownload(VideoDownloadModel download);

  Future<void> deleteDownload(String videoId);

  /// Drops every download record whose file is no longer on disk (OS cleanup,
  /// a manual delete, a reinstall) and returns the video ids that were
  /// dropped, so their cards fall back to "not downloaded" instead of opening
  /// a player over nothing.
  Future<List<String>> reconcileDownloads();

  /// Stores the playback position of a saved download. A record that is not
  /// there (deleted while the player was open) is left alone.
  Future<void> saveResumePosition(String videoId, int seconds);

  /// Metadata snapshot of a video whose download is in flight.
  Future<VideoModel?> getPendingVideo(String videoId);

  Future<void> putPendingVideo(VideoModel video);

  Future<void> deletePendingVideo(String videoId);
}

class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  final Box<dynamic> _box;

  VideosLocalDataSourceImpl(Box<dynamic> box) : _box = box;

  static String subjectKey(String subjectId) => 'subject:$subjectId';
  static String downloadKey(String videoId) => 'download:$videoId';
  static String pendingKey(String videoId) => 'pending:$videoId';

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

  @override
  Future<Map<String, VideoDownloadModel>> getAllDownloads() async {
    final downloads = <String, VideoDownloadModel>{};
    for (final key in _box.keys) {
      if (key is! String || !key.startsWith('download:')) continue;
      final raw = _box.get(key);
      if (raw is VideoDownloadModel) downloads[raw.videoId] = raw;
    }
    return downloads;
  }

  @override
  Future<void> putDownload(VideoDownloadModel download) {
    return _box.put(downloadKey(download.videoId), download);
  }

  @override
  Future<void> deleteDownload(String videoId) {
    return _box.delete(downloadKey(videoId));
  }

  @override
  Future<List<String>> reconcileDownloads() async {
    final removed = <String>[];
    final downloads = await getAllDownloads();
    for (final download in downloads.values) {
      if (File(download.localPath).existsSync()) continue;
      await _box.delete(downloadKey(download.videoId));
      removed.add(download.videoId);
    }
    return removed;
  }

  @override
  Future<void> saveResumePosition(String videoId, int seconds) async {
    final existing = await getDownload(videoId);
    if (existing == null) return;
    final position = seconds < 0 ? 0 : seconds;
    if (existing.resumePositionSeconds == position) return;
    await putDownload(existing.copyWith(resumePositionSeconds: position));
  }

  @override
  Future<VideoModel?> getPendingVideo(String videoId) async {
    final raw = _box.get(pendingKey(videoId));
    return raw is VideoModel ? raw : null;
  }

  @override
  Future<void> putPendingVideo(VideoModel video) {
    return _box.put(pendingKey(video.id), video);
  }

  @override
  Future<void> deletePendingVideo(String videoId) {
    return _box.delete(pendingKey(videoId));
  }
}
