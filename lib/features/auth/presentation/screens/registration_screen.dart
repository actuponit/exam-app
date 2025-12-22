import 'dart:ui';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/features/auth/domain/models/institution_type.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:exam_app/features/auth/presentation/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:exam_app/features/auth/presentation/utils/form_validator.dart';
import 'package:exam_app/features/auth/presentation/widgets/exam_selection_widget.dart';
import 'package:exam_app/features/auth/presentation/widgets/password_text_field.dart';
import 'package:exam_app/features/auth/presentation/widgets/phone_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
        } else if (state.currentStep == RegistrationStep.examSelection) {
          _goToPage(2);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                Theme.of(context).colorScheme.surface,
                Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.2),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  _buildCreativeHeader(),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height - 290,
                    ),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) {
                        final step = page == 0
                            ? RegistrationStep.personalInfo
                            : page == 1
                                ? RegistrationStep.institutionInfo
                                : RegistrationStep.examSelection;

                        if (context
                                .read<RegistrationBloc>()
                                .state
                                .currentStep !=
                            step) {
                          context
                              .read<RegistrationBloc>()
                              .add(RegistrationStepChanged(step));
                        }
                      },
                      children: [
                        const _PersonalInfoPage(),
                        const _InstitutionInfoPage(),
                        const _ExamSelectionPage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreativeHeader() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        final currentStepIndex = state.currentStep.index;
        final progress = (currentStepIndex + 1) / 3.0;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Back Button and Close
                  Row(
                    children: [
                      if (currentStepIndex > 0)
                        GestureDetector(
                          onTap: () {
                            final previousStep =
                                RegistrationStep.values[currentStepIndex - 1];
                            context.read<RegistrationBloc>().add(
                                  RegistrationStepChanged(previousStep),
                                );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${currentStepIndex + 1} of 3',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Creative Step Indicator
                  Row(
                    children: [
                      _buildStepCircle(
                          1, currentStepIndex == 0, currentStepIndex > 0),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: currentStepIndex >= 1
                                  ? [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ]
                                  : [
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                    ],
                            ),
                          ),
                        ),
                      ),
                      _buildStepCircle(
                          2, currentStepIndex == 1, currentStepIndex > 1),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: currentStepIndex >= 2
                                  ? [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ]
                                  : [
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                    ],
                            ),
                          ),
                        ),
                      ),
                      _buildStepCircle(3, currentStepIndex == 2, false),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Title and Description
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      key: ValueKey(currentStepIndex),
                      children: [
                        Text(
                          currentStepIndex == 0
                              ? 'Tell us about yourself'
                              : currentStepIndex == 1
                                  ? 'Institution Details'
                                  : 'Select Exam',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentStepIndex == 0
                              ? 'Let\'s start with your basic information to create your account'
                              : currentStepIndex == 1
                                  ? 'Help us understand your educational background'
                                  : 'Choose the exam you are preparing for',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.4,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Progress Bar
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: MediaQuery.of(context).size.width * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepCircle(int step, bool isActive, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive || isCompleted
            ? LinearGradient(colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ])
            : null,
        color: isActive || isCompleted
            ? null
            : Theme.of(context).colorScheme.surfaceVariant,
        boxShadow: isActive || isCompleted
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isCompleted && !isActive
            ? Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
                key: const ValueKey('check'),
              )
            : Text(
                step.toString(),
                key: ValueKey('number_$step'),
                style: TextStyle(
                  color: isActive || isCompleted
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Add form key for validation
  final _formKey = GlobalKey<FormState>();

  // Add error states
  String? firstNameError;
  String? lastNameError;
  String? phoneError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();
    final state = context.read<RegistrationBloc>().state;
    firstNameController.text = state.personalInfo.firstName;
    lastNameController.text = state.personalInfo.lastName;
    phoneController.text = state.personalInfo.phone;
    emailController.text = state.personalInfo.email;
    passwordController.text = state.personalInfo.password;
    confirmPasswordController.text = state.personalInfo.confirmPassword;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return firstNameError == null &&
        lastNameError == null &&
        phoneError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  void _validateAndUpdateField(String field, String value) {
    setState(() {
      switch (field) {
        case 'firstName':
          firstNameError = FormValidator.validateName(value);
          break;
        case 'lastName':
          lastNameError = FormValidator.validateName(value);
          break;
        case 'phone':
          // Format phone number before validation
          final formattedPhone = FormValidator.formatPhoneNumber(value);
          phoneController.text = formattedPhone;
          phoneController.selection = TextSelection.fromPosition(
            TextPosition(offset: formattedPhone.length),
          );
          phoneError = FormValidator.validatePhone(formattedPhone);
          break;
        case 'email':
          emailError = FormValidator.validateEmail(value);
          break;
        case 'password':
          passwordError = FormValidator.validatePassword(value);
          // Re-validate confirm password if it has a value
          if (confirmPasswordController.text.isNotEmpty) {
            confirmPasswordError = FormValidator.validateConfirmPassword(
              confirmPasswordController.text,
              value,
            );
          }
          break;
        case 'confirmPassword':
          confirmPasswordError = FormValidator.validateConfirmPassword(
            value,
            passwordController.text,
          );
          break;
      }
    });

    // Only update the bloc if there are no errors
    if (field == 'phone') {
      context.read<RegistrationBloc>().add(
            RegistrationFormFieldUpdated(
              step: RegistrationStep.personalInfo,
              field: field,
              value: FormValidator.formatPhoneNumber(value),
            ),
          );
    } else {
      context.read<RegistrationBloc>().add(
            RegistrationFormFieldUpdated(
              step: RegistrationStep.personalInfo,
              field: field,
              value: value,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final bloc = context.read<RegistrationBloc>();

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField(
                  context: context,
                  label: 'First Name',
                  field: 'firstName',
                  autofillHints: const [AutofillHints.givenName],
                  controller: firstNameController,
                  errorText: firstNameError,
                ),
                _buildTextField(
                  context: context,
                  label: 'Last Name',
                  field: 'lastName',
                  autofillHints: const [AutofillHints.familyName],
                  controller: lastNameController,
                  errorText: lastNameError,
                ),
                PhoneTextField(
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  controller: phoneController,
                  onChanged: (value) => _validateAndUpdateField('phone', value),
                  errorText: phoneError,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.next,
                ),
                _buildTextField(
                  context: context,
                  label: 'Email',
                  field: 'email',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  controller: emailController,
                  errorText: emailError,
                ),
                PasswordTextField(
                  label: 'Password',
                  controller: passwordController,
                  onChanged: (value) =>
                      _validateAndUpdateField('password', value),
                  errorText: passwordError,
                  textInputAction: TextInputAction.next,
                ),
                PasswordTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  onChanged: (value) =>
                      _validateAndUpdateField('confirmPassword', value),
                  errorText: confirmPasswordError,
                  isConfirmPassword: true,
                  originalPassword: passwordController.text,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 30),
                _buildGradientButton(
                  context: context,
                  text: 'Continue',
                  onPressed: _isFormValid()
                      ? () {
                          bloc.add(const RegistrationStepChanged(
                            RegistrationStep.institutionInfo,
                          ));
                        }
                      : null,
                ),
              ],
            ),
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
    String? errorText,
    String? prefixText,
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
          errorText: errorText,
          prefixText: prefixText,
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
        onChanged: (value) => _validateAndUpdateField(field, value),
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: onPressed == null
            ? Theme.of(context).colorScheme.surfaceVariant
            : null,
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onPressed != null
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
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
  final PageController _pageController = PageController();

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
    _pageController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return institutionNameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final institutionType = state.institutionInfo.institutionType;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          controller: _pageController,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildInstitutionTypeDropdown(
                  context: context, currentValue: institutionType),
              const SizedBox(height: 30),
              _buildInstitutionNameField(context, institutionType),
              const SizedBox(height: 30),
              _buildGradientButton(
                context: context,
                text: 'Continue',
                onPressed: _isFormValid()
                    ? () {
                        final institutionType =
                            state.institutionInfo.institutionType;
                        if (institutionType == InstitutionType.none) {
                          AppSnackBar.show(
                            context: context,
                            message: 'Please select an institution type',
                            type: SnackBarType.error,
                          );
                        } else {
                          context.read<RegistrationBloc>().add(
                                const RegistrationStepChanged(
                                  RegistrationStep.examSelection,
                                ),
                              );
                        }
                      }
                    : null,
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

  Widget _buildInstitutionNameField(
      BuildContext context, InstitutionType institutionType) {
    if (institutionType == InstitutionType.university) {
      return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return _getUniversitySuggestions(textEditingValue.text);
        },
        onSelected: (String selection) {
          institutionNameController.text = selection;
          context.read<RegistrationBloc>().add(
                RegistrationFormFieldUpdated(
                  step: RegistrationStep.institutionInfo,
                  field: 'institutionName',
                  value: selection,
                ),
              );
          setState(() {});
        },
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
          // Sync the controller with our main controller only once
          if (textEditingController.text != institutionNameController.text) {
            textEditingController.text = institutionNameController.text;
          }

          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'University Name',
              hintText: 'Type to search universities...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              institutionNameController.text = value;
              context.read<RegistrationBloc>().add(
                    RegistrationFormFieldUpdated(
                      step: RegistrationStep.institutionInfo,
                      field: 'institutionName',
                      value: value,
                    ),
                  );
            },
          );
        },
      );
    } else {
      return TextField(
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
      );
    }
  }

  Iterable<String> _getUniversitySuggestions(String query) {
    final universities = [
      'Addis Ababa Science and Technology University',
      'Addis Ababa University',
      'Adigrat University',
      'Ambo University',
      'Arba Minch University',
      'Arsi University',
      'Adama Science and Technology University',
      'Axum University',
      'Bahir Dar University',
      'Bonga University',
      'Bule Hora University',
      'Dambi Dollo University',
      'Debark University',
      'Debre Berhan University',
      'Debre Markos University',
      'Debre Tabor University',
      'Defence University',
      'Dilla University',
      'Dire Dawa University',
      'Gambella University',
      'Gondar University',
      'Haramaya University',
      'Hawassa University',
      'Injibara University',
      'Jijiga University',
      'Jimma University',
      'Jinka University',
      'Kebri Dehar University',
      'Kotebe Metropolitan University',
      'Madda Walabu University',
      'Mekdela Amba University',
      'Mekelle University',
      'Mettu University',
      'Mizan Tepi University',
      'Oda Bultum University',
      'Raya University',
      'Salale University',
      'Semera University',
      'Wachamo University',
      'Werabe University',
      'Wolaita Sodo University',
      'Woldia University',
      'Wollega University',
      'Wollo University',
      'Wolkite University',
    ];

    return universities
        .where((university) =>
            university.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: onPressed == null
            ? Theme.of(context).colorScheme.surfaceVariant
            : null,
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onPressed != null
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ExamSelectionPage extends StatefulWidget {
  const _ExamSelectionPage();

  @override
  State<_ExamSelectionPage> createState() => _ExamSelectionPageState();
}

class _ExamSelectionPageState extends State<_ExamSelectionPage> {
  final TextEditingController referralCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<RegistrationBloc>().state;
    referralCodeController.text = state.institutionInfo.referralCode;
  }

  @override
  void dispose() {
    referralCodeController.dispose();
    super.dispose();
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
          previous.isRegistrationSuccessful != current.isRegistrationSuccessful,
      listener: (context, state) {
        if (state.isRegistrationSuccessful) {
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
              if (state.hasRegistrationError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.registrationError,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(buttonRadius),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                        ),
                        onPressed: state.isRegistrationLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        gradient: state.isRegistrationLoading
                            ? null
                            : LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        color: state.isRegistrationLoading
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : null,
                        borderRadius: BorderRadius.circular(buttonRadius),
                        boxShadow: !state.isRegistrationLoading
                            ? [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                        ),
                        onPressed: state.isRegistrationLoading
                            ? null
                            : () {
                                _completeRegistration();
                              },
                        child: state.isRegistrationLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              )
                            : Text(
                                'Confirm',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
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
        password: state.personalInfo.password,
        institutionType: state.institutionInfo.institutionType.name,
        institutionName: state.institutionInfo.institutionName,
        examType: state.institutionInfo.examType,
        referralCode: state.institutionInfo.referralCode));
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: onPressed == null
            ? Theme.of(context).colorScheme.surfaceVariant
            : null,
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onPressed != null
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const ExamSelectionWidget(),
              const SizedBox(height: 30),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return _buildGradientButton(
                    context: context,
                    text: 'Complete Registration',
                    onPressed: state.institutionInfo.examType.id != -1 &&
                            !authState.isRegistrationLoading
                        ? () {
                            _showReferralDialog();
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
