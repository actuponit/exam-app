import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/blocs/registration_form_bloc/registration_form_bloc.dart';

class ExamSelectionWidget extends StatefulWidget {
  const ExamSelectionWidget({super.key});

  @override
  State<ExamSelectionWidget> createState() => _ExamSelectionWidgetState();
}

class _ExamSelectionWidgetState extends State<ExamSelectionWidget> {
  final List<ExamType> _examTypes = const [
    ExamType(
      title: 'EUEE',
      subtitle: 'Ethiopian University Entrance Exam',
      subjects: 6,
      price: 149,
      features: ['All Subjects', '5 Year Papers', 'Natural Science', 'Social Science', 'Up to 30 sample questions per subject'],
    ),
    ExamType(
      title: 'Exit Exam',
      subtitle: 'University Graduation Exam',
      subjects: 8,
      price: 199,
      features: ['Department Specific', 'Practical Tests', 'Explanation'],
    ),
    ExamType(
      title: 'GAT',
      subtitle: 'Graduate Admission Test',
      subjects: 4,
      price: 299,
      features: ['Explanation', 'Different Departments', 'Up to 10 sample questions per department'],
    ),
    ExamType(
      title: 'International',
      subtitle: 'SAT/ACT/IELTS Prep',
      subjects: 5,
      price: 399,
      features: ['Global Curriculum', 'Differe years'],
    ),
  ];

  String texam = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return Column(
          children: [
            Text(
              'Select Your Exam Type',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(_examTypes.length, (index) {
                final exam = _examTypes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: AnimatedExamCard(
                    exam: exam,
                    isSelected: texam == exam.title,
                    onTap: () {
                      setState(() {
                        texam = exam.title;
                      });
                    },
                    // onTap: () => context.read<RegistrationBloc>().add(
                    //   ExamTypeSelected(selectedExam == exam.title ? '' : exam.title),
                    // ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            _buildFreeTrialBanner(),
          ],
        );
      },
    );
  }

  Widget _buildFreeTrialBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, 
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Start with free sample questions for any exam! '
              'Upgrade anytime to unlock full access.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExamType {
  final String title;
  final String subtitle;
  final int subjects;
  final double price;
  final List<String> features;

  const ExamType({
    required this.title,
    required this.subtitle,
    required this.subjects,
    required this.price,
    required this.features,
  });
}

class AnimatedExamCard extends StatefulWidget {
  final ExamType exam;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedExamCard({
    super.key,
    required this.exam,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AnimatedExamCard> createState() => _AnimatedExamCardState();
}

class _AnimatedExamCardState extends State<AnimatedExamCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        // final isSelected = state.institutionInfo.examType == widget.exam.title;
        final isSelected = widget.isSelected;
        final isReallySelected = widget.exam.title == state.institutionInfo.examType;
        final theme = Theme.of(context);
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected || isReallySelected
                ? theme.colorScheme.primaryContainer.withAlpha(25)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected || isReallySelected
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected || isReallySelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(25),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Selection glow effect
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.5,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.05),
                          theme.colorScheme.primary.withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                  ),
                ),
              
              InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Selection indicator
                                if (isReallySelected)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Selected',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                Text(
                                  widget.exam.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : null,
                                      ),
                                ),
                                Text(
                                  widget.exam.subtitle,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isReallySelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isReallySelected 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ],
                      ),
                      if (isSelected) _buildExamDetails(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.exam.features
              .map((feature) => Chip(
                    label: Text(feature),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.read<RegistrationBloc>().add(
              ExamTypeSelected(widget.exam.title),
            ),
            child: const Text('Select Exam'),
          ),
        ),
      ],
    );
  }
} 