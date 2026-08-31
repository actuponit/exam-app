import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../../../videos/presentation/cubit/videos_cubit.dart';
import '../../../videos/presentation/widgets/videos_tab_content.dart';
import '../widgets/notes_tab_content.dart';
import 'year_selection_screen.dart';

class YearChapterSelectionScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final int duration;
  final String? region;
  /// Real numeric subject id, used only for the videos endpoint — [subjectId]
  /// is actually the subject name (quiz/note features key off the name).
  /// Falls back to [subjectId] when unavailable (older cached subjects).
  final String? videoSubjectId;

  const YearChapterSelectionScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.duration,
    this.region,
    this.videoSubjectId,
  });

  @override
  State<YearChapterSelectionScreen> createState() =>
      _YearChapterSelectionScreenState();
}

class _YearChapterSelectionScreenState extends State<YearChapterSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotesCubit _notesCubit;
  late VideosCubit _videosCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);
    _notesCubit = getIt<NotesCubit>();
    _notesCubit.loadNotes(widget.subjectName);
    _videosCubit = getIt<VideosCubit>();
    _videosCubit.loadVideos(widget.videoSubjectId ?? widget.subjectId);
  }

  static const _videosTabIndex = 2;

  void _onTabChanged() {
    // Rebuild so the app-bar refresh icon follows the selected tab.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _videosCubit.close();
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
        actions: [
          // Only the Videos tab has a refresh action; Exam and Note unchanged.
          if (_tabController.index == _videosTabIndex)
            BlocBuilder<VideosCubit, VideosState>(
              bloc: _videosCubit,
              builder: (context, state) {
                final busy = state is VideosLoading ||
                    (state is VideosLoaded && state.isRefreshing);
                return _RefreshIconButton(
                  spinning: busy,
                  onPressed: busy ? null : _videosCubit.refresh,
                );
              },
            ),
        ],
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
            Tab(
              icon: Icon(Icons.play_circle_outline),
              text: 'Videos',
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

          // Videos Tab - subject's lesson videos
          BlocProvider.value(
            value: _videosCubit,
            child: VideosTabContent(
              subjectId: widget.videoSubjectId ?? widget.subjectId,
              subjectName: widget.subjectName,
            ),
          ),
        ],
      ),
    );
  }
}

/// App-bar refresh icon that rotates continuously while [spinning].
class _RefreshIconButton extends StatefulWidget {
  final bool spinning;
  final VoidCallback? onPressed;

  const _RefreshIconButton({required this.spinning, this.onPressed});

  @override
  State<_RefreshIconButton> createState() => _RefreshIconButtonState();
}

class _RefreshIconButtonState extends State<_RefreshIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _controller.repeat();
  }

  @override
  void didUpdateWidget(_RefreshIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning == oldWidget.spinning) return;
    if (widget.spinning) {
      _controller.repeat();
    } else {
      // Finish the current turn so the icon settles upright.
      _controller.animateTo(1.0).then((_) {
        if (mounted) _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: IconButton(
        tooltip: 'Refresh videos',
        icon: const Icon(Icons.refresh, color: Colors.white),
        onPressed: widget.onPressed,
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
