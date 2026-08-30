part of 'videos_cubit.dart';

abstract class VideosState extends Equatable {
  const VideosState();

  @override
  List<Object?> get props => [];
}

class VideosInitial extends VideosState {
  const VideosInitial();
}

class VideosLoading extends VideosState {
  const VideosLoading();
}

class VideosLoaded extends VideosState {
  final String subjectId;
  final List<VideoChapterGroup> groups;

  const VideosLoaded({required this.subjectId, required this.groups});

  bool get isEmpty => groups.isEmpty;

  @override
  List<Object?> get props => [subjectId, groups];
}

class VideosError extends VideosState {
  final String message;

  const VideosError({required this.message});

  @override
  List<Object?> get props => [message];
}
