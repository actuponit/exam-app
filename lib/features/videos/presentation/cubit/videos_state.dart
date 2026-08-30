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

  /// A network fetch is in flight behind this list (initial revalidation or
  /// an explicit refresh). Drives the app-bar icon spin.
  final bool isRefreshing;

  /// The last refresh failed and [groups] came from cache.
  final bool isOffline;

  const VideosLoaded({
    required this.subjectId,
    required this.groups,
    this.isRefreshing = false,
    this.isOffline = false,
  });

  bool get isEmpty => groups.isEmpty;

  VideosLoaded copyWith({
    List<VideoChapterGroup>? groups,
    bool? isRefreshing,
    bool? isOffline,
  }) {
    return VideosLoaded(
      subjectId: subjectId,
      groups: groups ?? this.groups,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [subjectId, groups, isRefreshing, isOffline];
}

class VideosError extends VideosState {
  final String message;

  const VideosError({required this.message});

  @override
  List<Object?> get props => [message];
}
