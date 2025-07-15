import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/presentation/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';
import 'package:exam_app/core/widgets/shimmer_effect.dart';

class ExamSelectionWidget extends StatefulWidget {
  const ExamSelectionWidget({super.key});

  @override
  State<ExamSelectionWidget> createState() => _ExamSelectionWidgetState();
}

class _ExamSelectionWidgetState extends State<ExamSelectionWidget> {
  String selectedExam = '';

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadExamTypes());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
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
            if (state.isExamTypesLoading)
              _buildShimmerList()
            else if (state.hasExamTypesError)
              _buildErrorWidget(state.examTypesError)
            else
              _buildExamList(state.examTypes),
            const SizedBox(height: 30),
            _buildFreeTrialBanner(),
          ],
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerEffect(
                            width: 120,
                            height: 24,
                            radius: 4,
                            margin: EdgeInsets.only(bottom: 8),
                          ),
                          ShimmerEffect(
                            width: double.infinity,
                            height: 16,
                            radius: 4,
                            margin: EdgeInsets.only(bottom: 8),
                          ),
                          ShimmerEffect(
                            width: 80,
                            height: 20,
                            radius: 4,
                          ),
                        ],
                      ),
                    ),
                    ShimmerEffect(
                      width: 24,
                      height: 24,
                      radius: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to load exam types',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(LoadExamTypes());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildExamList(List<ExamType> examTypes) {
    return Column(
      children: List.generate(examTypes.length, (index) {
        final exam = examTypes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: AnimatedExamCard(
            exam: exam,
            isSelected: selectedExam == exam.name,
            onTap: () {
              setState(() {
                selectedExam = exam.name;
              });
            },
          ),
        );
      }),
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
              'Begin with free sample questions after successful registration'
              'You can upgrade anytime for full access to all exam materials.',
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
        final isSelected = widget.isSelected;
        final isReallySelected =
            widget.exam.id == state.institutionInfo.examType.id;
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
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.5,
                        colors: [
                          theme.colorScheme.primary.withAlpha(5),
                          theme.colorScheme.primary.withAlpha(1),
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
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                Text(
                                  widget.exam.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer
                                            : null,
                                      ),
                                ),
                                Text(
                                  widget.exam.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.exam.formattedPrice,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isReallySelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
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
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.read<RegistrationBloc>().add(
                  ExamTypeSelected(widget.exam),
                ),
            child: const Text('Select Exam'),
          ),
        ),
      ],
    );
  }
}
