import 'package:equatable/equatable.dart';

import 'video.dart';

/// A completed, verified download of one video on this device.
///
/// [video] is the metadata snapshot taken at download time so the card can
/// still render after the server removes or deactivates the video.
class VideoDownload extends Equatable {
  final String videoId;
  final String localPath;
  final bool verified;
  final int resumePositionSeconds;
  final Video? video;

  const VideoDownload({
    required this.videoId,
    required this.localPath,
    this.verified = false,
    this.resumePositionSeconds = 0,
    this.video,
  });

  @override
  List<Object?> get props =>
      [videoId, localPath, verified, resumePositionSeconds, video];
}
