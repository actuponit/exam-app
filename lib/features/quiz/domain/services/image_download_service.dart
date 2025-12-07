import '../models/download_progress.dart';

abstract class ImageDownloadService {
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
