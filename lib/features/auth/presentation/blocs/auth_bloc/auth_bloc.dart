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
    } catch (e) {
      emit(state.copyWith(
        examTypesStatus: LoadingStatus.error,
        examTypesError: e.toString(),
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
}
