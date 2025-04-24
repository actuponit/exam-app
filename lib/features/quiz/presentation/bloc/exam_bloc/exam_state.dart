part of 'exam_bloc.dart';

sealed class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object> get props => [];
}

final class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamLoaded extends ExamState {
  final Map<int, Exam> examsByYear;
  final List<Chapter> chapters;
  final String filteredChapterId;

  const ExamLoaded(
      {required this.examsByYear,
      this.filteredChapterId = "all",
      required this.chapters});

  @override
  List<Object> get props => [examsByYear, filteredChapterId, chapters];
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<String> get props => [message];
}
