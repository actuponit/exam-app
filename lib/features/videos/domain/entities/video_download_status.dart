import 'package:equatable/equatable.dart';

import 'video.dart';

/// State of one video download as the card sees it.
///
/// Everything up to and including [verifying] is owned by the download
/// engine's task database — never persisted by us. [downloaded] is owned by
/// the Hive download record: the moment that record is written the in-flight
/// entry is dropped, so the two never describe the same video at once.
enum VideoDownloadState {
  /// Nothing is happening for this video on this device.
  none,

  /// Added to the serial queue, or enqueued with the engine, but not running.
  queued,

  /// Bytes are moving.
  running,

  /// Paused by the student. Tapping the card resumes from where it stopped.
  paused,

  /// Bytes are all here; the checksum is being computed.
  verifying,

  /// The task ended in failure, or the file failed verification. Tapping the
  /// card retries. See [VideoDownloadStatus.failure] for the reason.
  failed,

  /// The file is on the device and has a Hive download record.
  downloaded,
}

/// Why a download is in [VideoDownloadState.failed], so the card can name it.
enum VideoDownloadFailure {
  /// The file arrived but its MD5 did not match the server's checksum.
  corrupted,

  /// The task failed and the device has no connection.
  noConnection,

  /// The task failed for any other reason.
  failed,
}

extension VideoDownloadFailureLabel on VideoDownloadFailure {
  String get label => switch (this) {
        VideoDownloadFailure.corrupted => 'Corrupted',
        VideoDownloadFailure.noConnection => 'No connection',
        VideoDownloadFailure.failed => 'Download failed',
      };
}

class VideoDownloadStatus extends Equatable {
  final VideoDownloadState state;

  /// 0..1, only meaningful while [state] is [VideoDownloadState.running] or
  /// [VideoDownloadState.paused].
  final double progress;

  /// Set only while [state] is [VideoDownloadState.failed].
  final VideoDownloadFailure? failure;

  /// Absolute path of the finished file. Set only while [state] is
  /// [VideoDownloadState.downloaded]; read back from the Hive record.
  final String? localPath;

  /// The running task reported that the server supports resuming it, so the
  /// card may offer Pause. False until the engine has heard back from the
  /// server, and on servers without range support it stays false forever —
  /// which is exactly the "cancel only" case.
  final bool canPause;

  /// Metadata snapshot copied into the Hive record at download time. Set only
  /// while [state] is [VideoDownloadState.downloaded], and the only way to
  /// render a card for a video the server no longer returns.
  final Video? video;

  const VideoDownloadStatus({
    required this.state,
    this.progress = 0,
    this.failure,
    this.localPath,
    this.canPause = false,
    this.video,
  });

  static const none = VideoDownloadStatus(state: VideoDownloadState.none);

  bool get isQueued => state == VideoDownloadState.queued;
  bool get isRunning => state == VideoDownloadState.running;
  bool get isPaused => state == VideoDownloadState.paused;
  bool get isVerifying => state == VideoDownloadState.verifying;
  bool get isFailed => state == VideoDownloadState.failed;
  bool get isDownloaded => state == VideoDownloadState.downloaded;

  /// True while the task occupies the queue and a tap should cancel it.
  bool get isActive => isQueued || isRunning || isPaused;

  /// True while the card must not react to a tap at all: the file is here but
  /// the record that makes it playable is not written yet.
  bool get isSettling => isVerifying;

  /// True when a tap on a downloading card must offer Pause alongside Cancel
  /// rather than cancelling outright.
  bool get isPausable => isRunning && canPause;

  VideoDownloadStatus copyWith({
    VideoDownloadState? state,
    double? progress,
    VideoDownloadFailure? failure,
    String? localPath,
    bool? canPause,
    Video? video,
  }) {
    return VideoDownloadStatus(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      failure: failure ?? this.failure,
      localPath: localPath ?? this.localPath,
      canPause: canPause ?? this.canPause,
      video: video ?? this.video,
    );
  }

  @override
  List<Object?> get props =>
      [state, progress, failure, localPath, canPause, video];
}
