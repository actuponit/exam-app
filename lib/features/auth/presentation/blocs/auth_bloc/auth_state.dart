part of 'auth_bloc.dart';

class AuthState {
  final List<ExamType> examTypes;
  final bool isLoading;
  final String error;
  final bool succssFullyRegistered;

  const AuthState({
    this.examTypes = const [],
    this.isLoading = false,
    this.error = '',
    this.succssFullyRegistered = false,
  });

  AuthState copyWith({
    List<ExamType>? examTypes,
    bool? isLoading,
    String? error,
    bool? succssFullyRegistered,
  }) {
    return AuthState(
      examTypes: examTypes ?? this.examTypes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      succssFullyRegistered: succssFullyRegistered ?? this.succssFullyRegistered,
    );
  }
} 