import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/video_download_service.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/video_download_status.dart';
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
  final VideoDownloadService downloadService;

  String? _subjectId;
  int _fetchSerial = 0;

  /// Latest list on screen, cached or fetched, before any download merge.
  /// Kept so a download change can rebuild the groups without a refetch.
  List<Video> _videos = const [];

  /// Mirror of the download service's snapshot, merged into every
  /// [VideosLoaded] so the cards render queue and progress state.
  Map<String, VideoDownloadStatus> _downloads;
  late final StreamSubscription<Map<String, VideoDownloadStatus>> _downloadsSub;

  VideosCubit({required this.repository, required this.downloadService})
      : _downloads = downloadService.current,
        super(const VideosInitial()) {
    _downloadsSub = downloadService.statuses.listen((downloads) {
      _downloads = downloads;
      final current = state;
      if (current is VideosLoaded) {
        // Groups are rebuilt, not just re-decorated: a finished download can
        // add a card the server never returned, and a delete removes it.
        emit(_loaded(
          current.subjectId,
          isRefreshing: current.isRefreshing,
          isOffline: current.isOffline,
        ));
      }
    });
  }

  /// One tap target per card: start, resume, cancel or retry depending on the
  /// state. Returns a message to show the student, or `null` when there is
  /// nothing to say.
  ///
  /// Two states are settled by the widget before it gets here, because both
  /// end in UI this cubit has no business owning: a saved download opens the
  /// player, and a *pausable* running download opens the Pause / Cancel
  /// sheet. Everything else is one unambiguous action.
  Future<String?> onVideoTapped(Video video) async {
    if (video.locked) return null;
    final status = _downloads[video.id] ?? VideoDownloadStatus.none;
    if (status.isPaused) {
      await downloadService.resume(video.id);
      return null;
    }
    if (status.isActive) {
      await downloadService.cancel(video.id);
      return null;
    }
    // Mid-verification the file exists but is not recorded yet: a tap must
    // neither cancel it nor start a second download.
    if (status.isSettling) return null;
    // Handled by the widget, which pushes the player route.
    if (status.isDownloaded) return null;
    // Everything left — never downloaded, or failed — enqueues, so the failed
    // card's Retry is the same call as a first download.
    return downloadService.enqueue(video);
  }

  /// Pauses a running, resumable download. Chosen from the card's sheet.
  Future<void> pauseDownload(String videoId) =>
      downloadService.pause(videoId);

  /// Cancels a queued, running or paused download. Chosen from the card's
  /// sheet, or straight from a tap when the server does not support pausing.
  Future<void> cancelDownload(String videoId) =>
      downloadService.cancel(videoId);

  /// Deletes a saved download after the student confirms the long-press sheet.
  Future<void> deleteDownload(String videoId) =>
      downloadService.deleteDownload(videoId);

  @override
  Future<void> close() {
    _downloadsSub.cancel();
    return super.close();
  }

  Future<void> loadVideos(String subjectId) async {
    final previous = state;
    _subjectId = subjectId;
    // Never leave another subject's list on screen while its cache is read.
    if (previous is VideosLoaded && previous.subjectId != subjectId) {
      _videos = const [];
      emit(const VideosLoading());
    }
    // A record whose file the OS reclaimed must not survive into the list as
    // a "Saved" card that opens a player over nothing.
    await downloadService.reconcile();
    if (isClosed || _subjectId != subjectId) return;

    final cached = await repository.getCachedVideosBySubject(subjectId);
    if (isClosed || _subjectId != subjectId) return;

    if (cached != null) {
      _videos = cached;
      emit(_loaded(subjectId, isRefreshing: true));
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
    // A refresh is also the student's way of saying "check again", so the
    // disk sweep runs here as well as on open.
    await downloadService.reconcile();
    if (isClosed || _subjectId != subjectId) return;
    await _fetch(subjectId);
  }

  Future<void> _fetch(String subjectId) async {
    final serial = ++_fetchSerial;
    try {
      final videos = await repository.getVideosBySubject(subjectId);
      if (!_isCurrent(serial, subjectId)) return;
      _videos = videos;
      emit(_loaded(subjectId));
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

  /// Builds the state for [subjectId] out of [_videos] and the current
  /// download map.
  ///
  /// A downloaded video outlives the server: one that vanished from the last
  /// response is re-added from its record's metadata snapshot, one returned
  /// with `isActive == false` is kept rather than dropped, and both are
  /// flagged so the card can say "No longer available". An inactive video
  /// with no download record stays hidden, as before.
  VideosLoaded _loaded(
    String subjectId, {
    bool isRefreshing = false,
    bool isOffline = false,
  }) {
    final unavailable = <String>{};
    final serverIds = <String>{};

    for (final video in _videos) {
      serverIds.add(video.id);
      if (!video.isActive && _isDownloaded(video.id)) unavailable.add(video.id);
    }

    final orphans = <Video>[];
    for (final entry in _downloads.entries) {
      if (serverIds.contains(entry.key)) continue;
      if (!entry.value.isDownloaded) continue;
      final snapshot = entry.value.video;
      // No snapshot (a record written before this field existed) means there
      // is nothing to render, and a snapshot from another subject belongs on
      // that subject's tab.
      if (snapshot == null || snapshot.subjectId != subjectId) continue;
      unavailable.add(entry.key);
      orphans.add(snapshot);
    }

    return VideosLoaded(
      subjectId: subjectId,
      groups: VideoChapterGroup.fromVideos(
        orphans.isEmpty ? _videos : [..._videos, ...orphans],
        keepInactiveIds: unavailable,
      ),
      downloads: _downloads,
      unavailableVideoIds: unavailable,
      isRefreshing: isRefreshing,
      isOffline: isOffline,
    );
  }

  bool _isDownloaded(String videoId) =>
      _downloads[videoId]?.isDownloaded ?? false;

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
