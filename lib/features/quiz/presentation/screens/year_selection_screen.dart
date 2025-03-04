import 'package:exam_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class YearSelectionScreen extends StatelessWidget {
  final List<int> years = List.generate(10, (index) => 2015 + index);

  YearSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Year', style: displayStyle.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: years.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => YearListItem(
                  year: years[index],
                  isPopular: index == 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearListItem extends StatelessWidget {
  final int year;
  final bool isPopular;

  const YearListItem({required this.year, this.isPopular = false});

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
          color: isPopular ? primaryColor.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isPopular ? primaryColor : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isPopular ? primaryColor : secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Flexible(
              child: Text(
                year.toString(),
                style: titleStyle.copyWith(
                  color: isPopular ? Colors.white : textDark,
                ),
              ),
            ),
          ),
          title: Text(
            'EUEE $year Entrance Exam',
            style: titleStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '75 Questions • 2h 30m',
            style: bodyStyle.copyWith(
              color: textLight,
            ),
          ),
          onTap: () => context.push('/questions'),
        ),
      ),
    );
  }
} 