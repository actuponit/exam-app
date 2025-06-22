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
        return Column(
          children: [
            if (state.regionSubjects.isNotEmpty &&
                state.regionSubjects.first.isNotEmpty) ...[
              RegionFilterWidget(regions: state.regionSubjects),
              const SizedBox(height: 16),
            ],
            Padding(
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
                itemBuilder: (context, index) => SubjectCard(
                    subject: subjects[index],
                    region: state.region == '' ? null : state.region),
              ),
            ),
          ],
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
  final String? region;

  const SubjectCard({super.key, required this.subject, this.region});

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
          onTap: () {
            context.push('/years/${subject.id}',
                extra: (subject.duration, region));
          },
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

class RegionFilterWidget extends StatefulWidget {
  final List<String> regions;

  const RegionFilterWidget({super.key, required this.regions});

  @override
  State<RegionFilterWidget> createState() => _RegionFilterWidgetState();
}

class _RegionFilterWidgetState extends State<RegionFilterWidget> {
  String selectedRegion = '';
  @override
  void initState() {
    setState(() {
      selectedRegion = widget.regions.first;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Create regions list with 'All' option
    final allRegions = widget.regions;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.05),
            secondaryColor.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Filter by Region',
              style: titleStyle.copyWith(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allRegions.length,
              itemBuilder: (context, index) {
                final region = allRegions[index];
                final isSelected = selectedRegion == region;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      region,
                      style: bodyStyle.copyWith(
                        color: isSelected ? Colors.white : primaryColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        selectedRegion = region;
                      });
                      context
                          .read<SubjectBloc>()
                          .add(FilterSubjects(selectedRegion));
                    },
                    backgroundColor: Colors.white,
                    selectedColor: primaryColor,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? primaryColor
                            : primaryColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: isSelected ? 2 : 0,
                    shadowColor: primaryColor.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
