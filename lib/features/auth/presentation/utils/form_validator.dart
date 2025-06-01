class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length > 1 && digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    // Check if the number starts with 251
    if (!digitsOnly.startsWith('9') && !digitsOnly.startsWith('7')) {
      return 'Phone number must start with 9 or 7';
    }

    // Check total length (251 + 9 digits)
    if (digitsOnly.length != 9) {
      return 'Phone number must be 9 digits';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (value.length > 100) {
      return 'Email must be less than 100 characters';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If it starts with 251, ensure it's not longer than 12 digits
    return digitsOnly;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }

    if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]')
        .hasMatch(value)) {
      return 'Password must contain at least one uppercase letter,\nlowercase letter, number, and special character';
    }

    return null;
  }

  static String? validateConfirmPassword(
      String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  static List<String> getPasswordStrengthIndicators(String password) {
    List<String> indicators = [];

    if (password.length >= 8) {
      indicators.add('At least 8 characters');
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      indicators.add('Contains lowercase letter');
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      indicators.add('Contains uppercase letter');
    }

    if (RegExp(r'\d').hasMatch(password)) {
      indicators.add('Contains number');
    }

    if (RegExp(r'[@$!%*?&]').hasMatch(password)) {
      indicators.add('Contains special character');
    }

    return indicators;
  }

  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[@$!%*?&]').hasMatch(password)) strength++;

    return strength;
  }
}
