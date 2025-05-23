part of 'exam_bloc.dart';

sealed class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object> get props => [];
}

final class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamLoaded extends ExamState {
  final List<Exam> exams;
  final List<ExamChapter> chapters;
  final ExamChapter? filteredChapter;

  const ExamLoaded(
      {required this.exams, this.filteredChapter, required this.chapters});

  @override
  List<Object> get props => [exams, chapters, filteredChapter?.id ?? "all"];
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<String> get props => [message];
}
