import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/models/question.dart';
import '../../domain/models/answer.dart' as models;
import '../../domain/services/score_calculator.dart';

enum QuestionMode { practice, quiz }
enum QuestionStatus { initial, loading, loaded, error, submitted }

class QuestionState extends Equatable {
  final List<Question> questions;
  final Map<String, models.Answer> answers;
  final int currentPage;
  final QuestionMode mode;
  final QuestionStatus status;
  final String? error;
  final String? chapter;
  final int? year;
  final int? timeRemaining;
  final PageController? pageController;
  final DateTime? startTime;
  final ScoreResult? scoreResult;

  const QuestionState({
    this.questions = const [],
    this.answers = const {},
    this.currentPage = 0,
    required this.mode,
    this.status = QuestionStatus.initial,
    this.error,
    this.chapter,
    this.year,
    this.timeRemaining,
    this.pageController,
    this.startTime,
    this.scoreResult,
  });

  @override
  List<Object?> get props => [
        questions,
        answers,
        currentPage,
        mode,
        status,
        error,
        chapter,
        year,
        timeRemaining,
        pageController,
        startTime,
        scoreResult,
      ];

  QuestionState copyWith({
    List<Question>? questions,
    Map<String, models.Answer>? answers,
    int? currentPage,
    QuestionMode? mode,
    QuestionStatus? status,
    String? error,
    String? chapter,
    int? year,
    int? timeRemaining,
    PageController? pageController,
    DateTime? startTime,
    ScoreResult? scoreResult,
  }) {
    return QuestionState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentPage: currentPage ?? this.currentPage,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      error: error,
      chapter: chapter ?? this.chapter,
      year: year ?? this.year,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      pageController: pageController ?? this.pageController,
      startTime: startTime ?? this.startTime,
      scoreResult: scoreResult ?? this.scoreResult,
    );
  }
} 