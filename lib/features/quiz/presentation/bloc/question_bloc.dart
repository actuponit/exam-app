import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/question.dart';
import '../../domain/models/answer.dart' as models;
import '../../domain/repositories/question_repository.dart';
import '../../domain/services/score_calculator.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuestionRepository repository;
  Timer? _timer;

  final int questionsPerPage = 3;

  QuestionBloc({
    required this.repository,
  }) : super(const QuestionState(mode: QuestionMode.practice)) {
    on<QuestionStarted>(_onQuestionStarted);
    on<QuestionPageChanged>(_onQuestionPageChanged);
    on<QuestionAnswered>(_onQuestionAnswered);
    on<QuizSubmitted>(_onQuizSubmitted);
    on<AnswerRevealed>(_onAnswerRevealed);
    on<LoadMoreRequested>(_onLoadMoreRequested);
  }

  Future<void> _onQuestionStarted(
    QuestionStarted event,
    Emitter<QuestionState> emit,
  ) async {
    emit(state.copyWith(
      status: QuestionStatus.loading,
      chapter: event.chapter,
      year: event.year,
      mode: event.mode,
      answers: const {},
      pageController: PageController(),
      startTime: DateTime.now(),
    ));

    try {
      final questions = await repository.getQuestions(
        chapter: event.chapter,
        year: event.year,
      );

      if (questions.isEmpty) {
        emit(state.copyWith(
          status: QuestionStatus.error,
          error: 'No questions available',
        ));
        return;
      }

      if (event.mode == QuestionMode.quiz) {
        _startTimer(emit);
      }

      emit(state.copyWith(
        status: QuestionStatus.loaded,
        questions: questions,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: QuestionStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _onQuestionPageChanged(
    QuestionPageChanged event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  Future<void> _onQuestionAnswered(
    QuestionAnswered event,
    Emitter<QuestionState> emit,
  ) async {
    final answer = models.Answer(
      questionId: event.questionId,
      selectedOption: event.selectedOption,
      answeredAt: DateTime.now(),
    );

    try {
      await repository.saveAnswer(answer);

      final answers = Map<String, models.Answer>.from(state.answers)
        ..[event.questionId] = answer;

      emit(state.copyWith(answers: answers));

      if (state.mode == QuestionMode.practice) {
        // Move to next question after a delay in practice mode
        await Future.delayed(const Duration(seconds: 2));
        if (state.currentPage < state.questions.length - 1) {
          state.pageController?.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: QuestionStatus.error,
        error: 'Failed to save answer: ${e.toString()}',
      ));
    }
  }

  Future<void> _onQuizSubmitted(
    QuizSubmitted event,
    Emitter<QuestionState> emit,
  ) async {
    _timer?.cancel();
    emit(state.copyWith(
      status: QuestionStatus.submitted,
      timeRemaining: 0,
    ));
  }

  void _onAnswerRevealed(
    AnswerRevealed event,
    Emitter<QuestionState> emit,
  ) {
    // In practice mode, we might want to track which answers were revealed
    // For now, we'll just keep it simple
  }

  Future<void> _onLoadMoreRequested(
    LoadMoreRequested event,
    Emitter<QuestionState> emit,
  ) async {
    try {
      final nextPage = (state.questions.length ~/ questionsPerPage);
      final moreQuestions = await repository.getQuestions(
        chapter: state.questions.first.chapter,
        year: state.questions.first.year,
        page: nextPage,
        pageSize: questionsPerPage,
      );

      if (moreQuestions.isNotEmpty) {
        emit(state.copyWith(
          questions: [...state.questions, ...moreQuestions],
        ));
      }
    } catch (e) {
      // Handle error silently or show a notification
    }
  }

  void _startTimer(Emitter<QuestionState> emit) {
    const quizDuration = 30; // 30 minutes
    emit(state.copyWith(timeRemaining: quizDuration));

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        final remaining = state.timeRemaining ?? 0;
        if (remaining <= 1) {
          add(const QuizSubmitted());
          timer.cancel();
        } else {
          emit(state.copyWith(timeRemaining: remaining - 1));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    state.pageController?.dispose();
    return super.close();
  }
} 