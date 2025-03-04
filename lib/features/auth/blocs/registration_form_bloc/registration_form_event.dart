part of 'registration_form_bloc.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

class RegistrationStepChanged extends RegistrationEvent {
  final RegistrationStep step;
  const RegistrationStepChanged(this.step);
}

class RegistrationFormFieldUpdated extends RegistrationEvent {
  final RegistrationStep step;
  final String field;
  final String value;
  const RegistrationFormFieldUpdated({
    required this.step,
    required this.field,
    required this.value,
  });
}

class RegistrationFormSubmitted extends RegistrationEvent {}

class ExamTypeSelected extends RegistrationEvent {
  final String examType;
  
  const ExamTypeSelected(this.examType);

  @override
  List<Object> get props => [examType];
}