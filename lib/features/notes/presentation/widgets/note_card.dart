import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and lock icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subject and chapter info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      note.subjectName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.chapterName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content preview
              Text(
                _getContentPreview(note.content),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      height: 1.4,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer with grade and tags
              Row(
                children: [
                  // Grade badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Grade ${note.grade}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tags
                  const Spacer(),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getContentPreview(String content) {
    // Remove markdown formatting for preview
    String preview = content
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // Remove headers
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Remove bold
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1') // Remove italic
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1') // Remove code
        .replaceAll(RegExp(r'\\\[.*?\\\]', dotAll: true),
            '[Formula]') // Replace LaTeX blocks
        .replaceAll(RegExp(r'\\\(.*?\\\)', dotAll: true),
            '[Formula]') // Replace LaTeX inline
        .replaceAll(RegExp(r'\n\s*\n'), ' ') // Replace multiple newlines
        .replaceAll('\n', ' ') // Replace single newlines
        .trim();

    return preview.isEmpty ? 'No preview available' : preview;
  }
}
