import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/video.dart';
import '../utils/video_format.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
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
                  Icon(
                    Icons.download_outlined,
                    color: theme.primaryColor,
                  ),
              ],
            ),
          ),
        ),
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
