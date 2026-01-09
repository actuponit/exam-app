part of 'password_reset_bloc.dart';

abstract class PasswordResetEvent {}

class SendPasswordResetOtpEvent extends PasswordResetEvent {
  final String email;
  SendPasswordResetOtpEvent({required this.email});
}

class VerifyPasswordResetOtpEvent extends PasswordResetEvent {
  final String email;
  final String otp;
  VerifyPasswordResetOtpEvent({required this.email, required this.otp});
}

class ConfirmResetPasswordEvent extends PasswordResetEvent {
  final String email;
  final String resetToken;
  final String newPassword;
  ConfirmResetPasswordEvent(
      {required this.email,
      required this.resetToken,
      required this.newPassword});
}
