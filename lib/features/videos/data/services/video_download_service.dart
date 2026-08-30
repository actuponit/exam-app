import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/video.dart';
import '../../domain/entities/video_download_status.dart';

/// Owns every video download on the device.
///
/// One `background_downloader` group of its own (`exam_app_video_downloads`)
/// so it never mixes with the exam image downloads, and one
/// [MemoryTaskQueue] with `maxConcurrent = 1` so exactly one video downloads
/// at a time and the rest report [VideoDownloadState.queued] ("Waiting").
///
/// In-flight state is read only from the engine (its task database on start,
/// its updates stream afterwards) — this class never persists status itself.
abstract class VideoDownloadService {
  /// The dedicated task group. Public so nothing else reuses the name.
  static const group = 'exam_app_video_downloads';

  /// Latest status per video id. Videos with nothing happening are absent.
  Map<String, VideoDownloadStatus> get current;

  /// Emits a fresh snapshot of [current] on every change.
  Stream<Map<String, VideoDownloadStatus>> get statuses;

  /// Starts the engine, attaches the serial queue and adopts whatever the
  /// task database survived the last app kill with. Safe to call twice.
  Future<void> initialize();

  /// Queues [video] for download. Returns `null` on success, or a message to
  /// show the student when the download was refused (no free space).
  Future<String?> enqueue(Video video);

  /// Cancels a queued or running download and removes any partial file.
  Future<void> cancel(String videoId);
}

class VideoDownloadServiceImpl implements VideoDownloadService {
  static const _directory = 'videos';

  /// Headroom demanded on top of the file itself, so a download never fills
  /// the volume to the last byte.
  static const _freeSpaceMarginBytes = 50 * 1024 * 1024;

  final DiskSpacePlus _diskSpace;

  final _statuses = <String, VideoDownloadStatus>{};

  /// videoId -> its task, so a cancel can find the taskId and file path even
  /// for a task adopted from the database after an app kill.
  final _tasks = <String, DownloadTask>{};

  final _controller =
      StreamController<Map<String, VideoDownloadStatus>>.broadcast();

  final MemoryTaskQueue _queue = MemoryTaskQueue()..maxConcurrent = 1;

  /// Video ids with an [enqueue] or [cancel] in flight — a per-video lock.
  ///
  /// Both operations await, and both key off one deterministic filename, so
  /// overlapping them corrupts state: two taps would build two tasks for one
  /// video (the second orphaning the first), and a cancel that published its
  /// cleared status early would let a re-tap start a replacement download
  /// whose partial file the still-running cleanup then deletes.
  final _busy = <String>{};

  StreamSubscription<TaskUpdate>? _updates;
  StreamSubscription<Task>? _enqueueErrors;
  bool _initialized = false;

  VideoDownloadServiceImpl({DiskSpacePlus? diskSpace})
      : _diskSpace = diskSpace ?? DiskSpacePlus();

  @override
  Map<String, VideoDownloadStatus> get current => Map.unmodifiable(_statuses);

  @override
  Stream<Map<String, VideoDownloadStatus>> get statuses => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FileDownloader().configureNotificationForGroup(
      VideoDownloadService.group,
      running: const TaskNotification('{displayName}', 'Downloading {progress}'),
      complete: const TaskNotification('{displayName}', 'Download complete'),
      error: const TaskNotification('{displayName}', 'Download failed'),
      paused: const TaskNotification('{displayName}', 'Paused'),
      progressBar: true,
    );

