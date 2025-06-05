import 'package:exam_app/features/auth/presentation/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_app/features/auth/presentation/utils/form_validator.dart';
import 'package:exam_app/features/auth/presentation/widgets/phone_text_field.dart';
import 'package:exam_app/features/auth/presentation/widgets/password_text_field.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/core/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Error states
  String? phoneError;
  String? passwordError;

  // Form validation state
  bool get _isFormValid =>
      phoneError == null &&
      passwordError == null &&
      _phoneController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _validateField(String field, String value) {
    setState(() {
      switch (field) {
        case 'phone':
          phoneError = FormValidator.validatePhone(value);
          break;
        case 'password':
          passwordError = value.isEmpty ? 'Password is required' : null;
          break;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navigate to home on success
      if (mounted) {
        context.go(RoutePaths.home);
      }
    }
  }

  void _validateAndUpdateField(String field, String value) {
    setState(() {
      switch (field) {
        case 'phone':
          // Format phone number before validation
          final formattedPhone = FormValidator.formatPhoneNumber(value);
          _phoneController.text = formattedPhone;
          _phoneController.selection = TextSelection.fromPosition(
            TextPosition(offset: formattedPhone.length),
          );
          phoneError = FormValidator.validatePhone(formattedPhone);
          break;

        case 'password':
          passwordError = FormValidator.validatePassword(value);
          // Re-validate confirm password if it has a value

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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white,
              secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back Button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    color: primaryColor,
                  ),

                  const SizedBox(height: 20),

                  // Header
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your exam preparation',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textLight,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email Field
                  PhoneTextField(
                    label: 'Phone Number',
                    hintText: 'Enter your phone number',
                    controller: _phoneController,
                    onChanged: (value) =>
                        _validateAndUpdateField('phone', value),
                    errorText: phoneError,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 24),

                  // Password Field
                  PasswordTextField(
                    label: 'Password',
                    controller: _passwordController,
                    onChanged: (value) =>
                        _validateAndUpdateField('password', value),
                    errorText: passwordError,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  _buildLoginButton(),

                  const SizedBox(height: 24),

                  // Divider
                  // Row(
                  //   children: [
                  //     const Expanded(child: Divider()),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16),
                  //       child: Text(
                  //         'or',
                  //         style: theme.textTheme.bodyMedium?.copyWith(
                  //           color: textLight,
                  //         ),
                  //       ),
                  //     ),
                  //     const Expanded(child: Divider()),
                  //   ],
                  // ),

                  const SizedBox(height: 24),

                  // Google Login Button
                  // _buildGoogleLoginButton(),

                  const SizedBox(height: 32),

                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(RoutePaths.signUp),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
