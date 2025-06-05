part of 'auth_bloc.dart';

enum LoadingStatus { initial, loading, loaded, error }

class AuthState {
  final List<ExamType> examTypes;
  final LoadingStatus examTypesStatus;
  final LoadingStatus registrationStatus;
  final String examTypesError;
  final String registrationError;
  final bool isRegistrationSuccessful;
  final LoadingStatus loginStatus;
  final String loginError;

  const AuthState({
    this.examTypes = const [],
    this.examTypesStatus = LoadingStatus.initial,
    this.registrationStatus = LoadingStatus.initial,
    this.examTypesError = '',
    this.registrationError = '',
    this.isRegistrationSuccessful = false,
    this.loginStatus = LoadingStatus.initial,
    this.loginError = '',
  });

  AuthState copyWith({
    List<ExamType>? examTypes,
    LoadingStatus? examTypesStatus,
    LoadingStatus? registrationStatus,
    String? examTypesError,
    String? registrationError,
    bool? isRegistrationSuccessful,
    LoadingStatus? loginStatus,
    String? loginError,
  }) {
    return AuthState(
      examTypes: examTypes ?? this.examTypes,
      examTypesStatus: examTypesStatus ?? this.examTypesStatus,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      examTypesError: examTypesError ?? '',
      registrationError: registrationError ?? '',
      isRegistrationSuccessful:
          isRegistrationSuccessful ?? this.isRegistrationSuccessful,
      loginStatus: loginStatus ?? this.loginStatus,
      loginError: loginError ?? '',
    );
  }

  bool get isExamTypesLoading => examTypesStatus == LoadingStatus.loading;
  bool get isRegistrationLoading => registrationStatus == LoadingStatus.loading;
  bool get hasExamTypesError => examTypesStatus == LoadingStatus.error;
  bool get hasRegistrationError => registrationStatus == LoadingStatus.error;
  bool get isLoginLoading => loginStatus == LoadingStatus.loading;
  bool get hasLoginError => loginStatus == LoadingStatus.error;
}
