import 'package:equatable/equatable.dart';

/// In-flight (and just-finished) state of one video download.
///
/// Owned by the download engine's task database — never persisted by us.
/// Completed downloads and resume positions live in the Hive download record
/// instead, so the two never drift.
enum VideoDownloadState {
  /// Nothing is happening for this video on this device.
  none,

  /// Added to the serial queue, or enqueued with the engine, but not running.
  queued,

  /// Bytes are moving.
  running,

  /// Paused by the student (resume affordance lands in a later ticket).
  paused,

  /// The task ended in failure. Tapping the card retries.
  failed,

  /// The file finished downloading. Checksum verification is a later ticket.
  complete,
}

class VideoDownloadStatus extends Equatable {
  final VideoDownloadState state;

  /// 0..1, only meaningful while [state] is [VideoDownloadState.running] or
  /// [VideoDownloadState.paused].
  final double progress;

  const VideoDownloadStatus({required this.state, this.progress = 0});

  static const none = VideoDownloadStatus(state: VideoDownloadState.none);

  bool get isQueued => state == VideoDownloadState.queued;
  bool get isRunning => state == VideoDownloadState.running;
  bool get isPaused => state == VideoDownloadState.paused;
  bool get isFailed => state == VideoDownloadState.failed;
  bool get isComplete => state == VideoDownloadState.complete;

  /// True while the task occupies the queue and a tap should cancel it.
  bool get isActive => isQueued || isRunning || isPaused;

  VideoDownloadStatus copyWith({VideoDownloadState? state, double? progress}) {
    return VideoDownloadStatus(
      state: state ?? this.state,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [state, progress];
}
