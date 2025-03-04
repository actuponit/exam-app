import 'package:formz/formz.dart';

enum InstitutionType {
  school,
  university,
  postGrad,
  other;

  static InstitutionType? fromString(String value) {
    try {
      return values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case InstitutionType.school:
        return 'School';
      case InstitutionType.university:
        return 'University';
      case InstitutionType.postGrad:
        return 'Post Graduate';
      case InstitutionType.other:
        return 'Other Institution';
    }
  }
}

class FirstName extends FormzInput<String, String> {
  const FirstName.pure([super.value = '']) : super.pure();
  const FirstName.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    return value?.isEmpty ?? true ? 'First name required' : null;
  }
}

class LastName extends FormzInput<String, String> {
  const LastName.pure([super.value = '']) : super.pure();
  const LastName.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    return value?.isEmpty ?? true ? 'Last name required' : null;
  }
}

class PhoneNumber extends FormzInput<String, String> {
  const PhoneNumber.pure([super.value = '']) : super.pure();
  const PhoneNumber.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    if (value?.isEmpty ?? true) return 'Phone number required';
    if (value!.length < 8) return 'Invalid phone number';
    return null;
  }
}

class Email extends FormzInput<String, String> {
  const Email.pure([super.value = '']) : super.pure();
  const Email.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  @override
  String? validator(String? value) {
    return _emailRegex.hasMatch(value ?? '') ? null : 'Invalid email';
  }
}

class Password extends FormzInput<String, String> {
  const Password.pure([super.value = '']) : super.pure();
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    if (value?.isEmpty ?? true) return 'Password required';
    if (value!.length < 6) return 'Password too short';
    return null;
  }
}

class ConfirmPassword extends FormzInput<String, String> {
  const ConfirmPassword.pure([super.value = '']) : super.pure();
  const ConfirmPassword.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    return value?.isEmpty ?? true ? 'Confirm password required' : null;
  }
}

class InstitutionName extends FormzInput<String, String> {
  const InstitutionName.pure([super.value = '']) : super.pure();
  const InstitutionName.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    return value?.isEmpty ?? true ? 'Institution name required' : null;
  }
}

class OtpInput extends FormzInput<String, String> {
  const OtpInput.pure([super.value = '']) : super.pure();
  const OtpInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    return value?.isEmpty ?? true ? 'OTP required' : null;
  }
}