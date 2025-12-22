import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/core/theme_cubit.dart';
import 'package:exam_app/features/quiz/presentation/widgets/markdown_latex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:no_screenshot/no_screenshot.dart';
// import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme.dart';
import '../cubit/notes_cubit.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late NotesCubit _notesCubit;
  final ScrollController _scrollController = ScrollController();

  final _noScreenshot = NoScreenshot.instance;

  void stopScreenshotListening() async {
    await _noScreenshot.stopScreenshotListening();
  }

  void startScreenshot() async {
    await _noScreenshot.screenshotOn();
  }

  Future<void> startScreenshotListening() async {
    await _noScreenshot.startScreenshotListening();
  }

  void listenForScreenshot() {
    _noScreenshot.screenshotStream.listen((value) {
      if (value.wasScreenshotTaken && mounted) {
        AppSnackBar.warning(
          context: context,
          message: 'Screenshots are not allowed on this page',
        );
      }
    });
  }

  void _startScreenshotListening() async {
    await _noScreenshot.screenshotOff();
    await startScreenshotListening();
    listenForScreenshot();
  }

  @override
  void initState() {
    super.initState();
    _startScreenshotListening();
    _notesCubit = getIt<NotesCubit>();
    _notesCubit.loadNoteDetail(widget.noteId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    stopScreenshotListening();
    startScreenshot();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notesCubit,
      child: Scaffold(
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is NoteDetailLoading) {
              return _buildLoadingScreen();
            } else if (state is NoteDetailLoaded) {
              return _buildNoteContent(state.note);
            } else if (state is NoteDetailError) {
              return _buildErrorScreen(state.message);
            }
            return _buildLoadingScreen();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
      ),
      body: Center(
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
              'Loading note...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
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
                          text: 'Note not found\n',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                        TextSpan(
                          text: message,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Go Back',
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
      ),
    );
  }

  Widget _buildNoteContent(note) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar with title and actions
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          leading: SizedBox.shrink(),
          actions: [
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                final brightness = Theme.of(context).brightness;
                final isDarkMode = state.themeMode == ThemeMode.dark ||
                    (state.themeMode == ThemeMode.system &&
                        brightness == Brightness.dark);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.8),
                                ]
                              : [
                                  Theme.of(context).primaryColor,
                                  Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.85),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          isDarkMode
                              ? Icons.wb_sunny_rounded
                              : Icons.nights_stay_rounded,
                          key: ValueKey(isDarkMode),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              note.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80), // Space for app bar
                    // if (note.isLocked) ...[
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 8,
                    //       vertical: 4,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.orange.withOpacity(0.2),
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         const Icon(
                    //           Icons.lock_outline,
                    //           size: 16,
                    //           color: Colors.white,
                    //         ),
                    //         const SizedBox(width: 4),
                    //         Text(
                    //           'Premium Content',
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .bodySmall
                    //               ?.copyWith(
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   const SizedBox(height: 8),
                    // ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Note metadata
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Subject badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note.subjectName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Grade badge
                    if (note.grade > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Grade ${note.grade}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Chapter info
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.chapterName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),

                // Tags
                // if (note.tags.isNotEmpty) ...[
                //   const SizedBox(height: 12),
                //   Wrap(
                //     spacing: 8,
                //     runSpacing: 4,
                //     children: note.tags.map((tag) {
                //       return Container(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 8,
                //           vertical: 4,
                //         ),
                //         decoration: BoxDecoration(
                //           color: Theme.of(context)
                //               .colorScheme
                //               .outline
                //               .withOpacity(0.1),
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         child: Text(
                //           '#$tag',
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodySmall
                //               ?.copyWith(
                //                 color: Theme.of(context).colorScheme.outline,
                //                 fontWeight: FontWeight.w500,
                //               ),
                //         ),
                //       );
                //     }).toList(),
                //   ),
                // ],
              ],
            ),
          ),
        ),

        // Note content
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              child: MarkdownLatexWidget(
                data: note.content,
                shrinkWrap: true,
              ),
            ),
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  // Widget _buildLockedContent() {
  //   return Container(
  //     padding: const EdgeInsets.all(32),
  //     child: Column(
  //       children: [
  //         Icon(
  //           Icons.lock_outline,
  //           size: 64,
  //           color: Colors.orange.shade600,
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           'Premium Content',
  //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.w600,
  //                 color: Theme.of(context).colorScheme.onSurface,
  //               ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'This note contains premium content. Upgrade your subscription to access all notes and features.',
  //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                 color:
  //                     Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
  //                 height: 1.5,
  //               ),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 24),
  //         ElevatedButton.icon(
  //           onPressed: () {
  //             // Navigate to subscription/payment screen
  //             context.push('/transaction-verification');
  //           },
  //           icon: const Icon(Icons.upgrade, color: Colors.white),
  //           label: const Text(
  //             'Upgrade Now',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //           style: ElevatedButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(
  //               horizontal: 24,
  //               vertical: 12,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
