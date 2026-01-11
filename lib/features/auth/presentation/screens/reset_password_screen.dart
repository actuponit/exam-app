import 'package:exam_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/presentation/widgets/password_text_field.dart';
import 'package:exam_app/features/auth/presentation/blocs/password_reset/password_reset_bloc.dart';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? resetToken;

  const ResetPasswordScreen({super.key, this.email, this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? passwordError;
  String? confirmError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValid() {
    return (passwordError == null) &&
        (confirmError == null) &&
        _passwordController.text.isNotEmpty &&
        _confirmController.text.isNotEmpty;
  }

  void _onChangePassword(String field, String value) {
    setState(() {
      if (field == 'password') {
        passwordError =
            value.length < 6 ? 'Password must be at least 6 characters' : null;
        if (_confirmController.text.isNotEmpty) {
          confirmError = _confirmController.text != value
              ? 'Passwords do not match'
              : null;
        }
      } else {
        confirmError =
            value != _passwordController.text ? 'Passwords do not match' : null;
      }
    });
  }

  void _submit() {
    if (!_isValid()) return;
    final bloc = context.read<PasswordResetBloc>();
    bloc.add(ConfirmResetPasswordEvent(
      email: widget.email ?? '',
      resetToken: widget.resetToken ?? '',
      newPassword: _passwordController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PasswordResetBloc, PasswordResetState>(
      listener: (context, state) {
        if (state.confirmStatus == RequestStatus.loading) {
          // show progress if needed
        } else if (state.confirmStatus == RequestStatus.success) {
          AppSnackBar.success(
              context: context,
              message:
                  'Password reset successful. Now you can log in with your new password.');
          context.go(RoutePaths.login);
        } else if (state.confirmStatus == RequestStatus.error) {
          AppSnackBar.error(context: context, message: state.confirmError);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reset Password', style: theme.textTheme.titleMedium),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('Set a new password for',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8))),
                const SizedBox(height: 6),
                Text(widget.email ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                PasswordTextField(
                  label: 'New Password',
                  controller: _passwordController,
                  onChanged: (v) => _onChangePassword('password', v),
                  errorText: passwordError,
                ),
                PasswordTextField(
                  label: 'Confirm Password',
                  controller: _confirmController,
                  onChanged: (v) => _onChangePassword('confirm', v),
                  errorText: confirmError,
                ),
                const SizedBox(height: 12),
                Spacer(),
                BlocBuilder<PasswordResetBloc, PasswordResetState>(
                  builder: (context, state) {
                    final isLoading =
                        state.confirmStatus == RequestStatus.loading;
                    return ElevatedButton(
                      onPressed: _isValid() && !isLoading ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            )
                          : Text('Reset Password',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: Colors.white)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