    // Listener first, then start(), so updates that arrived while the app was
    // suspended are not missed.
    _updates = FileDownloader().updates.listen(_onUpdate);
    _enqueueErrors = _queue.enqueueErrors.listen(_onEnqueueError);
    FileDownloader().addTaskQueue(_queue);
    await FileDownloader().start();
    await _adoptDatabase();
  }

  @override
  Future<String?> enqueue(Video video) async {
    if (!_busy.add(video.id)) return null;
    try {
      return await _enqueue(video);
    } finally {
      _busy.remove(video.id);
    }
  }

  Future<String?> _enqueue(Video video) async {
    final existing = _statuses[video.id];
    if (existing != null && (existing.isActive || existing.isComplete)) {
      return null;
    }

    final refusal = await _refuseForSpace(video);
    if (refusal != null) return refusal;

    final task = DownloadTask(
      url: video.downloadUrl,
      filename: fileNameFor(video),
      directory: _directory,
      baseDirectory: BaseDirectory.applicationDocuments,
      group: VideoDownloadService.group,
      updates: Updates.statusAndProgress,
      retries: 3,
      allowPause: true,
      metaData: video.id,
      displayName: video.title,
    );

    _tasks[video.id] = task;
    // Optimistic "Waiting": the queue may hold the task for a while before the
    // engine reports `enqueued`.
    _set(video.id, const VideoDownloadStatus(state: VideoDownloadState.queued));
    _queue.add(task);
    return null;
  }

  @override
  Future<void> cancel(String videoId) async {
    if (!_busy.add(videoId)) return;
    try {
      final task = _tasks[videoId];
      if (task == null) {
        if (_statuses.remove(videoId) != null) _emit();
        return;
      }

      // Covers both halves of the queue: still waiting (never enqueued), or
      // already handed to the engine.
      _queue.remove(task);
      await FileDownloader().cancelTaskWithId(task.taskId);
      await _deleteFile(task);

      // Cleared only once the partial file is gone, so a re-tap can never
      // race the deletion of its own fresh download.
      _tasks.remove(videoId);
      _statuses.remove(videoId);
      _emit();
    } finally {
      _busy.remove(videoId);
    }
  }

  /// `<videoId>.<ext>` with the extension taken from the server's mime type,
  /// defaulting to `mp4`.
  static String fileNameFor(Video video) => '${video.id}.${_extension(video)}';

  static String _extension(Video video) {
    final mime = video.mimeType?.trim().toLowerCase();
    if (mime == null || mime.isEmpty) return 'mp4';
    final subtype = mime.split('/').last.split(';').first.trim();
    if (subtype.isEmpty) return 'mp4';
    const aliases = {
      'quicktime': 'mov',
      'x-matroska': 'mkv',
      'x-msvideo': 'avi',
      'mpeg': 'mpg',
    };
    final ext = aliases[subtype] ?? subtype;
    // Anything exotic still has to look like a plausible file extension.
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(ext) ? ext : 'mp4';
  }

  /// Reads whatever the engine's database knows, so cards are correct on the
  /// first frame after a cold start (including a download killed mid-file and
  /// rescheduled by `start()`).
  Future<void> _adoptDatabase() async {
    final records = await FileDownloader()
        .database
        .allRecords(group: VideoDownloadService.group);
    for (final record in records) {
      final task = record.task;
      final videoId = task.metaData;
      if (videoId.isEmpty || task is! DownloadTask) continue;
      final state = _stateFor(record.status);
      if (state == null) continue;
      _tasks[videoId] = task;
      _statuses[videoId] = VideoDownloadStatus(
        state: state,
        progress: _cleanProgress(record.progress),
      );
    }
    _emit();
  }

  Future<void> _onUpdate(TaskUpdate update) async {
    final task = update.task;
    if (task.group != VideoDownloadService.group) return;
    final videoId = task.metaData;
    if (videoId.isEmpty) return;

    switch (update) {
      case TaskStatusUpdate():
        final tracked = _tasks[videoId];
        // A late update from a task this video has already moved on from must
        // not touch the current one — nor delete its file on `canceled`.
        if (tracked != null && tracked.taskId != task.taskId) return;
        if (task is DownloadTask) _tasks[videoId] = task;
        final state = _stateFor(update.status);
        if (update.status == TaskStatus.canceled) {
          await _deleteFile(task);
        }
        if (state == null) {
          _tasks.remove(videoId);
          if (_statuses.remove(videoId) != null) _emit();
        } else {
          final progress = state == VideoDownloadState.complete
              ? 1.0
              : (_statuses[videoId]?.progress ?? 0);
          _set(videoId, VideoDownloadStatus(state: state, progress: progress));
        }

      case TaskProgressUpdate():
        // Negative values are the engine's sentinels (failed, paused, ...);
        // the accompanying status update already carries that information.
        if (update.progress < 0) return;
        final existing = _statuses[videoId];
        // Nothing tracked means the download was just cancelled; a late
        // progress event must not resurrect the card.
        if (existing == null) return;
        final state = existing.state == VideoDownloadState.queued
            ? VideoDownloadState.running
            : existing.state;
        _set(
          videoId,
          VideoDownloadStatus(
            state: state,
            progress: _cleanProgress(update.progress),
          ),
        );
    }
  }

  /// A task the queue could not hand to the engine emits here instead of on
  /// the updates stream. It also still counts against `maxConcurrent`, so it
  /// has to be released or it blocks every later video forever.
  void _onEnqueueError(Task task) {
    _queue.taskFinished(task);
    if (task.group != VideoDownloadService.group) return;
    final videoId = task.metaData;
    if (videoId.isEmpty) return;
    final tracked = _tasks[videoId];
    if (tracked != null && tracked.taskId != task.taskId) return;
    _set(videoId, const VideoDownloadStatus(state: VideoDownloadState.failed));
  }

  /// Maps engine status to card state. `null` means "no longer interesting" —
  /// the card falls back to not-downloaded.
  static VideoDownloadState? _stateFor(TaskStatus status) => switch (status) {
        TaskStatus.enqueued ||
        TaskStatus.waitingToRetry =>
          VideoDownloadState.queued,
        TaskStatus.running => VideoDownloadState.running,
        TaskStatus.paused => VideoDownloadState.paused,
        TaskStatus.complete => VideoDownloadState.complete,
        TaskStatus.failed || TaskStatus.notFound => VideoDownloadState.failed,
        TaskStatus.canceled => null,
      };

  static double _cleanProgress(double raw) =>
      raw.isNaN || raw < 0 ? 0 : (raw > 1 ? 1 : raw);

  Future<String?> _refuseForSpace(Video video) async {
    try {
      final documents = await getApplicationDocumentsDirectory();
      final freeMb = await _diskSpace.getFreeDiskSpaceForPath(documents.path);
      // The platform could not tell us — do not block the student on a guess.
      if (freeMb == null) return null;
      final freeBytes = freeMb * 1024 * 1024;
      final needed = video.fileSizeBytes + _freeSpaceMarginBytes;
      if (freeBytes >= needed) return null;
      return 'Not enough storage to download this video. '
          'Free up some space and try again.';
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteFile(Task task) async {
    try {
      final file = File(await task.filePath());
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // A partial file we cannot remove is not worth failing the cancel over.
    }
  }

  void _set(String videoId, VideoDownloadStatus status) {
    if (_statuses[videoId] == status) return;
    _statuses[videoId] = status;
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(Map.unmodifiable(_statuses));
  }

  Future<void> dispose() async {
    await _enqueueErrors?.cancel();
    await _updates?.cancel();
    await _controller.close();
  }
}
