import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../data/services/video_download_service.dart';
import '../../domain/entities/video_download.dart';
import '../../domain/repositories/videos_repository.dart';

/// Full-screen playback of a downloaded video, straight off the local file so
/// it works with no network at all.
///
/// The screen owns three side effects for as long as it is on top: the screen
/// is kept awake (`allowedScreenSleep: false`), screenshots and screen
/// recording are blocked exactly as on the question and note-detail screens,
/// and the playback position is written back to the Hive download record so
/// the next open resumes.
class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  /// Below this, resuming is obviously right and asking would be noise. Above
  /// it, the student is far enough in that starting over has to be a choice.
  static const _resumePromptThreshold = Duration(seconds: 30);

  /// How often the position is written back while playing. Small enough that
  /// a kill loses at most this much, large enough not to hammer Hive.
  static const _saveInterval = Duration(seconds: 5);

  /// A position this close to the end means the lecture was finished; storing
  /// it would resume the next open at the credits.
  static const _endOfVideoSlack = Duration(seconds: 5);

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  final _repository = getIt<VideosRepository>();
  final _downloadService = getIt<VideoDownloadService>();
  final _noScreenshot = NoScreenshot.instance;
  StreamSubscription<dynamic>? _screenshotSub;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Timer? _saveTimer;

  String? _title;
  String? _error;

  /// Last value handed to Hive, so an idle player does not rewrite the same
  /// second every five seconds.
  int? _savedSeconds;

  /// Previous play/pause state, so a transition into "paused" can be caught
  /// and the position written at that moment.
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _blockScreenshots();
    _load();
  }

  Future<void> _blockScreenshots() async {
    await _noScreenshot.screenshotOff();
    await _noScreenshot.startScreenshotListening();
    _screenshotSub = _noScreenshot.screenshotStream.listen((value) {
      if (value.wasScreenshotTaken && mounted) {
        AppSnackBar.warning(
          context: context,
          message: 'Screenshots are not allowed on this page',
        );
      }
    });
  }

  Future<void> _load() async {
    VideoDownload? download;
    try {
      download = await _repository.getDownload(widget.videoId);
    } catch (_) {
      download = null;
    }
    if (!mounted) return;

    if (download == null || !File(download.localPath).existsSync()) {
      // Reachable when the file vanished after the list was already on screen.
      // Sweeping now drops the record and re-publishes the status, so the card
      // behind this screen offers a download instead of reopening this error.
      await _downloadService.reconcile();
      if (!mounted) return;
      setState(() => _error = 'This video is no longer on your device. '
          'Go back and download it again.');
      return;
    }

    final controller = VideoPlayerController.file(File(download.localPath));
    try {
      await controller.initialize();
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() => _error = 'This video could not be played. '
          'Delete it from the list and download it again.');
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }

    final start = await _resolveStart(controller, download);
    if (!mounted) {
      await controller.dispose();
      return;
    }

    _savedSeconds = start.inSeconds;
    controller.addListener(_onPlaybackChanged);
    _saveTimer = Timer.periodic(_saveInterval, (_) {
      if (controller.value.isPlaying) unawaited(_savePosition());
    });

    setState(() {
      _title = download?.video?.title;
      _videoController = controller;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        startAt: start,
        // The whole point of the feature: a 40-minute lecture must not be
        // interrupted by the screen dimming.
        allowedScreenSleep: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: _speeds,
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor,
        ),
      );
    });
  }

  /// Where playback should begin: the stored position, zero, or whichever the
  /// student picks when they were far enough in for the question to matter.
  Future<Duration> _resolveStart(
    VideoPlayerController controller,
    VideoDownload download,
  ) async {
    final stored = Duration(seconds: download.resumePositionSeconds);
    final duration = controller.value.duration;
    if (stored <= Duration.zero) return Duration.zero;
    // A stored position past the end (or past a file that was re-downloaded
    // shorter) is meaningless.
    if (duration > Duration.zero && stored >= duration - _endOfVideoSlack) {
      return Duration.zero;
    }
    if (stored <= _resumePromptThreshold) return stored;

    final resume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Resume playback?'),
        content: Text('You stopped at ${_formatPosition(stored)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Start over'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
    return resume == true ? stored : Duration.zero;
  }

  void _onPlaybackChanged() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final playing = controller.value.isPlaying;
    if (_wasPlaying && !playing) unawaited(_savePosition());
    _wasPlaying = playing;
  }

  /// Reads the position synchronously and then writes it, so this stays
  /// correct when called from [dispose] just before the controller goes away.
  Future<void> _savePosition() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final position = controller.value.position;
    final duration = controller.value.duration;
    final finished =
        duration > Duration.zero && position >= duration - _endOfVideoSlack;
    final seconds = finished ? 0 : position.inSeconds;
    if (seconds == _savedSeconds) return;
    _savedSeconds = seconds;
    try {
      await _repository.saveResumePosition(widget.videoId, seconds);
    } catch (_) {
      // Losing a resume position is not worth interrupting playback over.
    }
  }

  static String _formatPosition(Duration position) {
    final hours = position.inHours;
    final minutes = position.inMinutes.remainder(60);
    final seconds = position.inSeconds.remainder(60);
    final mm = hours > 0 ? minutes.toString().padLeft(2, '0') : '$minutes';
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Fired before the controller is torn down; the position is read
    // synchronously inside, so the pending write still sees the real value.
    unawaited(_savePosition());
    _videoController?.removeListener(_onPlaybackChanged);
    _chewieController?.dispose();
    _videoController?.dispose();
    unawaited(_screenshotSub?.cancel());
    unawaited(_noScreenshot.stopScreenshotListening());
    unawaited(_noScreenshot.screenshotOn());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: Center(child: _body())),
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Back',
                onPressed: () => context.pop(),
              ),
            ),
            if (_title != null)
              Positioned(
                top: 12,
                left: 56,
                right: 16,
                child: Text(
                  _title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    final error = _error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 56),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    final chewieController = _chewieController;
    if (chewieController == null) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    return Chewie(controller: chewieController);
  }
}
