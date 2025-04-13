part of 'auth_bloc.dart';

class AuthState {
  final List<ExamType> examTypes;
  final bool isLoading;
  final String error;

  const AuthState({
    this.examTypes = const [],
    this.isLoading = false,
    this.error = '',
  });

  AuthState copyWith({
    List<ExamType>? examTypes,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      examTypes: examTypes ?? this.examTypes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
} 