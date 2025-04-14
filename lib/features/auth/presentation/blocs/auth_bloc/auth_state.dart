part of 'auth_bloc.dart';

enum LoadingStatus { initial, loading, loaded, error }

class AuthState {
  final List<ExamType> examTypes;
  final LoadingStatus examTypesStatus;
  final LoadingStatus registrationStatus;
  final String examTypesError;
  final String registrationError;
  final bool isRegistrationSuccessful;

  const AuthState({
    this.examTypes = const [],
    this.examTypesStatus = LoadingStatus.initial,
    this.registrationStatus = LoadingStatus.initial,
    this.examTypesError = '',
    this.registrationError = '',
    this.isRegistrationSuccessful = false,
  });

  AuthState copyWith({
    List<ExamType>? examTypes,
    LoadingStatus? examTypesStatus,
    LoadingStatus? registrationStatus,
    String? examTypesError,
    String? registrationError,
    bool? isRegistrationSuccessful,
  }) {
    return AuthState(
      examTypes: examTypes ?? this.examTypes,
      examTypesStatus: examTypesStatus ?? this.examTypesStatus,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      examTypesError: examTypesError ?? this.examTypesError,
      registrationError: registrationError ?? this.registrationError,
      isRegistrationSuccessful: isRegistrationSuccessful ?? this.isRegistrationSuccessful,
    );
  }

  bool get isExamTypesLoading => examTypesStatus == LoadingStatus.loading;
  bool get isRegistrationLoading => registrationStatus == LoadingStatus.loading;
  bool get hasExamTypesError => examTypesStatus == LoadingStatus.error;
  bool get hasRegistrationError => registrationStatus == LoadingStatus.error;
} 