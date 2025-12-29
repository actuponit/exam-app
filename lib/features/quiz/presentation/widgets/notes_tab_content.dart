import 'dart:async';

import 'package:exam_app/features/quiz/utils/sort_with_chapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';

class NotesTabContent extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const NotesTabContent({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<NotesTabContent> createState() => _NotesTabContentState();
}

class _NotesTabContentState extends State<NotesTabContent> {
  late final NotesCubit _notesCubit;
  StreamSubscription<NotesState>? _subscription;

  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  List<String> _availableLanguages = [];
  String? _languageFilter; // null = all languages
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _notesCubit = context.read<NotesCubit>();
    _subscription = _notesCubit.stream.listen(_onStateChanged);
    _onStateChanged(
        _notesCubit.state); // hydrate from current state if available
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onStateChanged(NotesState state) {
    if (!mounted) return;

    if (state is NotesLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      return;
    }

    if (state is NotesError) {
      setState(() {
        _isLoading = false;
        _error = state.message;
        _allNotes = [];
        _filteredNotes = [];
        _availableLanguages = [];
      });
      return;
    }

    if (state is NotesLoaded) {
      final notes = state.subjects
          .expand((subject) => subject.chapters)
          .expand((chapter) => chapter.notes)
          .toList()
        ..sort((a, b) => sortChapters(a.chapterName, b.chapterName));

      final languages = _extractLanguages(notes);
      final filtered = _applyLanguageFilter(notes, languages);

      setState(() {
        _isLoading = false;
        _error = null;
        _allNotes = notes;
        _availableLanguages = languages;
        _filteredNotes = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen(context);
    }

    if (_error != null) {
      return _buildErrorScreen(context, _error!);
    }

    if (_filteredNotes.isEmpty) {
      return _buildEmptyState(context);
    }

    final notesByChapter = _groupNotesByChapter(_filteredNotes);
    final showFilter = _availableLanguages.length > 1;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesByChapter.keys.length + (showFilter ? 1 : 0),
      itemBuilder: (context, index) {
        if (showFilter && index == 0) {
          return _buildLanguageFilter(context, _availableLanguages);
        }

        final adjustedIndex = showFilter ? index - 1 : index;
        final chapterName = notesByChapter.keys.elementAt(adjustedIndex);
        final chapterNotes = notesByChapter[chapterName]!;

        return _buildChapterSection(context, chapterName, chapterNotes);
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading notes...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
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
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 20),
                SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Something went wrong\n',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      TextSpan(
                        text: message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<NotesCubit>().loadNotes(widget.subjectName),
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

  Widget _buildLanguageFilter(BuildContext context, List<String> languages) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final chips = languages
        .map(
          (lang) => _LanguageChip(
            label: lang,
            selected: _languageFilter?.toLowerCase() == lang.toLowerCase(),
            onSelected: () => _updateLanguageFilter(lang),
          ),
        )
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filter by language',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
        ],
      ),
    );
  }

  Widget _buildChapterSection(
      BuildContext context, String chapterName, List<Note> notes) {
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
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          chapterName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        subtitle: Text(
          '${notes.length} ${notes.length == 1 ? 'note' : 'notes'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        children: notes.map((note) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.note_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                title: Text(
                  note.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                ),
                onTap: () {
                  context.push('/notes/detail/${note.id}');
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes available for ${widget.subjectName}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Notes will be added soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, List<Note>> _groupNotesByChapter(List<Note> notes) {
    final Map<String, List<Note>> notesByChapter = {};
    for (final note in notes) {
      notesByChapter.putIfAbsent(note.chapterName, () => []).add(note);
    }
    return notesByChapter;
  }

  List<String> _extractLanguages(List<Note> notes) {
    final langs = <String>{};
    for (final note in notes) {
      final language = note.language?.trim();
      if (language != null && language.isNotEmpty) {
        langs.add(_titleCase(language));
      }
    }
    return langs.toList()..sort();
  }

  List<Note> _applyLanguageFilter(
    List<Note> notes,
    List<String> availableLanguages,
  ) {
    if (_languageFilter == null || availableLanguages.isEmpty) {
      return notes;
    }

    final hasValidFilter = availableLanguages.any(
      (lang) => lang.toLowerCase() == _languageFilter!.toLowerCase(),
    );

    if (!hasValidFilter) return notes;

    final selected = _languageFilter!.toLowerCase();
    return notes
        .where((note) => (note.language ?? '').toLowerCase() == selected)
        .toList();
  }

  void _updateLanguageFilter(String? value) {
    setState(() {
      _languageFilter = value;
      _filteredNotes = _applyLanguageFilter(_allNotes, _availableLanguages);
    });
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary.withOpacity(0.12)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_outlined,
                size: 16,
                color: selected ? colorScheme.primary : colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
