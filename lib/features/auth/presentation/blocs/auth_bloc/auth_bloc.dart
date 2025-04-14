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
  }

  Future<void> _onLoadExamTypes(
    LoadExamTypes event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: ''));
      
      final examTypes = await _authRepository.getExamTypes();
      
      emit(state.copyWith(
        isLoading: false,
        examTypes: examTypes,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: '', succssFullyRegistered: false));
      
      await _authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        institutionType: event.institutionType,
        institutionName: event.institutionName,
        examType: event.examType,
        referralCode: event.referralCode,
      );
      
      emit(state.copyWith(isLoading: false, succssFullyRegistered: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
} 