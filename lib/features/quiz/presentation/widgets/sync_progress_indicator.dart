import 'package:flutter/material.dart';
import 'package:exam_app/features/quiz/domain/models/download_progress.dart';

class SyncProgressIndicator extends StatelessWidget {
  final DownloadProgress progress;
  final VoidCallback? onCancel;

  const SyncProgressIndicator({
    super.key,
    required this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPhaseIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPhaseTitle(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        progress.displayMessage,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (onCancel != null &&
                    progress.phase == SyncPhase.downloadingImages)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onCancel,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress.overallProgress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            LinearProgressIndicator(
              value: progress.overallProgress,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            if (progress.phase == SyncPhase.downloadingImages) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progress.imagesDownloaded}/${progress.imagesTotalCount} images',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (progress.imageDownloadsFailed > 0)
                    Text(
                      '${progress.imageDownloadsFailed} failed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (progress.phase) {
      case SyncPhase.fetchingQuestions:
        icon = Icons.cloud_download;
        color = Theme.of(context).colorScheme.primary;
        break;
      case SyncPhase.savingData:
        icon = Icons.save;
        color = Theme.of(context).colorScheme.primary;
        break;
      case SyncPhase.downloadingImages:
        icon = Icons.image;
        color = Theme.of(context).colorScheme.primary;
        break;
      case SyncPhase.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case SyncPhase.error:
        icon = Icons.error;
        color = Theme.of(context).colorScheme.error;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  String _getPhaseTitle() {
    switch (progress.phase) {
      case SyncPhase.fetchingQuestions:
        return 'Fetching Questions';
      case SyncPhase.savingData:
        return 'Saving Content';
      case SyncPhase.downloadingImages:
        return 'Downloading Images';
      case SyncPhase.completed:
        return 'Sync Complete';
      case SyncPhase.error:
        return 'Sync Error';
      default:
        return 'Syncing';
    }
  }
}
