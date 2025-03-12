import 'dart:async';

import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/auth/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  late Timer _timer;
  int _start = 120;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() => _start--);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _resendOTP() {
    setState(() {
      _start = 120;
      _timer.cancel();
      _startTimer();
      for (var controller in _otpControllers) {
        controller.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('New OTP sent to your email'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<RegistrationBloc>().add(
                  const RegistrationStepChanged(
                    RegistrationStep.institutionInfo,
                  ),
                );
            context.pop();
          }
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProgressIndicator(context),
            const SizedBox(height: 40),
            _buildOTPIllustration(context),
            const SizedBox(height: 30),
            _buildOTPInputFields(),
            const SizedBox(height: 20),
            _buildTimerAndResend(context),
            const SizedBox(height: 40),
            _buildVerifyButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return LinearProgressIndicator(
      value: 1.0,
      minHeight: 8,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOTPIllustration(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.verified_user_rounded,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Enter 6-digit Code',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a verification code to your email',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildOTPInputFields() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorText: state.otp?.error,
                ),
                onChanged: (value) {
                  if (value.length == 1) {
                    if (index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    _updateOTPValue();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        );
      },
    );
  }

  void _updateOTPValue() {
    final otp = _otpControllers.map((c) => c.text).join();
    context.read<RegistrationBloc>().add(
          RegistrationFormFieldUpdated(
            step: RegistrationStep.otpVerification,
            field: 'otp',
            value: otp,
          ),
        );
  }

  Widget _buildTimerAndResend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.access_time_rounded,
          color: Theme.of(context).colorScheme.outline,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          _formattedTime,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(width: 20),
        TextButton(
          onPressed: _start == 0 ? _resendOTP : null,
          child: Text(
            'Resend Code',
            style: TextStyle(
              color: _start == 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return BlocConsumer<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state.status && state.currentStep == RegistrationStep.finish) {
          context.go(RoutePaths.home);
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: state.status
                ? () {
                  context.go(RoutePaths.home);
                  }
                : null,
            child: state.isLoading
                ? const CircularProgressIndicator()
                : const Text('Verify'),
          ),
        );
      },
    );
  }
}