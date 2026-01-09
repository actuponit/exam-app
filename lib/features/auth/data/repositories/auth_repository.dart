import 'package:exam_app/features/auth/data/models/exam_type.dart';

abstract class AuthRepository {
  Future<List<ExamType>> getExamTypes();
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String institutionType,
    required String institutionName,
    required ExamType examType,
    String? referralCode,
    required String password,
  });

  Future<void> login({
    required String phone,
    required String password,
  });

  // Profile methods
  Future<Map<String, dynamic>> getUserProfile();

  // Logout method
  Future<void> logout();

  /// Sends a password-reset OTP to the given email address.
  ///
  /// Expected behavior: backend will create/issue a short-lived OTP (6 digits)
  /// and send it to the supplied email. The method completes when request
  /// is accepted; verification of the OTP happens in [verifyPasswordResetOtp].
  Future<void> sendPasswordResetOtp({required String email});

  /// Verifies the OTP sent to [email].
  ///
  /// Returns a short-lived `resetToken` that can be used to confirm and
  /// complete the password reset in [resetPassword]. The token should be
  /// single-use and expire quickly (e.g. 10-15 minutes).
  Future<String> verifyPasswordResetOtp({
    required String email,
    required String otp,
  });

  /// Resets the user's password using a valid `resetToken` obtained from
  /// [verifyPasswordResetOtp].
  ///
  /// The backend should validate the token and update the user's password.
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}
