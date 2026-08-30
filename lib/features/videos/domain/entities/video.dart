import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool locked;
  final String downloadUrl;
  final int fileSizeBytes;
  final String? checksum;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? grade;
  final String? language;
  final int sortOrder;
  final bool isActive;
  final String subjectId;
  final String? chapterId;
  final String? chapterName;

  const Video({
    required this.id,
    required this.title,
    this.description,
    required this.locked,
    required this.downloadUrl,
    required this.fileSizeBytes,
    this.checksum,
    this.durationSeconds,
    this.thumbnailUrl,
    this.mimeType,
    this.grade,
    this.language,
    required this.sortOrder,
    required this.isActive,
    required this.subjectId,
    this.chapterId,
    this.chapterName,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        locked,
        downloadUrl,
        fileSizeBytes,
        checksum,
        durationSeconds,
        thumbnailUrl,
        mimeType,
        grade,
        language,
        sortOrder,
        isActive,
        subjectId,
        chapterId,
        chapterName,
      ];
}

/// Videos of one subject grouped under a chapter heading.
///
/// [chapterId] and [chapterName] are `null` for videos with no chapter
/// ("General" group). Order of videos inside a group is the server order,
/// never re-sorted.
class VideoChapterGroup extends Equatable {
  final String? chapterId;
  final String? chapterName;
  final List<Video> videos;

  const VideoChapterGroup({
    required this.chapterId,
    required this.chapterName,
    required this.videos,
  });

  static const generalLabel = 'General';

  String get displayName => chapterName ?? generalLabel;

  /// Groups [videos] by chapter: null-chapter videos first as "General",
  /// remaining chapters in first-appearance order. Inactive videos dropped,
  /// unless their id is in [keepInactiveIds] — a video the student has
  /// already downloaded stays on the list after the teacher deactivates it.
  ///
  /// Chapter identity is [Video.chapterId]; two chapters sharing a name stay
  /// separate groups. A video with a name but no id is keyed by its name.
  static List<VideoChapterGroup> fromVideos(
    List<Video> videos, {
    Set<String> keepInactiveIds = const {},
  }) {
    final general = <Video>[];
    final byChapter = <String, VideoChapterGroup>{};

    for (final video in videos) {
      if (!video.isActive && !keepInactiveIds.contains(video.id)) continue;
      final id = video.chapterId?.trim();
      final name = video.chapterName?.trim();
      final hasId = id != null && id.isNotEmpty;
      final hasName = name != null && name.isNotEmpty;
      if (!hasId && !hasName) {
        general.add(video);
        continue;
      }
      final key = hasId ? 'id:$id' : 'name:$name';
      final group = byChapter.putIfAbsent(
        key,
        () => VideoChapterGroup(
          chapterId: hasId ? id : null,
          chapterName: hasName ? name : null,
          videos: [],
        ),
      );
      group.videos.add(video);
    }

    return [
      if (general.isNotEmpty)
        VideoChapterGroup(chapterId: null, chapterName: null, videos: general),
      ...byChapter.values,
    ];
  }

  @override
  List<Object?> get props => [chapterId, chapterName, videos];
}
