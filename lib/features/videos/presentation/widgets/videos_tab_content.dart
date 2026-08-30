import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/video_download_status.dart';
import '../cubit/videos_cubit.dart';
import 'video_card.dart';
import 'video_chapter_header.dart';

class VideosTabContent extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const VideosTabContent({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        if (state is VideosError) {
          return _ErrorCard(
            message: state.message,
            onRetry: () => context.read<VideosCubit>().loadVideos(subjectId),
          );
        }
        if (state is VideosLoaded) {
          final cubit = context.read<VideosCubit>();
          return Column(
            children: [
              if (state.isOffline) const _OfflineNote(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: state.isEmpty
                      ? _EmptyState(subjectName: subjectName)
                      : _VideosList(
                          groups: state.groups,
                          downloads: state.downloads,
                        ),
                ),
              ),
            ],
          );
        }
        return const _LoadingScreen();
      },
    );
  }
}

/// Single-line note shown under the app bar when the last refresh failed and
/// the list on screen came from cache.
class _OfflineNote extends StatelessWidget {
  const _OfflineNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Offline — showing saved list',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideosList extends StatelessWidget {
  final List<VideoChapterGroup> groups;
  final Map<String, VideoDownloadStatus> downloads;

  const _VideosList({required this.groups, required this.downloads});

  /// One tap target per card. The cubit decides start / cancel / retry; a
  /// non-null answer is a refusal to surface (no free space).
  Future<void> _onTap(BuildContext context, Video video) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = await context.read<VideosCubit>().onVideoTapped(video);
    if (message == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Always scrollable so pull-to-refresh works on short lists too.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VideoChapterHeader(
                chapterName: group.displayName,
                videoCount: group.videos.length,
              ),
              for (final video in group.videos)
                VideoCard(
                  video: video,
                  status:
                      downloads[video.id] ?? VideoDownloadStatus.none,
                  onTap: () => _onTap(context, video),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading videos...',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 20),
                SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Something went wrong\n',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String subjectName;

  const _EmptyState({required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Scrollable so the enclosing RefreshIndicator can be pulled.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: _emptyBody(theme),
        ),
      ),
    );
  }

  Widget _emptyBody(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No videos available for $subjectName',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Videos will be added soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
