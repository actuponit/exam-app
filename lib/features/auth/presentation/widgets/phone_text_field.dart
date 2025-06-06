import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exam_app/features/auth/presentation/utils/form_validator.dart';

class PhoneTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? errorText;
  final List<String> autofillHints;
  final TextInputAction textInputAction;
  final bool enabled;

  const PhoneTextField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.autofillHints = const [],
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
  });

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled,
        keyboardType: TextInputType.phone,
        autofillHints: widget.autofillHints,
        textInputAction: widget.textInputAction,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          errorText: widget.errorText,
          prefixText: '+ 251 ',
          prefixStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(6),
            child: const Text(
              '🇪🇹',
              style: TextStyle(fontSize: 28),
            ),
          ),
        ),
        onChanged: (value) {
          final formattedValue = FormValidator.formatPhoneNumber(value);
          if (formattedValue != value) {
            widget.controller.text = formattedValue;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: formattedValue.length),
            );
          }
          widget.onChanged(formattedValue);
        },
      ),
    );
  }
}
