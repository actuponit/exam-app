import 'dart:async';
import 'package:background_downloader/background_downloader.dart';
import 'package:exam_app/features/quiz/domain/models/download_progress.dart';
import 'package:exam_app/features/quiz/domain/services/image_download_service.dart';

class ImageDownloadServiceImpl implements ImageDownloadService {
  static const int maxConcurrentDownloads = 5;
  static const int maxRetries = 3;

  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  final String downloadDirectory;
  int _totalImages = 0;
  int _downloadedImages = 0;
  int _failedImages = 0;
  bool _isDownloading = false;

  ImageDownloadServiceImpl({
    required this.downloadDirectory,
  });

  @override
  Stream<DownloadProgress> downloadImagesInBackground(
    Map<String, String> imageUrls,
  ) async* {
    _isDownloading = true;
    _totalImages = imageUrls.length;
    _downloadedImages = 0;
    _failedImages = 0;

    // Emit initial state
    yield _createProgress(SyncPhase.downloadingImages);

    // Configure download manager
    FileDownloader().configureNotificationForGroup(
      'exam_app_image_downloads',
      running: TaskNotification(
        'Downloading exam images',
        'In progress',
      ),
      complete: const TaskNotification(
        'Download complete',
        'All images downloaded',
      ),
      error: const TaskNotification(
        'Download failed',
        'Some images failed',
      ),
      progressBar: true,
      groupNotificationId: 'exam_app_image_downloads',
    );

    // Track tasks '$path/${entry.key}'
    final tasks = <DownloadTask>[];

    // Create download tasks
    for (final entry in imageUrls.entries) {
      final fileName = entry.key;
      final url = entry.value;

      final task = DownloadTask(
        url: url,
        filename: "$fileName.jpg",
        directory: 'images',
        baseDirectory: BaseDirectory.applicationDocuments,
        group: 'exam_app_image_downloads',
      );

      tasks.add(task);
    }

    // Process downloads with concurrency control
    // final batches = _batchTasks(tasks, maxConcurrentDownloads);
    if (tasks.isNotEmpty) {
      await FileDownloader().downloadBatch(tasks,
          batchProgressCallback: (succeeded, failed) {
        _downloadedImages = succeeded;
        _failedImages = failed;

        if (succeeded + failed == _totalImages) {
          _isDownloading = false;

          // Emit final state
          _progressController.add(_createProgress(
            _failedImages > 0 ? SyncPhase.error : SyncPhase.completed,
          ));
        } else {
          _progressController.add(_createProgress(SyncPhase.downloadingImages));
        }
      });
    }
  }

  DownloadProgress _createProgress(SyncPhase phase) {
    return DownloadProgress(
      phase: phase,
      imagesDownloaded: _downloadedImages,
      imagesTotalCount: _totalImages,
      imageDownloadsFailed: _failedImages,
      overallProgress:
          _totalImages > 0 ? _downloadedImages / _totalImages : 0.0,
    );
  }

  @override
  Future<void> cancelAllDownloads() async {
    final taskIds = await FileDownloader().allTaskIds();
    await FileDownloader().cancelTasksWithIds(taskIds);
    _isDownloading = false;
  }

  @override
  Future<void> resumeDownloads() async {
    // Resume all paused downloads
    _isDownloading = true;
  }

  @override
  Future<DownloadProgress> getCurrentProgress() async {
    return _createProgress(
      _isDownloading ? SyncPhase.downloadingImages : SyncPhase.idle,
    );
  }

  @override
  Future<bool> isDownloading() async {
    return _isDownloading;
  }

  void dispose() {
    _progressController.close();
  }
}
