import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  final VideosRepository repository;

  VideosCubit({required this.repository}) : super(const VideosInitial());

  Future<void> loadVideos(String subjectId) async {
    emit(const VideosLoading());
    try {
      final videos = await repository.getVideosBySubject(subjectId);
      emit(VideosLoaded(
        subjectId: subjectId,
        groups: VideoChapterGroup.fromVideos(videos),
      ));
    } catch (e) {
      emit(VideosError(message: _cleanMessage(e)));
    }
  }

  static String _cleanMessage(Object error) {
    final text = error.toString();
    const prefix = 'Exception: ';
    return text.startsWith(prefix) ? text.substring(prefix.length) : text;
  }
}
