import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../../../notes/domain/entities/note.dart';
import 'year_selection_screen.dart';

class YearChapterSelectionScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final int duration;
  final String? region;

  const YearChapterSelectionScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.duration,
    this.region,
  });

  @override
  State<YearChapterSelectionScreen> createState() =>
      _YearChapterSelectionScreenState();
}

class _YearChapterSelectionScreenState extends State<YearChapterSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotesCubit _notesCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notesCubit = getIt<NotesCubit>();
    _notesCubit.loadNotes(widget.subjectName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subjectName,
          style: displayStyle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.quiz_outlined),
              text: 'Exam',
            ),
            Tab(
              icon: Icon(Icons.note_outlined),
              text: 'Note',
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Exam Tab - existing year selection content
          YearSelectionContent(
            subjectId: widget.subjectId,
            duration: widget.duration,
            region: widget.region,
          ),

          // Note Tab - notes content for this subject
          BlocProvider.value(
            value: _notesCubit,
            child: NotesTabContent(
              subjectId: widget.subjectId,
              subjectName: widget.subjectName,
            ),
          ),
        ],
      ),
    );
  }
}

class YearSelectionContent extends StatelessWidget {
  final String subjectId;
  final int duration;
  final String? region;

  const YearSelectionContent({
    super.key,
    required this.subjectId,
    required this.duration,
    this.region,
  });

  @override
  Widget build(BuildContext context) {
    return YearSelectionScreen(
      subjectId: subjectId,
      duration: duration,
      region: region,
    );
  }
}

class NotesTabContent extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const NotesTabContent({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        if (state is NotesLoading) {
          return _buildLoadingScreen(context);
        } else if (state is NotesLoaded) {
          return _buildNotesContent(context, state);
        } else if (state is NotesError) {
          return _buildErrorScreen(context, state.message);
        }
        return _buildLoadingScreen(context);
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
                      context.read<NotesCubit>().loadNotes(subjectName),
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

  Widget _buildNotesContent(BuildContext context, NotesLoaded state) {
    // Filter notes for the current subject
    final subjectNotes = state.subjects
        .expand((subject) => subject.chapters)
        .expand((chapter) => chapter.notes)
        .where((note) => true)
        .toList();

    if (subjectNotes.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group notes by chapter for this subject
    final Map<String, List<Note>> notesByChapter = {};
    for (final note in subjectNotes) {
      if (!notesByChapter.containsKey(note.chapterName)) {
        notesByChapter[note.chapterName] = [];
      }
      notesByChapter[note.chapterName]!.add(note);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesByChapter.keys.length,
      itemBuilder: (context, index) {
        final chapterName = notesByChapter.keys.elementAt(index);
        final chapterNotes = notesByChapter[chapterName]!;

        return _buildChapterSection(context, chapterName, chapterNotes);
      },
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
            color: Theme.of(context).primaryColor,
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
            'No notes available for $subjectName',
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
}
