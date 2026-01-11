part of 'password_reset_bloc.dart';

enum RequestStatus { initial, loading, success, error }

class PasswordResetState {
  final RequestStatus sendStatus;
  final String sendError;
  final RequestStatus verifyStatus;
  final String verifyError;
  final String? resetToken;
  final RequestStatus confirmStatus;
  final String confirmError;

  const PasswordResetState({
    this.sendStatus = RequestStatus.initial,
    this.sendError = '',
    this.verifyStatus = RequestStatus.initial,
    this.verifyError = '',
    this.resetToken,
    this.confirmStatus = RequestStatus.initial,
    this.confirmError = '',
  });

  PasswordResetState copyWith({
    RequestStatus? sendStatus,
    String? sendError,
    RequestStatus? verifyStatus,
    String? verifyError,
    String? resetToken,
    RequestStatus? confirmStatus,
    String? confirmError,
  }) {
    return PasswordResetState(
      sendStatus: sendStatus ?? this.sendStatus,
      sendError: sendError ?? this.sendError,
      verifyStatus: verifyStatus ?? RequestStatus.initial,
      verifyError: verifyError ?? '',
      resetToken: resetToken ?? this.resetToken,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      confirmError: confirmError ?? this.confirmError,
    );
  }
}
