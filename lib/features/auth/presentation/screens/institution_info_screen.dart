import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/auth/presentation/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:exam_app/features/auth/domain/models/institution_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/presentation/widgets/exam_selection_widget.dart';
import 'package:go_router/go_router.dart';

class InstitutionInfoScreen extends StatelessWidget {
  const InstitutionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institution Information'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
            context.read<RegistrationBloc>().add(
                  const RegistrationStepChanged(
                    RegistrationStep.personalInfo,
                  ),
                );
          }
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProgressIndicator(context),
            const SizedBox(height: 30),
            _InstitutionInfoForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return LinearProgressIndicator(
      value: 0.66,
      minHeight: 8,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _InstitutionInfoForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final bloc = context.read<RegistrationBloc>();
        final theme = Theme.of(context);
        final institutionType = state.institutionInfo.institutionType;

        return Column(
          children: [
            const SizedBox(height: 20),
            _buildInstitutionTypeDropdown(context: context, currentValue: institutionType),
            const SizedBox(height: 30),
            _buildTextField(
              context: context,
              label: 'Institution Name',
              field: 'institutionName',
            ),
            const ExamSelectionWidget(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  bloc.add(RegistrationFormSubmitted());
                  context.go(RoutePaths.home);
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstitutionTypeDropdown({
    required BuildContext context,
    required InstitutionType currentValue,
  }) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<InstitutionType>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: 'Institution Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      items: InstitutionType.values
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(
                type.displayName,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<RegistrationBloc>().add(
                RegistrationFormFieldUpdated(
                  step: RegistrationStep.institutionInfo,
                  field: 'institutionType',
                  value: value.name,
                ),
              );
        }
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String field,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      onChanged: (value) => context.read<RegistrationBloc>().add(
            RegistrationFormFieldUpdated(
              step: RegistrationStep.institutionInfo,
              field: field,
              value: value,
            ),
          ),
    );
  }
}