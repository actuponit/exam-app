import 'package:exam_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class YearSelectionScreen extends StatefulWidget {
  final Map<String, List<int>> chapterYears = {
    'All': List.generate(10, (index) => 2015 + index),
    'Unit 1: Mechanics': [2015, 2016, 2017, 2019, 2020],
    'Unit 2: Electricity': [2016, 2017, 2018, 2021, 2022],
    'Unit 3: Waves & Optics': [2018, 2019, 2020, 2022, 2023],
    'Unit 4: Modern Physics': [2020, 2021, 2022, 2023, 2024],
  };

  YearSelectionScreen({super.key});

  @override
  State<YearSelectionScreen> createState() => _YearSelectionScreenState();
}

class _YearSelectionScreenState extends State<YearSelectionScreen> {
  String _selectedChapter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Chapter', style: displayStyle.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Chapter',
                  style: titleStyle.copyWith(
                    fontSize: 16,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cardRadius),
                  ),
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.chapterYears.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final chapter = widget.chapterYears.keys.elementAt(index);
                      final isSelected = chapter == _selectedChapter;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(chapter),
                        labelStyle: bodyStyle.copyWith(
                          color: isSelected ? Colors.white : textDark,
                          fontSize: 14,
                        ),
                        backgroundColor: Colors.grey[100],
                        selectedColor: primaryColor,
                        checkmarkColor: Colors.white,
                        onSelected: (selected) {
                          setState(() => _selectedChapter = chapter);
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildYearList(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearList() {
    final years = widget.chapterYears[_selectedChapter] ?? [];
    if (years.isEmpty) {
      return Center(
        child: Text(
          'No questions available for this chapter',
          style: bodyStyle.copyWith(color: textLight),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: years.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => YearListItem(
        year: years[index],
        chapter: _selectedChapter,
        questionCount: _selectedChapter == 'All' ? 35 : 9,
      ),
    );
  }
}

class YearListItem extends StatelessWidget {
  final int year;
  final String chapter;
  final int questionCount;

  const YearListItem({
    required this.year,
    required this.chapter,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  year.toString(),
                  style: titleStyle.copyWith(
                    color: primaryColor,
                    fontSize: 18,
                  ),
                ),
                if (chapter != 'All')
                  Text(
                    'Unit',
                    style: bodyStyle.copyWith(
                      color: textLight,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          title: Text(
            chapter == 'All' 
                ? 'EUEE $year Entrance Exam'
                : '$chapter ($year)',
            style: titleStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '$questionCount Questions • ${questionCount >= 50 ? "2h 30m" : "1h"}',
            style: bodyStyle.copyWith(
              color: textLight,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: textLight,
          ),
          onTap: () => _showModeSelectionDialog(context),
        ),
      ),
    );
  }

  Future<void> _showModeSelectionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Mode',
                  style: displayStyle.copyWith(
                    fontSize: 24,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to take this exam',
                  style: bodyStyle.copyWith(
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 24),
                _ModeButton(
                  icon: Icons.book_outlined,
                  title: 'Practice Mode',
                  description: 'Review answers as you go',
                  onTap: () {
                    context.pop();
                    context.push('/questions', extra: {'mode': 'practice'});
                  },
                ),
                const SizedBox(height: 16),
                _ModeButton(
                  icon: Icons.timer_outlined,
                  title: 'Quiz Mode',
                  description: 'Timed exam with final review',
                  onTap: () {
                    context.pop();
                    context.push('/questions', extra: {'mode': 'quiz'});
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
                    style: titleStyle.copyWith(
                      color: textLight,
                      fontSize: 16,
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
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: bodyStyle.copyWith(
                        color: textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 