import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_app/core/router/app_router.dart';

class VideoWalkthroughScreen extends StatefulWidget {
  const VideoWalkthroughScreen({super.key});

  @override
  State<VideoWalkthroughScreen> createState() => _VideoWalkthroughScreenState();
}

class _VideoWalkthroughScreenState extends State<VideoWalkthroughScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Timer? _hideSkipTimer;
  bool _showSkipButton = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _startHideSkipTimer();
  }

  void _startHideSkipTimer() {
    _hideSkipTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showSkipButton = false;
        });
      }
    });
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // Check if video file exists
      const String videoPath = 'assets/videos/walkthrough.mp4';

      // Try to load the video
      _videoPlayerController = VideoPlayerController.asset(videoPath);

      await _videoPlayerController.initialize();

      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: false,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            materialProgressColors: ChewieProgressColors(
              playedColor: Theme.of(context).colorScheme.primary,
              handleColor: Theme.of(context).colorScheme.primary,
              backgroundColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              bufferedColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            placeholder: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            autoInitialize: true,
            errorBuilder: (context, errorMessage) {
              return _buildErrorState(errorMessage);
            },
          );
          _isLoading = false;
        });

        // Listen for video completion
        _videoPlayerController.addListener(() {
          if (_videoPlayerController.value.position >=
              _videoPlayerController.value.duration) {
            _navigateToRegistration();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage =
              'No walkthrough video found. Click "Continue" to proceed with registration.';
        });
      }
    }
  }

  void _navigateToRegistration() {
    context.go(RoutePaths.signUp);
  }

  void _skipVideo() {
    _hideSkipTimer?.cancel();
    _navigateToRegistration();
  }

  @override
  void dispose() {
    _hideSkipTimer?.cancel();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player or Loading/Error State
            _buildVideoContent(),

            // Skip Button
            if (_showSkipButton)
              Positioned(
                top: 20,
                right: 20,
                child: AnimatedOpacity(
                  opacity: _showSkipButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildSkipButton(),
                ),
              ),

            // Back Button
            Positioned(
              top: 20,
              left: 20,
              child: _buildBackButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState(_errorMessage);
    }

    return _buildVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _chewieController != null
          ? Chewie(controller: _chewieController!)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading walkthrough video...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Exam App!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                message ?? 'Unable to load walkthrough video',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _skipVideo,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.skip_next,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Skip',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => context.go(RoutePaths.welcome),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _navigateToRegistration,
          child: Center(
            child: Text(
              'Continue to Registration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
