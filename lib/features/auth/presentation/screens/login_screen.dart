import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
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

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  // late Animation<double> _fadeAnimation;
  // late Animation<Offset> _slideAnimation;

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

    // _fadeAnimation = Tween<double>(
    //   begin: 0.0,
    //   end: 1.0,
    // ).animate(CurvedAnimation(
    //   parent: _fadeController,
    //   curve: Curves.easeInOut,
    // ));

    // _slideAnimation = Tween<Offset>(
    //   begin: const Offset(0, 0.3),
    //   end: Offset.zero,
    // ).animate(CurvedAnimation(
    //   parent: _slideController,
    //   curve: Curves.easeOutCubic,
    // ));

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

  Future<void> _handleLogin() async {
    context.read<AuthBloc>().add(LoginUser(
          phone: _phoneController.text,
          password: _passwordController.text,
        ));
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
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
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  // Header
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your exam preparation',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
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
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  _buildLoginButton(),

                  const SizedBox(height: 24),

                  const SizedBox(height: 32),

                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
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
                              color: Theme.of(context).colorScheme.primary,
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.loginStatus == LoadingStatus.loaded) {
          final c =
              GoRouter.of(context).routerDelegate.navigatorKey.currentContext!;
          AppSnackBar.show(
            context: c,
            message: 'Login successfully',
            type: SnackBarType.success,
            duration: const Duration(seconds: 6),
          );
          context.go(RoutePaths.home);
        } else if (state.loginStatus == LoadingStatus.error) {
          AppSnackBar.show(
            context: context,
            message: state.loginError,
            type: SnackBarType.error,
            duration: const Duration(seconds: 6),
          );
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(buttonRadius),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed:
                state.isLoginLoading || !_isFormValid ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
            ),
            child: state.isLoginLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
