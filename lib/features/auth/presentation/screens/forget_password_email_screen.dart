import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_app/core/router/app_router.dart';

class ForgetPasswordEmailScreen extends StatefulWidget {
  const ForgetPasswordEmailScreen({super.key});

  @override
  State<ForgetPasswordEmailScreen> createState() =>
      _ForgetPasswordEmailScreenState();
}

class _ForgetPasswordEmailScreenState extends State<ForgetPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final text = _emailController.text.trim();
    final isValid = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(text);
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  void _sendOtp() {
    if (!_isValid) return;
    // In a real app you would call your backend to send the OTP here.
    context.push(RoutePaths.forgetPasswordOtp,
        extra: {'email': _emailController.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password', style: theme.textTheme.titleMedium),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Enter the email associated with your account. We will send a verification code to reset your password.',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => _onEmailChanged(),
              ),
              const SizedBox(height: 20),
              Spacer(),
              ElevatedButton(
                onPressed: _isValid ? _sendOtp : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.12),
                ),
                child: Text('Send OTP',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
