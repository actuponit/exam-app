import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme.dart';
import '../../domain/models/filter_type.dart';
import '../../domain/services/filter_preferences.dart';
import '../bloc/question_state.dart';

class YearChapterSelectionScreen extends StatefulWidget {
  final QuestionMode mode;

  const YearChapterSelectionScreen({
    super.key,
    required this.mode,
  });

  @override
  State<YearChapterSelectionScreen> createState() =>
      _YearChapterSelectionScreenState();
}

class _YearChapterSelectionScreenState extends State<YearChapterSelectionScreen> {
  late QuestionFilterType _selectedFilterType;
  final List<String> _chapters = [
    'Mechanics',
    'Thermodynamics',
    'Waves and Optics',
    'Electricity and Magnetism',
    'Modern Physics',
  ];
  final List<int> _years = List.generate(5, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    _selectedFilterType =
        context.read<FilterPreferences>().getLastUsedFilterType();
  }

  void _onFilterTypeChanged(QuestionFilterType type) {
    setState(() {
      _selectedFilterType = type;
    });
    context.read<FilterPreferences>().saveFilterType(type);
  }

  void _onItemSelected(dynamic value) {
    final filter = _selectedFilterType == QuestionFilterType.byYear
        ? QuestionFilter.year(value as int)
        : QuestionFilter.chapter(value as String);

    context.go(
      '/questions/${filter.type == QuestionFilterType.byChapter ? filter.value : ""}/${filter.type == QuestionFilterType.byYear ? filter.value : ""}/${widget.mode == QuestionMode.practice ? "practice" : "quiz"}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == QuestionMode.practice
              ? 'Practice Questions'
              : 'Start Quiz',
          style: displayStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildFilterToggle(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedFilterType == QuestionFilterType.byYear
                  ? _buildYearGrid()
                  : _buildChapterList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<QuestionFilterType>(
        segments: QuestionFilterType.values
            .map(
              (type) => ButtonSegment<QuestionFilterType>(
                value: type,
                label: Text(type.label),
                icon: Icon(
                  type == QuestionFilterType.byYear
                      ? Icons.calendar_today
                      : Icons.book,
                ),
              ),
            )
            .toList(),
        selected: {_selectedFilterType},
        onSelectionChanged: (Set<QuestionFilterType> selected) {
          _onFilterTypeChanged(selected.first);
        },
      ),
    );
  }

  Widget _buildYearGrid() {
    return GridView.builder(
      key: const ValueKey('years_grid'),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _years.length,
      itemBuilder: (context, index) {
        final year = _years[index];
        return _buildSelectionCard(
          title: year.toString(),
          subtitle: 'Past Year Questions',
          icon: Icons.calendar_today,
          onTap: () => _onItemSelected(year),
        );
      },
    );
  }

  Widget _buildChapterList() {
    return ListView.builder(
      key: const ValueKey('chapters_list'),
      padding: const EdgeInsets.all(16),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSelectionCard(
            title: chapter,
            subtitle: 'Chapter Questions',
            icon: Icons.book,
            onTap: () => _onItemSelected(chapter),
          ),
        );
      },
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: titleStyle.copyWith(
                  fontSize: 20,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: bodyStyle.copyWith(
                  color: textLight,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 