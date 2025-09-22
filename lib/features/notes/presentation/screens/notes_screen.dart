import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/note.dart';
import '../cubit/notes_cubit.dart';
import '../widgets/note_card.dart';
import '../widgets/subject_notes_section.dart';

class NotesScreen extends StatefulWidget {
  final String subject;
  const NotesScreen({super.key, required this.subject});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotesCubit _notesCubit;

  @override
  void initState() {
    super.initState();
    _notesCubit = getIt<NotesCubit>();
    _notesCubit.loadNotes(widget.subject);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initTabController(List<int> grades) {
    _tabController = TabController(length: grades.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final grades = (_notesCubit.state as NotesLoaded).availableGrades;
        _notesCubit.changeGrade(grades[_tabController.index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notesCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Short Notes',
            style: displayStyle.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: NotesSearchDelegate(_notesCubit),
                );
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: BlocConsumer<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NotesLoaded && !this.mounted) {
              return;
            }
            if (state is NotesLoaded) {
              if (_tabController.length != state.availableGrades.length) {
                _initTabController(state.availableGrades);
              }
            }
          },
          builder: (context, state) {
            if (state is NotesLoading) {
              return _buildLoadingScreen();
            } else if (state is NotesLoaded) {
              if (!this.mounted) {
                _initTabController(state.availableGrades);
              }
              return _buildNotesContent(state);
            } else if (state is NotesError) {
              return _buildErrorScreen(state.message);
            } else if (state is NotesSearchLoaded) {
              return _buildSearchResults(state);
            } else if (state is NotesSearchLoading) {
              return _buildLoadingScreen();
            } else if (state is NotesSearchError) {
              return _buildErrorScreen(state.message);
            }
            return _buildLoadingScreen();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
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

  Widget _buildErrorScreen(String message) {
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
                  onPressed: () => _notesCubit.loadNotes(widget.subject),
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

  Widget _buildNotesContent(NotesLoaded state) {
    return Column(
      children: [
        // Tab bar
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: state.availableGrades
                .map((grade) => Tab(text: 'Grade $grade'))
                .toList(),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: state.availableGrades.map((grade) {
              final gradeSubjects = state.subjects
                  .where((subject) => subject.grade == grade)
                  .toList();

              if (gradeSubjects.isEmpty) {
                return _buildEmptyState('No notes available for Grade $grade');
              }

              return _buildGradeContent(gradeSubjects);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeContent(List<NoteSubject> subjects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return SubjectNotesSection(
          subject: subject,
          onNoteSelected: (note) {
            context.push('/notes/detail/${note.id}');
          },
        );
      },
    );
  }

  Widget _buildSearchResults(NotesSearchLoaded state) {
    if (state.searchResults.isEmpty) {
      return _buildEmptyState('No notes found for "${state.query}"');
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Text(
            '${state.searchResults.length} results for "${state.query}"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final note = state.searchResults[index];
              return NoteCard(
                note: note,
                onTap: () => context.push('/notes/detail/${note.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
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
            message,
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

class NotesSearchDelegate extends SearchDelegate<String> {
  final NotesCubit notesCubit;

  NotesSearchDelegate(this.notesCubit);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        notesCubit.clearSearch();
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Enter search terms to find notes'),
      );
    }

    notesCubit.searchNotes(query);

    return BlocBuilder<NotesCubit, NotesState>(
      bloc: notesCubit,
      builder: (context, state) {
        if (state is NotesSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NotesSearchLoaded) {
          if (state.searchResults.isEmpty) {
            return Center(
              child: Text('No results found for "$query"'),
            );
          }

          return ListView.builder(
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final note = state.searchResults[index];
              return NoteCard(
                note: note,
                onTap: () {
                  close(context, '');
                  context.push('/notes/detail/${note.id}');
                },
              );
            },
          );
        } else if (state is NotesSearchError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search notes...'),
      );
    }

    return buildResults(context);
  }
}
