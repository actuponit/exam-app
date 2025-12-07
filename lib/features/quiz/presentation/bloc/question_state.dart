import 'package:equatable/equatable.dart';
import '../../domain/models/question.dart';
import '../../domain/models/download_progress.dart';
import '../../domain/services/score_calculator.dart';

enum QuestionMode { practice, quiz }

enum QuestionStatus { initial, loading, success, error, submitted }

class QuestionState extends Equatable {
  final List<Question> questions;
  final Map<String, String> answers; // questionId -> selectedOption
  final QuestionStatus status;
  final String? error;
  final String subjectId;
  final String? chapterId;
  final int year;
  final bool isQuizMode;
  final bool isSubmitted;
  final int currentPage;
  final ScoreResult? scoreResult;
  final int? timeRemaining; // in seconds
  final DateTime? startTime;
  final DownloadProgress? syncProgress;

  const QuestionState({
    this.questions = const [],
    this.answers = const {},
    this.status = QuestionStatus.initial,
    this.error,
    this.subjectId = '',
    this.chapterId,
    this.year = 0,
    this.isQuizMode = false,
    this.isSubmitted = false,
    this.currentPage = 0,
    this.scoreResult,
    this.timeRemaining,
    this.startTime,
    this.syncProgress,
  });

  int get totalPages => (questions.length / 6).ceil();

  bool get canSubmit =>
      isQuizMode &&
      !isSubmitted &&
      questions.every((q) => answers.containsKey(q.id));

  bool get hasTimeExpired =>
      isQuizMode && timeRemaining != null && timeRemaining! <= 0;

  String get formattedTimeRemaining {
    if (timeRemaining == null) return '';
    final minutes = (timeRemaining! / 60).floor();
    final seconds = timeRemaining! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  QuestionState copyWith({
    List<Question>? questions,
    Map<String, String>? answers,
    QuestionStatus? status,
    String? error,
    String? subjectId,
    String? chapterId,
    int? year,
    bool? isQuizMode,
    bool? isSubmitted,
    int? currentPage,
    ScoreResult? scoreResult,
    int? timeRemaining,
    DateTime? startTime,
    DownloadProgress? syncProgress,
  }) {
    return QuestionState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      error: error ?? this.error,
      subjectId: subjectId ?? this.subjectId,
      chapterId: chapterId ?? this.chapterId,
      year: year ?? this.year,
      isQuizMode: isQuizMode ?? this.isQuizMode,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      currentPage: currentPage ?? this.currentPage,
      scoreResult: scoreResult ?? this.scoreResult,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      startTime: startTime ?? this.startTime,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        answers,
        status,
        error,
        subjectId,
        chapterId,
        year,
        isQuizMode,
        isSubmitted,
        currentPage,
        scoreResult,
        timeRemaining,
        startTime,
        syncProgress,
      ];
}
