import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';

part 'videos_state.dart';

/// Stale-while-revalidate over one subject's video list.
///
/// [loadVideos] paints the cached list at once (if any) and then fetches;
/// [refresh] re-fetches on demand. A fetch that fails while a list is showing
/// keeps that list and flags it `isOffline`; with nothing to show it becomes
/// [VideosError].
class VideosCubit extends Cubit<VideosState> {
  final VideosRepository repository;

  String? _subjectId;
  int _fetchSerial = 0;

  VideosCubit({required this.repository}) : super(const VideosInitial());

  Future<void> loadVideos(String subjectId) async {
    final previous = state;
    _subjectId = subjectId;
    // Never leave another subject's list on screen while its cache is read.
    if (previous is VideosLoaded && previous.subjectId != subjectId) {
      emit(const VideosLoading());
    }
    final cached = await repository.getCachedVideosBySubject(subjectId);
    if (isClosed || _subjectId != subjectId) return;

    if (cached != null) {
      emit(VideosLoaded(
        subjectId: subjectId,
        groups: VideoChapterGroup.fromVideos(cached),
        isRefreshing: true,
      ));
    } else {
      emit(const VideosLoading());
    }
    await _fetch(subjectId);
  }

  /// Pull-to-refresh and the app-bar icon both land here. Completes when the
  /// fetch settles so `RefreshIndicator` can hide itself.
  Future<void> refresh() async {
    final subjectId = _subjectId;
    if (subjectId == null) return;

    final current = state;
    if (current is VideosLoaded) {
      if (current.isRefreshing) return;
      emit(current.copyWith(isRefreshing: true));
    } else if (current is! VideosLoading) {
      emit(const VideosLoading());
    }
    await _fetch(subjectId);
  }

  Future<void> _fetch(String subjectId) async {
    final serial = ++_fetchSerial;
    try {
      final videos = await repository.getVideosBySubject(subjectId);
      if (!_isCurrent(serial, subjectId)) return;
      emit(VideosLoaded(
        subjectId: subjectId,
        groups: VideoChapterGroup.fromVideos(videos),
      ));
    } catch (e) {
      if (!_isCurrent(serial, subjectId)) return;
      final current = state;
      if (current is VideosLoaded && current.subjectId == subjectId) {
        emit(current.copyWith(isRefreshing: false, isOffline: true));
      } else {
        emit(VideosError(message: _cleanMessage(e)));
      }
    }
  }

  /// Guards against a slow response landing after a newer fetch or after the
  /// cubit moved to another subject.
  bool _isCurrent(int serial, String subjectId) =>
      !isClosed && serial == _fetchSerial && _subjectId == subjectId;

  static String _cleanMessage(Object error) {
    final text = error.toString();
    const prefix = 'Exception: ';
    return text.startsWith(prefix) ? text.substring(prefix.length) : text;
  }
}
