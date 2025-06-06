import 'package:exam_app/core/error/exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<LoadExamTypes>(_onLoadExamTypes);
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoginUser(
    LoginUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(
        loginStatus: LoadingStatus.loading,
        loginError: '',
      ));

      await _authRepository.login(
        phone: event.phone,
        password: event.password,
      );

      emit(state.copyWith(
        loginStatus: LoadingStatus.loaded,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        loginStatus: LoadingStatus.error,
        loginError: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        loginStatus: LoadingStatus.error,
        loginError: "Something went wrong",
      ));
    }
  }

  Future<void> _onLoadExamTypes(
    LoadExamTypes event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(
        examTypesStatus: LoadingStatus.loading,
        examTypesError: '',
      ));

      final examTypes = await _authRepository.getExamTypes();

      emit(state.copyWith(
        examTypesStatus: LoadingStatus.loaded,
        examTypes: examTypes,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        examTypesStatus: LoadingStatus.error,
        examTypesError: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        examTypesStatus: LoadingStatus.error,
        examTypesError: "Something went wrong",
      ));
    }
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(
        registrationStatus: LoadingStatus.loading,
        registrationError: '',
        isRegistrationSuccessful: false,
      ));

      await _authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        institutionType: event.institutionType,
        institutionName: event.institutionName,
        examType: event.examType,
        referralCode: event.referralCode,
        password: event.password,
      );

      emit(state.copyWith(
        registrationStatus: LoadingStatus.loaded,
        isRegistrationSuccessful: true,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        registrationStatus: LoadingStatus.error,
        registrationError: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        registrationStatus: LoadingStatus.error,
        registrationError: "Something went wrong",
      ));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(
        logoutStatus: LoadingStatus.loading,
        logoutError: '',
      ));

      await _authRepository.logout();

      emit(state.copyWith(
        logoutStatus: LoadingStatus.loaded,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        logoutStatus: LoadingStatus.error,
        logoutError: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        logoutStatus: LoadingStatus.error,
        logoutError: "Something went wrong during logout",
      ));
    }
  }
}
