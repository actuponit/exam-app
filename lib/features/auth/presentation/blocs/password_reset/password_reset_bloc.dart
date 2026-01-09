import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

@injectable
class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _authRepository;

  PasswordResetBloc(this._authRepository) : super(const PasswordResetState()) {
    on<SendPasswordResetOtpEvent>(_onSendOtp);
    on<VerifyPasswordResetOtpEvent>(_onVerifyOtp);
    on<ConfirmResetPasswordEvent>(_onConfirmReset);
  }

  Future<void> _onSendOtp(
    SendPasswordResetOtpEvent event,
    Emitter<PasswordResetState> emit,
  ) async {
    try {
      emit(state.copyWith(sendStatus: RequestStatus.loading, sendError: ''));
      await _authRepository.sendPasswordResetOtp(email: event.email);
      emit(state.copyWith(sendStatus: RequestStatus.success));
    } catch (e) {
      emit(state.copyWith(
          sendStatus: RequestStatus.error, sendError: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyPasswordResetOtpEvent event,
    Emitter<PasswordResetState> emit,
  ) async {
    try {
      emit(
          state.copyWith(verifyStatus: RequestStatus.loading, verifyError: ''));
      final token = await _authRepository.verifyPasswordResetOtp(
          email: event.email, otp: event.otp);
      emit(state.copyWith(
          verifyStatus: RequestStatus.success, resetToken: token));
    } catch (e) {
      emit(state.copyWith(
          verifyStatus: RequestStatus.error, verifyError: e.toString()));
    }
  }

  Future<void> _onConfirmReset(
    ConfirmResetPasswordEvent event,
    Emitter<PasswordResetState> emit,
  ) async {
    try {
      emit(state.copyWith(
          confirmStatus: RequestStatus.loading, confirmError: ''));
      await _authRepository.resetPassword(
          email: event.email,
          resetToken: event.resetToken,
          newPassword: event.newPassword);
      emit(state.copyWith(confirmStatus: RequestStatus.success));
    } catch (e) {
      emit(state.copyWith(
          confirmStatus: RequestStatus.error, confirmError: e.toString()));
    }
  }
}
