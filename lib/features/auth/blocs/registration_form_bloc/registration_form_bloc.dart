// First, create the registration bloc
// lib/features/auth/presentation/bloc/registration_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:exam_app/core/validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'registration_form_event.dart';
part 'registration_form_state.dart';


class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(const RegistrationState()) {
    on<RegistrationStepChanged>(_onStepChanged);
    on<RegistrationFormFieldUpdated>(_onFormFieldUpdated);
    on<RegistrationFormSubmitted>(_onFormSubmitted);
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
          status: Formz.validate([
            personalInfo.firstName,
            personalInfo.lastName,
            personalInfo.phone,
            personalInfo.email,
            personalInfo.password,
            personalInfo.confirmPassword,
          ]),
        ));
        break;
      case RegistrationStep.institutionInfo:
        final institutionInfo = updateInstitutionInfo(state.institutionInfo, event);
        emit(state.copyWith(
          institutionInfo: institutionInfo,
          status: Formz.validate([
            institutionInfo.institutionName,
          ]),
        ));
        break;
      case RegistrationStep.otpVerification:
        emit(state.copyWith(
          otp: OtpInput.dirty(event.value),
          status: Formz.validate([OtpInput.dirty(event.value)]),
        ));
        break;
      case RegistrationStep.finish:
        emit(state.copyWith(status: true));
        break;
    }
  }

  Future<void> _onFormSubmitted(
    RegistrationFormSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.status) {
      emit(state.copyWith(status: false, isLoading: true, currentStep: RegistrationStep.finish));
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        emit(state.copyWith(status: true, isLoading: false));
      } catch (_) {
        emit(state.copyWith(status: false, isLoading: false));
      }
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
        return form.copyWith(firstName: FirstName.dirty(event.value));
      case 'lastName':
        return form.copyWith(lastName: LastName.dirty(event.value));
      case 'phone':
        return form.copyWith(phone: PhoneNumber.dirty(event.value));
      case 'email':
        return form.copyWith(email: Email.dirty(event.value));
      case 'password':
        return form.copyWith(password: Password.dirty(event.value));
      case 'confirmPassword':
        return form.copyWith(confirmPassword: ConfirmPassword.dirty(event.value));
      default:
        return form;
    }
  }

  updateInstitutionInfo(InstitutionInfoForm institutionInfo, RegistrationFormFieldUpdated event) {
    switch (event.field) {
      case 'institutionType':
        return institutionInfo.copyWith(institutionType: InstitutionType.fromString(event.value));
      case 'institutionName':
        return institutionInfo.copyWith(institutionName: InstitutionName.dirty(event.value));
      case 'examType':
        return institutionInfo.copyWith(institutionName: InstitutionName.dirty(event.value));
      default:
        return institutionInfo;
    }
  }
}
