part of 'subject_bloc.dart';

sealed class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectLoaded extends SubjectState {
  final List<Subject> subjects;
  final String region;
  final List<String> regionSubjects;

  const SubjectLoaded(this.subjects, this.region, this.regionSubjects);

  @override
  List<Object?> get props => [subjects, region, regionSubjects];
}

class SubjectError extends SubjectState {
  final String message;

  const SubjectError(this.message);

  @override
  List<Object?> get props => [message];
}
