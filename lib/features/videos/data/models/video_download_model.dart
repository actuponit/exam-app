import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/video_download.dart';
import 'video_model.dart';

part 'video_download_model.g.dart';

/// Hive record for one completed download, keyed by video id in `videos_box`.
///
/// Registered from ticket 02 so the adapter exists on every install before
/// anything writes it (ticket 03). Hive rules: never renumber a `@HiveField`,
/// only append; new fields must be nullable or carry `defaultValue:`.
@HiveType(typeId: HiveTypeIds.videoDownload)
class VideoDownloadModel extends Equatable {
  @HiveField(0)
  final String videoId;
  @HiveField(1)
  final String localPath;
  @HiveField(2, defaultValue: false)
  final bool verified;
  @HiveField(3, defaultValue: 0)
  final int resumePositionSeconds;
  @HiveField(4)
  final VideoModel? video;

  const VideoDownloadModel({
    required this.videoId,
    required this.localPath,
    this.verified = false,
    this.resumePositionSeconds = 0,
    this.video,
  });

  factory VideoDownloadModel.fromEntity(VideoDownload download) {
    return VideoDownloadModel(
      videoId: download.videoId,
      localPath: download.localPath,
      verified: download.verified,
      resumePositionSeconds: download.resumePositionSeconds,
      video: download.video == null
          ? null
          : VideoModel.fromEntity(download.video!),
    );
  }

  VideoDownloadModel copyWith({
    String? localPath,
    bool? verified,
    int? resumePositionSeconds,
    VideoModel? video,
  }) {
    return VideoDownloadModel(
      videoId: videoId,
      localPath: localPath ?? this.localPath,
      verified: verified ?? this.verified,
      resumePositionSeconds:
          resumePositionSeconds ?? this.resumePositionSeconds,
      video: video ?? this.video,
    );
  }

  VideoDownload toEntity() {
    return VideoDownload(
      videoId: videoId,
      localPath: localPath,
      verified: verified,
      resumePositionSeconds: resumePositionSeconds,
      video: video?.toEntity(),
    );
  }

  @override
  List<Object?> get props =>
      [videoId, localPath, verified, resumePositionSeconds, video];
}
