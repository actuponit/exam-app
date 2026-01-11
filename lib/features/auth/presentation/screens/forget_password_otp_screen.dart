import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/auth/presentation/blocs/password_reset/password_reset_bloc.dart';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';

class ForgetPasswordOtpScreen extends StatefulWidget {
  final String? email;

  const ForgetPasswordOtpScreen({super.key, this.email});

  @override
  State<ForgetPasswordOtpScreen> createState() =>
      _ForgetPasswordOtpScreenState();
}

class _ForgetPasswordOtpScreenState extends State<ForgetPasswordOtpScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onCompleted(String pin) async {
    // verify via bloc
    final bloc = context.read<PasswordResetBloc>();
    bloc.add(VerifyPasswordResetOtpEvent(email: widget.email ?? '', otp: pin));
  }

  void _resend() {
    context.read<PasswordResetBloc>().add(SendPasswordResetOtpEvent(
          email: widget.email ?? '',
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
    );

    return BlocListener<PasswordResetBloc, PasswordResetState>(
      listener: (context, state) {
        if (state.verifyStatus == RequestStatus.success &&
            state.resetToken != null) {
          AppSnackBar.success(context: context, message: 'OTP verified');
          context.push(RoutePaths.forgetPasswordReset, extra: {
            'email': widget.email,
            'resetToken': state.resetToken,
          });
        } else if (state.verifyStatus == RequestStatus.error) {
          AppSnackBar.error(context: context, message: state.verifyError);
        } else if (state.sendStatus == RequestStatus.success) {
          AppSnackBar.success(
              context: context, message: "Otp resent successfully");
          _pinController.clear();
        } else if (state.sendStatus == RequestStatus.error &&
            state.sendError.isNotEmpty) {
          AppSnackBar.error(context: context, message: state.sendError);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verify OTP', style: theme.textTheme.titleMedium),
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
                Text(
                  'Enter the 6-digit code sent to',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8)),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.email ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _pinController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: defaultPinTheme,
                    showCursor: true,
                    onCompleted: _onCompleted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Didn\'t receive the code?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7))),
                    TextButton(
                      onPressed: _resend,
                      child: Text('Resend',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Spacer(),
                BlocBuilder<PasswordResetBloc, PasswordResetState>(
                  builder: (context, state) {
                    final isLoading =
                        (state.sendStatus == RequestStatus.loading) ||
                            (state.verifyStatus == RequestStatus.loading);
                    return SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed:
                            (_pinController.text.length == 6) && !isLoading
                                ? () => _onCompleted(_pinController.text)
                                : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: theme.colorScheme.primary,
                          disabledBackgroundColor:
                              theme.colorScheme.onSurface.withOpacity(0.12),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                'Submit',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
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
