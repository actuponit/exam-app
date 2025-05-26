import 'package:exam_app/core/theme.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SubjectSelectionScreen extends StatelessWidget {
  static Widget route = Scaffold(
    appBar: AppBar(
      title: const Text('Subjects'),
    ),
    body: const SubjectSelectionScreen(),
  );
  const SubjectSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectBloc, SubjectState>(builder: (context, state) {
      if (state is SubjectLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is SubjectLoaded) {
        final subjects = state.subjects;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) =>
                SubjectCard(subject: subjects[index]),
          ),
        );
      } else if (state is SubjectError) {
        return Center(child: Text(state.message));
      } else {
        context.read<SubjectBloc>().add(LoadSubjects());
        return const SizedBox();
      }
    });
  }
}

class SubjectCard extends StatelessWidget {
  final Subject subject;

  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            secondaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(cardRadius),
          onTap: () =>
              context.push('/years/${subject.id}', extra: subject.duration),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    subject.icon,
                    size: 28,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    subject.name.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: subject.progress,
                    backgroundColor: secondaryColor.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(primaryColor),
                  ),
                ),
                Text(
                  '${(subject.progress * 100).toInt()}% Completed',
                  style: bodyStyle.copyWith(
                    color: textLight,
                    fontSize: 12,
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
