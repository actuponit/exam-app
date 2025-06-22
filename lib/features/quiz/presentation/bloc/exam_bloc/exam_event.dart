part of 'exam_bloc.dart';

sealed class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object> get props => [];
}

class LoadExams extends ExamEvent {
  final String subjectId;
  final String? region;
  const LoadExams(this.subjectId, {this.region});

  @override
  List<Object> get props => [subjectId, region ?? ''];
}

class FilterExamsByChapter extends ExamEvent {
  final String chapterId;
  const FilterExamsByChapter(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}
