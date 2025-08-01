part of 'subject_bloc.dart';

abstract class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubjects extends SubjectEvent {}

class FilterSubjects extends SubjectEvent {
  final String region;

  const FilterSubjects(this.region);
}
