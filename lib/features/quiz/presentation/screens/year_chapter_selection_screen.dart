import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../widgets/notes_tab_content.dart';
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
