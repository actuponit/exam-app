import 'dart:async';
import 'package:background_downloader/background_downloader.dart';
import 'package:exam_app/features/quiz/domain/models/download_progress.dart';
import 'package:exam_app/features/quiz/domain/services/image_download_service.dart';

/// Downloads exam images through `background_downloader`'s own group
/// (`exam_app_image_downloads`), tracked from its persistent `updates`
/// stream rather than a per-call callback — the callback only lives as long
/// as the `Dart` isolate that started it, so a batch surviving an app kill
/// (native side keeps working; WorkManager / URLSession) would otherwise
/// have no one left to hear it finish, leaving the notification stuck.
class ImageDownloadServiceImpl implements ImageDownloadService {
  static const group = 'exam_app_image_downloads';
  static const int maxRetries = 3;

  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  final String downloadDirectory;
  int _totalImages = 0;
  int _downloadedImages = 0;
  int _failedImages = 0;
  bool _isDownloading = false;
  bool _initialized = false;

  /// taskIds of the current batch still awaiting a terminal status.
  final Set<String> _pendingTaskIds = {};

  StreamSubscription<TaskUpdate>? _updates;

  ImageDownloadServiceImpl({
    required this.downloadDirectory,
  });

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FileDownloader().configureNotificationForGroup(
      group,
      running: const TaskNotification(
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
      groupNotificationId: group,
    );

    // Listener before start(), so updates that arrived while the app was
    // suspended or killed are not missed.
    _updates = FileDownloader().updates.listen(_onUpdate);
    await FileDownloader().start();
    await _adoptDatabase();
  }

  /// Resolves whatever the engine's task database still holds from a run
  /// that never finished in Dart (app killed mid-batch): clears rows that
  /// already reached a terminal state so they cannot leak into the next
  /// batch, and — if nothing from that run is still in flight — pushes the
  /// notification group to its final state so it stops looking stuck.
  Future<void> _adoptDatabase() async {
    final records = await FileDownloader().database.allRecords(group: group);
    if (records.isEmpty) return;

    var stillRunning = 0;
    for (final record in records) {
      switch (record.status) {
        case TaskStatus.complete:
        case TaskStatus.failed:
        case TaskStatus.notFound:
        case TaskStatus.canceled:
          try {
            await FileDownloader().database.deleteRecordWithId(record.taskId);
          } catch (_) {}
        default:
          stillRunning++;
      }
    }

    if (stillRunning == 0) {
      _isDownloading = false;
      _progressController.add(_createProgress(SyncPhase.completed));
    }
  }

  @override
  Stream<DownloadProgress> downloadImagesInBackground(
    Map<String, String> imageUrls,
  ) {
    _isDownloading = true;
    _totalImages = imageUrls.length;
    _downloadedImages = 0;
    _failedImages = 0;
    _pendingTaskIds.clear();

    final tasks = <DownloadTask>[
      for (final entry in imageUrls.entries)
        DownloadTask(
          url: entry.value,
          filename: '${entry.key}.jpg',
          directory: 'images',
          baseDirectory: BaseDirectory.applicationDocuments,
          group: group,
          retries: maxRetries,
        ),
    ];
    _pendingTaskIds.addAll(tasks.map((task) => task.taskId));

    // Kick off after this call returns so the caller's .listen() is attached
    // before any progress event is emitted (the controller is a broadcast
    // stream and drops events with no listener).
    scheduleMicrotask(() async {
      if (!_initialized) await initialize();

      if (tasks.isEmpty) {
        _isDownloading = false;
        _progressController.add(_createProgress(SyncPhase.completed));
        return;
      }

      for (final task in tasks) {
        final enqueued = await FileDownloader().enqueue(task);
        if (!enqueued) {
          _pendingTaskIds.remove(task.taskId);
          _failedImages++;
          _emitProgress();
        }
      }
    });

    return _progressController.stream;
  }

  Future<void> _onUpdate(TaskUpdate update) async {
    if (update is! TaskStatusUpdate) return;
    final task = update.task;
    if (task.group != group) return;
    if (!_pendingTaskIds.contains(task.taskId)) return;

    switch (update.status) {
      case TaskStatus.complete:
        _pendingTaskIds.remove(task.taskId);
        _downloadedImages++;
      case TaskStatus.failed:
      case TaskStatus.notFound:
      case TaskStatus.canceled:
        _pendingTaskIds.remove(task.taskId);
        _failedImages++;
      default:
        // enqueued / running / paused / waitingToRetry — still in flight.
        return;
    }

    try {
      await FileDownloader().database.deleteRecordWithId(task.taskId);
    } catch (_) {}

    _emitProgress();
  }

  void _emitProgress() {
    final done = _downloadedImages + _failedImages;
    if (_totalImages > 0 && done >= _totalImages) {
      _isDownloading = false;
      _progressController.add(_createProgress(
        _failedImages > 0 ? SyncPhase.error : SyncPhase.completed,
      ));
    } else {
      _progressController.add(_createProgress(SyncPhase.downloadingImages));
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
    final taskIds = await FileDownloader().allTaskIds(group: group);
    await FileDownloader().cancelTasksWithIds(taskIds);
    _pendingTaskIds.clear();
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
    _updates?.cancel();
    _progressController.close();
  }
}
