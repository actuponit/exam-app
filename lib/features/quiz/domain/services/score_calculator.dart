import '../models/question.dart';
import '../models/answer.dart' as models;

class ScoreResult {
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final String grade;
  final String message;

  const ScoreResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.grade,
    required this.message,
  });
}

class ScoreCalculator {
  static ScoreResult calculateScore(
    List<Question> questions,
    Map<String, String> answers,
  ) {
    final totalQuestions = questions.length;
    final correctAnswers = questions.where((q) {
      final answer = answers[q.id];
      return answer != null && answer == q.correctOption;
    }).length;

    final percentage = (correctAnswers / totalQuestions) * 100;

    String grade;
    String message;

    if (percentage >= 90) {
      grade = 'A';
      message = 'Excellent! You\'ve mastered this topic!';
    } else if (percentage >= 80) {
      grade = 'B';
      message = 'Great job! Keep up the good work!';
    } else if (percentage >= 70) {
      grade = 'C';
      message = 'Good effort! A bit more practice will help.';
    } else if (percentage >= 60) {
      grade = 'D';
      message = 'You\'re getting there. Keep practicing!';
    } else {
      grade = 'F';
      message = 'Don\'t give up! Review and try again.';
    }

    return ScoreResult(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      percentage: percentage,
      grade: grade,
      message: message,
    );
  }
}