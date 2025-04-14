import 'dart:ui';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/auth/domain/models/institution_type.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:exam_app/features/auth/presentation/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:exam_app/features/auth/presentation/widgets/exam_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (state.currentStep == RegistrationStep.personalInfo) {
          _goToPage(0);
        } else if (state.currentStep == RegistrationStep.institutionInfo) {
          _goToPage(1);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<RegistrationBloc, RegistrationState>(
            buildWhen: (previous, current) =>
                previous.currentStep != current.currentStep,
            builder: (context, state) {
              return Text(
                state.currentStep == RegistrationStep.personalInfo
                    ? 'Personal Information'
                    : 'Institution Information',
              );
            },
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          leading: BlocBuilder<RegistrationBloc, RegistrationState>(
            builder: (context, state) {
              return state.currentStep == RegistrationStep.institutionInfo
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        context.read<RegistrationBloc>().add(
                              const RegistrationStepChanged(
                                RegistrationStep.personalInfo,
                              ),
                            );
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
        body: Column(
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  // Update the current step based on the page
                  final step = page == 0
                      ? RegistrationStep.personalInfo
                      : RegistrationStep.institutionInfo;

                  // Only update if step is different to avoid loops
                  if (context.read<RegistrationBloc>().state.currentStep !=
                      step) {
                    context
                        .read<RegistrationBloc>()
                        .add(RegistrationStepChanged(step));
                  }
                },
                children: const [
                  _PersonalInfoPage(),
                  _InstitutionInfoPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: LinearProgressIndicator(
            value: state.currentStep == RegistrationStep.personalInfo ? 0.5 : 1,
            minHeight: 8,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class _PersonalInfoPage extends StatefulWidget {
  const _PersonalInfoPage();

  @override
  State<_PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<_PersonalInfoPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<RegistrationBloc>().state;
    firstNameController.text = state.personalInfo.firstName;
    lastNameController.text = state.personalInfo.lastName;
    phoneController.text = state.personalInfo.phone;
    emailController.text = state.personalInfo.email;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final bloc = context.read<RegistrationBloc>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTextField(
                context: context,
                label: 'First Name',
                field: 'firstName',
                autofillHints: const [AutofillHints.givenName],
                controller: firstNameController,
              ),
              _buildTextField(
                context: context,
                label: 'Last Name',
                field: 'lastName',
                autofillHints: const [AutofillHints.familyName],
                controller: lastNameController,
              ),
              _buildTextField(
                context: context,
                label: 'Phone Number',
                field: 'phone',
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                controller: phoneController,
              ),
              _buildTextField(
                context: context,
                label: 'Email',
                field: 'email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                controller: emailController,
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
                  onPressed: _isFormValid()
                      ? () {
                          bloc.add(const RegistrationStepChanged(
                            RegistrationStep.institutionInfo,
                          ));
                        }
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
    List<String> autofillHints = const [],
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onPressed,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onPressed,
                )
              : null,
        ),
        onChanged: (value) {
          context.read<RegistrationBloc>().add(
                RegistrationFormFieldUpdated(
                  step: RegistrationStep.personalInfo,
                  field: field,
                  value: value,
                ),
              );
          setState(() {}); // Refresh UI to update button state
        },
      ),
    );
  }
}

class _InstitutionInfoPage extends StatefulWidget {
  const _InstitutionInfoPage();

  @override
  State<_InstitutionInfoPage> createState() => _InstitutionInfoPageState();
}

class _InstitutionInfoPageState extends State<_InstitutionInfoPage> {
  final TextEditingController institutionNameController =
      TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<RegistrationBloc>().state;
    institutionNameController.text = state.institutionInfo.institutionName;
    referralCodeController.text = state.institutionInfo.referralCode;
  }

  @override
  void dispose() {
    institutionNameController.dispose();
    referralCodeController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return institutionNameController.text.isNotEmpty;
  }

  void _showReferralDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: _buildReferralDialogContent(context),
          ),
        );
      },
    );
  }

  Widget _buildReferralDialogContent(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.succssFullyRegistered != current.succssFullyRegistered,
      listener: (context, state) {
        if (state.succssFullyRegistered) {
          context.go(RoutePaths.home);
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Almost Done!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 15),
              Text(
                'Do you have a referral code?',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: referralCodeController,
                decoration: InputDecoration(
                  labelText: 'Referral Code (Optional)',
                  hintText: 'Enter code if you have one',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.card_giftcard),
                ),
                onChanged: (value) {
                  context.read<RegistrationBloc>().add(
                        RegistrationFormFieldUpdated(
                          step: RegistrationStep.institutionInfo,
                          field: 'referralCode',
                          value: value,
                        ),
                      );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Clear the referral code if the user skips
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _completeRegistration();
                      },
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _completeRegistration() {
    final bloc = context.read<AuthBloc>();
    final state = context.read<RegistrationBloc>().state;
    bloc.add(RegisterUser(
      firstName: state.personalInfo.firstName,
      lastName: state.personalInfo.lastName,
      phone: state.personalInfo.phone,
      email: state.personalInfo.email,
      institutionType: state.institutionInfo.institutionType.name,
      institutionName: state.institutionInfo.institutionName,
      examType: state.institutionInfo.examType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final institutionType = state.institutionInfo.institutionType;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildInstitutionTypeDropdown(
                  context: context, currentValue: institutionType),
              const SizedBox(height: 30),
              TextField(
                controller: institutionNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Institution Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  context.read<RegistrationBloc>().add(
                        RegistrationFormFieldUpdated(
                          step: RegistrationStep.institutionInfo,
                          field: 'institutionName',
                          value: value,
                        ),
                      );
                  setState(() {}); // Refresh UI to update button state
                },
              ),
              const SizedBox(height: 30),
              const ExamSelectionWidget(),
              const SizedBox(height: 30),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _isFormValid() && state.institutionInfo.examType != -1 && !authState.isLoading
                              ? () {
                                  _showReferralDialog();
                                }
                              : null,
                      child: const Text('Complete Registration'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstitutionTypeDropdown({
    required BuildContext context,
    required InstitutionType currentValue,
  }) {
    return DropdownButtonFormField<InstitutionType>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: 'Institution Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: InstitutionType.values
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              ))
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
}
