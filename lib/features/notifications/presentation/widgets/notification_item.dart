import 'package:exam_app/features/notifications/domain/entities/notification.dart';
import 'package:exam_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class NotificationItem extends StatelessWidget {
  final Notification notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.imageUrl != null &&
              notification.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: notification.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat.yMMMd()
                          .add_jm()
                          .format(notification.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.body,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionButton(
                      icon: Icons.thumb_up_outlined,
                      label: '${notification.likeCount}',
                      onTap: () {
                        context
                            .read<NotificationBloc>()
                            .add(LikeNotificationEvent(notification.id));
                      },
                    ),
                    _ActionButton(
                      icon: Icons.thumb_down_outlined,
                      label: '${notification.dislikeCount}',
                      onTap: () {
                        context
                            .read<NotificationBloc>()
                            .add(DislikeNotificationEvent(notification.id));
                      },
                    ),
                    _ActionButton(
                      icon: Icons.comment_outlined,
                      label: '${notification.commentCount}',
                      onTap: () {
                        _showCommentDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your comment'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<NotificationBloc>().add(
                      CommentNotificationEvent(
                          notification.id, controller.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
