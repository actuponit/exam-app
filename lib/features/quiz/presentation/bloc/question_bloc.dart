import 'dart:async';
import 'package:exam_app/features/quiz/domain/models/answer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/services/score_calculator.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuestionRepository _repository;
  static const int questionsPerPage = 3;
  static const int quizDurationMinutes = 30;
  Timer? _timer;

  QuestionBloc({
    required QuestionRepository repository,
  })  : _repository = repository,
        super(const QuestionState()) {
    on<QuestionStarted>(_onQuestionStarted);
    on<QuestionPageChanged>(_onQuestionPageChanged);
    on<QuestionAnswered>(_onQuestionAnswered);
    on<QuizSubmitted>(_onQuizSubmitted);
    on<QuizTicked>(_onQuizTicked);
    on<FetchQuestions>(_onFetchQuestions);
  }

  Future<void> _onFetchQuestions(
    FetchQuestions event,
    Emitter<QuestionState> emit,
  ) async {
    emit(state.copyWith(status: QuestionStatus.loading));
    try {
      await _repository.getAllQuestions(ensureBackend: event.ensureBackend);
      emit(state.copyWith(status: QuestionStatus.success));
    } catch (e) {
      emit(state.copyWith(status: QuestionStatus.error, error: e.toString()));
    }
  }

  Future<void> _onQuestionStarted(
    QuestionStarted event,
    Emitter<QuestionState> emit,
  ) async {
    emit(state.copyWith(
      status: QuestionStatus.loading,
      chapterId: event.chapterId,
      subjectId: event.subjectId,
      year: event.year,
      isQuizMode: event.isQuizMode,
      answers: const {},
      currentPage: 0,
      isSubmitted: false,
      scoreResult: null,
      startTime: event.isQuizMode ? DateTime.now() : null,
    ));

    try {
      final questions = await _repository.getQuestions(
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        year: event.year,
        region: event.region,
      );

      final duration =
          questions.length * (questions.first.subject.duration ?? 2);

      emit(state.copyWith(
        status: QuestionStatus.success,
        questions: questions,
        timeRemaining: event.isQuizMode ? duration * 60 : null,
      ));

      if (event.isQuizMode) {
        _startTimer();
      }
    } catch (e) {
      emit(state.copyWith(
        status: QuestionStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(QuizTicked()),
    );
  }

  void _onQuizTicked(event, emit) {
    final remaining = state.timeRemaining;
    if (remaining == null || remaining <= 1) {
      _timer?.cancel();
      add(const QuizSubmitted());
    } else {
      emit(state.copyWith(timeRemaining: remaining - 1));
    }
  }

  void _onQuestionPageChanged(
    QuestionPageChanged event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  void _onQuestionAnswered(
    QuestionAnswered event,
    Emitter<QuestionState> emit,
  ) {
    final newAnswers = Map<String, String>.from(state.answers)
      ..[event.question.id] = event.selectedOption;

    _repository.saveAnswer(Answer(
      question: event.question,
      selectedOption: event.selectedOption,
      answeredAt: DateTime.now(),
    ));

    emit(state.copyWith(answers: newAnswers));

    // In practice mode, calculate score after each answer
    if (!state.isQuizMode) {
      final scoreResult = ScoreCalculator.calculateScore(
        state.questions,
        newAnswers,
      );
      emit(state.copyWith(scoreResult: scoreResult));
    }
  }

  void _onQuizSubmitted(
    QuizSubmitted event,
    Emitter<QuestionState> emit,
  ) {
    if (!state.canSubmit && !state.hasTimeExpired) return;

    _timer?.cancel();
    emit(state.copyWith(
      status: QuestionStatus.success,
      isSubmitted: false,
      scoreResult: null,
    ));
    final scoreResult = ScoreCalculator.calculateScore(
      state.questions,
      state.answers,
    );

    emit(state.copyWith(
      status: QuestionStatus.submitted,
      isSubmitted: true,
      scoreResult: scoreResult,
      timeRemaining: 0,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
