import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/video.dart';
import '../../domain/entities/video_download_status.dart';
import '../utils/video_format.dart';

class VideoCard extends StatelessWidget {
  final Video video;

  /// Download state for this video; drives the trailing control and the
  /// meaning of a tap.
  final VideoDownloadStatus status;
  final VoidCallback? onTap;

  /// Delete affordance. Wired only for a saved download; every other state
  /// passes `null` so a long-press does nothing at all.
  final VoidCallback? onLongPress;

  const VideoCard({
    super.key,
    required this.video,
    this.status = VideoDownloadStatus.none,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = video.locked;
    final duration = video.durationSeconds;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: locked ? null : onTap,
          onLongPress: locked ? null : onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Thumbnail(url: video.thumbnailUrl, dimmed: locked),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.chapterName ?? VideoChapterGroup.generalLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          formatVideoSize(video.fileSizeBytes),
                          if (duration != null) formatVideoDuration(duration),
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (locked)
                  Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  )
                else
                  _DownloadControl(status: status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Trailing control for a non-locked card. One tap target: the icon only
/// signals what a tap will do.
class _DownloadControl extends StatelessWidget {
  final VideoDownloadStatus status;

  const _DownloadControl({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    switch (status.state) {
      case VideoDownloadState.none:
        return Icon(Icons.download_outlined, color: theme.primaryColor);

      case VideoDownloadState.queued:
        return _label(theme, 'Waiting', muted);

      case VideoDownloadState.running:
        // The ring is the whole control unless the server let us pause: then
        // a pause glyph beside it says the tap now opens a choice.
        if (!status.canPause) return _ProgressRing(progress: status.progress);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_outline, size: 20, color: muted),
            const SizedBox(width: 6),
            _ProgressRing(progress: status.progress),
          ],
        );

      case VideoDownloadState.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 20,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 4),
            _label(theme, 'Paused', muted),
          ],
        );

      case VideoDownloadState.verifying:
        return _label(theme, 'Verifying', muted);

      case VideoDownloadState.failed:
        // Reason on top, Retry under it: the card names what went wrong and
        // what a tap will do about it.
        final failure = status.failure ?? VideoDownloadFailure.failed;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 4),
                _label(theme, failure.label, theme.colorScheme.error),
              ],
            ),
            const SizedBox(height: 2),
            _label(theme, 'Retry', theme.colorScheme.error),
          ],
        );

      case VideoDownloadState.downloaded:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill, size: 22, color: theme.primaryColor),
            const SizedBox(width: 4),
            _label(theme, 'Saved', muted),
          ],
        );
    }
  }

  Widget _label(ThemeData theme, String text, Color color) => Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      );
}

/// Progress ring with the percentage in the middle, sized to sit in the same
/// slot as the download icon.
class _ProgressRing extends StatelessWidget {
  final double progress;

  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).clamp(0, 100).round();
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              // Indeterminate until the first byte counts arrive.
              value: progress > 0 ? progress : null,
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              backgroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.12),
            ),
          ),
          Text(
            '$percent',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;
  final bool dimmed;

  const _Thumbnail({required this.url, required this.dimmed});

  static const double _width = 96;
  static const double _height = 54;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      width: _width,
      height: _height,
      color: theme.primaryColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.play_circle_outline,
        color: theme.primaryColor,
      ),
    );

    Widget image = url == null || url!.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url!,
            width: _width,
            height: _height,
            fit: BoxFit.cover,
            placeholder: (_, __) => placeholder,
            errorWidget: (_, __, ___) => placeholder,
          );

    if (dimmed) {
      image = Stack(
        children: [
          Opacity(opacity: 0.4, child: image),
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.lock,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(width: _width, height: _height, child: image),
    );
  }
}
