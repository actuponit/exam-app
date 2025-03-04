import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/auth/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state.currentStep != RegistrationStep.personalInfo) {
            context.push(RoutePaths.institution);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProgressIndicator(context),
              const SizedBox(height: 30),
              _PersonalInfoForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return LinearProgressIndicator(
      value: 0.33,
      minHeight: 8,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _PersonalInfoForm extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final bloc = context.read<RegistrationBloc>();
        final theme = Theme.of(context);
        
        return AutofillGroup(
          child: Column(
            children: [
              _buildTextField(
                context: context,
                label: 'First Name',
                field: 'firstName',
                errorText: state.personalInfo.firstName.displayError,
                autofillHints: const [AutofillHints.givenName],
                controller: firstNameController,
              ),
              _buildTextField(
                context: context,
                label: 'Last Name',
                field: 'lastName',
                errorText: state.personalInfo.lastName.displayError,
                autofillHints: const [AutofillHints.familyName],
                controller: lastNameController,
              ),
              _buildTextField(
                context: context,
                label: 'Phone Number',
                field: 'phone',
                errorText: state.personalInfo.phone.displayError,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                controller: phoneController,
              ),
              _buildTextField(
                context: context,
                label: 'Email',
                field: 'email',
                initialValue: state.personalInfo.email.value,
                errorText: state.personalInfo.email.displayError,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                controller: emailController,
              ),
              _buildTextField(
                context: context,
                label: 'Password',
                field: 'password',
                errorText: state.personalInfo.password.displayError,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                controller: passwordController,
              ),
              _buildTextField(
                context: context,
                label: 'Confirm Password',
                field: 'confirmPassword',
                errorText: state.personalInfo.confirmPassword.displayError,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                controller: confirmPasswordController,
              ),
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
                  onPressed: state.status
                      ? () => bloc.add(const RegistrationStepChanged(
                            RegistrationStep.institutionInfo))
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String field,
    String? initialValue,
    String? errorText,
    TextInputType? keyboardType,
    bool obscureText = false,
    List<String>? autofillHints,
    TextEditingController? controller,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          errorText: errorText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        onChanged: (value) => context.read<RegistrationBloc>().add(
              RegistrationFormFieldUpdated(
                step: RegistrationStep.personalInfo,
                field: field,
                value: value,
              ),
            ),
      ),
    );
  }
}