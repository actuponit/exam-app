// First, create the registration bloc
// lib/features/auth/presentation/bloc/registration_bloc.dart

import 'dart:async';
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

  Future<void> _onFormSubmitted(
    RegistrationFormSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: false, isLoading: true, currentStep: RegistrationStep.finish));
    try {
      // If authBloc is provided, use it to register the user
      if (authBloc != null) {
        authBloc!.add(RegisterUser(
          firstName: state.personalInfo.firstName,
          lastName: state.personalInfo.lastName,
          phone: state.personalInfo.phone,
          email: state.personalInfo.email,
          institutionType: state.institutionInfo.institutionType.name,
          institutionName: state.institutionInfo.institutionName,
          examType: state.institutionInfo.examType,
          referralCode: state.institutionInfo.referralCode.isNotEmpty ? state.institutionInfo.referralCode : null,
        ));
      } else {
        // Simulate API call for when authBloc isn't available
        await Future.delayed(const Duration(seconds: 2));
      }
      
      emit(state.copyWith(status: true, isLoading: false));
    } catch (_) {
      emit(state.copyWith(status: false, isLoading: false));
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
