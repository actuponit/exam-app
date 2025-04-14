// First, create the registration bloc
// lib/features/auth/presentation/bloc/registration_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/domain/models/institution_type.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

part 'registration_form_event.dart';
part 'registration_form_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AuthBloc? authBloc; // Optional to allow creation without auth bloc for tests

  RegistrationBloc({this.authBloc}) : super(const RegistrationState()) {
    on<RegistrationStepChanged>(_onStepChanged);
    on<RegistrationFormFieldUpdated>(_onFormFieldUpdated);
    on<ExamTypeSelected>(_onExamTypeSelected);
  }

  void _onStepChanged(
    RegistrationStepChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onFormFieldUpdated(
    RegistrationFormFieldUpdated event,
    Emitter<RegistrationState> emit,
  ) {
    switch (event.step) {
      case RegistrationStep.personalInfo:
        final personalInfo = updatePersonalInfo(state.personalInfo, event);
        emit(state.copyWith(
          personalInfo: personalInfo,
          status: true,
        ));
        break;
      case RegistrationStep.institutionInfo:
        final institutionInfo = updateInstitutionInfo(state.institutionInfo, event);
        emit(state.copyWith(
          institutionInfo: institutionInfo,
          status: true,
        ));
        break;
      case RegistrationStep.finish:
        emit(state.copyWith(status: true));
        break;
    }
  }

  void _onExamTypeSelected(
    ExamTypeSelected event,
    Emitter<RegistrationState> emit,
  ) {
    final institutionInfo = state.institutionInfo.copyWith(
      examType: event.examType,
    );
    emit(state.copyWith(
      institutionInfo: institutionInfo,
    ));
  }

  PersonalInfoForm updatePersonalInfo(PersonalInfoForm form, RegistrationFormFieldUpdated event) {
    switch (event.field) {
      case 'firstName':
        return form.copyWith(firstName: event.value);
      case 'lastName':
        return form.copyWith(lastName: event.value);
      case 'phone':
        return form.copyWith(phone: event.value);
      case 'email':
        return form.copyWith(email: event.value);
      default:
        return form;
    }
  }

  InstitutionInfoForm updateInstitutionInfo(InstitutionInfoForm form, RegistrationFormFieldUpdated event) {
    switch (event.field) {
      case 'institutionType':
        return form.copyWith(institutionType: InstitutionType.values.firstWhere(
          (type) => type.name == event.value,
        ));
      case 'institutionName':
        return form.copyWith(institutionName: event.value);
      case 'referralCode':
        return form.copyWith(referralCode: event.value);
      default:
        return form;
    }
  }
}
