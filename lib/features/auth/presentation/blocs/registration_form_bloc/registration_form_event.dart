part of 'registration_form_bloc.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

class RegistrationStepChanged extends RegistrationEvent {
  final RegistrationStep step;
  const RegistrationStepChanged(this.step);
  
  @override
  List<Object> get props => [step];
}

class PageChanged extends RegistrationEvent {
  final int page;
  const PageChanged(this.page);
  
  @override
  List<Object> get props => [page];
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
  
  @override
  List<Object> get props => [step, field, value];
}

class ExamTypeSelected extends RegistrationEvent {
  final ExamType examType;
  
  const ExamTypeSelected(this.examType);

  @override
  List<Object> get props => [examType];
}