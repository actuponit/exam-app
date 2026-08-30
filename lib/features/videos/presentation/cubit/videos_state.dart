part of 'videos_cubit.dart';

abstract class VideosState extends Equatable {
  const VideosState();

  @override
  List<Object?> get props => [];
}

class VideosInitial extends VideosState {
  const VideosInitial();
}

/// First load with nothing cached — the only time a full-screen spinner shows.
class VideosLoading extends VideosState {
  const VideosLoading();
}

class VideosLoaded extends VideosState {
  final String subjectId;
  final List<VideoChapterGroup> groups;

  /// In-flight download state per video id, owned by the download engine.
  /// Videos with nothing happening are absent.
  final Map<String, VideoDownloadStatus> downloads;

  /// A network fetch is in flight behind this list (initial revalidation or
  /// an explicit refresh). Drives the app-bar icon spin.
  final bool isRefreshing;

  /// The last refresh failed and [groups] came from cache.
  final bool isOffline;

  const VideosLoaded({
    required this.subjectId,
    required this.groups,
    this.downloads = const {},
    this.isRefreshing = false,
    this.isOffline = false,
  });

  bool get isEmpty => groups.isEmpty;

  VideoDownloadStatus statusOf(String videoId) =>
      downloads[videoId] ?? VideoDownloadStatus.none;

  VideosLoaded copyWith({
    List<VideoChapterGroup>? groups,
    Map<String, VideoDownloadStatus>? downloads,
    bool? isRefreshing,
    bool? isOffline,
  }) {
    return VideosLoaded(
      subjectId: subjectId,
      groups: groups ?? this.groups,
      downloads: downloads ?? this.downloads,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props =>
      [subjectId, groups, downloads, isRefreshing, isOffline];
}

class VideosError extends VideosState {
  final String message;

  const VideosError({required this.message});

  @override
  List<Object?> get props => [message];
}
