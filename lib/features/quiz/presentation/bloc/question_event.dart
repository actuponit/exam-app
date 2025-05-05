import 'package:equatable/equatable.dart';

abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object?> get props => [];
}

class QuestionStarted extends QuestionEvent {
  final String subjectId;
  final String? chapterId;
  final int year;
  final bool isQuizMode;

  const QuestionStarted({
    required this.subjectId,
    required this.year,
    this.chapterId,
    this.isQuizMode = false,
  });

  @override
  List<Object?> get props => [subjectId, chapterId, year, isQuizMode];
}

class QuestionPageChanged extends QuestionEvent {
  final int page;

  const QuestionPageChanged(this.page);

  @override
  List<Object> get props => [page];
}

class QuestionAnswered extends QuestionEvent {
  final String questionId;
  final String selectedOption;

  const QuestionAnswered({
    required this.questionId,
    required this.selectedOption,
  });

  @override
  List<Object> get props => [questionId, selectedOption];
}

class QuizSubmitted extends QuestionEvent {
  const QuizSubmitted();
}

class AnswerRevealed extends QuestionEvent {
  final String questionId;

  const AnswerRevealed(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class LoadMoreRequested extends QuestionEvent {}

class QuizTicked extends QuestionEvent {}
