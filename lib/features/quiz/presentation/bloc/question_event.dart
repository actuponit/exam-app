import 'package:equatable/equatable.dart';
import 'package:exam_app/features/quiz/domain/models/question.dart';

abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object?> get props => [];
}

class FetchQuestions extends QuestionEvent {
  final bool ensureBackend;

  const FetchQuestions({this.ensureBackend = false});

  @override
  List<Object?> get props => [ensureBackend];
}

class QuestionStarted extends QuestionEvent {
  final String subjectId;
  final String? chapterId;
  final int year;
  final bool isQuizMode;
  final String? region;

  const QuestionStarted({
    required this.subjectId,
    required this.year,
    this.chapterId,
    this.isQuizMode = false,
    this.region,
  });

  @override
  List<Object?> get props => [subjectId, chapterId, year, isQuizMode, region];
}

class QuestionPageChanged extends QuestionEvent {
  final int page;

  const QuestionPageChanged(this.page);

  @override
  List<Object> get props => [page];
}

class QuestionAnswered extends QuestionEvent {
  final Question question;
  final String selectedOption;

  const QuestionAnswered({
    required this.question,
    required this.selectedOption,
  });

  @override
  List<Object> get props => [question, selectedOption];
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
