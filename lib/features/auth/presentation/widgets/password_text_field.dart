import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? errorText;
  final bool isConfirmPassword;
  final String? originalPassword;
  final List<String> autofillHints;
  final TextInputAction textInputAction;

  const PasswordTextField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.isConfirmPassword = false,
    this.originalPassword,
    this.autofillHints = const [],
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscurePassword,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: widget.autofillHints,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          errorText: widget.errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: _togglePasswordVisibility,
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
