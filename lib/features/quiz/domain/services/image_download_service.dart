import '../models/download_progress.dart';

abstract class ImageDownloadService {
  /// Starts the engine and attaches its persistent update listener. Safe to
  /// call twice. Must run once at app start, before any download is
  /// requested, so updates that arrive while the app is suspended or killed
  /// are not missed — otherwise a batch killed mid-flight leaves its
  /// notification stuck forever with no one left to resolve it.
  Future<void> initialize();

  /// Start downloading images in background
  /// Returns a stream of progress updates
  Stream<DownloadProgress> downloadImagesInBackground(
    Map<String, String> imageUrls,
  );

  /// Cancel all ongoing downloads
  Future<void> cancelAllDownloads();

  /// Resume paused downloads
  Future<void> resumeDownloads();

  /// Get current download status
  Future<DownloadProgress> getCurrentProgress();

  /// Check if downloads are in progress
  Future<bool> isDownloading();
}
